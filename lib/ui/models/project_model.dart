import 'dart:convert';
import 'object_model.dart';

class Project {
  final String id;
  int? cloudId;
  String name;
  String description;
  String? _visibility;
  String get visibility => _visibility ?? 'Private';
  set visibility(String value) => _visibility = value;

  final DateTime createdAt;
  DateTime lastModified;

  // Thumbnail or preview color (stored as hex)
  String previewColor;
  String? projectImage;

  /// All 3D objects placed inside this project's scene.
  List<SceneObject> objects;


  Project({
    required this.id,
    this.cloudId,
    required this.name,
    this.description = '',
    String visibility = 'Private',
    this.previewColor = '#4A90D9',
    this.projectImage,
    List<SceneObject>? objects,
    DateTime? createdAt,
    DateTime? lastModified,
  })  : _visibility = visibility,
        objects = objects ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  // ── Convenience getters ───────────────────────────────────────────────────

  int get objectCount => objects.length;

  /// Finds an object by its id. Returns null if not found.
  SceneObject? findObject(String objectId) {
    try {
      return objects.firstWhere((o) => o.id == objectId);
    } catch (_) {
      return null;
    }
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id': id,
    'cloud_id': cloudId,
    'name': name,
    'description': description,
    'visibility': visibility,
    'previewColor': previewColor,
    'projectImage': projectImage,
    'createdAt': createdAt.toIso8601String(),
    'lastModified': lastModified.toIso8601String(),
    'objects': objects.map((o) => o.toMap()).toList(),
  };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
    id:   map['id'] as String,
    cloudId: map['cloud_id'] as int?,
    name: map['name'] as String,
    description: map['description'] as String? ?? '',
    visibility: map['visibility'] as String? ?? 'Private',
    previewColor: map['previewColor'] as String? ?? '#4A90D9',
    projectImage: map['projectImage'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    lastModified: DateTime.parse(map['lastModified'] as String),
    objects: (map['objects'] as List<dynamic>?)
        ?.map((o) => SceneObject.fromMap(o as Map<String, dynamic>))
        .toList() ??
        [],
  );

  String toJson() => jsonEncode(toMap());
  factory Project.fromJson(String source) =>
      Project.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Returns a full deep copy with a new id and modified name.
  Project duplicate() => Project(
    id: _generateId(),
    name: '$name (Copy)',
    description: description,
    visibility: visibility,
    previewColor: previewColor,
    projectImage: projectImage,
    objects: objects.map((o) => o.duplicate()).toList(),
  );

  static String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  @override
  String toString() =>
      'Project(id: $id, name: $name, objects: ${objects.length})';
}