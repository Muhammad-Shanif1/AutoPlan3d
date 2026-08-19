/*

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:flutter_unity_widget_example/ui/services/project_services.dart';
import 'package:get/get.dart';

import '../ui/controller/gallery_controller.dart';
import '../ui/models/project_model.dart';
import '../ui/services/camera_snapshot_service.dart';
import '../ui/services/scene_sync_service.dart';
import '../ui/widgets/furniture_bottom_sheet.dart';

class HouseSceneScreen extends StatefulWidget {
  final Project project;
  final bool issnap;
  const HouseSceneScreen({super.key, required this.project, required this.issnap});

  @override
  _HouseSceneScreenState createState() => _HouseSceneScreenState();
}

class _HouseSceneScreenState extends State<HouseSceneScreen> {
  // Add this state variable at the top with other state variables

  bool _isFirstPersonMode = false;
  void _toggleFirstPersonMode() {
    if (_unityWidgetController != null) {
      setState(() {
        _isFirstPersonMode = !_isFirstPersonMode;
      });

      if (_isFirstPersonMode) {
        // Switch to first-person mode
        _unityWidgetController?.postMessage(
            'CameraManager', // GameObject name
            'SetCameraModeFromFlutter', // Method name
            'firstperson' // Parameter
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to First-Person Mode'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // Switch back to edit mode
        _unityWidgetController?.postMessage(
          'CameraManager',
          'SetCameraModeFromFlutter',
          'universal',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to Edit Mode'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unity not ready'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final GlobalKey _unityWidgetKey = GlobalKey();
  final List<FurnitureItem> furnitureItems = kFurnitureItems;

  void showFurnitureBottomSheet({
    required BuildContext context,
    required List<FurnitureItem> furnitureItems,
    required void Function(FurnitureItem item) onItemSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FurnitureBottomSheet(
        furnitureItems: furnitureItems,
        onItemSelected: onItemSelected,
      ),
    );
  }
  // void _showFurnitureBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     isScrollControlled: true,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.6,
  //       child: Column(
  //         children: [
  //           // Header
  //           Container(
  //             padding: EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.black87,
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Add Furniture',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close, color: Colors.white),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           // Furniture Grid
  //           Expanded(
  //             child: GridView.builder(
  //               padding: EdgeInsets.all(16),
  //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                 crossAxisCount: 3,
  //                 crossAxisSpacing: 16,
  //                 mainAxisSpacing: 16,
  //                 childAspectRatio: 0.9,
  //               ),
  //               itemCount: furnitureItems.length,
  //               itemBuilder: (context, index) {
  //                 final item = furnitureItems[index];
  //                 return InkWell(
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     _showAddFurnitureDialog(item);
  //                   },
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(color: Colors.grey[300]!),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black12,
  //                           blurRadius: 6,
  //                           offset: Offset(0, 3),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(item.icon, color: Colors.deepPurple, size: 36),
  //                         SizedBox(height: 10),
  //                         Text(
  //                           item.name,
  //                           style: TextStyle(
  //                             color: Colors.black87,
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                           textAlign: TextAlign.center,
  //                           maxLines: 2,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //
  //           // Footer
  //           Container(
  //             padding: EdgeInsets.all(16),
  //             color: Colors.grey[50],
  //             child: Row(
  //               children: [
  //                 Icon(Icons.info, color: Colors.deepPurple, size: 16),
  //                 SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     'Click on furniture items to add them to the scene',
  //                     style: TextStyle(
  //                       color: Colors.grey[700],
  //                       fontSize: 12,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showAddFurnitureDialog(FurnitureItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add ${item.name}'),
          content: Text('Do you want to add ${item.name} to the scene?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                _addFurnitureToScene(item);
              },
            ),
          ],
        );
      },
    );
  }

  void _addFurnitureToScene(FurnitureItem item) {
    print('🎯 Adding furniture to scene: ${item.name}');

    if (_unityWidgetController != null) {
      // Example: Add at position (8, 0, 0)
      _addFurnitureWithPosition(item.prefabName, 8, 0, 0);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${item.name} to scene'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('❌ Unity controller is null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unity not ready. Please try again.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  UnityWidgetController? _unityWidgetController;
  double _zoomLevel = 10.0;
  Color _selectedColor = Colors.blue;
  Color _currentObjectColor = Colors.blue;
  bool _isObjectSelected = false;
  String _selectedObjectName = '';

  // Wall creation state
  bool _showWallPanel = false;
  final TextEditingController _wallHeightController = TextEditingController();
  final TextEditingController _wallWidthController = TextEditingController();
  final TextEditingController _wallPosXController = TextEditingController();
  final TextEditingController _wallPosYController = TextEditingController();
  final TextEditingController _wallPosZController = TextEditingController();
  final TextEditingController _wallRotationController = TextEditingController();

  // Rotation sliders state
  double _xRotation = 0.0;
  double _yRotation = 0.0;
  double _zRotation = 0.0;
  bool _showRotationPanel = false;


  void _toggleWallPanel() {
    setState(() {
      _showWallPanel = !_showWallPanel;
    });
  }

  void _onUnityMessage(dynamic message) async{
    print('Received message from Unity: $message');
    message=message.toString();
    if (message is String) {
      if (message.startsWith('SELECTED:')) {
        String objectName = message.substring(9);
        setState(() {
          _isObjectSelected = true;
          _selectedObjectName = objectName;
        });
        print('✅ Object selected: $objectName');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: $objectName'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }

      else if (message.startsWith('CAMERA_SNAPSHOT:')) {
        final galleryController = Get.isRegistered<GalleryController>()
            ? Get.find<GalleryController>()
            : Get.put(GalleryController());

        galleryController.onNewSnapshot(message).then((_) {
          Get.snackbar('Snapshot', 'Screenshot saved to gallery!',);
          if (widget.issnap && mounted) {
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) Navigator.of(context).pop();
              if (mounted) Navigator.of(context).pop();
            });
          }
        });
      }
      else if (message.startsWith('SNAPSHOT_ERROR:')) {
        Get.snackbar('Snapshot Error',
            message.substring('SNAPSHOT_ERROR:'.length));
        // if (widget.issnap) {
        //   Future.delayed(const Duration(milliseconds: 300), () {
        //     Get.back();
        //   });
        // }
        Get.back();
      }
      else if (message == 'HPM_READY') {
        print('✅ Unity fully ready — loading saved scene objects');
        final project = widget.project;

        if (project.objects.isNotEmpty) {
          print('Loading ${project.objects.length} object(s) into scene');
          await ProjectService.instance.loadProjectScene(project.id, _unityWidgetController!);
        }
        if (widget.issnap) {

          _unityWidgetController?.postMessage(
            'CameraSnapshotManager',
            'CaptureTopView',
            '',
          );

        }
        return;
      }
      else if (message.startsWith('SCENE_OBJECTS:')) {
        print(message);
        SceneSyncService.instance.handleUnityMessage(
          message,
          widget.project.id,
          onSuccess: (objects) {
            print('✅ Synced ${objects.length} object(s) to project');
            if (mounted) setState(() {});
          },
          onError: (error) {
            print('❌ Sync error: $error');
          },
        ).then((value) {
          print(widget.project.objects);
        },);
      }
      else if (message.startsWith('FURNITURE_PLACED:')) {
        final detail = message.replaceFirst('FURNITURE_PLACED:', '');
        print('✅ Placed: $detail');
        // Get.snackbar("AutoPlanner 5D", "placed: $detail");

      } else if (message.startsWith('FURNITURE_REMOVED:')) {
        final name = message.replaceFirst('FURNITURE_REMOVED:', '');
        print('🗑️ Removed: $name');
        Get.snackbar("AutoPlanner 5D", "Removed: $name");

      } else if (message.startsWith('FURNITURE_ALL_REMOVED:')) {
        final detail = message.replaceFirst('FURNITURE_ALL_REMOVED:', '');
        print('🗑️ All cleared — $detail');
        Get.snackbar("AutoPlanner 5D", '🗑️ All cleared — $detail');

      } else if (message.startsWith('FURNITURE_ERROR:')) {
        final error = message.replaceFirst('FURNITURE_ERROR:', '');
        print('❌ Error: $error');
        Get.snackbar("AutoPlanner 5D", '❌ Error: $error');

      }
      else if (message.startsWith('FP_MODE:')) {
        bool isFP = message.substring(8) == 'true';
        setState(() {
          _isFirstPersonMode = isFP;
        });
        print('First-Person Mode: $isFP');
      }
      else if (message == 'SHOW_JOYSTICKS') {
        // Unity is requesting to show joysticks
        print('Unity requesting joystick display');
      }

      else if (message == "DESELECTED") {
        setState(() {
          _isObjectSelected = false;
          _selectedObjectName = '';
          _showRotationPanel = false;
        });
        print('❌ Object deselected');
      }
    }
  }

  void _showColorPicker() async {
    if (!_isObjectSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an object in Unity first!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Color for $_selectedObjectName'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Apply'),
              onPressed: () {
                _applyColorToSelectedObject(_selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleRotationPanel() async {
    if (!_isObjectSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an object first!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _showRotationPanel = !_showRotationPanel;
    });
  }

  void _applyColorToSelectedObject(Color color) {
    if (!_isObjectSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No object selected! Please select an object first.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String colorHex = '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}'
        '${color.alpha.toRadixString(16).padLeft(2, '0')}';

    print('🎨 Applying color: $colorHex to $_selectedObjectName');

    _unityWidgetController?.postMessage(
      'UniversalCameraController',
      'ChangeObjectColor',
      colorHex,
    );

    setState(() {
      _currentObjectColor = color;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Color applied to $_selectedObjectName'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  // For JSON format
  void _addFurnitureWithPosition(String furnitureName, double x, double y, double z) {
    String jsonData = '{"furnitureName":"$furnitureName","x":$x,"y":$y,"z":$z}';

    _unityWidgetController?.postMessage(
        'FurnitureManager',
        'AddFurnitureAtPosition',
        jsonData
    );
  }
  void removeSelectedFurniture() {
    _unityWidgetController?.postMessage(
      'FurnitureManager',
      'RemoveFurniture',
      '',             // empty string, param is not used
    );
  }
  Future<void> removeAllFurniture()async{
    _unityWidgetController?.postMessage(
      'FurnitureManager',
      'RemoveAllFurniture',
      '',             // empty string, param is not used
    );
  }

  void _updateRotation() {
    if (!_isObjectSelected) return;

    String rotationString = '$_xRotation,$_yRotation,$_zRotation';

    _unityWidgetController?.postMessage(
      'UniversalCameraController',
      'SetObjectRotation',
      rotationString,
    );

    print('Sent rotation to Unity: X=$_xRotation, Y=$_yRotation, Z=$_zRotation');
  }

  void _resetRotation() {
    setState(() {
      _xRotation = 0.0;
      _yRotation = 0.0;
      _zRotation = 0.0;
    });
    _updateRotation();
  }

  void _rotateByDegrees(double x, double y, double z) {
    setState(() {
      _xRotation = x;
      _yRotation = y;
      _zRotation = z;
    });
    _updateRotation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.issnap?PreferredSize(preferredSize: Size(double.infinity, 50), child: SizedBox()):AppBar(
          title:  Text(_isFirstPersonMode ? 'First-Person Mode' : 'House Scene - Interactive'),
          leading: IconButton(onPressed: () async{
            print("object");
            await _unityWidgetController!.postMessage(
                'SceneStateReporter', // GameObject name in Unity
                'ReportFurnitureObjects', // Method name in Unity
                '' // Parameter
            );
            await removeAllFurniture();

            // Then pop
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }, icon: Icon(Icons.arrow_back)),
          // leadingWidth: 10,
          actions: [
            // Mode toggle button
            IconButton(
              icon: Icon(
                _isFirstPersonMode ? Icons.edit : Icons.person,
                color: Colors.white,
              ),
              onPressed: _toggleFirstPersonMode,
              tooltip: _isFirstPersonMode ? 'Switch to Edit Mode' : 'Switch to First-Person',
            ),
            IconButton(
              icon: Icon(
                Icons.save,
                color: Colors.white,
              ),
              onPressed: () {
                _unityWidgetController!.postMessage(
                    'SceneStateReporter', // GameObject name in Unity
                    'ReportFurnitureObjects', // Method name in Unity
                    '' // Parameter
                );
              },
              tooltip:"save project",
            ),
            // Other existing action buttons (only show in edit mode)
            if (!_isFirstPersonMode) ...[
              Container(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      _isObjectSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: _isObjectSelected ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isObjectSelected ? 'Selected' : 'No Selection',
                          style: TextStyle(
                            color: _isObjectSelected ? Colors.green : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.rotate_right),
                onPressed: _toggleRotationPanel,
                tooltip: 'Rotate Object',
                color: _isObjectSelected ? Colors.white : Colors.grey,
              ),
              IconButton(
                icon: Icon(Icons.color_lens),
                onPressed: _showColorPicker,
                tooltip: 'Change Object Color',
              ),
              IconButton(
                icon: Icon(Icons.center_focus_strong),
                onPressed: () {
                  _resetCamera;
                  print(widget.project.objects);
                  final project = widget.project;
                  if (project != null && project.objects.isNotEmpty) {
                    print('Loading ${project.objects.length} object(s) into scene');
                    ProjectService.instance.loadProjectScene(project.id, _unityWidgetController!);
                  }
                },
                tooltip: 'Reset Camera',
              ),

            ],
          ],
        ),
        body: widget.issnap
            ? Stack(
          children: [
            // Unity still needs to run in background to capture
            Opacity(
              opacity: 0,
              child: UnityWidget(
                key: _unityWidgetKey,
                onUnityCreated: onUnityCreated,
                onUnityMessage: _onUnityMessage,
                fullscreen: false,
              ),
            ),
            // Loading overlay on top
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Capturing snapshot...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            :PopScope(
          canPop: false, // Prevent default pop behavior
          onPopInvoked: (bool didPop) async {
            if (didPop) return;

            await _unityWidgetController!.postMessage(
                'SceneStateReporter', // GameObject name in Unity
                'ReportFurnitureObjects', // Method name in Unity
                '' // Parameter
            );
            await removeAllFurniture();
            // Then pop
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Stack(
            children: [
              // Unity View
              UnityWidget(
                key: _unityWidgetKey,
                onUnityCreated: onUnityCreated,
                onUnityMessage: _onUnityMessage,
                fullscreen: false,
              ),
              // Only show editing panels when NOT in first-person mode
              if (!_isFirstPersonMode) ...[
                // Rotation Panel
                if (_showRotationPanel && _isObjectSelected)
                  Positioned(
                    right: 16,
                    top: 16,
                    bottom: 16,
                    child: Container(
                      width: 300,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Rotate $_selectedObjectName',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.white, size: 20),
                                  onPressed: _toggleRotationPanel,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            _buildRotationSlider(
                              label: 'X Rotation',
                              value: _xRotation,
                              color: Colors.red,
                              onChanged: (value) {
                                setState(() {
                                  _xRotation = value;
                                });
                                _updateRotation();
                              },
                            ),

                            SizedBox(height: 16),

                            _buildRotationSlider(
                              label: 'Y Rotation',
                              value: _yRotation,
                              color: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  _yRotation = value;
                                });
                                _updateRotation();
                              },
                            ),

                            SizedBox(height: 16),

                            _buildRotationSlider(
                              label: 'Z Rotation',
                              value: _zRotation,
                              color: Colors.blue,
                              onChanged: (value) {
                                setState(() {
                                  _zRotation = value;
                                });
                                _updateRotation();
                              },
                            ),

                            SizedBox(height: 16),

                            Text(
                              'Quick Rotations:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildQuickRotationButton('0°', () => _rotateByDegrees(0, 0, 0)),
                                _buildQuickRotationButton('90° X', () => _rotateByDegrees(90, 0, 0)),
                                _buildQuickRotationButton('90° Y', () => _rotateByDegrees(0, 90, 0)),
                                _buildQuickRotationButton('90° Z', () => _rotateByDegrees(0, 0, 90)),
                                _buildQuickRotationButton('180° X', () => _rotateByDegrees(180, 0, 0)),
                                _buildQuickRotationButton('180° Y', () => _rotateByDegrees(0, 180, 0)),
                                _buildQuickRotationButton('-90° X', () => _rotateByDegrees(-90, 0, 0)),
                                _buildQuickRotationButton('-90° Y', () => _rotateByDegrees(0, -90, 0)),
                              ],
                            ),

                            SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _resetRotation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text('Reset Rotation'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Wall Creation Panel
                if (_showWallPanel)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      width: 300,
                      height: 400,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Create New Wall',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.white, size: 20),
                                  onPressed: _toggleWallPanel,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            _buildWallParameterField('Height', _wallHeightController, 'e.g., 3.0'),
                            SizedBox(height: 12),
                            _buildWallParameterField('Width', _wallWidthController, 'e.g., 5.0'),
                            SizedBox(height: 12),
                            _buildWallParameterField('Position X', _wallPosXController, 'e.g., 0.0'),
                            SizedBox(height: 12),
                            _buildWallParameterField('Position Y', _wallPosYController, 'e.g., 1.5'),
                            SizedBox(height: 12),
                            _buildWallParameterField('Position Z', _wallPosZController, 'e.g., 0.0'),
                            SizedBox(height: 12),
                            _buildWallParameterField('Rotation Y', _wallRotationController, 'e.g., 0.0'),

                            SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _createWallWithParameters,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Create Wall'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
              // Add a joystick info overlay in first-person mode
              if (_isFirstPersonMode)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'First-Person Mode Active\nUse on-screen joysticks to move',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: widget.issnap?SizedBox():_isFirstPersonMode?null:_buildEditModeFloatingButtons()
    );
  }
  void _loadUnityScene() {
    if (_unityWidgetController != null) {
      // Send message to Unity to load specific scene

      _unityWidgetController!.postMessage(
          'SceneManager', // GameObject name in Unity
          'LoadHouseScene', // Method name in Unity
          '' // Parameter
      );
    }}
  Widget _buildEditModeFloatingButtons() {
    return Container(
      height: 250,
      width: 50,
      color: Colors.black12,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "remove selected",
              onPressed:() {
                removeSelectedFurniture();
              },
              backgroundColor: Colors.orange,
              child: Icon(Icons.delete, color: Colors.white),
              tooltip: 'remove selected',
            ),
            FloatingActionButton(
              heroTag: "remove all",
              onPressed:() {
                removeAllFurniture();
                // _unityWidgetController?.postMessage(
                //   'UniversalCameraController', // GameObject name
                //   "DeleteAllWalls",// Method name
                //   "",
                // );
              },
              backgroundColor: Colors.orange,
              child: Icon(Icons.delete_forever_outlined, color: Colors.white),
              tooltip: 'remove all',
            ),
            // Mode toggle button
            FloatingActionButton(
              heroTag: "change",
              onPressed:() {
                _unityWidgetController?.postMessage(
                  'UniversalCameraController', // GameObject name
                  "ToggleDayNight",// Method name
                  "",
                );
              },
              backgroundColor: Colors.orange,
              child: Icon(Icons.light_mode, color: Colors.white),
              tooltip: 'day to night',
            ),
            FloatingActionButton(
              heroTag: "3rd person",
              onPressed:() {
                // Call from Flutter to switch to 3rd person view
                _unityWidgetController?.postMessage(
                  'CameraManager',
                  'SetCameraMode',
                  'thirdperson', // or 'third' or '3rd'
                );
              },
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
              tooltip: '3rd person',
            ),
            FloatingActionButton(
              heroTag: "mode_toggle",
              onPressed: _toggleFirstPersonMode,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
              tooltip: 'First-Person Mode',
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "wall_panel",  // UNIQUE TAG
              onPressed: _toggleWallPanel,
              backgroundColor: Colors.blue,
              child: Icon(Icons.add, color: Colors.white),
              tooltip: 'Add Wall',
            ),
            FloatingActionButton(
              heroTag: "furniture",  // UNIQUE TAG
              onPressed: () {
                showFurnitureBottomSheet(
                  context: context,
                  furnitureItems: furnitureItems,
                  onItemSelected: (item) => _showAddFurnitureDialog(item),
                );
              },
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.chair, color: Colors.white),
              tooltip: 'Add Furniture',
            ),
            FloatingActionButton(
              heroTag: "rotation",  // UNIQUE TAG
              onPressed: _toggleRotationPanel,
              backgroundColor: _isObjectSelected ? Colors.orange : Colors.grey,
              child: Icon(Icons.rotate_right, color: Colors.white),
              tooltip: 'Rotate Object',
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "line genereator",  // UNIQUE TAG
              onPressed: () {
                try {
                  final houseData={
                    "version": "1.0",
                    "canvasWidth": 324.0,
                    "canvasHeight": 383.0,
                    "coordinateSystem": "unity",
                    "origin": "center",
                    "strokeWidth": 10.0,
                    "strokeColor": "#0000FF",
                    "totalLines": 8,
                    "lines": [
                      {
                        "points": [
                          {
                            "x": -95.0,
                            "y": 138.5,
                            "z": 0.0
                          },
                          {
                            "x": -95.0,
                            "y": -90.5,
                            "z": 0.0
                          }
                        ],
                        "type": "vertical"
                      },
                      {
                        "points": [
                          {
                            "x": -89.0,
                            "y": -91.0,
                            "z": 0.0
                          },
                          {
                            "x": 91.5,
                            "y": -91.0,
                            "z": 0.0
                          }
                        ],
                        "type": "horizontal"
                      },
                      {
                        "points": [
                          {
                            "x": 92.5,
                            "y": -89.0,
                            "z": 0.0
                          },
                          {
                            "x": 92.5,
                            "y": 53.0,
                            "z": 0.0
                          }
                        ],
                        "type": "vertical"
                      },
                      {
                        "points": [
                          {
                            "x": 89.0,
                            "y": 52.5,
                            "z": 0.0
                          },
                          {
                            "x": -88.5,
                            "y": 52.5,
                            "z": 0.0
                          }
                        ],
                        "type": "horizontal"
                      },
                      {
                        "points": [
                          {
                            "x": -36.5,
                            "y": 42.5,
                            "z": 0.0
                          },
                          {
                            "x": -36.5,
                            "y": -84.5,
                            "z": 0.0
                          }
                        ],
                        "type": "vertical"
                      },
                      {
                        "points": [
                          {
                            "x": -90.5,
                            "y": -14.0,
                            "z": 0.0
                          },
                          {
                            "x": 84.5,
                            "y": -14.0,
                            "z": 0.0
                          }
                        ],
                        "type": "horizontal"
                      },
                      {
                        "points": [
                          {
                            "x": -88.0,
                            "y": 139.0,
                            "z": 0.0
                          },
                          {
                            "x": 11.5,
                            "y": 139.0,
                            "z": 0.0
                          }
                        ],
                        "type": "horizontal"
                      },
                      {
                        "points": [
                          {
                            "x": 11.0,
                            "y": 134.0,
                            "z": 0.0
                          },
                          {
                            "x": 11.0,
                            "y": 59.5,
                            "z": 0.0
                          }
                        ],
                        "type": "vertical"
                      }
                    ],
                    "timestamp": "2026-01-21T23:17:54.867507"
                  };
                  String jsonString = jsonEncode(houseData);
                  _unityWidgetController?.postMessage('FurnitureManager', 'ReceiveJsonData', jsonString);

                  // Send to Unity
                  // _unityWidgetController?.postMessage(
                  //   'FloorPlan', // GameObject name
                  //   // 'GenerateHouseFromJSON', // Method name
                  //   "ReceiveJsonData",
                  //   jsonString,
                  // );

                  print('House data sent to Unity');
                } catch (e) {
                  print('Error sending data to Unity: $e');
                }
              },
              backgroundColor: Colors.orange,
              child: Icon(Icons.line_axis, color: Colors.white),
              tooltip: 'Change Object Color',
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "color_picker",  // UNIQUE TAG
              onPressed: _showColorPicker,
              backgroundColor: _isObjectSelected ? _currentObjectColor : Colors.grey,
              child: Icon(Icons.color_lens, color: Colors.white),
              tooltip: 'Change Object Color',
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              mini: true,
              heroTag: "zoom_in",  // Already has tag
              onPressed: _zoomIn,
              child: Icon(Icons.zoom_in),
              tooltip: 'Zoom In',
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              mini: true,
              heroTag: "zoom_out",  // Already has tag
              onPressed: _zoomOut,
              child: Icon(Icons.zoom_out),
              tooltip: 'Zoom Out',
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "reset_camera",  // Change from "reset" to be more unique
              onPressed: _resetCamera,
              child: Icon(Icons.camera_alt),
              tooltip: 'Reset Camera',
            ),
          ],
        ),
      ),
    );
  }

  void _resetFirstPersonCamera() {
    _unityWidgetController?.postMessage(
      'FirstPersonController',
      'ResetPosition',
      '',
    );
  }
  Widget _buildQuickRotationButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size(0, 0),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  void onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
    _setZoomLevel(_zoomLevel);
    print('Unity controller initialized');
    _loadUnityScene();

  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel - 2.0).clamp(2.0, 20.0);
    });
    _setZoomLevel(_zoomLevel);
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel + 2.0).clamp(2.0, 20.0);
    });
    _setZoomLevel(_zoomLevel);
  }

  void _resetCamera() {
    _unityWidgetController?.postMessage(
        'UniversalCameraController',
        'ResetCamera',
        ''
    );
    setState(() {
      _zoomLevel = 10.0;
    });
  }

  void _setZoomLevel(double zoomLevel) {
    _unityWidgetController?.postMessage(
        'UniversalCameraController',
        'SetZoom',
        zoomLevel.toStringAsFixed(2)
    );
  }

  Widget _buildRotationSlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}°',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Slider(
          value: value,
          min: -180,
          max: 180,
          divisions: 360,
          onChanged: onChanged,
          activeColor: color,
          inactiveColor: color.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildWallParameterField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.5)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white54),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  void _createWallWithParameters() {
    try {

      // Create a single wall: "height,width,posX,posY,posZ,rotationY"
      _unityWidgetController?.postMessage('FurnitureManager', 'CreateWall', '3,5,0,1.5,0,0');


      // String parameters = '3.0,5.0,10,1,5,0.0';
      //
      // _unityWidgetController?.postMessage(
      //   'UniversalCameraController',
      //   'CreateWallWithParameters',
      //   parameters,
      // );

      // print('Creating wall with parameters: $parameters');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creating wall...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid numbers!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Flutter method to send JSON to Unity
  Future<void> sendHouseDataToUnity(Map<String, dynamic> houseData) async {
    try {
      String jsonString = jsonEncode(houseData);

      // Send to Unity
      _unityWidgetController?.postMessage(
        'HouseGenerator', // GameObject name
        // 'GenerateHouseFromJSON', // Method name
        "LoadFloorPlan",
        jsonString,
      );

      print('House data sent to Unity');
    } catch (e) {
      print('Error sending data to Unity: $e');
    }
  }

  @override
  void dispose() async{

    _unityWidgetController?.dispose();
    super.dispose();
  }
}

//
// // ── FURNITURE ──────────────────────────────────────────────────────────────
//
// // Add furniture at position
// final String json = jsonEncode({
//   'furnitureName': 'Chair_01',
//   'x': 2.0, 'y': 0.0, 'z': 3.0,
// });
// _unityWidgetController?.postMessage('FurnitureManager', 'AddFurnitureAtPosition', json);
//
// // Add furniture (legacy — name only)
// _unityWidgetController?.postMessage('FurnitureManager', 'AddFurniture', 'Chair_01');
//
// // ── WALL ───────────────────────────────────────────────────────────────────
//
// // Create a single wall: "height,width,posX,posY,posZ,rotationY"
// _unityWidgetController?.postMessage('FurnitureManager', 'CreateWall', '3,5,0,1.5,0,0');
//
// // ── ROOM ───────────────────────────────────────────────────────────────────
//
// // Create a room: "length,width,height,posX,posY,posZ"
// _unityWidgetController?.postMessage('FurnitureManager', 'CreateRoom', '5,5,3,0,0,0');
//
// // Create default 5×5×3 room at origin
// _unityWidgetController?.postMessage('FurnitureManager', 'CreateDefaultRoom', '');
//
// // ── FLOOR PLAN ─────────────────────────────────────────────────────────────
//
// // Send drawing JSON (same JSON you were sending to 'FloorPlan' before)
// final String floorPlanJson = jsonEncode(houseData);
// _unityWidgetController?.postMessage('FurnitureManager', 'ReceiveJsonData', floorPlanJson);
//
// // Clear floor plan
// _unityWidgetController?.postMessage('FurnitureManager', 'ClearDrawing', '');
//
// // ── LOAD FULL PROJECT ──────────────────────────────────────────────────────
//
// // Restore all saved objects (furniture + walls + floors)
// final String json = jsonEncode({
// 'objects': project.objects.map((obj) => {
// 'furnitureName': obj.type,
// 'category':      obj.category,   // "furniture" | "wall" | "floor"
// 'positionX': obj.position.x,
// 'positionY': obj.position.y,
// 'positionZ': obj.position.z,
// 'rotationX': obj.rotation.x,
// 'rotationY': obj.rotation.y,
// 'rotationZ': obj.rotation.z,
// 'scaleX':    obj.scale.x,
// 'scaleY':    obj.scale.y,
// 'scaleZ':    obj.scale.z,
// 'color':     obj.color,
// }).toList(),
// });
// _unityWidgetController?.postMessage('FurnitureManager', 'SpawnAllObjects', json);
//
// // ── DELETE ─────────────────────────────────────────────────────────────────
//
// // Remove currently selected object (furniture OR wall OR floor)
// _unityWidgetController?.postMessage('FurnitureManager', 'RemoveFurniture', '');
//
// // Remove ALL scene objects
// _unityWidgetController?.postMessage('FurnitureManager', 'RemoveAllFurniture', '');
//
// // Remove only walls and floors (keep furniture)
// _unityWidgetController?.postMessage('FurnitureManager', 'DeleteAllWalls', '');


 */