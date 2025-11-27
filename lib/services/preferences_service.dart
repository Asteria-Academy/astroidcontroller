// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app preferences and persistent storage
class PreferencesService {
  static PreferencesService? _instance;
  SharedPreferences? _prefs;

  // Preference keys
  static const String _keyShowcaseShown = 'showcase_shown';
  static const String _keyShowcaseDisconnectedShown =
      'showcase_disconnected_shown';
  static const String _keyShowcaseConnectedShown = 'showcase_connected_shown';
  static const String _keyHapticFeedback = 'haptic_feedback_enabled';
  static const String _keyLanguage = 'app_language';

  PreferencesService._();

  /// Singleton instance getter
  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  /// Initialize the service (call this in main.dart)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============================
  // Showcase / Tutorial
  // ============================

  /// Check if the showcase has been shown before
  bool hasShownShowcase() {
    return _prefs?.getBool(_keyShowcaseShown) ?? false;
  }

  /// Mark the showcase as shown
  Future<bool> setShowcaseShown(bool shown) async {
    return await _prefs?.setBool(_keyShowcaseShown, shown) ?? false;
  }

  /// Check if the disconnected state showcase has been shown
  bool hasShownDisconnectedShowcase() {
    return _prefs?.getBool(_keyShowcaseDisconnectedShown) ?? false;
  }

  /// Mark the disconnected showcase as shown
  Future<bool> setDisconnectedShowcaseShown(bool shown) async {
    return await _prefs?.setBool(_keyShowcaseDisconnectedShown, shown) ?? false;
  }

  /// Check if the connected state showcase has been shown
  bool hasShownConnectedShowcase() {
    return _prefs?.getBool(_keyShowcaseConnectedShown) ?? false;
  }

  /// Mark the connected showcase as shown
  Future<bool> setConnectedShowcaseShown(bool shown) async {
    return await _prefs?.setBool(_keyShowcaseConnectedShown, shown) ?? false;
  }

  // ============================
  // Haptic Feedback
  // ============================

  /// Check if haptic feedback is enabled (default: true)
  bool isHapticFeedbackEnabled() {
    return _prefs?.getBool(_keyHapticFeedback) ?? true;
  }

  /// Set haptic feedback preference
  Future<bool> setHapticFeedback(bool enabled) async {
    return await _prefs?.setBool(_keyHapticFeedback, enabled) ?? false;
  }

  // ============================
  // Language
  // ============================

  /// Get the saved language code
  /// Returns saved preference, or null if not set (to allow system locale detection)
  String? getSavedLanguage() {
    return _prefs?.getString(_keyLanguage);
  }

  /// Get the language code with fallback to English
  /// This is kept for backward compatibility
  String getLanguage() {
    return _prefs?.getString(_keyLanguage) ?? 'en';
  }

  /// Set the language preference
  Future<bool> setLanguage(String languageCode) async {
    return await _prefs?.setString(_keyLanguage, languageCode) ?? false;
  }

  // ============================
  // Clear All
  // ============================

  /// Clear all preferences (useful for debugging)
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
