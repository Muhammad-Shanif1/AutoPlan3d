import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_unity_widget_example/ui/services/api_service.dart';
import 'package:flutter_unity_widget_example/ui/services/camera_snapshot_service.dart';

/// Result of floorplan generation containing image and data
class FloorplanGenerationResult {
  final Uint8List imageBytes;
  final Map<String, dynamic> rawJson;
  final Size canvasSize;
  final double scale;
  final double offsetX;
  final double offsetY;

  FloorplanGenerationResult({
    required this.imageBytes,
    required this.rawJson,
    required this.canvasSize,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });
}

/// Result of CSP floorplan generation
class CspGenerationResult {
  final Uint8List imageBytes;
  final List<dynamic> layout;
  final int houseWidth;
  final int houseHeight;
  final int canvasSize;

  CspGenerationResult({
    required this.imageBytes,
    required this.layout,
    required this.houseWidth,
    required this.houseHeight,
    required this.canvasSize,
  });
}

/// Service class for handling drawing operations
class DrawingService {
  /// Save only the drawn lines with a white background to gallery
  static Future<(Uint8List, String?)> saveDrawing({
    required List drawnLines,
    required Size size,
  }) async {
    try {
      if (size.width <= 0 || size.height <= 0) {
        throw Exception('Invalid canvas dimensions');
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

      // 1. Draw white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );

      // 2. Draw lines (replicating LinePainter logic)
      for (final line in drawnLines) {
        if (line.isEmpty) continue;

        final bool isManualLine = line.length <= 2;
        final paint = Paint()
          ..color = Colors.blue
          ..strokeWidth = isManualLine ? 3.0 : 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        if (line.length >= 2) {
          final path = Path()..addPolygon(line as List<Offset>, line.length > 10);
          canvas.drawPath(path, paint);
        }
      }

      // 3. Finalize Image
      final picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      String? assetId;

      // Save to gallery using photo_manager
      bool hasPermission = await CameraSnapshotService.instance.requestGalleryPermission();
      if (hasPermission) {
        final AssetEntity? entity = await PhotoManager.editor.saveImage(
          pngBytes,
          filename: 'drawing_${DateTime.now().millisecondsSinceEpoch}.png',
          relativePath: 'Pictures/AutoPlan 3d',
        );
        if (entity != null) {
          assetId = entity.id;
        } else {
          throw Exception('Failed to save image to gallery');
        }
      } else {
        await PhotoManager.openSetting();
        throw Exception('Permission denied to save image');
      }

      return (pngBytes, assetId);
    } catch (e) {
      debugPrint("Save error: $e");
      throw Exception('Error saving image: $e');
    }
  }

  /// Check if the drawn lines form a closed boundary (no dangling ends)
  static bool isBoundaryClosed(List<List<Offset>> drawnLines) {
    if (drawnLines.isEmpty) return false;

    // Use a small epsilon for point comparison to account for floating point errors
    const double epsilon = 2.0;

    bool pointsMatch(Offset p1, Offset p2) {
      return (p1 - p2).distance < epsilon;
    }

    final List<Offset> endpoints = [];
    for (final line in drawnLines) {
      if (line.length >= 2) {
        endpoints.add(line.first);
        endpoints.add(line.last);
      }
    }

    if (endpoints.isEmpty) return false;

    // Verify that every endpoint is connected to at least one other endpoint
    for (int i = 0; i < endpoints.length; i++) {
      int matches = 0;
      for (int j = 0; j < endpoints.length; j++) {
        if (pointsMatch(endpoints[i], endpoints[j])) {
          matches++;
        }
      }
      // If an endpoint matches only itself, it's a dangling end
      if (matches < 2) return false;
    }

    return true;
  }

  /// Scale contours from image dimensions to canvas dimensions
  static List<List<Offset>> scaleContours(
    List<List<Offset>> contours,
    double imgWidth,
    double imgHeight,
    double canvasWidth,
    double canvasHeight,
  ) {
    final scaleX = canvasWidth / imgWidth;
    final scaleY = canvasHeight / imgHeight;

    return contours.map((contour) {
      return contour.map((point) {
        return Offset(
          (point.dx * scaleX).clamp(0.0, canvasWidth),
          (point.dy * scaleY).clamp(0.0, canvasHeight),
        );
      }).toList();
    }).toList();
  }

  /// Convert drawing to JSON format for Unity
  static String convertToJson(List points, GlobalKey drawingKey) {
    final List<Map<String, dynamic>> lines = [];
    List<Map<String, dynamic>> currentLine = [];

    for (var point in points) {
      if (point == Offset.zero) {
        // End of a line segment
        if (currentLine.isNotEmpty) {
          lines.add({
            'points': currentLine,
            'type': _determineLineType(currentLine),
          });
          currentLine = [];
        }
      } else {
        currentLine.add({'x': point.dx, 'y': point.dy});
      }
    }

    // Add last line if exists
    if (currentLine.isNotEmpty) {
      lines.add({
        'points': currentLine,
        'type': _determineLineType(currentLine),
      });
    }

    // Get canvas dimensions
    final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
    final size = box?.size ?? Size.zero;

    // Validate canvas dimensions
    if (size.width <= 0 || size.height <= 0) {
      throw Exception('Invalid canvas dimensions');
    }

    // Convert to Unity coordinate system (center origin, Y-up)
    final List<Map<String, dynamic>> unityLines = [];
    for (var line in lines) {
      List<Map<String, dynamic>> unityPoints = [];
      for (var point in line['points']) {
        // Convert Flutter coordinates to Unity coordinates
        // Unity: (0,0) at center, Y-up
        // Flutter: (0,0) at top-left, Y-down
        double unityX = point['x'] - (size.width / 2); // Center X
        double unityY = (size.height / 2) - point['y']; // Flip Y and center

        unityPoints.add({
          'x': double.parse(unityX.toStringAsFixed(2)),
          'y': double.parse(unityY.toStringAsFixed(2)),
          'z': 0.0, // Add Z coordinate for Unity 3D
        });
      }

      unityLines.add({'points': unityPoints, 'type': line['type']});
    }

    final jsonData = {
      'version': '1.0',
      'canvasWidth': size.width,
      'canvasHeight': size.height,
      'coordinateSystem': 'unity', // Indicate coordinate system
      'origin': 'center', // Origin at center
      'strokeWidth': 2.0,
      'strokeColor': '#0000FF',
      'totalLines': unityLines.length,
      'lines': unityLines,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return jsonEncode(jsonData);
  }

  /// Determine if line is horizontal or vertical
  static String _determineLineType(List<Map<String, dynamic>> linePoints) {
    if (linePoints.length < 2) return 'point';

    final firstPoint = linePoints.first;
    final lastPoint = linePoints.last;

    final dx = (lastPoint['x'] - firstPoint['x']).abs();
    final dy = (lastPoint['y'] - firstPoint['y']).abs();

    if (dx > dy) {
      return 'horizontal';
    } else if (dy > dx) {
      return 'vertical';
    } else {
      return 'diagonal';
    }
  }

  /// Copy JSON to clipboard and return the JSON string
  static Future exportToJson(
    List points,
    GlobalKey drawingKey,
  ) async {
    try {
      if (points.isEmpty) {
        throw Exception('Nothing to export!');
      }

      final jsonString = convertToJson(points, drawingKey);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: jsonString));

      return jsonString;
    } catch (e) {
      debugPrint("Export error: $e");
      throw Exception('Export error: $e');
    }
  }

