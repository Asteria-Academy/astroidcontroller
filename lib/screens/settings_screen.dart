// lib/screens/settings_screen.dart
import 'package:astroidcontroller/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/preferences_service.dart';
import '../l10n/app_localizations.dart';
import '../app.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService.instance;
  bool _hapticEnabled = true;
  String _selectedLanguage = 'en';
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  double _bgmVolume = 0.4;
  double _sfxVolume = 1.0;

  @override
  void initState() {
    super.initState();
    SoundService.instance.ensurePlaying();
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _hapticEnabled = _prefs.isHapticFeedbackEnabled();
      _selectedLanguage = _prefs.getLanguage();
      _bgmEnabled = _prefs.isMusicEnabled();
      _sfxEnabled = _prefs.isSfxEnabled();
      _bgmVolume = _prefs.getMusicVolume();
      _sfxVolume = _prefs.getSfxVolume();
    });
  }

  void _toggleHaptic(bool value) {
    SoundService.instance.playClick();
    if (_hapticEnabled) HapticFeedback.selectionClick();
    setState(() {
      _hapticEnabled = value;
    });
    _prefs.setHapticFeedback(value);
  }

  Future<void> _toggleBgm(bool value) async {
    SoundService.instance.playClick();
    if (_hapticEnabled) HapticFeedback.selectionClick();
    setState(() {
      _bgmEnabled = value;
    });
    await _prefs.setMusicEnabled(value);
    await SoundService.instance.setBgmEnabled(value);
    if (value) {
      await SoundService.instance.setBgmVolume(_bgmVolume);
    }
  }

  Future<void> _toggleSfx(bool value) async {
    SoundService.instance.playClick();
    if (_hapticEnabled) HapticFeedback.selectionClick();
    setState(() {
      _sfxEnabled = value;
    });
    await _prefs.setSfxEnabled(value);
    await SoundService.instance.setSfxEnabled(value);
    if (value) {
      await SoundService.instance.setSfxVolume(_sfxVolume);
      await SoundService.instance.playClick();
    }
  }

  Future<void> _onBgmVolumeChanged(double value) async {
    setState(() {
      _bgmVolume = value;
    });
    await _prefs.setMusicVolume(value);
    await SoundService.instance.setBgmVolume(value);
  }

  Future<void> _onSfxVolumeChanged(double value, {bool preview = false}) async {
    setState(() {
      _sfxVolume = value;
    });
    await _prefs.setSfxVolume(value);
    await SoundService.instance.setSfxVolume(value);
    if (preview && _sfxEnabled && value > 0) {
      await SoundService.instance.playClick();
    }
  }

  void _changeLanguage(String? languageCode) async {
    if (languageCode == null) return;
    SoundService.instance.playClick();
    if (_hapticEnabled) HapticFeedback.selectionClick();

    await _prefs.setLanguage(languageCode);

    setState(() {
      _selectedLanguage = languageCode;
    });

    if (mounted) {
      MyApp.setLocale(context, Locale(languageCode));
    }
  }

  void _showTutorial() async {
    SoundService.instance.playClick();
    if (_hapticEnabled) HapticFeedback.mediumImpact();

    final prefs = PreferencesService.instance;
    await prefs.setShowcaseShown(false);

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.tutorial,
      (Route<dynamic> route) => false,
    );
  }

  void _showAbout() {
    SoundService.instance.playClick();
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
                  SoundService.instance.playClick();
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

                        _buildSoundControl(
                          icon: Icons.music_note,
                          title: AppLocalizations.of(context)!.bgm,
                          subtitle: AppLocalizations.of(context)!.bgmDesc,
                          enabled: _bgmEnabled,
                          volume: _bgmVolume,
                          onToggle: _toggleBgm,
                          onVolumeChanged:
                              _bgmEnabled ? _onBgmVolumeChanged : null,
                        ),

                        const SizedBox(height: 16),

                        _buildSoundControl(
                          icon: Icons.graphic_eq,
                          title: AppLocalizations.of(context)!.sfx,
                          subtitle: AppLocalizations.of(context)!.sfxDesc,
                          enabled: _sfxEnabled,
                          volume: _sfxVolume,
                          onToggle: _toggleSfx,
                          onVolumeChanged:
                              _sfxEnabled ? _onSfxVolumeChanged : null,
                          onVolumeChangeEnd: _sfxEnabled
                              ? (value) =>
                                  _onSfxVolumeChanged(value, preview: true)
                              : null,
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
                            activeColor: Colors.deepPurpleAccent,
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

  Widget _buildSoundControl({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required double volume,
    required ValueChanged<bool> onToggle,
    ValueChanged<double>? onVolumeChanged,
    ValueChanged<double>? onVolumeChangeEnd,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(26, 0, 0, 0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(51, 255, 255, 255)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: Colors.deepPurpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.volume,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(volume * 100).round()}%',
                style: const TextStyle(
                  color: Color.fromARGB(179, 255, 255, 255),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: volume.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              onChanged: onVolumeChanged,
              onChangeEnd: onVolumeChangeEnd,
              activeColor: Colors.deepPurpleAccent,
              inactiveColor: Colors.white24,
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
