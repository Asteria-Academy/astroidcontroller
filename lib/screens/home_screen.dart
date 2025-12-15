// lib/screens/home_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';
import '../services/bluetooth_service.dart';
import '../l10n/app_localizations.dart';
import '../services/sound_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BluetoothService _btService = BluetoothService.instance;

  @override
  void initState() {
    super.initState();
    SoundService.instance.ensurePlaying();
    _btService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _btService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openSettings() async {
    SoundService.instance.playClick();
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1433),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;

          // Skala responsif (only for the main panel now)
          final isConnected = _btService.isConnected;
          final deviceName =
              _btService.connectedDevice?.platformName ?? "Unknown";
          final panelH = math.min(h * 0.56, 460.0);
          final panelMaxWidth = math.min(w * 0.78, 500.0);
          final panelMinWidthBase = math.min(w * 0.55, 200.0);
          final panelW = isConnected
              ? panelMaxWidth
              : math.min(panelMaxWidth, math.max(panelMinWidthBase, 320.0));
          final ctaH = math.min(h * 0.10, 64.0);
          final ctaCount = isConnected ? 2 : 1;
          final horizontalPadding = panelH * 0.08 * 2;
          final availableCTAWidth = math.max(panelW - horizontalPadding, 0.0);
          final rawSpacing = ctaCount > 1 ? availableCTAWidth * 0.03 : 0.0;
          final ctaSpacing = ctaCount > 1
              ? math.min(math.max(rawSpacing, 12.0), availableCTAWidth * 0.3)
              : 0.0;
          final totalSpacing = (ctaCount - 1) * ctaSpacing;
          final ctaBaseWidth = ctaCount > 0
              ? math.max(availableCTAWidth - totalSpacing, 0.0) / ctaCount
              : 0.0;
          final ctaW = math.min(ctaBaseWidth, 200.0);

          debugPrint('choosed ctaSpacing: $ctaSpacing');
          return Stack(
            children: [
              // 1) Galaxy background
              Positioned.fill(
                child: Image.asset('assets/splash/bg.png', fit: BoxFit.cover),
              ),

              // 2) Panel tengah (galaxy card) - Now centered
              Align(
                alignment: Alignment.center,
                child: _GalaxyPanel(
                  width: panelW,
                  height: panelH,
                  ctaWidth: ctaW,
                  ctaHeight: ctaH,
                  ctaSpacing: ctaSpacing,
                  isConnected: isConnected,
                  deviceName: deviceName,
                  onConnectTap: () {
                    Navigator.pushNamed(context, AppRoutes.connect);
                  },
                  onRemoteTap: () {
                    Navigator.pushNamed(context, AppRoutes.remoteControl);
                  },
                ),
              ),

              // 3) Settings button (top-right)
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
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _openSettings,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GalaxyPanel extends StatelessWidget {
  const _GalaxyPanel({
    required this.width,
    required this.height,
    required this.ctaWidth,
    required this.ctaHeight,
    required this.ctaSpacing,
    required this.isConnected,
    required this.deviceName,
    required this.onConnectTap,
    required this.onRemoteTap,
  });

  final double width;
  final double height;
  final double ctaWidth;
  final double ctaHeight;
  final double ctaSpacing;
  final bool isConnected;
  final String deviceName;
  final VoidCallback onConnectTap;
  final VoidCallback onRemoteTap;

  @override
  Widget build(BuildContext context) {
    final logoVisualWidth = math.min(width * 0.75, height * 0.9);

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(height * 0.08),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.08),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(111, 135, 11, 108),
            Color.fromARGB(172, 136, 8, 108),
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
          // Logo
          Expanded(
            flex: 3,
            child: Center(
              child: OverflowBox(
                minHeight: 0,
                minWidth: 0,
                maxWidth: logoVisualWidth,
                maxHeight: height * 0.5,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/brand/logo_crop.png',
                  width: logoVisualWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ctaWidth * 0.08,
                  vertical: ctaHeight * 0.12,
                ),
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0x334CAF50)
                      : const Color(0x33FF9800),
                  borderRadius: BorderRadius.circular(ctaHeight * 0.25),
                  border: Border.all(
                    color: isConnected
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle : Icons.info_outline,
                      color: isConnected
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      size: height * 0.06,
                    ),
                    SizedBox(width: ctaWidth * 0.03),
                    Text(
                      isConnected
                          ? AppLocalizations.of(
                              context,
                            )!.connectedTo(deviceName)
                          : AppLocalizations.of(context)!.noRobotConnected,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CTA Buttons
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isConnected)
                  _buildCTAButton(
                    label: AppLocalizations.of(context)!.connectButton,
                    icon: Icons.bluetooth,
                    width: ctaWidth,
                    height: ctaHeight,
                    onTap: onConnectTap,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 97, 153, 237),
                        Color.fromARGB(255, 74, 93, 217),
                      ],
                    ),
                    iconColor: const Color(0xFFE1FBFF),
                    borderColor: const Color.fromARGB(255, 255, 255, 255),
                    shadowColor: const Color(0xFF0CA6C4),
                  ),
                if (isConnected) ...[
                  _buildCTAButton(
                    label: AppLocalizations.of(context)!.remoteButton,
                    icon: Icons.gamepad,
                    width: ctaWidth,
                    height: ctaHeight,
                    onTap: onRemoteTap,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 160, 88, 219),
                        Color.fromARGB(255, 104, 48, 149),
                      ],
                    ),
                    iconColor: const Color.fromARGB(255, 255, 255, 255),
                    borderColor: const Color.fromARGB(255, 255, 255, 255),
                    shadowColor: const Color.fromARGB(255, 160, 88, 219),
                  ),
                  SizedBox(width: ctaSpacing),
                  _buildCTAButton(
                    label: AppLocalizations.of(context)!.disconnectButton,
                    icon: Icons.bluetooth_disabled,
                    width: ctaWidth,
                    height: ctaHeight,
                    onTap: () => BluetoothService.instance.disconnect(),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                    ),
                    iconColor: const Color(0xFFFFE5E5),
                    borderColor: const Color.fromARGB(255, 255, 255, 255),
                    shadowColor: const Color.fromARGB(255, 255, 43, 43),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton({
    required String label,
    required IconData icon,
    required double width,
    required double height,
    required VoidCallback onTap,
    required LinearGradient gradient,
    required Color iconColor,
    required Color borderColor,
    required Color shadowColor,
  }) {
    final radius = BorderRadius.circular(height * 0.5);
    final textStyle = GoogleFonts.titanOne(
      fontSize: height * 0.4,
      letterSpacing: 0.2,
      color: const Color.fromARGB(255, 255, 255, 255),
    );

    return InkWell(
      borderRadius: radius,
      onTap: () {
        SoundService.instance.playClick();
        onTap();
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          border: Border.all(color: borderColor, width: height * 0.06),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(140, shadowColor.red, shadowColor.green, shadowColor.blue), // ignore: deprecated_member_use
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: height * 0.36),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: height * 0.45, color: Colors.black),
                Icon(icon, size: height * 0.42, color: iconColor),
              ],
            ),
            SizedBox(width: height * 0.24),
            Flexible(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textStyle.copyWith(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = math.max(1.0, height * 0.06)
                        ..color = const Color.fromARGB(129, 0, 0, 0),
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
