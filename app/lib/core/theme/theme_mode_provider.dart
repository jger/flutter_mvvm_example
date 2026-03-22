import 'package:flutter/material.dart' show Brightness, ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_mode_provider.g.dart';

const String _prefsKeyThemeMode = 'theme_mode';

/// Persists and exposes the app [ThemeMode] via SharedPreferences.
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    Future<void>.microtask(_load);
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKeyThemeMode);
    if (raw == null) {
      return;
    }
    final ThemeMode? loaded = _decode(raw);
    if (loaded != null) {
      state = loaded;
    }
  }

  /// Sets [mode] and persists it for the next launch.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyThemeMode, _encode(mode));
  }

  /// Toggles light/dark; when [ThemeMode.system], uses [platformBrightness] to pick the opposite.
  Future<void> toggle(Brightness platformBrightness) async {
    final ThemeMode next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system =>
        platformBrightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark,
    };
    await setMode(next);
  }
}

String _encode(ThemeMode mode) => mode.name;

ThemeMode? _decode(String raw) {
  for (final ThemeMode m in ThemeMode.values) {
    if (m.name == raw) {
      return m;
    }
  }
  return null;
}
