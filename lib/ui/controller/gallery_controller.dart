import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';

import '../services/camera_snapshot_service.dart';

class GalleryController extends GetxController {
  final RxInt selectedTab = 0.obs;
  final RxBool currentdesign = true.obs;
  final RxList<CameraSnapshot> snapshots = <CameraSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSnapshots();

    // Refresh when navigating to Gallery tab
    try {
      if (Get.isRegistered<MenubarControlller>()) {
        final menuController = Get.find<MenubarControlller>();
        ever(menuController.currentIndex, (int index) {
          if (index == 2) { // Index 2 is the Gallery tab in MenuScreen1
            loadSnapshots();
          }
        });
      }
    } catch (e) {
      print("Could not register menu listener: $e");
    }
  }
  // In gallery_controller.dart add:
  List<CameraSnapshot> get allSnapshots =>
      CameraSnapshotService.instance.snapshots.toList();

  List<CameraSnapshot> _sorted(List<CameraSnapshot> list) {
    final sorted = List<CameraSnapshot>.from(list);
    sorted.sort((a, b) => b.capturedAt.compareTo(a.capturedAt)); // newest first
    return sorted;
  }
  Future<void> toggleFavorite(String filePath) async {
    await CameraSnapshotService.instance.toggleFavoriteByPath(filePath);
    snapshots.value = _sorted(CameraSnapshotService.instance.snapshots.toList());
  }

  Future<void> deleteSnapshot(String filePath) async {
    await CameraSnapshotService.instance.deleteByPath(filePath);
    snapshots.value = _sorted(CameraSnapshotService.instance.snapshots.toList());
  }
  Future<void> loadSnapshots() async {
    await CameraSnapshotService.instance.init();
    snapshots.value = _sorted(CameraSnapshotService.instance.snapshots.toList());
  }

  Future<void> onNewSnapshot(String rawMessage) async {
    final snap = await CameraSnapshotService.instance.handleUnityMessage(rawMessage);
    if (snap != null) {
      snapshots.value = _sorted(CameraSnapshotService.instance.snapshots.toList());
    }
  }
  // Future<void> loadSnapshots() async {
  //   await CameraSnapshotService.instance.init();
  //   snapshots.value = CameraSnapshotService.instance.snapshots.toList();
  // }

  List<CameraSnapshot> get favorites =>
      snapshots.where((s) => s.isFavorite).toList();

  void changeTab(int index) => selectedTab.value = index;

  // Future<void> toggleFavorite(int index) async {
  //   await CameraSnapshotService.instance.toggleFavorite(index);
  //   snapshots.value = CameraSnapshotService.instance.snapshots.toList();
  // }
  //
  // Future<void> deleteSnapshot(int index) async {
  //   await CameraSnapshotService.instance.deleteSnapshot(index);
  //   snapshots.value = CameraSnapshotService.instance.snapshots.toList();
  // }
  //
  // Future<void> onNewSnapshot(String rawMessage) async {
  //   final snap = await CameraSnapshotService.instance.handleUnityMessage(rawMessage);
  //   if (snap != null) {
  //     snapshots.value = CameraSnapshotService.instance.snapshots.toList();
  //   }
  // }

  bool fileExists(String path) => File(path).existsSync();

  String formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}