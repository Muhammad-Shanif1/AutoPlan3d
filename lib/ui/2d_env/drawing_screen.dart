import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_unity_widget_example/screens/jsonto3d.dart';

// Internal project imports - Fixed package name
import 'package:flutter_unity_widget_example/ui/2d_env/cv.dart';
import 'package:flutter_unity_widget_example/ui/widgets/project_creation_bottom_sheet.dart';
import '../controller/profile_controller.dart';
import '../controller/gallery_controller.dart';
import '../services/camera_snapshot_service.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'services.dart';
import 'widgets/drawing_controls.dart';
import 'widgets/drawing_canvas.dart';

/// Key for correct drawing bounds
final GlobalKey drawingKey = GlobalKey();

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({
    super.key,
    this.title = 'Draw Floor Plan Boundary',
    this.autoStartScan = false,
    this.initialImage,
    this.projectId,
  });

  final String title;
  final bool autoStartScan;
  final File? initialImage;
  final String? projectId;

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  String? _activeProjectId;

  @override
  void initState() {
    super.initState();
    _activeProjectId = widget.projectId;
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processImage(_selectedImage!);
      });
    } else if (widget.autoStartScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage();
      });
    }
  }

  List<List<Offset>> _drawnLines = [];
  final List<List<List<Offset>>> _history = [[]];
  List<Offset> _currentLine = [];
  Offset? _startPoint;
  bool? _lineType;

  // Track stretching state
  int? _draggedLineIndex;
  int? _draggedPointIndex;

  // Track potential stretch to decide between stretch and new line
  int? _potentialDraggedLineIndex;
  int? _potentialDraggedPointIndex;

  int? _selectedLineIndex;

  // Track moving state
  int? _movingLineIndex;
  Offset? _moveLastPosition;
  DateTime? _lastDoubleTapTime;

  double _currentScale = 1.0;
  static const double _minScale = 0.5;
  static const double _maxScale = 3.0;
  final TransformationController _transformationController = TransformationController();

  File? _selectedImage;

  static const double _hitThreshold = 30.0;
  static const double _snapThreshold = 20.0;

  double get _dynamicHitThreshold => _hitThreshold / _currentScale;
  double get _dynamicSnapThreshold => _snapThreshold / _currentScale;

  /// Duplicate the selected line
  void _duplicateSelectedLine() {
    if (_selectedLineIndex != null && _selectedLineIndex! < _drawnLines.length) {
      final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
      final size = box?.size;

      setState(() {
        final lineToCopy = _drawnLines[_selectedLineIndex!];
        // Offset the new line slightly so it's visible
        final duplicatedLine = lineToCopy.map((p) {
          double dx = p.dx + 20;
          double dy = p.dy + 20;
          if (size != null) {
            dx = dx.clamp(0.0, size.width);
            dy = dy.clamp(0.0, size.height);
          }
          return Offset(dx, dy);
        }).toList();
        _drawnLines.add(duplicatedLine);
        _selectedLineIndex = _drawnLines.length - 1; // Select the new line
        _saveToHistory();
      });
    }
  }

  /// Delete the selected line
  void _deleteSelectedLine() {
    if (_selectedLineIndex != null && _selectedLineIndex! < _drawnLines.length) {
      setState(() {
        _drawnLines.removeAt(_selectedLineIndex!);
        _selectedLineIndex = null;
        _saveToHistory();
      });
    }
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _selectedImage = File(image.path);
      await _processImage(_selectedImage!);
    }
  }

  Future<void> _processImage(File imageFile) async {
    if (!mounted) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CV2screen(selectedImage: imageFile),
      ),
    );

    if (result != null && result['contours'] != null) {
      // Properly cast the nested list structure
      final rawContours = result['contours'] as List<dynamic>;
      final contours = rawContours.map((contour) {
        final rawContour = contour as List<dynamic>;
        return rawContour.map((point) => point as Offset).toList();
      }).toList();

      final imgWidth = result['width'] as int;
      final imgHeight = result['height'] as int;

      // Get canvas dimensions
      final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final canvasWidth = box.size.width;
        final canvasHeight = box.size.height;

        // Scale contours to fit canvas
        final scaledContours = DrawingService.scaleContours(
          contours,
          imgWidth.toDouble(),
          imgHeight.toDouble(),
          canvasWidth,
          canvasHeight,
        );

        setState(() {
          _drawnLines.addAll(scaledContours);
          _saveToHistory();
        });
      }
    }
  }

  Future<void> saveDrawing() async {
    try {
      final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
      final size = box?.size ?? Size.zero;

      final (bytes, assetId) = await DrawingService.saveDrawing(
        drawnLines: _drawnLines,
        size: size,
      );

      // Save to app gallery too
      await CameraSnapshotService.instance.saveImageToAppGallery(
        bytes,
        'drawing_${DateTime.now().millisecondsSinceEpoch}',
        galleryAssetId: assetId,
      );

      // Refresh gallery if active
      if (Get.isRegistered<GalleryController>()) {
        Get.find<GalleryController>().loadSnapshots();
      }

      if (mounted) {
        AppSnackbars.success(title: 'Saved', message: 'Drawing saved to gallery!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.error(title: 'Error', message: '$e');
      }
    }
  }

  /// Save current state to history
  void _saveToHistory() {
    _history.add(_drawnLines.map((line) => List<Offset>.from(line)).toList());
    // Keep history size manageable (last 50 states)
    if (_history.length > 50) {
      _history.removeAt(0);
    }
  }

  /// Undo last action
  void _undo() {
    if (_history.length > 1) {
      setState(() {
        // Remove current state from history
        _history.removeLast();
        // Restore previous state (deep copy)
        _drawnLines = _history.last.map((line) => List<Offset>.from(line)).toList();
        // Reset drawing state
        _selectedLineIndex = null;
        _startPoint = null;
        _lineType = null;
        _currentLine = [];
      });
    }
  }

  /// Generate floorplan via FastAPI
  Future<void> _generateFloorplan() async {
    if (_drawnLines.isEmpty) {
      AppSnackbars.warning(title: 'Warning', message: 'Please draw a boundary first');
      return;
    }

    if (!DrawingService.isBoundaryClosed(_drawnLines)) {
      AppSnackbars.warning(
        title: 'Warning',
        message: 'Please close the boundary (connect all wall ends)',
      );
      return;
    }

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
          // Should have reset, maybe refresh
          await profileController.fetchCredits();
          if (profileController.hasEnoughCredits(20)) {
            _generateFloorplan(); // Retry
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

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await DrawingService.generateFloorplan(
        _drawnLines,
        drawingKey,
      );
      final imageBytes = result.imageBytes;

      if (!mounted) return;
      profileController.useCredits(20);
      Navigator.pop(context); // Close loading indicator

      // Show result in a dialog with a custom Room Color Legend Map
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Generated Floorplan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(imageBytes),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Room Color Map',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
                const Divider(height: 12, thickness: 1),
                const SizedBox(height: 6),
                const RoomLegend(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_activeProjectId == null) {
                  showProjectCreationBottomSheet(
                    context: context,
                    onProjectCreated: (id) {
                      setState(() => _activeProjectId = id);
                      final unityJson = DrawingService.convertFloorplanToUnityJson(result);
                      // Get.to(() => UnityHomeScreen(jsonString: unityJson));
                    },
                  );
                } else {
                  final unityJson = DrawingService.convertFloorplanToUnityJson(result);
                  // Get.to(() => UnityHomeScreen(jsonString: unityJson));
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
            ElevatedButton(
              onPressed: () async {
                // Save the generated image
                final fileName = 'floorplan_${DateTime.now().millisecondsSinceEpoch}';
                String? galleryAssetId;
                bool hasPermission = await CameraSnapshotService.instance.requestGalleryPermission();
                if (hasPermission) {
                  final asset = await PhotoManager.editor.saveImage(
                    imageBytes,
                    filename: '$fileName.png',
                    relativePath: 'Pictures/AutoPlan 3d',
                  );
                  galleryAssetId = asset.id;
                } else {
                  await PhotoManager.openSetting();
                  throw Exception('Permission denied to save image');
                }

                // Save to app gallery too
                await CameraSnapshotService.instance.saveImageToAppGallery(imageBytes, fileName, galleryAssetId: galleryAssetId);

                // Refresh gallery if active
                if (Get.isRegistered<GalleryController>()) {
                  Get.find<GalleryController>().loadSnapshots();
                }

                if (context.mounted) {
                  AppSnackbars.success(title: 'Success', message: 'Floorplan saved to gallery!');
                  Navigator.pop(context);
                }
              },
              child: const Text('Save to Gallery'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading indicator
      AppSnackbars.error(title: 'Error', message: 'Failed to generate floorplan: $e');
    }
  }

  /// Snap a point to the nearest endpoint of existing lines
  Offset _snapPoint(Offset point, {int? excludeIndex}) {
    Offset snapped = point;
    double minDistance = _dynamicSnapThreshold;

    for (int i = 0; i < _drawnLines.length; i++) {
      if (i == excludeIndex) continue;
      final line = _drawnLines[i];
      if (line.isEmpty) continue;
      // Check start and end of each line
      for (var endpoint in [line.first, line.last]) {
        final distance = (point - endpoint).distance;
        if (distance < minDistance) {
          minDistance = distance;
          snapped = endpoint;
        }
      }
    }

    // Also snap to the start of the current line to help closing loops
    if (_startPoint != null) {
      final distance = (point - _startPoint!).distance;
      if (distance < minDistance) {
        snapped = _startPoint!;
      }
    }

    return snapped;
  }

  void _zoomIn() => _updateZoom(0.1);

  void _zoomOut() => _updateZoom(-0.1);

  void _updateZoom(double delta) {
    final double oldScale = _transformationController.value.getMaxScaleOnAxis();
    final double newScale = (oldScale + delta).clamp(_minScale, _maxScale);
    if (oldScale == newScale) return;

    final double ratio = newScale / oldScale;
    final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset center = Offset(box.size.width / 2, box.size.height / 2);

    setState(() {
      _currentScale = newScale;
      _transformationController.value = _transformationController.value.clone()
        ..translate(center.dx, center.dy)
        ..scale(ratio, ratio)
        ..translate(-center.dx, -center.dy);
    });
  }

  void _handlePanStart(DragStartDetails details) {
    final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset localPosition = Offset(
      details.localPosition.dx.clamp(0.0, box.size.width),
      details.localPosition.dy.clamp(0.0, box.size.height),
    );
    final Size size = box.size;

    // Check if we are starting a move (Double Tap + Hold)
    if (_lastDoubleTapTime != null &&
        DateTime.now().difference(_lastDoubleTapTime!) <
            const Duration(milliseconds: 500)) {
      _movingLineIndex = _selectedLineIndex;
      if (_movingLineIndex != null) {
        _moveLastPosition = localPosition;
        _draggedLineIndex = null;
        _potentialDraggedLineIndex = null;
        return; // Enter move mode and skip other logic
      }
    }

    // Reset move/stretch states
    _movingLineIndex = null;
    _draggedLineIndex = null;
    _draggedPointIndex = null;
    _potentialDraggedLineIndex = null;
    _potentialDraggedPointIndex = null;

    // 1. Check for node hits first
    for (int i = 0; i < _drawnLines.length; i++) {
      for (int j = 0; j < _drawnLines[i].length; j++) {
        if ((localPosition - _drawnLines[i][j]).distance < _dynamicHitThreshold) {
          _potentialDraggedLineIndex = i;
          _potentialDraggedPointIndex = j;
          _selectedLineIndex = i; // Select the line when node is hit
          break;
        }
      }
      if (_potentialDraggedLineIndex != null) break;
    }

    // 2. If no node hit, check for line segment hits to select the line
    if (_potentialDraggedLineIndex == null) {
      int? hitIndex;
      for (int i = 0; i < _drawnLines.length; i++) {
        final line = _drawnLines[i];
        if (line.length == 2) {
          if (_isPointNearSegment(localPosition, line[0], line[1], _dynamicHitThreshold * 0.6)) {
            hitIndex = i;
            break;
          }
        }
      }
      if (hitIndex != null) {
        setState(() {
          _selectedLineIndex = hitIndex;
        });
      } else {
        // Only deselect if we truly hit empty space
        setState(() {
          _selectedLineIndex = null;
        });
      }
    }

    if (localPosition.dx >= 0 &&
        localPosition.dy >= 0 &&
        localPosition.dx <= size.width &&
        localPosition.dy <= size.height) {
      // Always prepare for a potential new line
      _startPoint = _snapPoint(localPosition);
      _lineType = null;
      setState(() {
        // Only show current line preview if we aren't stretching an existing node
        if (_potentialDraggedLineIndex == null) {
          _currentLine = [_startPoint!, _startPoint!];
        } else {
          _currentLine = [];
        }
      });
    }
  }

  /// Helper to check if a point is near a line segment
  bool _isPointNearSegment(Offset p, Offset a, Offset b, double threshold) {
    final double dist = (a - b).distance;
    if (dist < 1) return (p - a).distance < threshold;

    // Calculate distance from point to line segment
    final double t = ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / (dist * dist);
    final double clampedT = t.clamp(0.0, 1.0);
    final Offset projection = Offset(
      a.dx + clampedT * (b.dx - a.dx),
      a.dy + clampedT * (b.dy - a.dy),
    );
    return (p - projection).distance < threshold;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    // Clamp current position to drawing area bounds
    final Offset currentPosition = Offset(
      details.localPosition.dx.clamp(0.0, box.size.width),
      details.localPosition.dy.clamp(0.0, box.size.height),
    );

    // 1. Handle Moving the entire line
    if (_movingLineIndex != null && _moveLastPosition != null) {
      final Offset delta = currentPosition - _moveLastPosition!;
      final line = _drawnLines[_movingLineIndex!];

      // Tentatively move all points
      List<Offset> newPoints = line.map((p) => p + delta).toList();

      // Check if either end of the moved line should snap to another line
      Offset adjustment = Offset.zero;
      for (var p in [newPoints.first, newPoints.last]) {
        final snapped = _snapPoint(p, excludeIndex: _movingLineIndex);
        if (snapped != p) {
          adjustment = snapped - p;
          break; // Use the first snap found
        }
      }

      setState(() {
        for (int i = 0; i < line.length; i++) {
          final Offset p = newPoints[i] + adjustment;
          line[i] = Offset(
            p.dx.clamp(0.0, box.size.width),
            p.dy.clamp(0.0, box.size.height),
          );
        }
      });
      _moveLastPosition = currentPosition + adjustment;
      return;
    }

    if (_startPoint == null) return;

    // Calculate absolute differences to determine direction
    final double dx = (currentPosition.dx - _startPoint!.dx).abs();
    final double dy = (currentPosition.dy - _startPoint!.dy).abs();

    // Determine line type if not already determined
    if (_lineType == null) {
      if (dx > 5 / _currentScale || dy > 5 / _currentScale) {
        _lineType = dx > dy; // true for horizontal, false for vertical
      }
    }

    // Decision Logic: Stretch vs New Line
    if (_lineType != null &&
        _draggedLineIndex == null &&
        _potentialDraggedLineIndex != null) {
      final line = _drawnLines[_potentialDraggedLineIndex!];

      // Only allow stretching for manual lines (2 points)
      if (line.length == 2) {
        // --- SMOOTH OPTIMIZATION: Dominant component check prevents misclassifications ---
        final double lineDx = (line[0].dx - line[1].dx).abs();
        final double lineVerticalDelta = (line[0].dy - line[1].dy).abs();
        final bool isLineHorizontal = lineDx > lineVerticalDelta;

        if (_lineType == isLineHorizontal) {
          // Move direction matches line orientation -> SWITCH TO STRETCH
          setState(() {
            _draggedLineIndex = _potentialDraggedLineIndex;
            _draggedPointIndex = _potentialDraggedPointIndex;
            _currentLine = []; // Cancel new line
          });
        } else {
          // Perpendicular movement -> STAY IN DRAW MODE
          _potentialDraggedLineIndex = null;
        }
      } else {
        // Not a stretchable manual line -> STAY IN DRAW MODE
        _potentialDraggedLineIndex = null;
      }
    }

    // 1. Handle Stretching
    if (_draggedLineIndex != null) {
      final line = _drawnLines[_draggedLineIndex!];

      // Safety check for manual line stretching
      if (line.length == 2 && _draggedPointIndex! < 2) {
        final otherPoint = line[1 - _draggedPointIndex!];

        // --- SMOOTH OPTIMIZATION: Robust orientation check ---
        final double lineDx = (line[0].dx - line[1].dx).abs();
        final double lineVerticalDelta = (line[0].dy - line[1].dy).abs();
        final bool isHorizontal = lineDx > lineVerticalDelta;

        Offset newPoint;
        if (isHorizontal) {
          newPoint = Offset(currentPosition.dx, otherPoint.dy);
        } else {
          newPoint = Offset(otherPoint.dx, currentPosition.dy);
        }

        // Get snap position candidates from other lines
        newPoint = _snapPoint(newPoint, excludeIndex: _draggedLineIndex);

        // --- SMOOTH OPTIMIZATION: Lock axis POST-SNAP to prevent diagonal wall distortion ---
        if (isHorizontal) {
          newPoint = Offset(newPoint.dx, otherPoint.dy);
        } else {
          newPoint = Offset(otherPoint.dx, newPoint.dy);
        }

        setState(() {
          line[_draggedPointIndex!] = Offset(
            newPoint.dx.clamp(0.0, box.size.width),
            newPoint.dy.clamp(0.0, box.size.height),
          );
        });
        return;
      } else if (_draggedPointIndex! < line.length) {
        // Fallback for contours: just move the point freely
        setState(() {
          line[_draggedPointIndex!] = _snapPoint(currentPosition, excludeIndex: _draggedLineIndex);
        });
        return;
      }
    }

    // 2. Handle Drawing New Line
    if (_lineType != null) {
      Offset constrainedPoint;
      if (_lineType == true) {
        constrainedPoint = Offset(currentPosition.dx, _startPoint!.dy);
      } else {
        constrainedPoint = Offset(_startPoint!.dx, currentPosition.dy);
      }

      constrainedPoint = _snapPoint(constrainedPoint);

      setState(() {
        // Initialize currentLine if it was delayed due to potential stretch
        if (_currentLine.isEmpty && _draggedLineIndex == null) {
          _currentLine = [_startPoint!, constrainedPoint];
        } else if (_currentLine.length >= 2) {
          _currentLine[1] = constrainedPoint;
        }
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    bool stateChanged = false;

    if (_movingLineIndex != null) {
      stateChanged = true;
      setState(() {
        _movingLineIndex = null;
        _moveLastPosition = null;
      });
    } else if (_draggedLineIndex != null) {
      stateChanged = true;
      setState(() {
        _draggedLineIndex = null;
        _draggedPointIndex = null;
      });
    } else if (_startPoint != null && _currentLine.length == 2) {
      // Check if we actually drew a line (not just a point)
      final lastPoint = _currentLine[1];
      if (lastPoint != _startPoint) {
        setState(() {
          _drawnLines.add(List<Offset>.from(_currentLine));
          _currentLine = [];
        });
        stateChanged = true;
      }
    }

    if (stateChanged) {
      _saveToHistory();
    }

    _startPoint = null;
    _lineType = null;
    _currentLine = [];
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset localPosition = Offset(
      details.localPosition.dx.clamp(0.0, box.size.width),
      details.localPosition.dy.clamp(0.0, box.size.height),
    );

    int? hitLineIndex;
    // Check nodes first
    for (int i = 0; i < _drawnLines.length; i++) {
      for (var point in _drawnLines[i]) {
        if ((localPosition - point).distance < _dynamicHitThreshold) {
          hitLineIndex = i;
          break;
        }
      }
      if (hitLineIndex != null) break;
    }

    // Check segments if no node hit
    if (hitLineIndex == null) {
      for (int i = 0; i < _drawnLines.length; i++) {
        final line = _drawnLines[i];
        if (line.length == 2) {
          if (_isPointNearSegment(localPosition, line[0], line[1], _dynamicHitThreshold * 0.6)) {
            hitLineIndex = i;
            break;
          }
        }
      }
    }

    if (hitLineIndex != null) {
      setState(() {
        _selectedLineIndex = hitLineIndex;
        _lastDoubleTapTime = DateTime.now();
      });
    }
  }

  void _handleTapDown(TapDownDetails details) {
    final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset localPosition = Offset(
      details.localPosition.dx.clamp(0.0, box.size.width),
      details.localPosition.dy.clamp(0.0, box.size.height),
    );

    int? hitLineIndex;
    // Check nodes first
    for (int i = 0; i < _drawnLines.length; i++) {
      for (var point in _drawnLines[i]) {
        if ((localPosition - point).distance < _dynamicHitThreshold) {
          hitLineIndex = i;
          break;
        }
      }
      if (hitLineIndex != null) break;
    }

    // Check segments if no node hit
    if (hitLineIndex == null) {
      for (int i = 0; i < _drawnLines.length; i++) {
        final line = _drawnLines[i];
        if (line.length == 2) {
          if (_isPointNearSegment(localPosition, line[0], line[1], _dynamicHitThreshold * 0.6)) {
            hitLineIndex = i;
            break;
          }
        }
      }
    }

    setState(() {
      _selectedLineIndex = hitLineIndex;
    });
  }

  /// Export JSON and Navigate to Unity
  Future<void> exportToJson() async {
    if (_drawnLines.isEmpty) {
      AppSnackbars.warning(title: 'Warning', message: 'Please draw a boundary first');
      return;
    }

    if (_activeProjectId == null) {
      showProjectCreationBottomSheet(
        context: context,
        onProjectCreated: (id) {
          setState(() => _activeProjectId = id);
          exportToJson(); // Proceed after creation
        },
      );
      return;
    }

    try {
      // Convert _drawnLines to flat points list with Offset.zero separators
      final flatPoints = <Offset>[];
      for (var line in _drawnLines) {
        flatPoints.addAll(line);
        flatPoints.add(Offset.zero);
      }
      final jsonString = await DrawingService.exportToJson(
        flatPoints,
        drawingKey,
      );

      if (mounted) {
        // Navigate to Unity View with the generated JSON
        // Get.to(() => UnityHomeScreen(jsonString: jsonString));
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.error(title: 'Error', message: '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: isLandscape
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildDrawingArea(),
              ),
            ),
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(-10, 0),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: _buildControls(theme, isLandscape: true),
              ),
            ),
          ],
        )
            : Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildDrawingArea(),
              ),
            ),
            _buildControls(theme, isLandscape: false),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingArea() {
    return DrawingCanvas(
      drawingKey: drawingKey,
      transformationController: _transformationController,
      drawnLines: _drawnLines,
      currentLine: _currentLine,
      currentScale: _currentScale,
      selectedLineIndex: _selectedLineIndex,
      draggedLineIndex: _draggedLineIndex ?? _potentialDraggedLineIndex,
      draggedPointIndex: _potentialDraggedPointIndex ?? _draggedPointIndex,
      minScale: _minScale,
      maxScale: _maxScale,
      onTapDown: _handleTapDown,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onDoubleTapDown: _handleDoubleTapDown,
      onInteractionUpdate: (_) {
        setState(() {
          _currentScale = _transformationController.value.getMaxScaleOnAxis();
        });
      },
      onZoomIn: _zoomIn,
      onZoomOut: _zoomOut,
    );
  }

  Widget _buildControls(ThemeData theme, {required bool isLandscape}) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, isLandscape ? 0 : 24, 16, 16),
      decoration: isLandscape
          ? null
          : BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusInfo(theme),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                CircularActionButton(
                  onTap: _undo,
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  color: Colors.orange,
                  enabled: _history.length > 1,
                ),
                const SizedBox(width: 12),
                CircularActionButton(
                  onTap: _duplicateSelectedLine,
                  icon: Icons.copy_all_rounded,
                  label: 'Copy',
                  color: Colors.indigo,
                  enabled: _selectedLineIndex != null,
                ),
                const SizedBox(width: 12),
                CircularActionButton(
                  onTap: _deleteSelectedLine,
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: Colors.redAccent,
                  enabled: _selectedLineIndex != null,
                ),
                const SizedBox(width: 12),
                CircularActionButton(
                  onTap: () {
                    if (_drawnLines.isEmpty) return;
                    _showClearDialog();
                  },
                  icon: Icons.layers_clear,
                  label: 'Clear',
                  enabled: _drawnLines.isNotEmpty,
                  color: Colors.blueGrey.shade200,
                ),
                const SizedBox(width: 12),
                CircularActionButton(
                  onTap: saveDrawing,
                  icon: Icons.save_alt_rounded,
                  enabled: _drawnLines.isNotEmpty,
                  label: 'Save',
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: MainActionButton(
                  onTap: _generateFloorplan,
                  icon: Icons.auto_awesome_rounded,
                  label: 'Generate AI',
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MainActionButton(
                  onTap: exportToJson,
                  icon: Icons.view_in_ar_rounded,
                  label: 'Unity View',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.polyline_rounded, size: 14, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                '${_drawnLines.length} Segments',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Drawing?'),
        content: const Text('This will delete all lines and reset history.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _drawnLines.clear();
                _history.clear();
                _history.add([]);
                _currentLine = [];
                _selectedLineIndex = null;
                _startPoint = null;
                _lineType = null;
                _transformationController.value = Matrix4.identity();
                _currentScale = 1.0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
