// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/preferences_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/donut_led_picker.dart';

class RemoteControlScreen extends StatefulWidget {
  const RemoteControlScreen({super.key});

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> {
  Timer? _driveTimer, _headTimer;
  double _lastDriveX = 0, _lastDriveY = 0;
  double _lastHeadX = 0, _lastHeadY = 0;

  bool get _hapticsEnabled =>
      PreferencesService.instance.isHapticFeedbackEnabled();

  bool _isGripperOpen = true;
  double _driveX = 0, _driveY = 0;
  double _headX = 0, _headY = 0;
  bool _gestureGripper = false,
      _gestureSketcher = false,
      _gestureLauncher = false;
  List<Color> _ledColors = List.generate(12, (_) => Colors.grey.shade800);
  Color _currentColor = Colors.deepPurpleAccent;

  @override
  void initState() {
    super.initState();
    _driveTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _sendDriveCommand(),
    );
    _headTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _sendHeadCommand(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BluetoothService>().sendCommand({
          "command": "GET_BATTERY_STATUS",
          "params": {},
        });
      }
    });
  }

  @override
  void dispose() {
    _driveTimer?.cancel();
    _headTimer?.cancel();
    context.read<BluetoothService>().sendCommand({
      "command": "DRIVE_DIRECT",
      "params": {"left_speed": 0, "right_speed": 0},
    });
    super.dispose();
  }

  void _sendCommand(Map<String, dynamic> command) {
    if (mounted) {
      context.read<BluetoothService>().sendCommand(command);
    }
  }

  @override
  Widget build(BuildContext context) {
    final btService = context.watch<BluetoothService>();
    if (!btService.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return const Scaffold(
        backgroundColor: Color(0xFF0B1433),
        body: Center(child: Text("Disconnecting...")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1433),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/splash/bg.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _TopAppBar(
                  isConnected: btService.isConnected,
                  deviceName:
                      btService.connectedDevice?.platformName ??
                      'Not Connected',
                  batteryLevel: btService.batteryLevel,
                  onBackPressed: () => Navigator.of(context).pop(),
                  onEstopPressed: () =>
                      _sendCommand({"command": "ESTOP", "params": {}}),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildJoystick(
                          AppLocalizations.of(context)!.driveJoystick,
                          isDriveJoystick: true,
                        ),
                        _buildCenterControlPanel(),
                        _buildJoystick(
                          AppLocalizations.of(context)!.headJoystick,
                          isDriveJoystick: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControlPanel() {
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: Icon(
                _isGripperOpen
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
              ),
              label: Text(
                _isGripperOpen
                    ? AppLocalizations.of(context)!.closeGripper
                    : AppLocalizations.of(context)!.openGripper,
              ),
              onPressed: _toggleGripper,
              style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
            ),
            const SizedBox(height: 16),
            _buildFlyoutButton(
              Icons.sentiment_very_satisfied,
              AppLocalizations.of(context)!.expressions,
              _showExpressionsDialog,
            ),
            const SizedBox(height: 12),
            _buildFlyoutButton(
              Icons.music_note,
              AppLocalizations.of(context)!.sounds,
              _showSoundsDialog,
            ),
            const SizedBox(height: 12),
            _buildFlyoutButton(
              Icons.lightbulb,
              AppLocalizations.of(context)!.ledColor,
              _showLedControlDialog,
            ),
            const SizedBox(height: 12),
            _buildFlyoutButton(
              Icons.smart_toy,
              AppLocalizations.of(context)!.modes,
              _showModesDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoystick(String label, {required bool isDriveJoystick}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),

        Listener(
          onPointerDown: (_) {
            if (_hapticsEnabled) HapticFeedback.lightImpact();
          },
          onPointerUp: (_) {
            if (_hapticsEnabled) HapticFeedback.selectionClick();
          },
          child: Joystick(
            listener: (details) {
              if (isDriveJoystick) {
                if ((details.y.abs() > 0.1 && _lastDriveY.abs() <= 0.1) ||
                    (details.x.abs() > 0.1 && _lastDriveX.abs() <= 0.1)) {
                  if (_hapticsEnabled) HapticFeedback.selectionClick();
                }
                _lastDriveX = details.x;
                _lastDriveY = details.y;
                setState(() {
                  _driveX = details.x;
                  _driveY = details.y;
                });
              } else {
                if ((details.y.abs() > 0.1 && _lastHeadY.abs() <= 0.1) ||
                    (details.x.abs() > 0.1 && _lastHeadX.abs() <= 0.1)) {
                  if (_hapticsEnabled) HapticFeedback.selectionClick();
                }
                _lastHeadX = details.x;
                _lastHeadY = details.y;
                setState(() {
                  _headX = details.x;
                  _headY = details.y;
                });
              }
            },
            onStickDragStart: () {
              if (_hapticsEnabled) HapticFeedback.lightImpact();
            },
            onStickDragEnd: () {
              if (_hapticsEnabled) HapticFeedback.selectionClick();
              if (isDriveJoystick) {
                setState(() {
                  _driveX = 0;
                  _driveY = 0;
                });
                _sendCommand({
                  "command": "DRIVE_DIRECT",
                  "params": {"left_speed": 0, "right_speed": 0},
                });
              } else {
                setState(() {
                  _headX = 0;
                  _headY = 0;
                });
              }
            },
            base: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F3A66), Color(0xFF101D38)],
                ),
                border: Border.all(color: const Color(0x996EE7FF), width: 2),
              ),
            ),
            stick: const Icon(
              Icons.control_camera,
              size: 50,
              color: Color(0xFF6EE7FF),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLedControlDialog() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          const Color offColor = Colors.black;
          const Color customPickerColor = Colors.transparent;

          void showColorWheel() {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.pickAColor),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: _currentColor,
                    onColorChanged: (color) {
                      // We can update the color live, or wait for the user to confirm.
                      // Let's update it live for a better experience.
                      setDialogState(() => _currentColor = color);
                    },
                    pickerAreaHeightPercent: 0.8,
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.select),
                    onPressed: () {
                      if (_hapticsEnabled) HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          }

          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.ledControl),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Donut Picker on the Left ---
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.tapSegment,
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      DonutLedPicker(
                        ledColors: _ledColors,
                        onSegmentTapped: (index) async {
                          if (_hapticsEnabled) {
                            await HapticFeedback.selectionClick();
                          }
                          final physicalLed = ((index + 3) % 12) + 1;
                          setDialogState(() {
                            _ledColors[index] = _currentColor;
                          });
                          _sendCommand({
                            "command": "SET_LED_COLOR",
                            "params": {
                              "led_id": physicalLed,
                              "r": _currentColor == offColor
                                  ? 0
                                  : _currentColor.red,
                              "g": _currentColor == offColor
                                  ? 0
                                  : _currentColor.green,
                              "b": _currentColor == offColor
                                  ? 0
                                  : _currentColor.blue,
                            },
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),

                  // --- Color Picker (Right) ---
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectColor,
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: BlockPicker(
                            pickerColor: _currentColor,
                            onColorChanged: (color) async {
                              if (_hapticsEnabled) {
                                await HapticFeedback.selectionClick();
                              }
                              setDialogState(() => _currentColor = color);
                            },
                            itemBuilder: (color, isCurrentColor, changeColor) {
                              if (color == customPickerColor) {
                                return GestureDetector(
                                  onTap: () {
                                    if (_hapticsEnabled) HapticFeedback.lightImpact();
                                    showColorWheel();
                                  },
                                  child: Container(
                                    height: 50, width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Colors.red, Colors.green, Colors.blue],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(color: Colors.white, width: 0.5),
                                    ),
                                    child: const Icon(Icons.colorize, color: Colors.white),
                                  ),
                                );
                              }
                              
                              return GestureDetector(
                                onTap: changeColor,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    boxShadow: [
                                      if (isCurrentColor)
                                        BoxShadow(
                                          color: color,
                                          blurRadius: 4,
                                          spreadRadius: 2,
                                        ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: isCurrentColor ? 2 : 0.5,
                                    ),
                                  ),
                                  child: color == offColor
                                      ? const Icon(
                                          Icons.power_settings_new,
                                          color: Colors.white54,
                                        )
                                      : null,
                                ),
                              );
                            },
                            availableColors: [
                              offColor,
                              Colors.red,
                              Colors.pink,
                              Colors.purple,
                              Colors.deepPurple,
                              Colors.indigo,
                              Colors.blue,
                              Colors.lightBlue,
                              Colors.cyan,
                              Colors.teal,
                              Colors.green,
                              Colors.lightGreen,
                              Colors.lime,
                              Colors.yellow,
                              Colors.amber,
                              Colors.orange,
                              Colors.white,
                              customPickerColor
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.select_all),
                label: Text(AppLocalizations.of(context)!.setAllLeds),
                onPressed: () async {
                  if (_hapticsEnabled) await HapticFeedback.lightImpact();
                  setDialogState(
                    () => _ledColors = List.generate(12, (_) => _currentColor),
                  );
                  _sendCommand({
                    "command": "SET_LED_COLOR",
                    "params": {
                      "led_id": "all",
                      "r": _currentColor == offColor ? 0 : _currentColor.red,
                      "g": _currentColor == offColor ? 0 : _currentColor.green,
                      "b": _currentColor == offColor ? 0 : _currentColor.blue,
                    },
                  });
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.done),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sendDriveCommand() {
    double y = -_driveY;
    double x = _driveX;
    double speed = y * 100;
    double turn = x * 100;
    int leftSpeed = (speed + turn).clamp(-100, 100).toInt();
    int rightSpeed = (speed - turn).clamp(-100, 100).toInt();
    if (leftSpeed.abs() > 5 || rightSpeed.abs() > 5) {
      // Deadzone
      _sendCommand({
        "command": "DRIVE_DIRECT",
        "params": {"left_speed": leftSpeed, "right_speed": rightSpeed},
      });
    }
  }

  void _toggleGripper() {
    if (_hapticsEnabled) HapticFeedback.lightImpact();
    setState(() => _isGripperOpen = !_isGripperOpen);
    _sendCommand({
      "command": "SET_GRIPPER",
      "params": {"state": _isGripperOpen ? "open" : "closed"},
    });
  }

  Widget _buildFlyoutButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        if (_hapticsEnabled) HapticFeedback.lightImpact();
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(180, 48),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _sendHeadCommand() {
    int yaw = (90 + (-_headX * 10)).clamp(80, 100).toInt();
    int pitch = (90 + (-_headY * 10)).clamp(80, 100).toInt();
    if (_headX.abs() > 0.1 || _headY.abs() > 0.1) {
      _sendCommand({
        "command": "SET_HEAD_POSITION",
        "params": {"pitch": pitch, "yaw": yaw},
      });
    }
  }

  void _setGestureMode(String mode, bool active) {
    setState(() {
      if (mode == "gripper") _gestureGripper = active;
      if (mode == "sketcher") _gestureSketcher = active;
      if (mode == "launcher") _gestureLauncher = active;
    });
    _sendCommand({
      "command": "SET_GESTURE_MODE",
      "params": {"mode": mode, "active": active},
    });
  }

  void _showExpressionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.setExpression),
        content: _buildControlCard(null, [
          _iconButton(Icons.sentiment_very_satisfied, "happy", Colors.green),
          _iconButton(Icons.sentiment_dissatisfied, "sad", Colors.blue),
          _iconButton(Icons.help_outline, "confused", Colors.orange),
          _iconButton(Icons.whatshot, "mad", Colors.red),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showSoundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.playSound),
        content: _buildControlCard(null, [
          _soundButton(Icons.music_note, 1),
          _soundButton(Icons.notifications, 2),
          _soundButton(Icons.check_circle, 3),
          _soundButton(Icons.warning, 4),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showModesDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.specialModes),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlCard(
                    AppLocalizations.of(context)!.lineFollower,
                    [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: Text(
                              AppLocalizations.of(context)!.startStop,
                            ),
                            onPressed: () => _sendCommand({
                              "command": "SET_AUTONOMOUS_STATE",
                              "params": {
                                "mode": "line_follower",
                                "active": true,
                              },
                            }),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            child: Text(
                              AppLocalizations.of(context)!.calibrate,
                            ),
                            onPressed: () => _sendCommand({
                              "command": "CALIBRATE_SENSORS",
                              "params": {},
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildControlCard(
                    AppLocalizations.of(context)!.wonderPackGestures,
                    [
                      _gestureSwitch(
                        AppLocalizations.of(context)!.gripper,
                        "gripper",
                        _gestureGripper,
                        setDialogState,
                      ),
                      _gestureSwitch(
                        AppLocalizations.of(context)!.sketcher,
                        "sketcher",
                        _gestureSketcher,
                        setDialogState,
                      ),
                      _gestureSwitch(
                        AppLocalizations.of(context)!.launcher,
                        "launcher",
                        _gestureLauncher,
                        setDialogState,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlCard(String? title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, String iconName, Color color) {
    return ElevatedButton(
      onPressed: () {
        _sendCommand({
          "command": "DISPLAY_ICON",
          "params": {"icon_name": iconName},
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(icon, size: 24),
    );
  }

  Widget _soundButton(IconData icon, int soundId) {
    return ElevatedButton(
      onPressed: () {
        _sendCommand({
          "command": "PLAY_INTERNAL_SOUND",
          "params": {"sound_id": soundId},
        });
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(icon, size: 24),
    );
  }

  Widget _gestureSwitch(
    String label,
    String mode,
    bool value,
    void Function(void Function()) setDialogState,
  ) {
    return Column(
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: (active) {
            _setGestureMode(mode, active);
            setDialogState(() {});
          },
          activeThumbColor: Colors.deepPurpleAccent,
        ),
      ],
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({
    required this.isConnected,
    required this.deviceName,
    this.batteryLevel,
    required this.onBackPressed,
    required this.onEstopPressed,
  });

  final bool isConnected;
  final String deviceName;
  final int? batteryLevel;
  final VoidCallback onBackPressed;
  final VoidCallback onEstopPressed;

  @override
  Widget build(BuildContext context) {
    final statusColor = isConnected ? Colors.greenAccent : Colors.orangeAccent;
    final icon = isConnected
        ? Icons.bluetooth_connected
        : Icons.bluetooth_disabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xAA122A4D), Color(0xAA0F1D3C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: const Color(0xCC73F0FF), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x556AE8FF), blurRadius: 12, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: onBackPressed,
          ),

          // Status Info (BT and Battery)
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        deviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildBatteryIndicator(batteryLevel),
              ],
            ),
          ),

          // Emergency Stop Button
          ElevatedButton.icon(
            onPressed: onEstopPressed,
            icon: const Icon(Icons.emergency_sharp, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.emergencyStop,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryIndicator(int? level) {
    IconData batteryIcon;
    if (level == null) {
      batteryIcon = Icons.battery_unknown;
    } else if (level > 90) {
      batteryIcon = Icons.battery_full;
    } else if (level > 75) {
      batteryIcon = Icons.battery_6_bar;
    } else if (level > 50) {
      batteryIcon = Icons.battery_4_bar;
    } else if (level > 25) {
      batteryIcon = Icons.battery_2_bar;
    } else {
      batteryIcon = Icons.battery_alert;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          batteryIcon,
          color: level == null ? Colors.grey : Colors.cyanAccent,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          level != null ? '$level%' : '--%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
