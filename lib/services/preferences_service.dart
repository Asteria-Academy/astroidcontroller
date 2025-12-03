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
  // Clear All
  // ============================
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