  /// Generate floorplan from boundary using FastAPI
  static Future<FloorplanGenerationResult> generateFloorplan(List drawnLines, GlobalKey drawingKey) async {
    try {
      final box = drawingKey.currentContext?.findRenderObject() as RenderBox?;
      final size = box?.size ?? Size.zero;

      if (size.width <= 0 || size.height <= 0) {
        throw Exception('Invalid canvas dimensions');
      }

      // 1. Order segments into a contiguous polygon loop for the AI model
      final List<Offset> orderedPoints = _orderSegments(drawnLines) as List<Offset>;

      // 2. Apply Uniform Aspect Ratio Scaling with Padding Centering
      final double scale = 255.0 / (size.width > size.height ? size.width : size.height);
      final double offsetX = (255.0 - (size.width * scale)) / 2;
      final double offsetY = (255.0 - (size.height * scale)) / 2;

      final List<Map<String, int>> boundaryData = [];

      for (int i = 0; i < orderedPoints.length; i++) {
        final point = orderedPoints[i];

        // Uniform aspect ratio fit inside the 256x256 space
        final int x = ((point.dx * scale) + offsetX).round().clamp(0, 255);
        final int y = ((point.dy * scale) + offsetY).round().clamp(0, 255);

        // Avoid adding duplicate vertices consecutively in the target space
        if (boundaryData.isNotEmpty &&
            boundaryData.last['x'] == x &&
            boundaryData.last['y'] == y) {
          continue;
        }

        // Determine orientation based on local slopes and threshold parameters
        int orientation = 0; // Default to Horizontal (0)
        if (i < orderedPoints.length - 1) {
          final next = orderedPoints[i + 1];
          final double dx = (next.dx - point.dx).abs();
          final double dy = (next.dy - point.dy).abs();

          if (dy > dx * 1.5) {
            orientation = 1; // Vertical
          } else if (dx > dy * 1.5) {
            orientation = 0; // Horizontal
          } else {
            orientation = (dx > dy) ? 0 : 1;
          }
        } else if (orderedPoints.length > 1) {
          // Orient the last point towards the first node to cleanly seal the loop
          final first = orderedPoints.first;
          final double dx = (first.dx - point.dx).abs();
          final double dy = (first.dy - point.dy).abs();

          if (dy > dx * 1.5) {
            orientation = 1;
          } else if (dx > dy * 1.5) {
            orientation = 0;
          } else {
            orientation = (dx > dy) ? 0 : 1;
          }
        }

        boundaryData.add({
          'x': x,
          'y': y,
          'orientation': orientation,
          'isNew': i == 0 ? 1 : 0, // Mark loop origin
        });
      }

      final response = await ApiService.instance.post(
        '/floorplan/generate',
        body: {
          'boundary': boundaryData,
        },
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';

        if (contentType.contains('application/json')) {
          debugPrint("API Response Body: ${response.body}");
          final decoded = jsonDecode(response.body);

          // Render layout coordinates back to viewport using uniform scaling factors
          if (decoded['rooms'] != null) {
            final Uint8List imageBytes = await _renderFloorplanFromJson(decoded, size, scale, offsetX, offsetY);
            return FloorplanGenerationResult(
              imageBytes: imageBytes,
              rawJson: decoded,
              canvasSize: size,
              scale: scale,
              offsetX: offsetX,
              offsetY: offsetY,
            );
          }

          throw Exception(
            'API returned success but no layout data was found in JSON',
          );
        }

        throw Exception('API did not return JSON');
      } else {
        debugPrint("API Error Detail: ${response.body}");
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint("API error: $e");
      rethrow;
    }
  }

  /// Generate floorplan from bubble diagram using FastAPI (CSP model)
  static Future<CspGenerationResult> generateFromCsp(List<Map<String, dynamic>> roomList, int totalArea) async {
    try {
      final List<Map<String, dynamic>> roomsPayload = [];

      for (var room in roomList) {
        roomsPayload.add({
          'name': room['name'],
          'quantity': 1,
          'size_index': room['sizeIndex'] ?? 2,
          'color': room['color'],
        });
      }

      final payload = {
        'total_area': totalArea,
        'rooms': roomsPayload,
      };

      final response = await ApiService.instance.post(
        '/csp-floorplan/generate',
        body: payload,
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';

        if (contentType.contains('application/json')) {
          final decoded = jsonDecode(response.body);
          return CspGenerationResult(
            imageBytes: base64Decode(decoded['image'] ?? decoded['image_base64'] ?? ''),
            layout: decoded['layout'] ?? [],
            houseWidth: decoded['house_width'] ?? 0,
            houseHeight: decoded['house_height'] ?? 0,
            canvasSize: decoded['canvas_size'] ?? 0,
          );
        } else if (contentType.contains('image/')) {
          // Fallback for raw image bytes
          return CspGenerationResult(
            imageBytes: response.bodyBytes,
            layout: [],
            houseWidth: 0,
            houseHeight: 0,
            canvasSize: 0,
          );
        }

        // Final fallback for raw bytes without correct content-type
        if (response.bodyBytes.length > 4 && 
            response.bodyBytes[0] == 0x89 && 
            response.bodyBytes[1] == 0x50 && 
            response.bodyBytes[2] == 0x4E && 
            response.bodyBytes[3] == 0x47) {
          return CspGenerationResult(
            imageBytes: response.bodyBytes,
            layout: [],
            houseWidth: 0,
            houseHeight: 0,
            canvasSize: 0,
          );
        }

        throw Exception('API returned 200 but response format was unexpected (Content-Type: $contentType)');
      } else {
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final contentType = response.headers['content-type'] ?? '';
          if (contentType.contains('application/json')) {
            final errorData = jsonDecode(response.body);
            if (errorData['detail'] != null) {
              errorMessage = errorData['detail'];
            }
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("CSP API error: $e");
      rethrow;
    }
  }

  /// Generate floorplan from bubble diagram using FastAPI
  static Future generateFromBubbleDiagram(Map<String, dynamic> jsonData) async {
    try {
      // 1. Map room codes to HouseGAN room names (matching backend ROOM_CLASS)
      final List<int> roomTypes = List<int>.from(jsonData['room_type']);
      final List<String> roomNames = roomTypes.map((code) {
        switch (code) {
          case 1:
            return 'living_room';
          case 2:
            return 'kitchen';
          case 3:
            return 'bedroom';
          case 4:
            return 'bathroom';
          case 5:
            return 'balcony';
          case 6:
            return 'corridor'; // Entrance
          case 7:
            return 'dining_room';
          case 8:
            return 'bedroom'; // Study room -> closest match
          case 10:
            return 'closet'; // Storage -> closest match
          default:
            return 'missing';
        }
      }).toList();

      // 2. Map edges (adjacent pairs) from the 'ed_rm' field
      final List<List<int>> adjacentPairs = (jsonData['ed_rm'] as List).map((edge) => List<int>.from(edge)).toList();

      // 3. Prepare payload for /housegan/generate (matching housegan_api.py)
      final payload = {
        'rooms': roomNames,
        'adjacent_pairs': adjacentPairs,
        'num_variations': 1,
        'return_images': true,
        'return_polygons': false,
      };

      final response = await ApiService.instance.post(
        '/housegan/generate',
        body: payload,
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';

        if (contentType.contains('application/json')) {
          final decoded = jsonDecode(response.body);
          if (decoded['variations'] != null && (decoded['variations'] as List).isNotEmpty) {
            final variation = decoded['variations'][0];
            final String? base64String = variation['png_base64'];
            if (base64String != null) {
              return base64Decode(base64String);
            }
          }
          throw Exception('No generated floorplan found in the response');
        } else if (contentType.contains('image/')) {
          return response.bodyBytes;
        }

        // Check for raw PNG bytes fallback
        if (response.bodyBytes.length > 4 && 
            response.bodyBytes[0] == 0x89 && 
            response.bodyBytes[1] == 0x50 && 
            response.bodyBytes[2] == 0x4E && 
            response.bodyBytes[3] == 0x47) {
          return response.bodyBytes;
        }

        throw Exception('API returned 200 but response format was unexpected');
      } else {
        try {
          final contentType = response.headers['content-type'] ?? '';
          if (contentType.contains('application/json')) {
            final error = jsonDecode(response.body);
            throw Exception(error['detail'] ?? 'Server error: ${response.statusCode}');
          }
        } catch (e) {
          if (e is Exception) rethrow;
        }
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("HouseGAN API error: $e");
      rethrow;
    }
  }

  /// Render floorplan structural data into a PNG image using precise Inverse Uniform Aspect Scaling
  static Future _renderFloorplanFromJson(
    Map<String, dynamic> data,
    Size canvasSize,
    double scale,
    double offsetX,
    double offsetY,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
    );

    // 1. Canvas Baseline Setup
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      Paint()..color = Colors.white,
    );

    final List rooms = data['rooms'] ?? [];
    final List renderOrder = data['render_order'] ?? [];
    final List doors = data['doors'] ?? [];
    final List windows = data['windows'] ?? [];

    // --- ALIGNMENT & SNAPPING ENGINE ---
    // Collect all raw coordinates in 256x256 space to find coincidences
    final List<double> rawXs = [];
    final List<double> rawYs = [];

    for (var room in rooms) {
      final List<dynamic> box = room['box'];
      rawXs.add(box[0].toDouble());
      rawYs.add(box[1].toDouble());
      rawXs.add(box[2].toDouble());
      rawYs.add(box[3].toDouble());

      final List<dynamic>? polygon = room['polygon'];
      if (polygon != null) {
        for (var pt in polygon) {
          rawXs.add(pt[0].toDouble());
          rawYs.add(pt[1].toDouble());
        }
      }
    }

    for (var win in windows) {
      rawXs.add((win['x'] ?? 0).toDouble());
      rawYs.add((win['y'] ?? 0).toDouble());
      rawXs.add((win['width'] ?? 0).toDouble());
      rawYs.add((win['height'] ?? 0).toDouble());
    }

    for (var door in doors) {
      rawXs.add((door['x'] ?? 0).toDouble());
      rawYs.add((door['y'] ?? 0).toDouble());
      rawXs.add((door['width'] ?? 0).toDouble());
      rawYs.add((door['height'] ?? 0).toDouble());
    }

    // Increased snapping threshold in 256x256 coordinate space to eliminate gaps (approx 2.3% wall tolerance)
    const double snapThreshold = 6.0;

    // Groups coordinates within threshold and calculates clustered averages
    List<double> calculateSnappedGridLines(List<double> values) {
      if (values.isEmpty) return [];
      values.sort();
      final List<double> gridLines = [];
      double currentClusterSum = values.first;
      int currentClusterCount = 1;

      for (int i = 1; i < values.length; i++) {
        if (values[i] - values[i - 1] <= snapThreshold) {
          currentClusterSum += values[i];
          currentClusterCount++;
        } else {
          gridLines.add(currentClusterSum / currentClusterCount);
          currentClusterSum = values[i];
          currentClusterCount = 1;
        }
      }
      gridLines.add(currentClusterSum / currentClusterCount);
      return gridLines;
    }

    final List<double> snappedGridXs = calculateSnappedGridLines(rawXs);
    final List<double> snappedGridYs = calculateSnappedGridLines(rawYs);

    // Clamps coordinate to closest global snapped coordinate line, or layout borders (0.0 / 256.0)
    double getSnappedValue(double val, List<double> gridLines) {
      if (val <= snapThreshold) return 0.0;
      if (val >= 256.0 - snapThreshold) return 256.0;

      double bestGrid = val;
      double minDiff = snapThreshold;
      for (double grid in gridLines) {
        final double diff = (val - grid).abs();
        if (diff < minDiff) {
          minDiff = diff;
          bestGrid = grid;
        }
      }
      return bestGrid;
    }

    // Scale inverse helpers with snapped inputs
    double invX(num x) => (getSnappedValue(x.toDouble(), snappedGridXs) - offsetX) / scale;
    double invY(num y) => (getSnappedValue(y.toDouble(), snappedGridYs) - offsetY) / scale;
    double invLen(num l) => l.toDouble() / scale;

    final List<int> order = renderOrder.isNotEmpty ? List<int>.from(renderOrder) : List.generate(rooms.length, (i) => i);

    // Map to quickly look up room rectangles by index for layout validation
    final Map<int, Rect> roomRects = {};

    // Standard Point-in-Polygon Raycasting Verification Helper for non-convex room topologies
    bool isPointInPolygon(Offset point, List<Offset> vertices) {
      int intersectCount = 0;
      for (int i = 0; i < vertices.length; i++) {
        final double x1 = vertices[i].dx;
        final double y1 = vertices[i].dy;
        final double x2 = vertices[(i + 1) % vertices.length].dx;
        final double y2 = vertices[(i + 1) % vertices.length].dy;

        if (((y1 > point.dy) != (y2 > point.dy)) &&
            (point.dx < (x2 - x1) * (point.dy - y1) / (y2 - y1) + x1)) {
          intersectCount++;
        }
      }
      return intersectCount % 2 == 1;
    }

    // Heuristic visual center solver inside non-convex polygons
    Offset findVisualCenter(List<Offset> poly, Rect boundingBox) {
      final Offset defaultCenter = boundingBox.center;
      if (isPointInPolygon(defaultCenter, poly)) {
        return defaultCenter;
      }

      // Scan horizontal line steps inside bounding box to locate the longest segment
      double bestSegmentWidth = 0;
      Offset bestCenter = defaultCenter;

      final List<double> ySamples = [
        boundingBox.top + boundingBox.height * 0.5,
        boundingBox.top + boundingBox.height * 0.3,
        boundingBox.top + boundingBox.height * 0.7,
      ];

      for (final y in ySamples) {
        List<double> insideX = [];
        const int steps = 40;
        for (int i = 0; i <= steps; i++) {
          final double x = boundingBox.left + (boundingBox.width * i / steps);
          final testPoint = Offset(x, y);
          if (isPointInPolygon(testPoint, poly)) {
            insideX.add(x);
          } else {
            if (insideX.isNotEmpty) {
              final double segmentWidth = insideX.last - insideX.first;
              if (segmentWidth > bestSegmentWidth) {
                bestSegmentWidth = segmentWidth;
                bestCenter = Offset(insideX.first + segmentWidth / 2, y);
              }
              insideX.clear();
            }
          }
        }
        if (insideX.isNotEmpty) {
          final double segmentWidth = insideX.last - insideX.first;
          if (segmentWidth > bestSegmentWidth) {
            bestSegmentWidth = segmentWidth;
            bestCenter = Offset(insideX.first + segmentWidth / 2, y);
          }
        }
      }
      return bestCenter;
    }

    // Determine precise local room bounds around visual center along horizontal axis
    double getAvailableWidthAt(Offset center, List<Offset> poly, Rect boundingBox) {
      double leftBoundary = boundingBox.left;
      double rightBoundary = boundingBox.right;

      for (int i = 0; i < poly.length; i++) {
        final p1 = poly[i];
        final p2 = poly[(i + 1) % poly.length];

        if ((p1.dy > center.dy) != (p2.dy > center.dy)) {
          final double intersectX = p1.dx + (center.dy - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy);
          if (intersectX < center.dx && intersectX > leftBoundary) {
            leftBoundary = intersectX;
          } else if (intersectX > center.dx && intersectX < rightBoundary) {
            rightBoundary = intersectX;
          }
        }
      }
      return (rightBoundary - leftBoundary);
    }

    // 2. Draw Rooms in Z-Index Priority Order
    for (int roomIdx in order) {
      final room = rooms.firstWhere((r) => r['room_index'] == roomIdx, orElse: () => null);
      if (room == null) continue;

      final List<dynamic> box = room['box'];
      final String type = room['type_name'] ?? 'Room';
      final int typeIndex = room['type_index'] ?? -1;

      // Map back using the exact scale inverse with snapped coordinates
      final rect = Rect.fromLTRB(
        invX(box[0]),
        invY(box[1]),
        invX(box[2]),
        invY(box[3]),
      );

      // SAFETY FILTER: If the room is squashed out of physical bounds, skip rendering it and its labels
      if (rect.width <= 5 || rect.height <= 5) {
        continue;
      }

      roomRects[roomIdx] = rect;

      final List<dynamic>? polygon = room['polygon'];
      final List<Offset> polyPoints = [];
      Path? roomPath;
      if (polygon != null && polygon.isNotEmpty) {
        roomPath = Path();
        for (int i = 0; i < polygon.length; i++) {
          final pt = polygon[i];
          final double px = invX(pt[0]);
          final double py = invY(pt[1]);
          final offsetPt = Offset(px, py);

          // Avoid adding degenerate consecutive overlapping points from snapping
          if (polyPoints.isEmpty || (polyPoints.last - offsetPt).distance > 1.0) {
            polyPoints.add(offsetPt);
          }

          if (i == 0) {
            roomPath.moveTo(px, py);
          } else {
            roomPath.lineTo(px, py);
          }
        }
        roomPath.close();

        // Ensure loop is cleanly closed and doesn't duplicate the start node
        if (polyPoints.length > 2 && (polyPoints.last - polyPoints.first).distance < 1.0) {
          polyPoints.removeLast();
        }
      }

      // Streamline coordinate logic: fallback to box boundaries if no polygon is present
      if (polyPoints.isEmpty) {
        polyPoints.addAll([
          rect.topLeft,
          rect.topRight,
          rect.bottomRight,
          rect.bottomLeft,
        ]);
      }

      final roomColor = _getRoomColor(typeIndex, type).withValues(alpha: 0.4);

      if (roomPath != null) {
        // Render Polygon Boundary
        canvas.drawPath(roomPath, Paint()..color = roomColor);
        canvas.drawPath(
          roomPath,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke,
        );
      } else {
        // Render Rectangular Boundary
        canvas.drawRect(rect, Paint()..color = roomColor);
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke,
        );
      }

      // Solve visual center and available width constraint inside room polygon
      final Offset labelCenter = findVisualCenter(polyPoints, rect);
      final double localWidth = getAvailableWidthAt(labelCenter, polyPoints, rect);
      final double maxTextWidth = localWidth - 8;

      if (maxTextWidth > 10) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: type,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '..',
        )..layout(maxWidth: maxTextWidth);

        // Compute text offset centering coordinates
        final Offset textOffset = Offset(
          labelCenter.dx - tp.width / 2,
          labelCenter.dy - tp.height / 2,
        );

        // Keep label strictly clamped inside physical borders to prevent spilling
        if (textOffset.dx >= rect.left && (textOffset.dx + tp.width) <= rect.right) {
          tp.paint(canvas, textOffset);
        } else {
          final double clampedX = textOffset.dx.clamp(rect.left + 4, rect.right - tp.width - 4);
          tp.paint(canvas, Offset(clampedX, textOffset.dy));
        }
      }
    }

