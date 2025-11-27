// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/preferences_service.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService.instance;
  bool _hapticEnabled = true;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _hapticEnabled = _prefs.isHapticFeedbackEnabled();
      _selectedLanguage = _prefs.getLanguage();
    });
  }

  void _toggleHaptic(bool value) {
    if (_hapticEnabled) HapticFeedback.selectionClick();
    setState(() {
      _hapticEnabled = value;
    });
    _prefs.setHapticFeedback(value);
  }

  void _changeLanguage(String? languageCode) async {
    if (languageCode == null) return;
    if (_hapticEnabled) HapticFeedback.selectionClick();

    // Save the language preference
    await _prefs.setLanguage(languageCode);

    // Update state to reflect new language immediately
    setState(() {
      _selectedLanguage = languageCode;
    });

    // Restart the app to apply language changes
    if (mounted) {
      RestartWidget.restartApp(context);
    }
  }

  void _showTutorial() {
    if (_hapticEnabled) HapticFeedback.mediumImpact();
    // Return 'true' to signal HomeScreen to restart the tutorial
    Navigator.pop(context, true);
  }

  void _showAbout() {
    if (_hapticEnabled) HapticFeedback.lightImpact();
    showAboutDialog(
      context: context,
      applicationName: AppLocalizations.of(context)!.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(
        'assets/brand/mascotnobg.png',
        width: 64,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.gamepad,
            size: 64,
            color: Colors.deepPurpleAccent,
          );
        },
      ),
      applicationLegalese: AppLocalizations.of(context)!.copyright,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            AppLocalizations.of(context)!.aboutDescription,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width * 0.6;
    final panelHeight = size.height * 0.75;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1433),
      body: Stack(
        children: [
          // Background (galaxy)
          Positioned.fill(
            child: Image.asset(
              'assets/splash/bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0B1433), Color(0xFF1C1C1E)],
                    ),
                  ),
                );
              },
            ),
          ),

          // Close button (top-right)
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(128, 0, 0, 0),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 116, 225),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(39, 255, 9, 202),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () {
                  if (_prefs.isHapticFeedbackEnabled()) 
                  {
                    HapticFeedback.lightImpact();
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // Settings panel with glow (matching home screen style)
          Center(
            child: Container(
              width: panelWidth,
              height: panelHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(200, 135, 11, 108),
                    Color.fromARGB(230, 136, 8, 108),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 116, 225),
                  width: 4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(39, 255, 9, 202),
                    blurRadius: 12,
                    spreadRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.settings_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.settingsTitle,
                          style: GoogleFonts.titanOne(
                            fontSize: 18,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(128, 255, 255, 255),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Settings items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      children: [
                        // Language Selection
                        _buildSettingRow(
                          icon: Icons.language,
                          title: AppLocalizations.of(context)!.language,
                          subtitle: AppLocalizations.of(context)!.languageDesc,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(51, 124, 77, 255),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              underline: const SizedBox(),
                              dropdownColor: const Color.fromARGB(
                                230,
                                30,
                                20,
                                50,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: 'id',
                                  child: Text('Bahasa Indonesia'),
                                ),
                              ],
                              onChanged: _changeLanguage,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Show Tutorial Button
                        _buildSettingRow(
                          icon: Icons.lightbulb_outline,
                          title: AppLocalizations.of(context)!.showTutorial,
                          subtitle: AppLocalizations.of(
                            context,
                          )!.showTutorialDesc,
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onTap: _showTutorial,
                        ),

                        const SizedBox(height: 16),

                        // Haptic Feedback Toggle
                        _buildSettingRow(
                          icon: Icons.vibration,
                          title: AppLocalizations.of(context)!.hapticFeedback,
                          subtitle: AppLocalizations.of(
                            context,
                          )!.hapticFeedbackDesc,
                          trailing: Switch(
                            value: _hapticEnabled,
                            onChanged: _toggleHaptic,
                            activeThumbColor: Colors.deepPurpleAccent,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // About Button
                        _buildSettingRow(
                          icon: Icons.info_outline,
                          title: AppLocalizations.of(context)!.aboutLicenses,
                          subtitle: AppLocalizations.of(
                            context,
                          )!.aboutLicensesDesc,
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onTap: _showAbout,
                        ),
                      ],
                    ),
                  ),

                  // Version footer
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppLocalizations.of(context)!.versionLabel('1.0.0'),
                      style: const TextStyle(
                        color: Color.fromARGB(128, 255, 255, 255),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(26, 0, 0, 0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromARGB(51, 255, 255, 255)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(51, 124, 77, 255),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.deepPurpleAccent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color.fromARGB(179, 255, 255, 255),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
