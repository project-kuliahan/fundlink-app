import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('id'),
  });

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );
}

class AppSettingsCubit extends Cubit<AppSettings> {
  static const _keyTheme = 'theme_mode';
  static const _keyLocale = 'locale';

  AppSettingsCubit() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_keyTheme) == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
    final locale = Locale(prefs.getString(_keyLocale) ?? 'id');
    emit(state.copyWith(themeMode: theme, locale: locale));
  }

  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, isDark ? 'dark' : 'light');
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }
}
