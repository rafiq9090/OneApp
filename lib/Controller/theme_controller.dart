import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> mode = ThemeMode.system.obs;

  void setMode(ThemeMode newMode) {
    mode.value = newMode;
  }

  void toggleDarkLight() {
    if (mode.value == ThemeMode.dark) {
      mode.value = ThemeMode.light;
    } else {
      mode.value = ThemeMode.dark;
    }
  }
}
