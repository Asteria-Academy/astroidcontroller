// lib/screens/tutorial_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';

import '../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../services/preferences_service.dart';
import '../services/sound_service.dart';

part 'tutorial_widgets.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  bool _isShowingConnectedState = false;

  final GlobalKey _statusKey = GlobalKey();
  final GlobalKey _connectKey = GlobalKey();
  final GlobalKey _remoteKey = GlobalKey();
  final GlobalKey _disconnectKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  
  late final List<GlobalKey> _showcaseKeys;
  late final ShowcaseView _showcase;

  @override
  void initState() {
    super.initState();
    SoundService.instance.ensurePlaying();
    _showcaseKeys = [_statusKey, _connectKey, _remoteKey, _disconnectKey, _settingsKey];

    ShowcaseView.register(
      enableAutoScroll: false,
      disableBarrierInteraction: false,
      disableMovingAnimation: true,
      disableScaleAnimation: true,
    );

    _showcase = ShowcaseView.get();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showcase.startShowCase(_showcaseKeys);
    });
  }

  @override
  void dispose() {
    _showcase.unregister();
    super.dispose();
  }
  
  void _onConnectShowcaseNext() {
    SoundService.instance.playClick();
    setState(() {
      _isShowingConnectedState = true;
    });
    _showcase.next();
  }

  void _onRemoteShowcasePrevious() {
    SoundService.instance.playClick();
    setState(() {
      _isShowingConnectedState = false;
    });
    _showcase.previous();
  }
  
  void _onFinishTutorial() async {
    SoundService.instance.playClick();
    final prefs = PreferencesService.instance;
    await prefs.setShowcaseShown(true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
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

          final isConnected = _isShowingConnectedState;
          final deviceName = "Astroidbot";
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
          final ctaSpacing = ctaCount > 1 ? math.min(math.max(availableCTAWidth * 0.03, 12.0), 20.0) : 0.0;
          final totalSpacing = (ctaCount - 1) * ctaSpacing;
          final ctaBaseWidth = ctaCount > 0 ? math.max(availableCTAWidth - totalSpacing, 0.0) / ctaCount : 0.0;
          final ctaW = math.min(ctaBaseWidth, 200.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/splash/bg.png', fit: BoxFit.cover),
              ),

              Align(
                alignment: Alignment.center,
                child: _MockGalaxyPanel(
                  width: panelW,
                  height: panelH,
                  ctaWidth: ctaW,
                  ctaHeight: ctaH,
                  ctaSpacing: ctaSpacing,
                  isConnected: isConnected,
                  deviceName: deviceName,
                  
                  statusKey: _statusKey,
                  connectKey: _connectKey,
                  remoteKey: _remoteKey,
                  disconnectKey: _disconnectKey,
                  
                  onConnectShowcaseNext: _onConnectShowcaseNext,
                  onRemoteShowcasePrevious: _onRemoteShowcasePrevious,
                  onFinish: _onFinishTutorial,
                ),
              ),

              Positioned(
                top: 24,
                right: 24,
                child: _MockSettingsButton(
                  settingsKey: _settingsKey,
                  onFinish: _onFinishTutorial,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
