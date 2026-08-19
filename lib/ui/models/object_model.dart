import 'dart:convert';

/// Represents a single 3D object placed inside a project scene.
class SceneObject {
  final String id;
  String name;
  String category; // ← "furniture" | "wall" | "drawing"

  // Transform
  ObjectPosition position;
  ObjectRotation rotation;
  ObjectScale scale;

  // Appearance
  String color; // hex e.g. "#FF5733"
  String type;  // e.g. "Chair_01", "Wall_1", "Floor_abc"

  // Metadata
  final DateTime createdAt;
  DateTime lastModified;

  SceneObject({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    ObjectPosition? position,
    ObjectRotation? rotation,
    ObjectScale? scale,
    this.color = '#FFFFFF',
    DateTime? createdAt,
    DateTime? lastModified,
  })  : position = position ?? ObjectPosition(),
        rotation = rotation ?? ObjectRotation(),
        scale = scale ?? ObjectScale(),
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  // ── Serialization ────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'category': category,
    'position': position.toMap(),
    'rotation': rotation.toMap(),
    'scale': scale.toMap(),
    'color': color,
    'createdAt': createdAt.toIso8601String(),
    'lastModified': lastModified.toIso8601String(),
  };

  factory SceneObject.fromMap(Map<String, dynamic> map) => SceneObject(
    id: map['id'] as String,
    name: map['name'] as String,
    type: map['type'] as String,
    category: map['category'] as String? ?? 'furniture',
    position: ObjectPosition.fromMap(map['position'] as Map<String, dynamic>),
    rotation: ObjectRotation.fromMap(map['rotation'] as Map<String, dynamic>),
    scale: ObjectScale.fromMap(map['scale'] as Map<String, dynamic>),
    color: map['color'] as String? ?? '#FFFFFF',
    createdAt: DateTime.parse(map['createdAt'] as String),
    lastModified: DateTime.parse(map['lastModified'] as String),
  );

  String toJson() => jsonEncode(toMap());
  factory SceneObject.fromJson(String source) =>
      SceneObject.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Returns a deep copy of this object with a new id.
  SceneObject duplicate() => SceneObject(
    id: _generateId(),
    name: '$name (Copy)',
    type: type,
    category: category,
    position: ObjectPosition(
        x: position.x + 0.5, y: position.y, z: position.z + 0.5),
    rotation: ObjectRotation(x: rotation.x, y: rotation.y, z: rotation.z),
    scale: ObjectScale(x: scale.x, y: scale.y, z: scale.z),
    color: color,
  );

  static String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  @override
  String toString() => 'SceneObject(id: $id, name: $name, type: $type)';
}

// ── Sub-models ────────────────────────────────────────────────────────────────

class ObjectPosition {
  double x, y, z;
  ObjectPosition({this.x = 0, this.y = 0, this.z = 0});

  Map<String, dynamic> toMap() => {'x': x, 'y': y, 'z': z};
  factory ObjectPosition.fromMap(Map<String, dynamic> m) =>
      ObjectPosition(
          x: (m['x'] as num?)?.toDouble() ?? 0,
          y: (m['y'] as num?)?.toDouble() ?? 0,
          z: (m['z'] as num?)?.toDouble() ?? 0);

  @override
  String toString() => '($x, $y, $z)';
}

class ObjectRotation {
  double x, y, z;
  ObjectRotation({this.x = 0, this.y = 0, this.z = 0});

  Map<String, dynamic> toMap() => {'x': x, 'y': y, 'z': z};
  factory ObjectRotation.fromMap(Map<String, dynamic> m) =>
      ObjectRotation(
          x: (m['x'] as num?)?.toDouble() ?? 0,
          y: (m['y'] as num?)?.toDouble() ?? 0,
          z: (m['z'] as num?)?.toDouble() ?? 0);

  @override
  String toString() => '($x°, $y°, $z°)';
}

class ObjectScale {
  double x, y, z;
  ObjectScale({this.x = 1, this.y = 1, this.z = 1});

  Map<String, dynamic> toMap() => {'x': x, 'y': y, 'z': z};
  factory ObjectScale.fromMap(Map<String, dynamic> m) =>
      ObjectScale(
          x: (m['x'] as num?)?.toDouble() ?? 1,
          y: (m['y'] as num?)?.toDouble() ?? 1,
          z: (m['z'] as num?)?.toDouble() ?? 1);

  @override
  String toString() => '($x, $y, $z)';
}