import 'dart:convert';

import 'package:flutter_unity_widget_example/ui/services/project_services.dart';

import '../models/object_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SceneSyncService
//
// Parses the "SCENE_OBJECTS:{...}" message sent by Unity's SceneStateReporter
// and syncs the result into the active project via ProjectService.
// ─────────────────────────────────────────────────────────────────────────────

class SceneSyncService {
  SceneSyncService._();
  static final SceneSyncService instance = SceneSyncService._();

  final _projectService = ProjectService.instance;

  // ── Parse & Sync ──────────────────────────────────────────────────────────

  /// Call this from your onUnityMessage handler.
  ///
  /// Returns the number of objects synced, or -1 on error.
  ///
  /// ```dart
  /// void _onUnityMessage(message) {
  ///   final msg = message.toString();
  ///   if (msg.startsWith('SCENE_OBJECTS:')) {
  ///     SceneSyncService.instance.handleUnityMessage(msg, currentProjectId);
  ///   }
  /// }
  /// ```
  Future<int> handleUnityMessage(
      String rawMessage,
      String projectId, {
        void Function(List<SceneObject> objects)? onSuccess,
        void Function(String error)? onError,
      }) async {
    try {
      // ── Strip prefix ───────────────────────────────────────────────────────
      if (!rawMessage.startsWith('SCENE_OBJECTS:')) {
        onError?.call('Not a SCENE_OBJECTS message');
        return -1;
      }

      final jsonString = rawMessage.substring('SCENE_OBJECTS:'.length);

      // ── Parse JSON ─────────────────────────────────────────────────────────
      final Map<String, dynamic> report =
      jsonDecode(jsonString) as Map<String, dynamic>;

      final rawObjects = report['objects'] as List<dynamic>? ?? [];
      final List<SceneObject> parsedObjects =
      rawObjects.map((raw) => _parseSceneObject(raw as Map<String, dynamic>)).toList();

      // ── Update project ─────────────────────────────────────────────────────
      await _syncToProject(projectId, parsedObjects);

      onSuccess?.call(parsedObjects);
      return parsedObjects.length;
    } catch (e) {
      final error = 'SceneSyncService error: $e';
      print('❌ $error');
      onError?.call(error);
      return -1;
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  /// Replaces the project's object list with the objects coming from Unity.
  /// Existing objects with the same [id] are updated in-place (preserving
  /// any Flutter-side metadata). New objects are added. Objects no longer
  /// in the Unity scene are removed.
  Future<void> _syncToProject(
      String projectId, List<SceneObject> incoming) async {
    final project = _projectService.getProject(projectId);
    if (project == null) {
      print('⚠️ SceneSyncService: project $projectId not found');
      return;
    }

    // Build a quick lookup of existing objects by id
    final Map<String, SceneObject> existing = {
      for (final o in project.objects) o.id: o
    };

    // Build the new list — update matching, add new
    final List<SceneObject> updated = incoming.map((inObj) {
      final current = existing[inObj.id];
      if (current != null) {
        // Update mutable fields only — preserve createdAt
        current.name     = inObj.name;
        current.category=inObj.category;
        current.position = inObj.position;
        current.rotation = inObj.rotation;
        current.scale    = inObj.scale;
        current.color    = inObj.color;
        current.lastModified = DateTime.now();
        return current;
      }
      return inObj; // brand-new object from Unity
    }).toList();

    // Replace the full list and persist
    project.objects
      ..clear()
      ..addAll(updated);
    project.lastModified = DateTime.now();

    // Persist via the service (uses internal _persistProject)
    await _projectService.syncObjectsFromUnity(projectId, updated);

    print('✅ Synced ${updated.length} object(s) into project $projectId');
  }

  /// Converts a raw JSON map (from Unity's SceneObjectData) into a [SceneObject].
  SceneObject _parseSceneObject(Map<String, dynamic> map) {
    return SceneObject(
      id:   map['id']   as String? ?? _generateId(),
      name: map['name'] as String? ?? 'Unknown',
      type: map['type'] as String? ?? 'Unknown',
      category: map["category"] as String? ?? "furniture",
      color: map['color'] as String? ?? '#FFFFFF',
      position: ObjectPosition(
        x: (map['positionX'] as num?)?.toDouble() ?? 0,
        y: (map['positionY'] as num?)?.toDouble() ?? 0,
        z: (map['positionZ'] as num?)?.toDouble() ?? 0,
      ),
      rotation: ObjectRotation(
        x: (map['rotationX'] as num?)?.toDouble() ?? 0,
        y: (map['rotationY'] as num?)?.toDouble() ?? 0,
        z: (map['rotationZ'] as num?)?.toDouble() ?? 0,
      ),
      scale: ObjectScale(
        x: (map['scaleX'] as num?)?.toDouble() ?? 1,
        y: (map['scaleY'] as num?)?.toDouble() ?? 1,
        z: (map['scaleZ'] as num?)?.toDouble() ?? 1,
      ),
    );
  }

  static String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}