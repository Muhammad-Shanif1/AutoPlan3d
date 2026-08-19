// import 'package:flutter/material.dart';
// import 'package:flutter_unity_widget/flutter_unity_widget.dart';
//
// class ARSceneScreen extends StatefulWidget {
//   var indexoffurniture;
//   ARSceneScreen({ Key? key,required indexoffurniture}) : super(key: key);
//   @override
//   _ARSceneScreenState createState() => _ARSceneScreenState();
// }
//
// class _ARSceneScreenState extends State<ARSceneScreen> {
//   UnityWidgetController? _unityWidgetController;
//   var indexoffurniture;
//   @override
//   void initState() {
//     indexoffurniture=widget.indexoffurniture;
//     seneinit();
//     super.initState();
//   }
//   @override
//   void dispose() {
//     _unityWidgetController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('AR Scene',style: TextStyle(color: Theme.of(context).colorScheme.primary),),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: UnityWidget(
//               onUnityCreated: onUnityCreated,
//               onUnityMessage: _onUnityMessage,
//               fullscreen: false,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   void _onUnityMessage(dynamic message) {
//     print('Received message from Unity: $message');
//   }
//   void onUnityCreated(UnityWidgetController controller) {
//     _unityWidgetController = controller;
//     // controller.resume();
//     _loadUnityScene();
//   }
//   seneinit()async{
//     Future.delayed(Duration(seconds: 2));
//     _unityWidgetController?.postMessage(
//       'XR Origin', // Name of your GameObject with the script
//       'SetFurnitureByIndex',
//       indexoffurniture.toString(),
//     );
//     print("furniture index changed");
//
//   }
//
//   void _loadUnityScene() {
//     if (_unityWidgetController != null) {
//       // Send message to Unity to load specific scene
//
//       _unityWidgetController!.postMessage(
//           'SceneManager', // GameObject name in Unity
//           'LoadSingleObjectARScene', // Method name in Unity
//           '' // Parameter
//       );
//     }
//     void onUnityMessage(dynamic message) {
//       print('Received from Unity: $message');
//     }
//
//     void onUnitySceneLoaded(SceneLoaded? scene) {
//       if (scene != null) {
//         print('Unity scene loaded: ${scene.name}, buildIndex: ${scene
//             .buildIndex}');
//       }
//     }
//   }
// }



