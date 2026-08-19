import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ✅ FIXED ThemeService
class ThemeService extends GetxService {
  final RxBool isDarkMode = false.obs;
  late final _SystemThemeObserver _observer; // store reference

  @override
  void onInit() {
    super.onInit();
    _observer = _SystemThemeObserver(this); // save instance
    WidgetsBinding.instance.addObserver(_observer);
    _updateThemeFromSystem();

    ever(isDarkMode, (_) {
      print("Theme changed to: ${isDarkMode.value ? 'DARK' : 'LIGHT'}");
    });
  }

  void _updateThemeFromSystem() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode.value = brightness == Brightness.dark;
  }

  void toggleTheme() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(_observer); // ✅ same instance
    super.onClose();
  }
}
class _SystemThemeObserver extends WidgetsBindingObserver {
  final ThemeService service;

  _SystemThemeObserver(this.service);

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    print("System brightness changed!");
    service._updateThemeFromSystem();
  }
}