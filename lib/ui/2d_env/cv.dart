import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

class CV2screen extends StatefulWidget {
  const CV2screen({super.key, required this.selectedImage});
  final File? selectedImage;

  @override
  State<CV2screen> createState() => _CV2screenState();
}

class _CV2screenState extends State<CV2screen> {
  cv.Mat? image;
  bool isLoading = false;
  String? errorMessage;
  List<List<Offset>>? contourPoints;

  @override
  void initState() {
    super.initState();
    if (widget.selectedImage != null) {
      processImage();
    }
  }

  @override
  void dispose() {
    image?.dispose();
    super.dispose();
  }

  Future<void> processImage() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    await Future.delayed(Duration.zero);
    cv.Mat? matOriginal;
    cv.Mat? nonNullMat;
    cv.Mat? thresh;
    cv.Mat? output;
    cv.VecVecPoint? contours;

    try {
      matOriginal = cv.imread(widget.selectedImage!.path, flags: cv.IMREAD_GRAYSCALE);
      if (matOriginal.isEmpty) throw Exception('Failed to load image');

      // 1. Downscale for standardized processing sizes
      final double targetWidth = 1000;
      final double scale = targetWidth / matOriginal.cols;
      final int targetHeight = (matOriginal.rows * scale).round();
      nonNullMat = cv.resize(matOriginal, (targetWidth.toInt(), targetHeight));
      matOriginal.dispose();

      // 2. Smooth out paper texture
      cv.gaussianBlur(nonNullMat, (5, 5), 0, dst: nonNullMat);

      // 3. Adaptive Thresholding
      thresh = cv.adaptiveThreshold(
          nonNullMat,
          255,
          cv.ADAPTIVE_THRESH_GAUSSIAN_C,
          cv.THRESH_BINARY_INV,
          41,
          5
      );

      // 4. Morphological Closing to weld ink lines together solidly
      final closeKernel = cv.getStructuringElement(cv.MORPH_RECT, (7, 7));
      cv.dilate(thresh, closeKernel, dst: thresh);
      cv.erode(thresh, closeKernel, dst: thresh);
      closeKernel.dispose();

      // 5. Find ALL Contours (CRITICAL CHANGE HERE)
      // RETR_LIST extracts both the outer boundary and all inner room loops
      final (contoursVec, hierarchy) = cv.findContours(
        thresh,
        cv.RETR_LIST, // Changed from cv.RETR_EXTERNAL
        cv.CHAIN_APPROX_SIMPLE,
      );

      // 6. Filter & Poly Approximation
      final contoursList = <List<cv.Point>>[];
      final double borderThresholdW = nonNullMat.cols * 0.98;
      final double borderThresholdH = nonNullMat.rows * 0.98;

      for (int i = 0; i < contoursVec.length; i++) {
        final contour = contoursVec[i];
        final rect = cv.boundingRect(contour);

        // Skip the border frame of the image itself
        if (rect.width >= borderThresholdW && rect.height >= borderThresholdH) continue;

        // Filter out tiny stray artifacts or specs of dust
        if (cv.contourArea(contour) < 150) continue;

        if (contour.length > 2) {
          // Keep closed loop generation true for floor plan layout cells
          final approximated = cv.approxPolyDP(contour, 2.0, true);
          contoursList.add(approximated.toList());
          approximated.dispose();
        }
      }

      contours = cv.VecVecPoint.fromList(contoursList);

      // 7. Render clean vector output
      output = cv.Mat.zeros(nonNullMat.rows, nonNullMat.cols, cv.MatType.CV_8UC3);
      output.setTo(cv.Scalar.white);

      cv.drawContours(
        output,
        contours,
        -1,
        cv.Scalar.blue,
        thickness: 3,
        lineType: cv.LINE_AA,
      );

      final List<List<Offset>> convertedContours = [];
      for (int i = 0; i < contours.length; i++) {
        final contour = contours[i];
        final points = contour.map((pt) => Offset(pt.x.toDouble(), pt.y.toDouble())).toList();
        convertedContours.add(points);
      }

      setState(() {
        image?.dispose();
        image = output;
        contourPoints = convertedContours;
        isLoading = false;
      });

      contours.dispose();
      contoursVec.dispose();
      hierarchy.dispose();
      thresh.dispose();
      nonNullMat.dispose();

    } catch (e, stackTrace) {
      debugPrint('Error: $e\n$stackTrace');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      output?.dispose();
      thresh?.dispose();
      nonNullMat?.dispose();
      contours?.dispose();
      matOriginal?.dispose();
    }
  }

  // Future<void> processImage() async {
  //   setState(() {
  //     isLoading = true;
  //     errorMessage = null;
  //   });
  //
  //   await Future.delayed(Duration.zero);
  //
  //   cv.Mat? mat;
  //   cv.Mat? thresh;
  //   cv.Mat? output;
  //   cv.VecVecPoint? contours;
  //
  //   try {
  //     mat = cv.imread(widget.selectedImage!.path, flags: cv.IMREAD_GRAYSCALE);
  //     if (mat.isEmpty) {
  //       throw Exception('Failed to load image');
  //     }
  //
  //     final nonNullMat = mat;
  //
  //     // 1. Noise Reduction
  //     // Use Median Blur to remove small dots while preserving line edges
  //     cv.medianBlur(nonNullMat, 3, dst: nonNullMat);
  //
  //     // 2. Adaptive Thresholding
  //     // Better than Otsu for sketches on paper (handles uneven lighting)
  //     thresh = cv.adaptiveThreshold(
  //       nonNullMat,
  //       255,
  //       cv.ADAPTIVE_THRESH_GAUSSIAN_C,
  //       cv.THRESH_BINARY_INV,
  //       11,
  //       2
  //     );
  //
  //     // 3. Close Gaps
  //     // Thicken lines slightly before skeletonization to ensure they are connected
  //     final kernel = cv.getStructuringElement(cv.MORPH_RECT, (3, 3));
  //     cv.dilate(thresh, kernel, dst: thresh);
  //     kernel.dispose();
  //
  //     // 4. Manual Skeletonization
  //     cv.Mat skel = cv.Mat.zeros(thresh.rows, thresh.cols, cv.MatType.CV_8UC1);
  //     cv.Mat temp = cv.Mat.zeros(thresh.rows, thresh.cols, cv.MatType.CV_8UC1);
  //     cv.Mat eroded = cv.Mat.zeros(thresh.rows, thresh.cols, cv.MatType.CV_8UC1);
  //     final element = cv.getStructuringElement(cv.MORPH_CROSS, (3, 3));
  //
  //     cv.Mat currentThresh = thresh.clone();
  //     bool done = false;
  //     int iterations = 0;
  //
  //     while (!done && iterations < 100) {
  //       cv.erode(currentThresh, element, dst: eroded);
  //       cv.dilate(eroded, element, dst: temp);
  //       cv.subtract(currentThresh, temp, dst: temp);
  //       cv.bitwiseOR(skel, temp, dst: skel);
  //       eroded.copyTo(currentThresh);
  //
  //       if (cv.countNonZero(currentThresh) == 0) {
  //         done = true;
  //       }
  //       iterations++;
  //     }
  //
  //     currentThresh.dispose();
  //     eroded.dispose();
  //     temp.dispose();
  //     element.dispose();
  //     thresh.dispose();
  //     thresh = skel;
  //
  //     // 5. Find contours - Using RETR_EXTERNAL to get only the outer boundary
  //     // and avoid "double" contours from thick lines.
  //     final (contoursVec, hierarchy) = cv.findContours(
  //       thresh,
  //       cv.RETR_EXTERNAL,
  //       cv.CHAIN_APPROX_SIMPLE,
  //     );
  //
  //     // 6. Refined Approximation & Filtering
  //     final contoursList = <List<cv.Point>>[];
  //     final double borderThresholdW = nonNullMat.cols * 0.98;
  //     final double borderThresholdH = nonNullMat.rows * 0.98;
  //
  //     for (int i = 0; i < contoursVec.length; i++) {
  //       final contour = contoursVec[i];
  //
  //       // Skip the contour if it's the outermost boundary (the frame)
  //       final rect = cv.boundingRect(contour);
  //       if (rect.width >= borderThresholdW && rect.height >= borderThresholdH) {
  //         continue;
  //       }
  //
  //       if (contour.length > 2) {
  //         final approximated = cv.approxPolyDP(contour, 1.0, false);
  //         contoursList.add(approximated.toList());
  //         approximated.dispose();
  //       }
  //     }
  //
  //     contours = cv.VecVecPoint.fromList(contoursList);
  //
  //     // Create output image
  //     output = cv.Mat.zeros(nonNullMat.rows, nonNullMat.cols, cv.MatType.CV_8UC3);
  //     output.setTo(cv.Scalar.white);
  //
  //     // Draw contours
  //     cv.drawContours(
  //       output,
  //       contours,
  //       -1,
  //       cv.Scalar.blue,
  //       thickness: 2,
  //       lineType: cv.LINE_8,
  //     );
  //
  //     // Convert contours for Flutter UI
  //     final List<List<Offset>> convertedContours = [];
  //     for (int i = 0; i < contours.length; i++) {
  //       final contour = contours[i];
  //       final points = contour.map((pt) => Offset(pt.x.toDouble(), pt.y.toDouble())).toList();
  //       convertedContours.add(points);
  //     }
  //
  //     setState(() {
  //       image?.dispose();
  //       image = output;
  //       contourPoints = convertedContours;
  //       isLoading = false;
  //     });
  //
  //     // Cleanup
  //     output = null; // Stored in state
  //     contours.dispose();
  //     contoursVec.dispose();
  //     hierarchy.dispose();
  //     thresh.dispose();
  //     mat.dispose();
  //
  //   } catch (e, stackTrace) {
  //     debugPrint('Error in contour detection: $e');
  //     debugPrint('Stack trace: $stackTrace');
  //
  //     setState(() {
  //       errorMessage = e.toString();
  //       isLoading = false;
  //     });
  //
  //     output?.dispose();
  //     thresh?.dispose();
  //     mat?.dispose();
  //     contours?.dispose();
  //   }
  // }

  Uint8List? matToBytes(cv.Mat? mat) {
    if (mat == null) return null;
    final (success, bytes) = cv.imencode('.png', mat);
    return success ? bytes : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCV Image Processing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              if (contourPoints != null && image != null) {
                Navigator.pop(context, {
                  'contours': contourPoints,
                  'width': image!.cols,
                  'height': image!.rows,
                });
              } else {
                Navigator.pop(context, null);
              }
            },
            icon: const Icon(Icons.check),
            tooltip: 'Use these contours',
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing image...'),
                ],
              )
            : errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error processing image:'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: processImage,
                    child: const Text('Retry'),
                  ),
                ],
              )
            : image != null
            ? Image.memory(matToBytes(image)!)
            : const Text('No image loaded'),
      ),
    );
  }
}
