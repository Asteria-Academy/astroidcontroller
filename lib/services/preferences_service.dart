// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static PreferencesService? _instance;
  SharedPreferences? _prefs;

  static const String _keyShowcaseShown = 'showcase_shown';
  static const String _keyShowcaseDisconnectedShown = 'showcase_disconnected_shown';
  static const String _keyShowcaseConnectedShown = 'showcase_connected_shown';
  static const String _keyHapticFeedback = 'haptic_feedback_enabled';
  static const String _keyLanguage = 'app_language';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keyMusicVolume = 'music_volume';
  static const String _keySfxEnabled = 'sfx_enabled';
  static const String _keySfxVolume = 'sfx_volume';

  PreferencesService._();

  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============================
  // Showcase / Tutorial
  // ============================
  bool hasShownShowcase() {
    return _prefs?.getBool(_keyShowcaseShown) ?? false;
  }

  Future<bool> setShowcaseShown(bool shown) async {
    return await _prefs?.setBool(_keyShowcaseShown, shown) ?? false;
  }

  bool hasShownDisconnectedShowcase() {
    return _prefs?.getBool(_keyShowcaseDisconnectedShown) ?? false;
  }

  Future<bool> setDisconnectedShowcaseShown(bool shown) async {
    return await _prefs?.setBool(_keyShowcaseDisconnectedShown, shown) ?? false;
  }

  bool hasShownConnectedShowcase() {
    return _prefs?.getBool(_keyShowcaseConnectedShown) ?? false;
  }

  Future<bool> setConnectedShowcaseShown(bool shown) async {
    return await _prefs?.setBool(_keyShowcaseConnectedShown, shown) ?? false;
  }

  // ============================
  // Haptic Feedback
  // ============================
  bool isHapticFeedbackEnabled() {
    return _prefs?.getBool(_keyHapticFeedback) ?? true;
  }

  Future<bool> setHapticFeedback(bool enabled) async {
    return await _prefs?.setBool(_keyHapticFeedback, enabled) ?? false;
  }

  // ============================
  // Language
  // ============================

  String? getSavedLanguage() {
    return _prefs?.getString(_keyLanguage);
  }

  String getLanguage() {
    return _prefs?.getString(_keyLanguage) ?? 'en';
  }

  Future<bool> setLanguage(String languageCode) async {
    return await _prefs?.setString(_keyLanguage, languageCode) ?? false;
  }

  // ============================
  // Sound
  // ============================
  bool isMusicEnabled() {
    return _prefs?.getBool(_keyMusicEnabled) ?? true;
  }

  Future<bool> setMusicEnabled(bool enabled) async {
    return await _prefs?.setBool(_keyMusicEnabled, enabled) ?? false;
  }

  double getMusicVolume() {
    return _prefs?.getDouble(_keyMusicVolume) ?? 0.4;
  }

  Future<bool> setMusicVolume(double volume) async {
    return await _prefs?.setDouble(_keyMusicVolume, volume) ?? false;
  }

  bool isSfxEnabled() {
    return _prefs?.getBool(_keySfxEnabled) ?? true;
  }

  Future<bool> setSfxEnabled(bool enabled) async {
    return await _prefs?.setBool(_keySfxEnabled, enabled) ?? false;
  }

  double getSfxVolume() {
    return _prefs?.getDouble(_keySfxVolume) ?? 1.0;
  }

  Future<bool> setSfxVolume(double volume) async {
    return await _prefs?.setDouble(_keySfxVolume, volume) ?? false;
  }

  // ============================
  // Clear All
  // ============================
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
