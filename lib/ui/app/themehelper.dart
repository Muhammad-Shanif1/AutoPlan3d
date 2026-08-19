import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeHelper {
  static Color getSurfaceColor(BuildContext context) {
    return Get.isDarkMode ? const Color(0xFF111827) : Colors.white;
  }

  static Color get scaffoldBackgroundColor {
    return Get.isDarkMode ? const Color(0xFF111827) : Colors.white;
  }

  static Color get bottomAppBarColor {
    return Get.isDarkMode ? const Color(0xFF1F2937) : Colors.grey.shade100;
  }

  static Color get cardColor {
    return Get.isDarkMode ? const Color(0xFF1F2937) : Colors.white;
  }

  // Text colors
  static Color get textPrimaryColor {
    return Get.isDarkMode ? Colors.white : Colors.black87;
  }

  static Color get textSecondaryColor {
    return Get.isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  }

  static Color get textHintColor {
    return Get.isDarkMode ? Colors.grey[500]! : Colors.grey[400]!;
  }

  // Icon colors
  static Color get iconActiveColor {
    return Colors.blueAccent.shade400;
  }

  static Color get iconInactiveColor {
    return Get.isDarkMode ? Colors.grey[600]! : Colors.black12;
  }

  // Border colors
  static Color get borderColor {
    return Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
  }

  // Divider color
  static Color get dividerColor {
    return Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
  }

  // Shadow color
  static Color get shadowColor {
    return Get.isDarkMode ? Colors.black54 : Colors.black26;
  }

  // Status bar brightness
  static Brightness get statusBarBrightness {
    return Get.isDarkMode ? Brightness.light : Brightness.dark;
  }

  static Brightness get statusBarIconBrightness {
    return Get.isDarkMode ? Brightness.light : Brightness.dark;
  }
}