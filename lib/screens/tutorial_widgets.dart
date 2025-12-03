// lib/screens/tutorial_widgets.dart

part of 'tutorial_screen.dart'; // Allows this file to be part of tutorial_screen.dart

// --- Reusable Showcase Styling ---
Map<String, dynamic> getShowcaseStyle(BuildContext context) {
  return {
    'targetBorderRadius': BorderRadius.circular(16),
    'tooltipBackgroundColor': const Color(0xFF0F1D3C),
    'tooltipBorderRadius': BorderRadius.circular(16),
    'titleTextStyle': GoogleFonts.titanOne(
      fontSize: 16,
      color: const Color(0xFFA5F1FF),
      letterSpacing: 0.8,
    ),
    'descTextStyle': GoogleFonts.inter(
      fontSize: 13,
      color: const Color(0xFFF5FDFF),
      fontWeight: FontWeight.w400,
    ),
    'tooltipPadding': const EdgeInsets.all(20),
    'showArrow': false,
    'tooltipActionConfig': const TooltipActionConfig(
      position: TooltipActionPosition.outside,
      alignment: MainAxisAlignment.spaceBetween,
    ),
  };
}

// --- ADAPTED GALAXY PANEL FOR THE TUTORIAL ---
class _MockGalaxyPanel extends StatelessWidget {
  const _MockGalaxyPanel({
    required this.width,
    required this.height,
    required this.ctaWidth,
    required this.ctaHeight,
    required this.ctaSpacing,
    required this.isConnected,
    required this.deviceName,
    required this.statusKey,
    required this.connectKey,
    required this.remoteKey,
    required this.disconnectKey,
    required this.onConnectShowcaseNext,
    required this.onRemoteShowcasePrevious,
    required this.onFinish,
  });

  final double width;
  final double height;
  final double ctaWidth;
  final double ctaHeight;
  final double ctaSpacing;
  final bool isConnected;
  final String deviceName;

  // Showcase Keys
  final GlobalKey statusKey;
  final GlobalKey connectKey;
  final GlobalKey remoteKey;
  final GlobalKey disconnectKey;

