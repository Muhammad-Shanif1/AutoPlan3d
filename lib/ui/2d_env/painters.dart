import 'package:flutter/material.dart';

/// Painter for simple drawing points
class DrawPainter extends CustomPainter {
  final List<Offset> points;

  DrawPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool isNewPath = true;

    for (var point in points) {
      if (point == Offset.zero) {
        isNewPath = true;
      } else {
        if (isNewPath) {
          path.moveTo(point.dx, point.dy);
          isNewPath = false;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawPainter oldDelegate) =>
      oldDelegate.points != points;
}

/// Painter for a technical grid background
class GridPainter extends CustomPainter {
  final double spacing;
  final Color color;

  GridPainter({this.spacing = 20.0, this.color = const Color(0xFFEEEEEE)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    for (double i = 0; i <= size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for technical lines with selection and drag handles
class LinePainter extends CustomPainter {
  final List<List<Offset>> lines;
  final double scale;
  final int? selectedLineIndex;
  final int? draggedLineIndex;
  final int? draggedPointIndex;

  LinePainter(
      this.lines, {
        this.scale = 1.0,
        this.selectedLineIndex,
        this.draggedLineIndex,
        this.draggedPointIndex,
      });

  /// Static mathematical utility to snap a coordinate point perfectly
  /// horizontal or vertical relative to an anchor point.
  static Offset snapPoint(Offset draggedPoint, Offset anchorPoint, double scale) {
    final double dx = (draggedPoint.dx - anchorPoint.dx).abs();
    final double dy = (draggedPoint.dy - anchorPoint.dy).abs();

    // Snapping window size (independent of layout scale layers)
    final double snapThreshold = 22.0 / scale;

    if (dy < snapThreshold) {
      // Perfectly lock to the horizontal axis of the anchor point
      return Offset(draggedPoint.dx, anchorPoint.dy);
    } else if (dx < snapThreshold) {
      // Perfectly lock to the vertical axis of the anchor point
      return Offset(anchorPoint.dx, draggedPoint.dy);
    }
    return draggedPoint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final draggedNodePaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;

      final bool isManualLine = line.length <= 2;
      final paint = Paint()
        ..color = Colors.blue
        ..strokeWidth = (isManualLine ? 3.0 : 1.5) / scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (line.length >= 2) {
        // Create a separate container for points so adjustments do not overwrite source arrays
        List<Offset> pointsToDraw = line;

        // Apply smooth horizontal/vertical alignment constraint on the active node
        if (isManualLine && i == draggedLineIndex && draggedPointIndex != null) {
          pointsToDraw = List<Offset>.from(line);
          int anchorIndex = draggedPointIndex == 0 ? 1 : 0;

          if (anchorIndex < pointsToDraw.length) {
            pointsToDraw[draggedPointIndex!] = snapPoint(
              pointsToDraw[draggedPointIndex!],
              pointsToDraw[anchorIndex],
              scale,
            );
          }
        }

        final path = Path()..addPolygon(pointsToDraw, pointsToDraw.length > 10);
        canvas.drawPath(path, paint);

        // Draw nodes at endpoints for 2-point lines (manual technical lines)
        if (isManualLine && (i == selectedLineIndex || i == draggedLineIndex)) {
          final bool isFirstDragged = draggedLineIndex == i && draggedPointIndex == 0;
          final bool isLastDragged = draggedLineIndex == i && draggedPointIndex == 1;

          final double handleSize = 10.0 / scale;
          canvas.drawCircle(pointsToDraw.first, handleSize, isFirstDragged ? draggedNodePaint : nodePaint);
          canvas.drawCircle(pointsToDraw.last, handleSize, isLastDragged ? draggedNodePaint : nodePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.selectedLineIndex != selectedLineIndex ||
        oldDelegate.draggedLineIndex != draggedLineIndex ||
        oldDelegate.draggedPointIndex != draggedPointIndex ||
        oldDelegate.scale != scale;
  }
}