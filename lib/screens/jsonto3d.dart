/*

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityHomeScreen extends StatefulWidget {
  final String jsonString;

  const UnityHomeScreen({super.key, required this.jsonString});

  @override
  State<UnityHomeScreen> createState() => _UnityHomeScreenState();
}

class _UnityHomeScreenState extends State<UnityHomeScreen> {
  final GlobalKey _unityWidgetKey = GlobalKey();
  UnityWidgetController? _unityWidgetController;

  @override
  void dispose() {
    _unityWidgetController?.dispose();
    super.dispose();
  }

  void onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
    print('Unity controller initialized');
    
    // Send the JSON data as soon as Unity is ready
    _sendDataToUnity();
  }

  void _sendDataToUnity() {
    if (_unityWidgetController != null && widget.jsonString.isNotEmpty) {
      print('Sending JSON data to Unity...');
      _unityWidgetController!.postMessage(
        'FurnitureManager', // Common GameObject name for floorplan handling
        'ReceiveJsonData',  // Common method name
        widget.jsonString,
      );
    }
  }

  void onUnityMessage(dynamic message) {
    print('Received message from Unity: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity Render View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _sendDataToUnity,
            tooltip: 'Resend Data',
          ),
        ],
      ),
      body: UnityWidget(
        key: _unityWidgetKey,
        onUnityCreated: onUnityCreated,
        onUnityMessage: onUnityMessage,
        fullscreen: false,
      ),
    );
  }
}
*/