    // 3. Draw Windows (Aligned correctly onto the boundaries)
    final windowPaint = Paint()..color = Colors.blue.shade300..style = PaintingStyle.fill;
    for (var win in windows) {
      final int roomIndex = win['room_index'] ?? -1;
      // Skip windows attached to collapsed rooms
      if (roomIndex != -1 && !roomRects.containsKey(roomIndex)) continue;

      final double x0 = (win['x'] ?? 0).toDouble();
      final double y0 = (win['y'] ?? 0).toDouble();
      final double w_val = (win['width'] ?? 0).toDouble();
      final double h_val = (win['height'] ?? 0).toDouble();
      final double x1 = x0 + w_val;
      final double y1 = y0 + h_val;
      final int dir = win['direction'] ?? 0;

      // Extract accurate bounding box coordinates
      final double minX = x0 < x1 ? x0 : x1;
      final double maxX = x0 > x1 ? x0 : x1;
      final double minY = y0 < y1 ? y0 : y1;
      final double maxY = y0 > y1 ? y0 : y1;

      // Map coordinate bounds to physical canvas with snapping applied
      final double x = invX(minX);
      final double y = invY(minY);
      final double w = invLen(maxX - minX);
      final double h = invLen(maxY - minY);

      // Filter collapsed elements
      if (w <= 0.5 && h <= 0.5) continue;

      Rect elementRect;
      // Determine orientation based on structural wall thickness
      if (dir == 0 || w >= h) {
        // Horizontal Window: Enforce thin wall line thickness (2.5px) and scale width
        final double finalLength = w < 14.0 ? 14.0 : w;
        elementRect = Rect.fromLTWH(x - (w < 14.0 ? (14.0 - w) / 2 : 0), y - 1.25, finalLength, 2.5);
      } else {
        // Vertical Window: Enforce thin wall line thickness (2.5px) and scale height
        final double finalHeight = h < 14.0 ? 14.0 : h;
        elementRect = Rect.fromLTWH(x - 1.25, y - (h < 14.0 ? (14.0 - h) / 2 : 0), 2.5, finalHeight);
      }

      canvas.drawRect(elementRect, windowPaint);
    }

