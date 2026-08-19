import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:get/get.dart';
import 'package:flutter_unity_widget_example/screens/jsonto3d.dart';
import 'package:flutter_unity_widget_example/ui/widgets/project_creation_bottom_sheet.dart';
import '../controller/profile_controller.dart';
import '../controller/gallery_controller.dart';
import '../services/camera_snapshot_service.dart';
import '../view/main_menu/pages/profile_pages/pricing_page.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'services.dart';

// ─── Data Models ────────────────────────────────────────────────────────────

class BubbleNode {
  final String id;
  String label;
  Offset position;
  Color color;
  int sizeIndex; // 1: Small, 2: Medium, 3: Large

  BubbleNode({
    required this.id,
    required this.label,
    required this.position,
    required this.color,
    this.sizeIndex = 2,
  });
}

class Edge {
  final String fromId;
  final String toId;

  Edge({required this.fromId, required this.toId});

  String get key => '${fromId}_$toId';

  @override
  bool operator ==(Object other) =>
      other is Edge &&
      ((other.fromId == fromId && other.toId == toId) ||
          (other.fromId == toId && other.toId == fromId));

  @override
  int get hashCode => fromId.hashCode ^ toId.hashCode;
}

// ─── House-GAN++ JSON Mapper ────────────────────────────────────────────────

class HouseGANMapper {
  static const Map<String, int> roomTypeCodes = {
    'Living room': 1,
    'Kitchen': 2,
    'Bedroom': 3,
    'Bathroom': 4,
    'Balcony': 5,
    'Entrance': 6,
    'Dining room': 7,
    'Study room': 8,
    'Storage': 10,
    'Outside': 0,
    'Front door': 15,
  };

  static int getRoomCode(String label) {
    return roomTypeCodes[label] ?? 16; // 16 = Unknown
  }

  static String getRoomLabel(int code) {
    return roomTypeCodes.entries
        .firstWhere(
          (e) => e.value == code,
          orElse: () => const MapEntry('Unknown', 16),
        )
        .key;
  }
}

class BubbleDiagramToJson {
  static Map<String, dynamic> convert({
    required List<BubbleNode> nodes,
    required List<Edge> edges,
    double canvasWidth = 256.0,
    double canvasHeight = 256.0,
  }) {
    if (nodes.isEmpty) {
      return {'room_type': [], 'boxes': [], 'edges': [], 'ed_rm': []};
    }

    final roomTypes = nodes.map((n) => HouseGANMapper.getRoomCode(n.label)).toList();

    final roomSize = 60.0;
    final rooms = <Map<String, dynamic>>[];

    for (final node in nodes) {
      final centerX = node.position.dx;
      final centerY = node.position.dy;
      final halfSize = roomSize / 2;

      rooms.add({
        'index': nodes.indexOf(node),
        'bounds': <double>[
          (centerX - halfSize).clamp(0, canvasWidth).toDouble(),
          (centerY - halfSize).clamp(0, canvasHeight).toDouble(),
          (centerX + halfSize).clamp(0, canvasWidth).toDouble(),
          (centerY + halfSize).clamp(0, canvasHeight).toDouble(),
        ],
        'center': <double>[centerX, centerY],
        'type': HouseGANMapper.getRoomCode(node.label),
      });
    }

    final boxes = rooms.map((room) {
      final bounds = room['bounds'] as List<double>;
      return bounds.map((coord) => (coord / canvasWidth * 256).roundToDouble()).toList().cast<double>();
    }).toList();

    final edgeList = <List<num>>[];
    final edRm = <List<int>>[];

    for (final edge in edges) {
      final fromIndex = nodes.indexWhere((n) => n.id == edge.fromId);
      final toIndex = nodes.indexWhere((n) => n.id == edge.toId);

      if (fromIndex == -1 || toIndex == -1) continue;

      final fromNode = nodes[fromIndex];
      final toNode = nodes[toIndex];

      final midX = (fromNode.position.dx + toNode.position.dx) / 2;
      final midY = (fromNode.position.dy + toNode.position.dy) / 2;

      final dx = toNode.position.dx - fromNode.position.dx;
      final dy = toNode.position.dy - fromNode.position.dy;
      final length = sqrt(dx * dx + dy * dy);

      if (length == 0) continue;

      final wallLength = 50.0;
      final perpX = -dy / length * wallLength / 2;
      final perpY = dx / length * wallLength / 2;

      final fromRoomCode = HouseGANMapper.getRoomCode(fromNode.label);
      final toRoomCode = HouseGANMapper.getRoomCode(toNode.label);

      edgeList.add([
        ((midX - perpX).clamp(0, canvasWidth) / canvasWidth * 256).roundToDouble(),
        ((midY - perpY).clamp(0, canvasHeight) / canvasHeight * 256).roundToDouble(),
        ((midX + perpX).clamp(0, canvasWidth) / canvasWidth * 256).roundToDouble(),
        ((midY + perpY).clamp(0, canvasHeight) / canvasHeight * 256).roundToDouble(),
        fromRoomCode,
        toRoomCode,
      ]);

      edRm.add([fromIndex, toIndex]);
    }

    return {
      'room_type': roomTypes,
      'boxes': boxes,
      'edges': edgeList,
      'ed_rm': edRm,
    };
  }
}