/*
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import '../ui/constants/libraries/app_libraries.dart';

// ---------------------------------------------------------------------------
// Data model — replace 'assetPath' with your real image assets or network URLs
// ---------------------------------------------------------------------------
class FurnitureItem {
  final int index;
  final String name;
  final String category;
  final String assetPath; // e.g. 'assets/furniture/sofa.png'

  const FurnitureItem({
    required this.index,
    required this.name,
    required this.category,
    required this.assetPath,
  });
}

// ---------------------------------------------------------------------------
// Sample catalogue — sync index values with Unity's furnitureList order
// ---------------------------------------------------------------------------
const List<FurnitureItem> kFurnitureCatalogue = [
  FurnitureItem(index: 0, name: 'Sofa',        category: 'Living Room', assetPath: 'assets/furniture/sofa.png'),
  FurnitureItem(index: 1, name: 'Armchair',    category: 'Living Room', assetPath: 'assets/furniture/armchair.png'),
  FurnitureItem(index: 2, name: 'Coffee Table',category: 'Tables',      assetPath: 'assets/furniture/coffee_table.png'),
  FurnitureItem(index: 3, name: 'Bookshelf',   category: 'Storage',     assetPath: 'assets/furniture/bookshelf.png'),
  FurnitureItem(index: 4, name: 'Bed',         category: 'Bedroom',     assetPath: 'assets/furniture/bed.png'),
  FurnitureItem(index: 5, name: 'Wardrobe',    category: 'Bedroom',     assetPath: 'assets/furniture/wardrobe.png'),
  FurnitureItem(index: 6, name: 'Dining Table',category: 'Dining',      assetPath: 'assets/furniture/dining_table.png'),
  FurnitureItem(index: 7, name: 'Chair',       category: 'Dining',      assetPath: 'assets/furniture/chair.png'),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class ARSceneScreen extends StatefulWidget {
  const ARSceneScreen({Key? key}) : super(key: key);

  @override
  State<ARSceneScreen> createState() => _ARSceneScreenState();
}

class _ARSceneScreenState extends State<ARSceneScreen> {
  // Unity
  UnityWidgetController? _unity;
  bool _unityReady = false;       // true once Unity sends READY:<n>
  int  _furnitureCountInUnity = 0;

  // Selection state
  int? _selectedIndex;            // null = nothing selected yet
  bool _hasPlacedObject = false;

  // UI feedback
  String _statusMessage = 'Scan a flat surface to begin';
  bool   _showControls  = false;  // show rotate/scale buttons after placement

  // ==================== UNITY CALLBACKS ====================

  void _onUnityCreated(UnityWidgetController controller) {
    _unity = controller;
    debugPrint('[Flutter] Unity widget created');
    _unity!.postMessage(
          'SceneManager', // GameObject name in Unity
          'LoadSingleObjectARScene', // Method name in Unity
          '' // Parameter
      );
  }

  void _onUnityMessage(dynamic raw) {
    final message = raw.toString();
    debugPrint('[Unity→Flutter] $message');

    setState(() {
      if (message.startsWith('READY:')) {
        _unityReady = true;
        _furnitureCountInUnity = int.tryParse(message.substring(6)) ?? 0;
        _statusMessage = 'Select a furniture item below';

      } else if (message.startsWith('PLACED:')) {
        final name = message.substring(7);
        _hasPlacedObject = true;
        _showControls    = true;
        _statusMessage   = '$name placed ✓  Pinch & rotate to adjust';

      } else if (message == 'RESET_DONE') {
        _selectedIndex   = null;
        _hasPlacedObject = false;
        _showControls    = false;
        _statusMessage   = 'Select a furniture item below';

      } else if (message.startsWith('FURNITURE_SELECTED:')) {
        // e.g. FURNITURE_SELECTED:2:Coffee Table
        final parts = message.split(':');
        _statusMessage = 'Tap a surface to place ${parts.length > 2 ? parts[2] : "item"}';

      } else if (message.startsWith('ERROR:')) {
        _statusMessage = '⚠ ${message.substring(6)}';

      } else if (message.startsWith('ROTATED:')) {
        // silent
      } else if (message.startsWith('SCALE_SET:')) {
        // silent
      }
    });
  }

  void _onUnitySceneLoaded(SceneLoaded? scene) {
    debugPrint('[Flutter] Scene loaded: ${scene?.name}');
  }

  // ==================== SEND TO UNITY ====================

  void _selectFurniture(FurnitureItem item) {
    if (!_unityReady) return;

    setState(() {
      _selectedIndex   = item.index;
      _hasPlacedObject = false;
      _showControls    = false;
      _statusMessage   = 'Tap a surface to place ${item.name}';
    });

    _unity?.postMessage(
      'XR Origin',            // GameObject with SingleObjectARManager
      'OnFlutterMessage',
      'SELECT_FURNITURE:${item.index}',
    );
    debugPrint('[Flutter→Unity] SELECT_FURNITURE:${item.index}');
  }

  void _sendReset() {
    _unity?.postMessage('XR Origin', 'OnFlutterMessage', 'RESET');
  }

  void _sendRotate(double degrees) {
    _unity?.postMessage('XR Origin', 'OnFlutterMessage', 'ROTATE:$degrees');
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // leading: InkWell(
        //     onTap: () {
        //       Get.back();
        //     },
        //     child: Icon(Icons.arrow_back_rounded)),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Unity AR view (full screen) ──────────────────────────────
          const Positioned.fill(child: SizedBox()),
          Positioned.fill(
            child: UnityWidget(
              onUnityCreated:     _onUnityCreated,
              onUnityMessage:     _onUnityMessage,
              onUnitySceneLoaded: _onUnitySceneLoaded,
              fullscreen:         false,
            ),
          ),

          // ── Top status bar ───────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _StatusBanner(message: _statusMessage, ready: _unityReady),
          ),

          // ── Top-right controls (reset) ───────────────────────────────
          if (_hasPlacedObject || _selectedIndex != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: _IconBtn(
                icon: Icons.refresh_rounded,
                tooltip: 'Reset',
                onTap: _sendReset,
              ),
            ),

          // ── Rotation controls (shown after placement) ────────────────
          if (_showControls)
            Positioned(
              right: 16,
              bottom: 220,
              child: Column(
                children: [
                  _IconBtn(
                    icon: Icons.rotate_left_rounded,
                    tooltip: 'Rotate left 15°',
                    onTap: () => _sendRotate(-15),
                  ),
                  const SizedBox(height: 8),
                  _IconBtn(
                    icon: Icons.rotate_right_rounded,
                    tooltip: 'Rotate right 15°',
                    onTap: () => _sendRotate(15),
                  ),
                ],
              ),
            ),

          // ── Bottom furniture picker ──────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FurniturePicker(
              catalogue:     kFurnitureCatalogue,
              selectedIndex: _selectedIndex,
              enabled:       _unityReady,
              onSelect:      _selectFurniture,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _unity?.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Status banner
// ---------------------------------------------------------------------------
class _StatusBanner extends StatelessWidget {
  final String message;
  final bool   ready;

  const _StatusBanner({required this.message, required this.ready});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!ready)
            const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white70),
              ),
            )
          else
            const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small floating icon button
// ---------------------------------------------------------------------------
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String   tooltip;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Furniture picker shelf
// ---------------------------------------------------------------------------
class _FurniturePicker extends StatelessWidget {
  final List<FurnitureItem> catalogue;
  final int?                selectedIndex;
  final bool                enabled;
  final ValueChanged<FurnitureItem> onSelect;

  const _FurniturePicker({
    required this.catalogue,
    required this.selectedIndex,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.85),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'FURNITURE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(enabled ? 0.9 : 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: catalogue.length,
                  itemBuilder: (ctx, i) {
                    final item      = catalogue[i];
                    final isSelected = selectedIndex == item.index;
                    return _FurnitureCard(
                      item:       item,
                      isSelected: isSelected,
                      enabled:    enabled,
                      onTap:      enabled ? () => onSelect(item) : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual furniture card
// ---------------------------------------------------------------------------
class _FurnitureCard extends StatelessWidget {
  final FurnitureItem item;
  final bool          isSelected;
  final bool          enabled;
  final VoidCallback? onTap;

  const _FurnitureCard({
    required this.item,
    required this.isSelected,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF4FC3F7); // light blue highlight

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(0.22)
              : Colors.white.withOpacity(enabled ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accent : Colors.white.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Thumbnail ──
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 68,
                height: 68,
                child: _FurnitureThumbnail(
                  assetPath: item.assetPath,
                  enabled:   enabled,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // ── Name ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(enabled ? 0.8 : 0.35),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
            // ── Selected badge ──
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '● Selected',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Thumbnail — tries asset image, falls back to category icon
// ---------------------------------------------------------------------------
class _FurnitureThumbnail extends StatelessWidget {
  final String assetPath;
  final bool   enabled;

  const _FurnitureThumbnail({required this.assetPath, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: enabled
          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
          : ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.white10,
          child: const Icon(
            Icons.chair_alt_rounded,
            color: Colors.white38,
            size: 36,
          ),
        ),
      ),
    );
  }
}


 */