    // 4. Draw Doors (Aligned correctly onto the boundaries)
    final doorPaint = Paint()..color = Colors.orange.shade800..style = PaintingStyle.fill;
    for (var door in doors) {
      final int roomIndex = door['room_index'] ?? -1;
      // Skip doors attached to collapsed rooms
      if (roomIndex != -1 && !roomRects.containsKey(roomIndex)) continue;

      final double x0 = (door['x'] ?? 0).toDouble();
      final double y0 = (door['y'] ?? 0).toDouble();
      final double w_val = (door['width'] ?? 0).toDouble();
      final double h_val = (door['height'] ?? 0).toDouble();
      final double x1 = x0 + w_val;
      final double y1 = y0 + h_val;
      final int dir = door['direction'] ?? 0;

      // Extract accurate bounding box coordinates
      final double minX = x0 < x1 ? x0 : x1;
      final double maxX = x0 > x1 ? x0 : x1;
      final double minY = y0 < y1 ? y0 : y1;
      final double maxY = y0 > y1 ? y0 : y1;

      // Map coordinate bounds to physical canvas with snapping applied
      final double x = invX(minX);
      final double y = invY(minY);
      final double w = invLen(maxX - minX);
      final double h = invLen(maxY - minY);

      // Filter collapsed elements
      if (w <= 0.5 && h <= 0.5) continue;

      Rect elementRect;
      // Determine orientation based on structural wall thickness
      if (dir == 0 || w >= h) {
        // Horizontal Door: Enforce thin structural line segment (2.5px thickness)
        final double finalLength = w < 12.0 ? 12.0 : w;
        elementRect = Rect.fromLTWH(x - (w < 12.0 ? (12.0 - w) / 2 : 0), y - 1.25, finalLength, 2.5);
      } else {
        // Vertical Door: Enforce thin structural line segment (2.5px thickness)
        final double finalHeight = h < 12.0 ? 12.0 : h;
        elementRect = Rect.fromLTWH(x - 1.25, y - (h < 12.0 ? (12.0 - h) / 2 : 0), 2.5, finalHeight);
      }

      canvas.drawRect(elementRect, doorPaint);
    }

