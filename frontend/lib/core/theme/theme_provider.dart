import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MdpThemeMode { system, light, dark }

final themeModeProvider = NotifierProvider<ThemeModeNotifier, MdpThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<MdpThemeMode> {
  @override
  MdpThemeMode build() {
    return MdpThemeMode.system;
  }

  void setTheme(MdpThemeMode mode) {
    state = mode;
  }

  void toggle(Brightness brightness) {
    if (state == MdpThemeMode.system) {
      state = brightness == Brightness.dark
          ? MdpThemeMode.light
          : MdpThemeMode.dark;
    } else if (state == MdpThemeMode.light) {
      state = MdpThemeMode.dark;
    } else {
      state = MdpThemeMode.system;
    }
  }
}

extension MdpThemeModeExtension on MdpThemeMode {
  ThemeMode get flutterMode {
    switch (this) {
      case MdpThemeMode.system:
        return ThemeMode.system;
      case MdpThemeMode.light:
        return ThemeMode.light;
      case MdpThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