// ─── Node Types (room presets) ──────────────────────────────────────────────

class NodeType {
  final String label;
  final Color color;
  final IconData icon;

  const NodeType({
    required this.label,
    required this.color,
    required this.icon,
  });
}

const List<NodeType> kNodeTypes = [
  NodeType(label: 'Lounge Area', color: Color(0xFFF87171), icon: Icons.weekend_rounded),
  NodeType(label: 'Master Bedroom (with bathroom)', color: Color(0xFFFBBF24), icon: Icons.king_bed_rounded),
  NodeType(label: 'Regular Bedroom (with bathroom)', color: Color(0xFFFDE047), icon: Icons.bed_rounded),
  NodeType(label: 'Guest Room (with bathroom)', color: Color(0xFFFACC15), icon: Icons.people_rounded),
  NodeType(label: 'Kitchen', color: Color(0xFFFB923C), icon: Icons.soup_kitchen_rounded),
  NodeType(label: 'Dirty Kitchen', color: Color(0xFFD97706), icon: Icons.kitchen_rounded),
  NodeType(label: 'Bathroom', color: Color(0xFF60A5FA), icon: Icons.hot_tub_rounded),
  NodeType(label: 'Drawing Room', color: Color(0xFF34D399), icon: Icons.restaurant_rounded),
  NodeType(label: 'Study', color: Color(0xFF818CF8), icon: Icons.menu_book_rounded),
  NodeType(label: 'Balcony', color: Color(0xFF2DD4BF), icon: Icons.balcony_rounded),
  NodeType(label: 'Garage', color: Color(0xFFA78BFA), icon: Icons.door_front_door_rounded),
  NodeType(label: 'Store', color: Color(0xFF94A3B8), icon: Icons.inventory_2_rounded),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class BubbleDiagramScreen2 extends StatefulWidget {
  final String? projectId;
  const BubbleDiagramScreen2({super.key, this.projectId});

  @override
  State<BubbleDiagramScreen2> createState() => _BubbleDiagramScreen2State();
}

class _BubbleDiagramScreen2State extends State<BubbleDiagramScreen2> {
  final List<BubbleNode> _nodes = [];
  final List<Edge> _edges = [];
  int _nodeCounter = 1;
  CspGenerationResult? _lastGenerationResult;
  String? _activeProjectId;

  String? _selectedNodeId;
  String? _connectingFromId;
  bool _isConnectMode = false;
  bool _isDeleteMode = false;
  bool _isFabMenuOpen = false;

  static const double _bubbleRadius = 42.0;

  @override
  void initState() {
    super.initState();
    _activeProjectId = widget.projectId;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _addNode(Offset position, NodeType type) {
    setState(() {
      _nodes.add(
        BubbleNode(
          id: 'node_$_nodeCounter',
          label: type.label,
          position: position,
          color: type.color,
          sizeIndex: 2,
        ),
      );
      _nodeCounter++;
      _selectedNodeId = null;
    });
  }

  void _deleteNode(String nodeId) {
    setState(() {
      _nodes.removeWhere((n) => n.id == nodeId);
      _edges.removeWhere((e) => e.fromId == nodeId || e.toId == nodeId);
      if (_selectedNodeId == nodeId) _selectedNodeId = null;
      if (_connectingFromId == nodeId) _connectingFromId = null;
    });
  }

  void _deleteEdge(Edge edge) {
    setState(() => _edges.removeWhere((e) => e == edge));
  }

  void _handleNodeTap(String nodeId) {
    if (_isDeleteMode) {
      _showDeleteNodeDialog(nodeId);
      return;
    }
    if (_isConnectMode) {
      if (_connectingFromId == null) {
        setState(() => _connectingFromId = nodeId);
      } else if (_connectingFromId != nodeId) {
        final newEdge = Edge(fromId: _connectingFromId!, toId: nodeId);
        if (!_edges.any((e) => e == newEdge)) {
          setState(() {
            _edges.add(newEdge);
            _connectingFromId = null;
          });
        } else {
          setState(() => _connectingFromId = null);
        }
      } else {
        setState(() => _connectingFromId = null);
      }
      return;
    }
    setState(() => _selectedNodeId = _selectedNodeId == nodeId ? null : nodeId);
  }

  void _handleCanvasTap(TapUpDetails details) {
    if (_isConnectMode || _isDeleteMode) return;
    setState(() => _selectedNodeId = null);
    for (final edge in _edges) {
      final from = _nodeById(edge.fromId)?.position;
      final to = _nodeById(edge.toId)?.position;
      if (from == null || to == null) continue;
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      if ((mid - details.localPosition).distance < 20) {
        _showDeleteEdgeDialog(edge);
        return;
      }
    }
  }

  BubbleNode? _nodeById(String id) {
    try {
      return _nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  void _exportJson(BuildContext context) async {
    if (_nodes.isEmpty || _edges.isEmpty) {
      AppSnackbars.warning(
        title: 'Empty Diagram', 
        message: _nodes.isEmpty ? 'Add at least one room first' : 'Add at least one connection',
      );
      return;
    }

    final size = MediaQuery.of(context).size;
    final jsonData = BubbleDiagramToJson.convert(
      nodes: _nodes,
      edges: _edges,
      canvasWidth: size.width,
      canvasHeight: size.height,
    );

    final prettyJson = jsonEncode(jsonData);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Colors.indigo),
            const SizedBox(width: 12),
            const Text('Layout JSON Data'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueGrey.shade200),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              prettyJson,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5, color: Color(0xFF334155)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: prettyJson));
              if (!context.mounted) return;
              Navigator.pop(context);
              AppSnackbars.success(title: 'Copied', message: 'JSON copied to clipboard!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showDeleteNodeDialog(String nodeId) {
    final node = _nodeById(nodeId);
    if (node == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Room?'),
        content: Text('This will remove "${node.label}" and all its connections.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNode(nodeId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteEdgeDialog(Edge edge) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Connection?'),
        content: const Text('Are you sure you want to remove this connection?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEdge(edge);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _renameNode(String nodeId) {
    final node = _nodeById(nodeId);
    if (node == null) return;
    final controller = TextEditingController(text: node.label);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename Room'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Room Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (v) {
            if (v.isNotEmpty) setState(() => node.label = v);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) setState(() => node.label = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateFloorplan(BuildContext context) async {
    final profileController = Get.find<ProfileController>();

    if (profileController.isGuest.value) {
      AppSnackbars.show(
        title: "Sign In Required",
        message: "Please sign in to access AI floorplan generation features.",
        backgroundColor: Colors.indigoAccent,
        colorText: Colors.white,
        icon: const Icon(Icons.lock_outline_rounded, color: Colors.white),
      );
      return;
    }

    if (!profileController.hasEnoughCredits(20)) {
      String message = "You need at least 20 credits to generate a floorplan.";
      if (profileController.creditsResetAt.value != null) {
        final resetTime = profileController.creditsResetAt.value!;
        final now = DateTime.now();
        final difference = resetTime.difference(now);
        if (difference.isNegative) {
          await profileController.fetchCredits();
          if (profileController.hasEnoughCredits(20)) {
            _generateFloorplan(context);
            return;
          }
        } else {
          final hours = difference.inHours;
          final minutes = difference.inMinutes % 60;
          message += " Credits will reset in ${hours}h ${minutes}m.";
        }
      }
      AppSnackbars.show(
        title: "Insufficient Credits",
        message: message,
        backgroundColor: Colors.indigoAccent,
        colorText: Colors.white,
        icon: const Icon(Icons.bolt, color: Colors.white),
      );
      return;
    }

    if (_nodes.isEmpty) {
      AppSnackbars.warning(
        title: 'Empty Diagram', 
        message: 'Add at least one room first',
      );
      return;
    }

    // Ask for Total Area
    final areaController = TextEditingController(text: '2500');
    final int? totalArea = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Total Floor Area'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Specify the total area of the floor plan. Rooms will be scaled to fit this space.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: areaController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Total Area (sq units)',
                  hintText: 'e.g. 2500',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, int.tryParse(areaController.text)),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (totalArea == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating Floorplan...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // CSP Mode
      final rooms = _nodes.map((n) => {
        'name': n.label, // Labels now match CSP precisely
        'color': '#${n.color.value.toRadixString(16).substring(2)}',
        'sizeIndex': n.sizeIndex,
      }).toList();
      
      final result = await DrawingService.generateFromCsp(rooms, totalArea);
      _lastGenerationResult = result;

      if (!context.mounted) return;
      
      // Update credits from backend to stay in sync
      await profileController.fetchCredits();

      Navigator.pop(context); // Close loading dialog

      // Show Result
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Generated Floorplan'),
          content: Image.memory(_lastGenerationResult!.imageBytes),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton.icon(
              onPressed: () {
                if (_lastGenerationResult == null) return;
                
                final jsonString = DrawingService.convertCspToUnityJson(_lastGenerationResult!);

                void navigateToUnity() {
                  // Get.to(() => UnityHomeScreen(jsonString: jsonString));
                }

                if (_activeProjectId == null) {
                  showProjectCreationBottomSheet(
                    context: context,
                    onProjectCreated: (id) {
                      setState(() => _activeProjectId = id);
                      navigateToUnity();
                    },
                  );
                } else {
                  navigateToUnity();
                }
              },
              icon: const Icon(Icons.view_in_ar_rounded),
              label: const Text('View in 3D'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 5,),
            ElevatedButton.icon(
              onPressed: () async {
                final fileName = 'floorplan_${DateTime.now().millisecondsSinceEpoch}';
                String? galleryAssetId;
                bool hasPermission = await CameraSnapshotService.instance.requestGalleryPermission();
                if (hasPermission) {
                  final asset = await PhotoManager.editor.saveImage(
                    _lastGenerationResult!.imageBytes, 
                    filename: '$fileName.png',
                    relativePath: 'Pictures/AutoPlan 3d',
                  );
                  galleryAssetId = asset?.id;
                } else {
                  await PhotoManager.openSetting();
                  throw Exception('Permission denied to save image');
                }
                
                // Save to app gallery too
                await CameraSnapshotService.instance.saveImageToAppGallery(_lastGenerationResult!.imageBytes, fileName, galleryAssetId: galleryAssetId);

                // Refresh gallery if active
                if (Get.isRegistered<GalleryController>()) {
                  Get.find<GalleryController>().loadSnapshots();
                }

                if (!context.mounted) return;
                AppSnackbars.success(title: 'Success', message: 'Floorplan saved to gallery!');
              },
              icon: const Icon(Icons.download),
              label: const Text('Save to Gallery'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        final errorMsg = e.toString().replaceFirst('Exception: ', '');

        if (errorMsg.contains('too small')) {
          AppSnackbars.show(
            title: 'Area Too Small',
            message: errorMsg,
            backgroundColor: Colors.amber.shade800,
            colorText: Colors.white,
            icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white),
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          AppSnackbars.error(title: 'Error', message: errorMsg);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.white : const Color(0xFF0F172A), size: 20),
        ),
        title: Text(
          'Bubble Diagram',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isDarkMode ? Colors.blueGrey.shade800 : Colors.blueGrey.shade200, width: 1)),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _generateFloorplan(context),
            icon: const Icon(Icons.auto_awesome_mosaic_rounded, color: Colors.indigoAccent, size: 20),
            label: const Text('Generate', style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold)),
          ),
          // IconButton(
          //   icon: const Icon(Icons.ios_share_rounded, color: Colors.indigoAccent),
          //   tooltip: 'Export JSON',
          //   onPressed: () => _exportJson(context),
          // ),
          // const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StatusBar(
              isConnectMode: _isConnectMode,
              isDeleteMode: _isDeleteMode,
              connectingFromLabel: _connectingFromId != null ? (_nodeById(_connectingFromId!)?.label ?? '') : null,
            ),
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: _handleCanvasTap,
                    child: Stack(
                      children: [
                        CustomPaint(painter: _GridPainter(isDarkMode: isDarkMode), child: const SizedBox.expand()),
                        CustomPaint(
                          painter: _EdgePainter(
                            nodes: _nodes,
                            edges: _edges,
                            selectedNodeId: _selectedNodeId,
                            connectingFromId: _connectingFromId,
                          ),
                          child: const SizedBox.expand(),
                        ),
                        ..._nodes.map(
                          (node) => _DraggableNode(
                            node: node,
                            isSelected: _selectedNodeId == node.id,
                            isConnecting: _connectingFromId == node.id,
                            isDeleteMode: _isDeleteMode,
                            isConnectMode: _isConnectMode,
                            radius: _bubbleRadius,
                            onTap: () => _handleNodeTap(node.id),
                            onDragUpdate: (delta) {
                              if (_isConnectMode || _isDeleteMode) return;
                              setState(() => node.position += delta);
                            },
                            onLongPress: () => _renameNode(node.id),
                          ),
                        ),
                        if (!_isConnectMode && !_isDeleteMode)
                          ..._edges.map((edge) {
                            final from = _nodeById(edge.fromId)?.position;
                            final to = _nodeById(edge.toId)?.position;
                            if (from == null || to == null) return const SizedBox();
                            final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
                            return Positioned(
                              left: mid.dx - 12,
                              top: mid.dy - 12,
                              child: GestureDetector(
                                onTap: () => _showDeleteEdgeDialog(edge),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
                                    border: Border.all(color: isDarkMode ? Colors.blueGrey.shade700 : Colors.blueGrey.shade200),
                                  ),
                                  child: Icon(Icons.close_rounded, size: 14, color: isDarkMode ? Colors.white70 : Colors.blueGrey),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  // Floating Toolbars
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08), blurRadius: 15, offset: const Offset(0, 5))],
                          border: Border.all(color: isDarkMode ? Colors.blueGrey.shade700 : Colors.blueGrey.shade100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ModeToggle(
                              icon: Icons.link_rounded,
                              label: 'Connect',
                              active: _isConnectMode,
                              activeColor: Colors.indigoAccent,
                              onTap: () => setState(() {
                                _isConnectMode = !_isConnectMode;
                                _isDeleteMode = false;
                                _connectingFromId = null;
                                _selectedNodeId = null;
                              }),
                            ),
                            const SizedBox(width: 4),
                            _ModeToggle(
                              icon: Icons.delete_outline_rounded,
                              label: 'Delete',
                              active: _isDeleteMode,
                              activeColor: Colors.redAccent,
                              onTap: () => setState(() {
                                _isDeleteMode = !_isDeleteMode;
                                _isConnectMode = false;
                                _connectingFromId = null;
                                _selectedNodeId = null;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedNodeId != null && !_isConnectMode && !_isDeleteMode)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 120, // Leave room for FAB
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 5))],
                            border: Border.all(color: isDarkMode ? Colors.blueGrey.shade700 : Colors.blueGrey.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SizeOption(
                                label: 'S',
                                active: _nodeById(_selectedNodeId!)?.sizeIndex == 1,
                                onTap: () => setState(() => _nodeById(_selectedNodeId!)?.sizeIndex = 1),
                              ),
                              const SizedBox(width: 4),
                              _SizeOption(
                                label: 'M',
                                active: _nodeById(_selectedNodeId!)?.sizeIndex == 2,
                                onTap: () => setState(() => _nodeById(_selectedNodeId!)?.sizeIndex = 2),
                              ),
                              const SizedBox(width: 4),
                              _SizeOption(
                                label: 'L',
                                active: _nodeById(_selectedNodeId!)?.sizeIndex == 3,
                                onTap: () => setState(() => _nodeById(_selectedNodeId!)?.sizeIndex = 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _AddNodeFab(
        isOpen: _isFabMenuOpen,
        onToggle: () => setState(() => _isFabMenuOpen = !_isFabMenuOpen),
        onSelectType: (type) {
          final size = MediaQuery.of(context).size;
          final rand = Random();
          _addNode(
            Offset(80 + rand.nextDouble() * (size.width - 160), 120 + rand.nextDouble() * (size.height - 320)),
            type,
          );
          setState(() => _isFabMenuOpen = false);
        },
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeToggle({required this.icon, required this.label, required this.active, required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: active ? Colors.white : (isDarkMode ? Colors.white70 : Colors.blueGrey.shade600)),
            if (active) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SizeOption({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.indigoAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : (isDarkMode ? Colors.white70 : Colors.blueGrey.shade600),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Add-Node Floating Action Button ────────────────────────────────────────

class _AddNodeFab extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final void Function(NodeType type) onSelectType;

  const _AddNodeFab({required this.isOpen, required this.onToggle, required this.onSelectType});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: anim, alignment: Alignment.bottomRight, child: child),
          ),
          child: isOpen
              ? Container(
                  key: const ValueKey('menu'),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 240,
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Material(
                      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              color: isDarkMode ? Colors.indigo.withValues(alpha: 0.2) : Colors.indigo.shade50,
                              child: Text('Add Room Node', style: TextStyle(fontWeight: FontWeight.w800, color: isDarkMode ? Colors.indigoAccent : Colors.indigo, fontSize: 14)),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8),
                              itemCount: kNodeTypes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 4),
                              itemBuilder: (context, i) => _NodeTypeMenuItem(type: kNodeTypes[i], onTap: () => onSelectType(kNodeTypes[i])),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        FloatingActionButton.extended(
          onPressed: onToggle,
          backgroundColor: isOpen ? (isDarkMode ? Colors.blueGrey.shade700 : Colors.blueGrey.shade800) : Colors.indigoAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isOpen ? const Text('Close') : const Text('Add Room'),
          ),
          icon: AnimatedRotation(
            turns: isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class _NodeTypeMenuItem extends StatelessWidget {
  final NodeType type;
  final VoidCallback onTap;

  const _NodeTypeMenuItem({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: type.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(type.icon, size: 18, color: type.color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(type.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : const Color(0xFF1E293B)))),
            Icon(Icons.add_circle_outline_rounded, size: 16, color: isDarkMode ? Colors.white38 : Colors.blueGrey),
          ],
        ),
      ),
    );
  }
}

// ─── Status Bar ──────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final bool isConnectMode;
  final bool isDeleteMode;
  final String? connectingFromLabel;

  const _StatusBar({required this.isConnectMode, required this.isDeleteMode, required this.connectingFromLabel});

  @override
  Widget build(BuildContext context) {
    if (!isConnectMode && !isDeleteMode) return const SizedBox.shrink();

    String text;
    Color color;
    if (isDeleteMode) {
      text = 'Delete Mode: Tap a node to remove it';
      color = Colors.redAccent;
    } else if (connectingFromLabel == null) {
      text = 'Connect Mode: Select the first room';
      color = Colors.indigo;
    } else {
      text = 'Connecting from: "$connectingFromLabel"';
      color = Colors.green;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: color.withValues(alpha: 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text, 
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Draggable Node ───────────────────────────────────────────────────────────

class _DraggableNode extends StatefulWidget {
  final BubbleNode node;
  final bool isSelected;
  final bool isConnecting;
  final bool isDeleteMode;
  final bool isConnectMode;
  final double radius;
  final VoidCallback onTap;
  final void Function(Offset delta) onDragUpdate;
  final VoidCallback onLongPress;

  const _DraggableNode({
    required this.node,
    required this.isSelected,
    required this.isConnecting,
    required this.isDeleteMode,
    required this.isConnectMode,
    required this.radius,
    required this.onTap,
    required this.onDragUpdate,
    required this.onLongPress,
  });

  @override
  State<_DraggableNode> createState() => _DraggableNodeState();
}

class _DraggableNodeState extends State<_DraggableNode> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;
    final pos = widget.node.position;
    final color = widget.node.color;

    return Positioned(
      left: pos.dx - r,
      top: pos.dy - r,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onPanStart: (_) => setState(() => _dragging = true),
        onPanEnd: (_) => setState(() => _dragging = false),
        onPanUpdate: (d) => widget.onDragUpdate(d.delta),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) {
            double scale = _dragging ? 1.05 : 1.0;
            if (widget.isConnecting) scale = 1.0 + 0.08 * _pulse.value;
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: r * 2,
            height: r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: _dragging ? 16 : 10,
                  offset: Offset(0, _dragging ? 8 : 4),
                ),
                if (widget.isSelected) BoxShadow(color: Colors.indigo.withValues(alpha: 0.4), spreadRadius: 4, blurRadius: 10),
              ],
              border: Border.all(
                color: widget.isSelected ? Colors.indigo : (widget.isDeleteMode ? Colors.redAccent : Colors.white),
                width: widget.isSelected || widget.isDeleteMode ? 3 : 2,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.node.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w800, height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.node.sizeIndex == 1 ? 'Small' : widget.node.sizeIndex == 2 ? 'Medium' : 'Large',
                      style: TextStyle(color: Colors.black54, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Edge Painter ────────────────────────────────────────────────────────────

class _EdgePainter extends CustomPainter {
  final List<BubbleNode> nodes;
  final List<Edge> edges;
  final String? selectedNodeId;
  final String? connectingFromId;

  _EdgePainter({required this.nodes, required this.edges, required this.selectedNodeId, required this.connectingFromId});

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final from = nodes.where((n) => n.id == edge.fromId).firstOrNull;
      final to = nodes.where((n) => n.id == edge.toId).firstOrNull;
      if (from == null || to == null) continue;

      final isHigh = selectedNodeId == edge.fromId || selectedNodeId == edge.toId || connectingFromId == edge.fromId || connectingFromId == edge.toId;
      final paint = Paint()
        ..color = isHigh ? Colors.indigo : Colors.blueGrey.shade300
        ..strokeWidth = isHigh ? 3 : 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final dir = (to.position - from.position);
      final dist = dir.distance;
      if (dist < 80) continue;
      final norm = dir / dist;
      final p1 = from.position + norm * 42;
      final p2 = to.position - norm * 42;

      canvas.drawLine(p1, p2, paint);

      // Arrow
      const arrowSize = 12.0;
      final perp = Offset(-norm.dy, norm.dx);
      final tip = p2;
      final b1 = tip - norm * arrowSize + perp * (arrowSize * 0.4);
      final b2 = tip - norm * arrowSize - perp * (arrowSize * 0.4);
      final arrowPath = Path()..moveTo(tip.dx, tip.dy)..lineTo(b1.dx, b1.dy)..lineTo(b2.dx, b2.dy)..close();
      canvas.drawPath(arrowPath, Paint()..color = paint.color..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) => true;
}

class _GridPainter extends CustomPainter {
  final bool isDarkMode;
  _GridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 40.0;
    final paint = Paint()..color = (isDarkMode ? Colors.white10 : Colors.blueGrey.shade200.withValues(alpha: 0.4))..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