    // 5. Finalize Image PNG Output
    final picture = recorder.endRecording();
    final img = await picture.toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Color _getRoomColor(int typeIndex, String typeName) {
    switch (typeIndex) {
      case 0:
        return const Color(0xFFE6194B); // LivingRoom
      case 1:
        return const Color(0xFF3CB44B); // MasterRoom
      case 2:
        return const Color(0xFFAAFFC3); // Kitchen
      case 3:
        return const Color(0xFF0082C8); // Bathroom
      case 4:
        return const Color(0xFFF58230); // DiningRoom
      case 5:
        return const Color(0xFF911EB4); // ChildRoom
      case 6:
        return const Color(0xFF46F0F0); // StudyRoom
      case 7:
        return const Color(0xFFF032E6); // SecondRoom
      case 8:
        return const Color(0xFFD2F53C); // GuestRoom
      case 9:
        return const Color(0xFFFABEBE); // Balcony
      case 10:
        return const Color(0xFF008080); // Entrance
      case 11:
        return const Color(0xFFE6BEFF); // Storage
      case 12:
        return const Color(0xFFAA6E28); // Wall-in
      default:
        switch (typeName.toLowerCase().replaceAll(' ', '')) {
          case 'livingroom':
            return const Color(0xFFE6194B);
          case 'masterroom':
            return const Color(0xFF3CB44B);
          case 'kitchen':
            return const Color(0xFFAAFFC3);
          case 'bathroom':
            return const Color(0xFF0082C8);
          case 'diningroom':
            return const Color(0xFFF58230);
          case 'childroom':
            return const Color(0xFF911EB4);
          case 'studyroom':
            return const Color(0xFF46F0F0);
          case 'secondroom':
            return const Color(0xFFF032E6);
          case 'guestroom':
            return const Color(0xFFD2F53C);
          case 'balcony':
            return const Color(0xFFFABEBE);
          case 'entrance':
            return const Color(0xFF008080);
          case 'storage':
            return const Color(0xFFE6BEFF);
          case 'wall-in':
          case 'walk-in':
          case 'walk-incloset':
            return const Color(0xFFAA6E28);
          default:
            return Colors.grey;
        }
    }
  }

