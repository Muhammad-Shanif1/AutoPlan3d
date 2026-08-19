import 'package:flutter/material.dart';
import '../painters.dart';
import 'drawing_controls.dart';

class DrawingCanvas extends StatelessWidget {
  final GlobalKey drawingKey;
  final TransformationController transformationController;
  final List<List<Offset>> drawnLines;
  final List<Offset> currentLine;
  final double currentScale;
  final int? selectedLineIndex;
  final int? draggedLineIndex;
  final int? draggedPointIndex;
  final double minScale;
  final double maxScale;
  
  final GestureTapDownCallback? onTapDown;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureTapDownCallback? onDoubleTapDown;
  final Function(ScaleUpdateDetails)? onInteractionUpdate;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const DrawingCanvas({
    super.key,
    required this.drawingKey,
    required this.transformationController,
    required this.drawnLines,
    required this.currentLine,
    required this.currentScale,
    this.selectedLineIndex,
    this.draggedLineIndex,
    this.draggedPointIndex,
    required this.minScale,
    required this.maxScale,
    this.onTapDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onDoubleTapDown,
    this.onInteractionUpdate,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: transformationController,
              minScale: minScale,
              maxScale: maxScale,
              panEnabled: false,
              onInteractionUpdate: onInteractionUpdate,
              child: Container(
                key: drawingKey,
                color: Colors.transparent,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: onTapDown,
                  onPanStart: onPanStart,
                  onPanUpdate: onPanUpdate,
                  onPanEnd: onPanEnd,
                  onDoubleTapDown: onDoubleTapDown,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: GridPainter(
                          spacing: 40,
                          color: isDarkMode
                              ? Colors.white30
                              : Colors.blueGrey.shade200.withOpacity(0.4),
                        ),
                      ),
                      CustomPaint(
                        size: Size.infinite,
                        painter: LinePainter(
                          [
                            ...drawnLines,
                            if (currentLine.isNotEmpty) currentLine,
                          ],
                          scale: currentScale,
                          selectedLineIndex: selectedLineIndex,
                          draggedLineIndex: draggedLineIndex,
                          draggedPointIndex: draggedPointIndex,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  ZoomButton(
                    onTap: onZoomIn,
                    icon: Icons.add_rounded,
                    enabled: currentScale < 1.0,
                  ),
                  const SizedBox(height: 8),
                  ZoomButton(
                    onTap: onZoomOut,
                    icon: Icons.remove_rounded,
                    enabled: currentScale > minScale,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
