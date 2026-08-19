import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:photo_manager/photo_manager.dart';

class CameraSnapshot {
  final String filePath;
  final DateTime capturedAt;
  bool isFavorite;
  String? galleryAssetId;

  CameraSnapshot({
    required this.filePath,
    required this.capturedAt,
    this.isFavorite = false,
    this.galleryAssetId,
  });

  Map<String, dynamic> toMap() => {
    'filePath':    filePath,
    'capturedAt':  capturedAt.toIso8601String(),
    'isFavorite':  isFavorite,
    'galleryAssetId': galleryAssetId,
  };

  factory CameraSnapshot.fromMap(Map<String, dynamic> map) => CameraSnapshot(
    filePath:   map['filePath']   as String,
    capturedAt: DateTime.parse(map['capturedAt'] as String),
    isFavorite: map['isFavorite'] as bool? ?? false,
    galleryAssetId: map['galleryAssetId'] as String?,
  );
}

class CameraSnapshotService {
  CameraSnapshotService._();
  static final CameraSnapshotService instance = CameraSnapshotService._();

  static const String _key = 'camera_snapshots';
  static const String _deletedKey = 'deleted_camera_snapshots';

  final List<CameraSnapshot> _snapshots = [];
  final Set<String> _deletedAssetIds = {};
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      await _load();
      _initialized = true;
    }
    await syncWithLocalFolder();
    await syncWithGallery();
  }

  List<CameraSnapshot> get snapshots => List.unmodifiable(_snapshots);
  List<CameraSnapshot> get favorites  =>
      _snapshots.where((s) => s.isFavorite).toList();

  Future<void> syncWithLocalFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final snapshotsDir = Directory('${directory.path}/snapshots');
      if (await snapshotsDir.exists()) {
        final files = snapshotsDir.listSync().whereType<File>().toList();
        bool changed = false;
        for (var file in files) {
          if (!_snapshots.any((s) => s.filePath == file.path)) {
            _snapshots.add(CameraSnapshot(
              filePath: file.path,
              capturedAt: file.lastModifiedSync(),
            ));
            changed = true;
          }
        }
        if (changed) await _save();
      }
    } catch (e) {
      print('❌ Error syncing with local folder: $e');
    }
  }

  Future<void> syncWithGallery() async {
    try {
      final hasPermission = await requestGalleryPermission();
      if (!hasPermission) return;

      final directory = await getApplicationDocumentsDirectory();
      final snapshotsDir = Directory('${directory.path}/snapshots');
      if (!await snapshotsDir.exists()) await snapshotsDir.create(recursive: true);

      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      AssetPathEntity? autoPlanAlbum;
      for (var album in albums) {
        if (album.name == 'AutoPlan 3d') {
          autoPlanAlbum = album;
          break;
        }
      }

      if (autoPlanAlbum != null) {
        final assets = await autoPlanAlbum.getAssetListRange(start: 0, end: 100);
        bool changed = false;

        for (var asset in assets) {
          // If the user previously deleted this image from the app, don't re-sync it
          if (_deletedAssetIds.contains(asset.id)) continue;

          final index = _snapshots.indexWhere((s) => s.galleryAssetId == asset.id);
          
          bool needsLocalization = false;
          if (index != -1) {
            final snap = _snapshots[index];
            if (!snap.filePath.startsWith(directory.path) || !File(snap.filePath).existsSync()) {
              needsLocalization = true;
            }
          } else {
            needsLocalization = true;
          }

          if (needsLocalization) {
            final file = await asset.file;
            if (file != null) {
              final localPath = '${snapshotsDir.path}/gallery_${asset.id}.png';
              final localFile = File(localPath);
              
              if (!await localFile.exists() || (await localFile.length() != await file.length())) {
                await file.copy(localPath);
              }

              if (index != -1) {
                _snapshots[index] = CameraSnapshot(
                  filePath: localPath,
                  capturedAt: asset.createDateTime,
                  isFavorite: _snapshots[index].isFavorite,
                  galleryAssetId: asset.id,
                );
              } else {
                _snapshots.add(CameraSnapshot(
                  filePath: localPath,
                  capturedAt: asset.createDateTime,
                  galleryAssetId: asset.id,
                ));
              }
              changed = true;
            }
          }
        }
        if (changed) await _save();
      }
    } catch (e) {
      print('❌ Error syncing with gallery: $e');
    }
  }

  // ── Handle Unity message ──────────────────────────────────────────────────
  Future<void> toggleFavoriteByPath(String filePath) async {
    final index = _snapshots.indexWhere((s) => s.filePath == filePath);
    if (index == -1) return;
    _snapshots[index].isFavorite = !_snapshots[index].isFavorite;
    await _save();
  }

  Future<void> deleteByPath(String filePath) async {
    try {
      final index = _snapshots.indexWhere((s) => s.filePath == filePath);
      if (index != -1) {
        final snap = _snapshots[index];
        
        // Track that this gallery ID was deleted so we don't sync it back
        if (snap.galleryAssetId != null) {
          _deletedAssetIds.add(snap.galleryAssetId!);
        }

        // 1. Delete from app storage
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          print('🗑️ File deleted from storage: $filePath');
        }
        
        _snapshots.removeAt(index);
        await _save();
      }
    } catch (e) {
      print('❌ Error in deleteByPath: $e');
    }
  }

  Future<CameraSnapshot?> handleUnityMessage(String rawMessage) async {
    if (!rawMessage.startsWith('CAMERA_SNAPSHOT:')) return null;

    try {
      final filePath = rawMessage.substring('CAMERA_SNAPSHOT:'.length).trim();

      final snapshot = CameraSnapshot(
        filePath:   filePath,
        capturedAt: DateTime.now(),
      );

      _snapshots.add(snapshot);
      await _save();

      print('📸 Snapshot stored: $filePath');
      return snapshot;
    } catch (e) {
      print('❌ CameraSnapshotService error: $e');
      return null;
    }
  }

  Future<CameraSnapshot?> saveImageToAppGallery(Uint8List bytes, String fileName, {String? galleryAssetId}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final snapshotsDir = Directory('${directory.path}/snapshots');
      if (!await snapshotsDir.exists()) {
        await snapshotsDir.create(recursive: true);
      }

      final filePath = '${snapshotsDir.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final snapshot = CameraSnapshot(
        filePath: filePath,
        capturedAt: DateTime.now(),
        galleryAssetId: galleryAssetId,
      );

      _snapshots.add(snapshot);
      await _save();
      
      return snapshot;
    } catch (e) {
      print('❌ Error saving to app gallery: $e');
      return null;
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(int index) async {
    if (index < 0 || index >= _snapshots.length) return;
    _snapshots[index].isFavorite = !_snapshots[index].isFavorite;
    await _save();
  }

  Future<void> deleteSnapshot(int index) async {
    if (index < 0 || index >= _snapshots.length) return;
    final snap = _snapshots[index];
    await deleteByPath(snap.filePath);
  }

  Future<void> clearAll() async {
    final paths = _snapshots.map((s) => s.filePath).toList();
    for (var path in paths) {
      await deleteByPath(path);
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<bool> requestGalleryPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonSnapshots = jsonEncode(_snapshots.map((s) => s.toMap()).toList());
    await prefs.setString(_key, jsonSnapshots);
    
    final jsonDeleted = jsonEncode(_deletedAssetIds.toList());
    await prefs.setString(_deletedKey, jsonDeleted);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    
    final jsonSnapshots = prefs.getString(_key);
    if (jsonSnapshots != null) {
      try {
        final list = jsonDecode(jsonSnapshots) as List<dynamic>;
        _snapshots.clear();
        _snapshots.addAll(
          list.map((e) => CameraSnapshot.fromMap(e as Map<String, dynamic>)),
        );
      } catch (e) {
        print('⚠️ Could not load snapshots: $e');
      }
    }

    final jsonDeleted = prefs.getString(_deletedKey);
    if (jsonDeleted != null) {
      try {
        final list = jsonDecode(jsonDeleted) as List<dynamic>;
        _deletedAssetIds.clear();
        _deletedAssetIds.addAll(List<String>.from(list));
      } catch (e) {
        print('⚠️ Could not load deleted asset IDs: $e');
      }
    }
  }
}