  /// Convert AI floorplan result to Unity-compatible JSON
  static String convertFloorplanToUnityJson(FloorplanGenerationResult result) {
    final data = result.rawJson;
    final size = result.canvasSize;
    final scale = result.scale;
    final offsetX = result.offsetX;
    final offsetY = result.offsetY;

    if (scale == 0) return jsonEncode({'error': 'Invalid scale'});

    // Inverse scaling helpers to map 256x256 back to canvas coords
    double invX(num x) => (x.toDouble() - offsetX) / scale;
    double invY(num y) => (y.toDouble() - offsetY) / scale;

    final List<Map<String, dynamic>> unityLines = [];

    final List rooms = data['rooms'] ?? [];
    for (var room in rooms) {
      final List<dynamic>? polygon = room['polygon'];
      final List<dynamic> box = room['box'] ?? [0, 0, 0, 0];
      
      // If polygon exists, use segments. Otherwise fallback to box.
      List<Offset> points = [];
      if (polygon != null && polygon.length >= 2) {
        points = polygon.map((pt) => Offset(invX(pt[0]), invY(pt[1]))).toList();
        // Close polygon
        if (points.first != points.last) {
          points.add(points.first);
        }
      } else {
        final double x0 = invX(box[0]);
        final double y0 = invY(box[1]);
        final double x1 = invX(box[2]);
        final double y1 = invY(box[3]);
        points = [
          Offset(x0, y0),
          Offset(x1, y0),
          Offset(x1, y1),
          Offset(x0, y1),
          Offset(x0, y0),
        ];
      }

      // Convert segments to Unity lines
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        // Convert Flutter coords to Unity (center-origin, Y-up)
        double uX1 = p1.dx - (size.width / 2);
        double uY1 = (size.height / 2) - p1.dy;
        double uX2 = p2.dx - (size.width / 2);
        double uY2 = (size.height / 2) - p2.dy;

        final dx = (uX2 - uX1).abs();
        final dy = (uY2 - uY1).abs();
        String type = dx > dy ? 'horizontal' : 'vertical';

        unityLines.add({
          'points': [
            {'x': double.parse(uX1.toStringAsFixed(2)), 'y': double.parse(uY1.toStringAsFixed(2)), 'z': 0.0},
            {'x': double.parse(uX2.toStringAsFixed(2)), 'y': double.parse(uY2.toStringAsFixed(2)), 'z': 0.0},
          ],
          'type': type,
          'room_name': room['type_name'] ?? 'Room',
        });
      }
    }

