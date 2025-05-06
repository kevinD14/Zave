import 'package:flutter/material.dart';
import 'package:myapp/utils/theme/themes.dart';

class ThemeController extends ValueNotifier<AppThemeOption> {
  ThemeController(super.initial);

  void setTheme(AppThemeOption t) {
    value = t;
  }
}
