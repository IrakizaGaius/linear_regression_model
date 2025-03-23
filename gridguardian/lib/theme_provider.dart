import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'themeMode';
  static const String _systemKey = 'useSystem';
  static const String _textScaleKey = 'textScale';
  static const double _baseTextScale = 1.0;

  ThemeMode _themeMode = ThemeMode.system;
  bool _useSystemTheme = true;
  double _textScaleFactor = _baseTextScale;
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs) {
    _initializeFromPreferences();
    _watchSystemChanges();
  }

  ThemeMode get currentThemeMode => _themeMode;
  bool get usingSystemTheme => _useSystemTheme;
  double get textScaleFactor => _textScaleFactor;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  Future<void> _initializeFromPreferences() async {
    _useSystemTheme = _prefs.getBool(_systemKey) ?? true;
    _textScaleFactor = _prefs.getDouble(_textScaleKey) ?? _baseTextScale;

    if (!_useSystemTheme) {
      final savedMode = _prefs.getString(_themeKey);
      _themeMode = _parseThemeMode(savedMode);
    }
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String? mode) {
    switch (mode?.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void _watchSystemChanges() {
    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      if (_useSystemTheme) {
        _themeMode = ThemeMode.system;
        notifyListeners();
      }
    };
  }

  ThemeData get currentTheme {
    final systemDark =
        PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    return _resolveTheme(systemDark);
  }

  ThemeData _resolveTheme(bool systemDark) {
    final effectiveMode = _useSystemTheme
        ? (systemDark ? ThemeMode.dark : ThemeMode.light)
        : _themeMode;

    return effectiveMode == ThemeMode.dark ? darkTheme : lightTheme;
  }

  Future<void> updateThemeSettings({
    ThemeMode? mode,
    bool? useSystem,
    double? textScale,
  }) async {
    _themeMode = mode ?? _themeMode;
    _useSystemTheme = useSystem ?? _useSystemTheme;
    _textScaleFactor = textScale ?? _textScaleFactor;

    await Future.wait([
      _prefs.setBool(_systemKey, _useSystemTheme),
      if (!_useSystemTheme) _prefs.setString(_themeKey, _themeMode.name),
      _prefs.setDouble(_textScaleKey, _textScaleFactor),
    ]);

    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await updateThemeSettings(
      mode: ThemeMode.system,
      useSystem: true,
      textScale: _baseTextScale,
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final seedColor = brightness == Brightness.light
        ? const Color(0xFF2196F3)
        : const Color(0xFF4DB6AC);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
        surface:
            brightness == Brightness.light ? Colors.grey[50] : Colors.grey[900],
      ),
      inputDecorationTheme: _buildInputTheme(brightness),
      typography: Typography.material2021(),
      appBarTheme: AppBarTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(Brightness brightness) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      filled: true,
      fillColor:
          brightness == Brightness.light ? Colors.grey[100] : Colors.grey[800],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      floatingLabelStyle: TextStyle(
        color: brightness == Brightness.light
            ? Colors.blue[800]
            : Colors.cyan[300],
      ),
    );
  }
}