    // Process doors and windows as lines
    final List doors = data['doors'] ?? [];
    for (var door in doors) {
      final double fx1 = invX(door['x']);
      final double fy1 = invY(door['y']);
      final double fx2 = invX(door['x'] + (door['width'] ?? 10));
      final double fy2 = invY(door['y'] + (door['height'] ?? 10));

      double uX1 = fx1 - (size.width / 2);
      double uY1 = (size.height / 2) - fy1;
      double uX2 = fx2 - (size.width / 2);
      double uY2 = (size.height / 2) - fy2;

      unityLines.add({
        'points': [
          {'x': double.parse(uX1.toStringAsFixed(2)), 'y': double.parse(uY1.toStringAsFixed(2)), 'z': 0.0},
          {'x': double.parse(uX2.toStringAsFixed(2)), 'y': double.parse(uY2.toStringAsFixed(2)), 'z': 0.0},
        ],
        'type': (uX2 - uX1).abs() > (uY2 - uY1).abs() ? 'horizontal' : 'vertical',
        'sub_type': 'door',
      });
    }

    final List windows = data['windows'] ?? [];
    for (var win in windows) {
      final double fx1 = invX(win['x']);
      final double fy1 = invY(win['y']);
      final double fx2 = invX(win['x'] + (win['width'] ?? 15));
      final double fy2 = invY(win['y'] + (win['height'] ?? 15));

      double uX1 = fx1 - (size.width / 2);
      double uY1 = (size.height / 2) - fy1;
      double uX2 = fx2 - (size.width / 2);
      double uY2 = (size.height / 2) - fy2;

      unityLines.add({
        'points': [
          {'x': double.parse(uX1.toStringAsFixed(2)), 'y': double.parse(uY1.toStringAsFixed(2)), 'z': 0.0},
          {'x': double.parse(uX2.toStringAsFixed(2)), 'y': double.parse(uY2.toStringAsFixed(2)), 'z': 0.0},
        ],
        'type': (uX2 - uX1).abs() > (uY2 - uY1).abs() ? 'horizontal' : 'vertical',
        'sub_type': 'window',
      });
    }

