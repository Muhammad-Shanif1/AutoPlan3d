import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbars {
  static void success({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
    );
  }

  static void error({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
    );
  }

  static void warning({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
    );
  }

  static void info({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.blueAccent.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
    );
  }

  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    Icon? icon,
    SnackPosition? snackPosition,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: colorText,
      icon: icon,
      snackPosition: snackPosition ?? SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
    );
  }
}