  // Action Callbacks
  final VoidCallback onConnectShowcaseNext;
  final VoidCallback onRemoteShowcasePrevious;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final logoVisualWidth = math.min(width * 0.75, height * 0.9);
    final commonStyles = getShowcaseStyle(context);

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(height * 0.08),
      decoration: BoxDecoration(
        // ... (styling is copied from the original _GalaxyPanel)
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

          // --- Status Badge Showcase ---
          Expanded(
            flex: 2,
            child: Center(
              child: Showcase(
                key: statusKey,
                title: AppLocalizations.of(context)!.showcaseStatusTitle,
                description: AppLocalizations.of(context)!.showcaseStatusDesc,
                targetBorderRadius: commonStyles['targetBorderRadius'],
                tooltipBackgroundColor: commonStyles['tooltipBackgroundColor'],
                tooltipBorderRadius: commonStyles['tooltipBorderRadius'],
                titleTextStyle: commonStyles['titleTextStyle'],
                descTextStyle: commonStyles['descTextStyle'],
                tooltipPadding: commonStyles['tooltipPadding'],
                showArrow: commonStyles['showArrow'],
                tooltipActionConfig: commonStyles['tooltipActionConfig'],
                tooltipActions: [
                  TooltipActionButton(
                    type: TooltipDefaultActionType.skip,
                    name: AppLocalizations.of(context)!.btnSkip,
                    onTap: onFinish,
                  ),
                  TooltipActionButton(
                    type: TooltipDefaultActionType.next,
                    name: AppLocalizations.of(context)!.btnNext,
                  ),
                ],
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
          ),

          // --- CTA Buttons Showcase ---
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isConnected)
                  Showcase(
                    key: connectKey,
                    title: AppLocalizations.of(context)!.showcaseConnectTitle,
                    description: AppLocalizations.of(
                      context,
                    )!.showcaseConnectDesc,
                    targetBorderRadius: commonStyles['targetBorderRadius'],
                    tooltipBackgroundColor:
                        commonStyles['tooltipBackgroundColor'],
                    tooltipBorderRadius: commonStyles['tooltipBorderRadius'],
                    titleTextStyle: commonStyles['titleTextStyle'],
                    descTextStyle: commonStyles['descTextStyle'],
                    tooltipPadding: commonStyles['tooltipPadding'],
                    showArrow: commonStyles['showArrow'],
                    tooltipActionConfig: commonStyles['tooltipActionConfig'],
                    tooltipActions: [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.previous,
                        name: AppLocalizations.of(context)!.btnPrevious,
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        name: AppLocalizations.of(context)!.btnNext,
                        onTap: onConnectShowcaseNext,
                      ),
                    ],
                    child: _TutorialCTAButton(
                      label: AppLocalizations.of(context)!.connectButton,
                      icon: Icons.bluetooth,
                      width: ctaWidth,
                      height: ctaHeight,
                      onTap: onConnectShowcaseNext,
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
                  ),
                if (isConnected) ...[
                  Showcase(
                    key: remoteKey,
                    title: AppLocalizations.of(context)!.showcaseRemoteTitle,
                    description: AppLocalizations.of(
                      context,
                    )!.showcaseRemoteDesc,
                    targetBorderRadius: commonStyles['targetBorderRadius'],
                    tooltipBackgroundColor:
                        commonStyles['tooltipBackgroundColor'],
                    tooltipBorderRadius: commonStyles['tooltipBorderRadius'],
                    titleTextStyle: commonStyles['titleTextStyle'],
                    descTextStyle: commonStyles['descTextStyle'],
                    tooltipPadding: commonStyles['tooltipPadding'],
                    showArrow: commonStyles['showArrow'],
                    tooltipActionConfig: commonStyles['tooltipActionConfig'],
                    tooltipActions: [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.previous,
                        name: AppLocalizations.of(context)!.btnPrevious,
                        onTap: onRemoteShowcasePrevious,
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        name: AppLocalizations.of(context)!.btnNext,
                      ),
                    ],
                    child: _TutorialCTAButton(
                      label: AppLocalizations.of(context)!.remoteButton,
                      icon: Icons.gamepad,
                      width: ctaWidth,
                      height: ctaHeight,
                      onTap: () {}, // Does nothing in tutorial
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
                  ),
                  SizedBox(width: ctaSpacing),
                  Showcase(
                    key: disconnectKey,
                    title: AppLocalizations.of(
                      context,
                    )!.showcaseDisconnectTitle,
                    description: AppLocalizations.of(
                      context,
                    )!.showcaseDisconnectDesc,
                    targetBorderRadius: commonStyles['targetBorderRadius'],
                    tooltipBackgroundColor:
                        commonStyles['tooltipBackgroundColor'],
                    tooltipBorderRadius: commonStyles['tooltipBorderRadius'],
                    titleTextStyle: commonStyles['titleTextStyle'],
                    descTextStyle: commonStyles['descTextStyle'],
                    tooltipPadding: commonStyles['tooltipPadding'],
                    showArrow: commonStyles['showArrow'],
                    tooltipActionConfig: commonStyles['tooltipActionConfig'],
                    tooltipActions: [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.previous,
                        name: AppLocalizations.of(context)!.btnPrevious,
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        name: AppLocalizations.of(context)!.btnNext,
                      ),
                    ],
                    child: _TutorialCTAButton(
                      label: AppLocalizations.of(context)!.disconnectButton,
                      icon: Icons.bluetooth_disabled,
                      width: ctaWidth,
                      height: ctaHeight,
                      onTap: () {}, // Does nothing in tutorial
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                      ),
                      iconColor: const Color(0xFFFFE5E5),
                      borderColor: const Color.fromARGB(255, 255, 255, 255),
                      shadowColor: const Color.fromARGB(255, 255, 43, 43),
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
}

// --- COPIED & RENAMED CTA BUTTON ---
class _TutorialCTAButton extends StatelessWidget {
  const _TutorialCTAButton({
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
    required this.onTap,
    required this.gradient,
    required this.iconColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final String label;
  final IconData icon;
  final double width;
  final double height;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final Color iconColor;
  final Color borderColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height * 0.5);
    final textStyle = GoogleFonts.titanOne(
      fontSize: height * 0.4,
      letterSpacing: 0.2,
      color: const Color.fromARGB(255, 255, 255, 255),
    );

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          border: Border.all(color: borderColor, width: height * 0.06),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB( 140, shadowColor.red, shadowColor.green, shadowColor.blue ), // ignore: deprecated_member_use
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

// --- COPIED & ADAPTED SETTINGS BUTTON ---
class _MockSettingsButton extends StatelessWidget {
  const _MockSettingsButton({
    required this.settingsKey,
    required this.onFinish,
  });

  final GlobalKey settingsKey;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final commonStyles = getShowcaseStyle(context);
    return Showcase(
      key: settingsKey,
      title: AppLocalizations.of(context)!.showcaseSettingsTitle,
      description: AppLocalizations.of(context)!.showcaseSettingsDesc,
      targetBorderRadius: commonStyles['targetBorderRadius'],
      tooltipBackgroundColor: commonStyles['tooltipBackgroundColor'],
      tooltipBorderRadius: commonStyles['tooltipBorderRadius'],
      titleTextStyle: commonStyles['titleTextStyle'],
      descTextStyle: commonStyles['descTextStyle'],
      tooltipPadding: commonStyles['tooltipPadding'],
      showArrow: commonStyles['showArrow'],
      tooltipActionConfig: commonStyles['tooltipActionConfig'],
      tooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          name: AppLocalizations.of(context)!.btnPrevious,
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: AppLocalizations.of(context)!.btnFinish,
          onTap: onFinish,
        ),
      ],
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
          icon: const Icon(Icons.settings, color: Colors.white, size: 32),
          onPressed: () {}, // Does nothing in tutorial
        ),
      ),
    );
  }
}