    final jsonData = {
      'version': '1.0',
      'canvasWidth': size.width,
      'canvasHeight': size.height,
      'coordinateSystem': 'unity',
      'origin': 'center',
      'totalLines': unityLines.length,
      'lines': unityLines,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return jsonEncode(jsonData);
  }

  /// Convert Bubble Diagram CSP result to Unity-compatible JSON (Walls only)
  static String convertCspToUnityJson(CspGenerationResult result) {
    final List<Map<String, dynamic>> unityLines = [];
    final canvasSize = result.canvasSize.toDouble();
    final layout = result.layout;

    for (var room in layout) {
      final List<dynamic> bbox = room['bbox']; // [x1, y1, x2, y2]
      final double x1 = bbox[0].toDouble();
      final double y1 = bbox[1].toDouble();
      final double x2 = bbox[2].toDouble();
      final double y2 = bbox[3].toDouble();

      // Create a rectangle for each room
      final List<Offset> rectPoints = [
        Offset(x1, y1),
        Offset(x2, y1),
        Offset(x2, y2),
        Offset(x1, y2),
        Offset(x1, y1),
      ];

      // Convert rectangle to 4 lines for Unity
      for (int i = 0; i < rectPoints.length - 1; i++) {
        final p1 = rectPoints[i];
        final p2 = rectPoints[i + 1];

        // Convert coordinates to Unity (center-origin, Y-up)
        double uX1 = p1.dx - (canvasSize / 2);
        double uY1 = (canvasSize / 2) - p1.dy;
        double uX2 = p2.dx - (canvasSize / 2);
        double uY2 = (canvasSize / 2) - p2.dy;

        unityLines.add({
          'points': [
            {'x': double.parse(uX1.toStringAsFixed(2)), 'y': double.parse(uY1.toStringAsFixed(2)), 'z': 0.0},
            {'x': double.parse(uX2.toStringAsFixed(2)), 'y': double.parse(uY2.toStringAsFixed(2)), 'z': 0.0},
          ],
          'type': (uX1 == uX2) ? 'vertical' : 'horizontal',
          'room_name': room['name'] ?? 'Room',
        });
      }
    }

    final jsonData = {
      'version': '1.0',
      'canvasWidth': canvasSize,
      'canvasHeight': canvasSize,
      'coordinateSystem': 'unity',
      'origin': 'center',
      'totalLines': unityLines.length,
      'lines': unityLines,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return jsonEncode(jsonData);
  }

  /// Helper to order separate segments into a contiguous path
  static List _orderSegments(List segments) {
    if (segments.isEmpty) return [];

    // Working copy
    final List<List<Offset>> remaining = segments.map((s) => List<Offset>.from(s)).toList();
    final List<Offset> ordered = [];

    // Start with the first segment
    var current = remaining.removeAt(0);
    ordered.addAll(current);

    const double epsilon = 5.0; // Tolerance for endpoint snapping

    while (remaining.isNotEmpty) {
      final lastPoint = ordered.last;
      bool found = false;

      for (int i = 0; i < remaining.length; i++) {
        final seg = remaining[i];

        // Try matching with start of segment
        if ((lastPoint - seg.first).distance < epsilon) {
          ordered.addAll(seg.skip(1));
          remaining.removeAt(i);
          found = true;
          break;
        }
        // Try matching with end of segment (and reverse it)
        else if ((lastPoint - seg.last).distance < epsilon) {
          ordered.addAll(seg.reversed.skip(1));
          remaining.removeAt(i);
          found = true;
          break;
        }
      }

      if (!found) {
        // Fallback for gaps
        var next = remaining.removeAt(0);
        ordered.addAll(next);
      }
    }

    return ordered;
  }
}
