import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return const Locale('fr');
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggle() {
    state = state.languageCode == 'fr'
        ? const Locale('en')
        : const Locale('fr');
  }
}
