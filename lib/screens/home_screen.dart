// lib/screens/home_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../services/bluetooth_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1433),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;

          // Skala responsif (only for the main panel now)
          final panelW = math.min(w * 0.78, 640.0);
          final panelH = math.min(h * 0.56, 460.0);

          final ctaW = math.min(w * 0.22, 320.0);
          final ctaH = math.min(h * 0.10, 64.0);

          return Stack(
            children: [
              // 1) Galaxy background
              Positioned.fill(
                child: Image.asset('assets/splash/bg.png', fit: BoxFit.cover),
              ),

              // 2) Panel tengah (galaxy card) - Now centered
              Align(
                alignment: Alignment.center, // <-- CHANGED
                child: _GalaxyPanel(
                  width: panelW,
                  height: panelH,
                  ctaWidth: ctaW,
                  ctaHeight: ctaH,
                  isConnected: _btService.isConnected,
                  deviceName:
                      _btService.connectedDevice?.platformName ?? "Unknown",
                  onConnectTap: () {
                    Navigator.pushNamed(context, AppRoutes.connect);
                  },
                  onRemoteTap: () {
                    Navigator.pushNamed(context, AppRoutes.remoteControl);
                  },
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
    required this.isConnected,
    required this.deviceName,
    required this.onConnectTap,
    required this.onRemoteTap,
  });

  final double width;
  final double height;
  final double ctaWidth;
  final double ctaHeight;
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
          colors: [Color(0x66122A4D), Color(0x660F1D3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color.fromARGB(102, 115, 240, 255),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(64, 106, 232, 255),
            blurRadius: 32,
            spreadRadius: 4,
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
                          ? "Connected to: $deviceName"
                          : "No Robot Connected",
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
                    label: "CONNECT",
                    icon: Icons.bluetooth,
                    width: ctaWidth,
                    height: ctaHeight,
                    onTap: onConnectTap,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF25CBE9), Color(0xFF1B8FB0)],
                    ),
                  ),
                if (isConnected) ...[
                  _buildCTAButton(
                    label: "REMOTE",
                    icon: Icons.gamepad,
                    width: ctaWidth,
                    height: ctaHeight,
                    onTap: onRemoteTap,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                    ),
                  ),
                  SizedBox(width: ctaWidth * 0.1),
                  _buildCTAButton(
                    label: "DISCONNECT",
                    icon: Icons.bluetooth_disabled,
                    width: ctaWidth,
                    height: ctaHeight,
                    onTap: () => BluetoothService.instance.disconnect(),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                    ),
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
    required Gradient gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(height * 0.25),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(height * 0.25),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(77, 0, 0, 0),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: height * 0.38),
              SizedBox(width: width * 0.05),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: height * 0.32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}