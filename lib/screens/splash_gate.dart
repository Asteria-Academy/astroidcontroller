// lib/screens/splash_gate.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../router/app_router.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with TickerProviderStateMixin {
  late final AnimationController _progressCtl;
  late final AnimationController _meteorCtl;

  @override
  void initState() {
    super.initState();
    _progressCtl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addStatusListener((s) {
            if (s == AnimationStatus.completed) {
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          });

    _meteorCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _boot();
  }

  Future<void> _boot() async {
    // Precache dulu supaya layer tidak “pop in”
    Future<void> safePrecache(String path) async {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (e) {
        debugPrint('precache skip $path -> $e');
      }
    }

    await Future.wait([
      safePrecache('assets/splash/bg.png'),
      safePrecache('assets/brand/logo.png'),
      safePrecache('assets/splash/bar_track.png'),
      safePrecache('assets/splash/bar_fill.png'),
      safePrecache('assets/splash/meteor.png'),
    ]);

    // Jalankan animasi progress (kalau perlu, kamu bisa update manual step-by-step)
    _progressCtl.forward(from: 0);
  }

  @override
  void dispose() {
    _progressCtl.dispose();
    _meteorCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1433),
      body: Stack(
        children: [
          // background outside SafeArea
          Positioned.fill(
            child: Image.asset('assets/splash/bg.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;

                // Skala proporsional
                final titleW = math.min(w * 0.85, 1000.0);
                final titleH = math.min(h * 0.42, 560.0);
                final barW = math.min(w * 0.42, 520.0);
                final barH = math.min(h * 0.11, 68.0);
                final meteorSize = barH * 1.6;
                final barVerticalInset = (meteorSize - barH) / 2;

                return Stack(
                  children: [
                    // 2) Title (mascot image layered above text logo)
                    Align(
                      alignment: const Alignment(0, -0.5),
                      child: SizedBox(
                        width: titleW,
                        height: titleH,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Mascot image - BEHIND (with subtle pink glow)
                            Positioned(
                              top: titleH * -0.15,
                              left: titleW / 3.5,
                              child: SizedBox(
                                width: titleW / 2.5,
                                height: titleH,
                                child: Container(
                                  // transparent so image shows, but provide glow via shadow
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pinkAccent.withOpacity(
                                          0.1,
                                        ),
                                        blurRadius: 28,
                                        spreadRadius: 6,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/brand/mascotnobg.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            // Logo text at mascot's feet - IN FRONT (with shadow + pink glow)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: titleH * 0.45,
                                child: Center(
                                  child: Container(
                                    // transparent color so shadow & glow are visible
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.45),
                                          blurRadius: 12,
                                          offset: Offset(0, 6),
                                        ),
                                        BoxShadow(
                                          color: Colors.pinkAccent.withOpacity(
                                            0.55,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 4,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/brand/logo_crop.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3) Progress bar (track + fill + meteor)
                    Align(
                      alignment: const Alignment(0, 0.4),
                      child: SizedBox(
                        width: barW,
                        height: barH + barVerticalInset * 2,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Track
                            Positioned.fill(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: barVerticalInset,
                                ),
                                child: Image.asset(
                                  'assets/splash/bar_track.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _progressCtl,
                              builder: (context, _) {
                                final p = Curves.easeInOut.transform(
                                  _progressCtl.value,
                                );
                                return Positioned.fill(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: barVerticalInset,
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, barBox) {
                                        final clamped = p
                                            .clamp(0.0, 1.0)
                                            .toDouble();
                                        if (clamped <= 0) {
                                          return const SizedBox.shrink();
                                        }
                                        final clipWidth =
                                            barBox.maxWidth * clamped;
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: ClipRect(
                                            clipper: _ProgressClipper(
                                              clipWidth,
                                            ),
                                            child: SizedBox(
                                              width: barBox.maxWidth,
                                              height: barBox.maxHeight,
                                              child: Image.asset(
                                                'assets/splash/bar_fill.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Meteor di atas bar
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _progressCtl,
                                _meteorCtl,
                              ]),
                              builder: (context, _) {
                                final p = Curves.easeInOut.transform(
                                  _progressCtl.value,
                                );
                                final bob =
                                    (_meteorCtl.value - 0.5) * (barH * 0.18);
                                final clamped = p.clamp(0.0, 1.0).toDouble();
                                final x = (barW - (meteorSize / 2)) * clamped;
                                return Positioned(
                                  top: bob,
                                  left: x,
                                  child: SizedBox(
                                    width: meteorSize,
                                    height: meteorSize,
                                    child: Image.asset(
                                      'assets/splash/meteor.png',
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4) Branding
                    Positioned(
                      bottom: 5,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Powered by Astroid Engine',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(192, 192, 192, 192),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressClipper extends CustomClipper<Rect> {
  _ProgressClipper(this.width);

  final double width;

  @override
  Rect getClip(Size size) {
    final clampedWidth = width.clamp(0.0, size.width).toDouble();
    return Rect.fromLTWH(0, 0, clampedWidth, size.height);
  }

  @override
  bool shouldReclip(_ProgressClipper oldClipper) => width != oldClipper.width;
}
