// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
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

  bool _isGripperOpen = true;
  double _driveX = 0, _driveY = 0;
  double _headX = 0, _headY = 0;
  bool _gestureGripper = false, _gestureSketcher = false, _gestureLauncher = false;
  List<Color> _ledColors = List.generate(12, (_) => Colors.grey.shade800);
  Color _currentColor = Colors.deepPurpleAccent;

  @override
  void initState() {
    super.initState();
    _driveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => _sendDriveCommand());
    _headTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => _sendHeadCommand());
    context.read<BluetoothService>().sendCommand({"command": "GET_BATTERY_STATUS", "params": {}});
  }

  @override
  void dispose() {
    _driveTimer?.cancel();
    _headTimer?.cancel();
    context.read<BluetoothService>().sendCommand({"command": "DRIVE_DIRECT", "params": {"left_speed": 0, "right_speed": 0}});
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
      return const Scaffold(backgroundColor: Color(0xFF0B1433), body: Center(child: Text("Disconnecting...")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1433),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/splash/bg.png', fit: BoxFit.cover)),
          SafeArea(
            child: Column(
              children: [
                _TopAppBar(
                  isConnected: btService.isConnected,
                  deviceName: btService.connectedDevice?.platformName ?? 'Not Connected',
                  batteryLevel: btService.batteryLevel,
                  onBackPressed: () => Navigator.of(context).pop(),
                  onEstopPressed: () => _sendCommand({"command": "ESTOP", "params": {}}),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildJoystick("Drive", isDriveJoystick: true),
                        _buildCenterControlPanel(),
                        _buildJoystick("Head", isDriveJoystick: false),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: Icon(
            _isGripperOpen
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_up,
          ),
          label: Text(_isGripperOpen ? "Close Gripper" : "Open Gripper"),
          onPressed: _toggleGripper,
          style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
        ),
        const SizedBox(height: 16),
        _buildFlyoutButton(
          Icons.sentiment_very_satisfied,
          "Expressions",
          _showExpressionsDialog,
        ),
        const SizedBox(height: 12),
        _buildFlyoutButton(Icons.music_note, "Sounds", _showSoundsDialog),
        const SizedBox(height: 12),
        _buildFlyoutButton(Icons.smart_toy, "Modes", _showModesDialog),
        const SizedBox(height: 12),
        _buildFlyoutButton(Icons.lightbulb, "LED Color", _showLedControlDialog),
      ],
    );
  }

  Widget _buildJoystick(String label, {required bool isDriveJoystick}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 16),
        
        Listener(
          onPointerDown: (_) => HapticFeedback.lightImpact(), // <-- UPDATED
          onPointerUp: (_) => HapticFeedback.selectionClick(), 
          child: Joystick(
            listener: (details) {
              if (isDriveJoystick) {
                if ((details.y.abs() > 0.1 && _lastDriveY.abs() <= 0.1) || (details.x.abs() > 0.1 && _lastDriveX.abs() <= 0.1)) {
                  HapticFeedback.selectionClick();
                }
                _lastDriveX = details.x; _lastDriveY = details.y;
                setState(() { _driveX = details.x; _driveY = details.y; });
              } else {
                if ((details.y.abs() > 0.1 && _lastHeadY.abs() <= 0.1) || (details.x.abs() > 0.1 && _lastHeadX.abs() <= 0.1)) {
                  HapticFeedback.selectionClick();
                }
                _lastHeadX = details.x; _lastHeadY = details.y;
                setState(() { _headX = details.x; _headY = details.y; });
              }
            },
            onStickDragStart: () {
              HapticFeedback.lightImpact();
            },
            onStickDragEnd: () {
              HapticFeedback.selectionClick();
              if (isDriveJoystick) {
                setState(() { _driveX = 0; _driveY = 0; });
                _sendCommand({"command": "DRIVE_DIRECT", "params": {"left_speed": 0, "right_speed": 0}});
              } else {
                setState(() { _headX = 0; _headY = 0; });
              }
            },
            base: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF1F3A66), Color(0xFF101D38)]), border: Border.all(color: const Color(0x996EE7FF), width: 2))),
            stick: const Icon(Icons.control_camera, size: 50, color: Color(0xFF6EE7FF)),
          ),
        ),
      ],
    );
  }

  Future<void> _showLedControlDialog() async {
    // Haptic is on the button that calls this.
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Define our "Off" color as pure black
          const Color offColor = Colors.black;

          return AlertDialog(
            title: const Text('LED Control'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Donut Picker on the Left ---
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tap a segment', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      DonutLedPicker(
                        ledColors: _ledColors,
                        onSegmentTapped: (index) async {
                          await HapticFeedback.selectionClick();
                          setDialogState(() { _ledColors[index] = _currentColor; });
                          _sendCommand({
                            "command": "SET_LED_COLOR",
                            "params": {
                              "led_id": index,
                              "r": _currentColor == offColor ? 0 : _currentColor.red,
                              "g": _currentColor == offColor ? 0 : _currentColor.green,
                              "b": _currentColor == offColor ? 0 : _currentColor.blue
                            }
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
                        const Text('Select a color', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 10),
                        BlockPicker(
                          pickerColor: _currentColor,
                          onColorChanged: (color) async {
                            await HapticFeedback.selectionClick();
                            setDialogState(() => _currentColor = color);
                          },
                          itemBuilder: (color, isCurrentColor, changeColor) {
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
                                      BoxShadow(color: color, blurRadius: 4, spreadRadius: 2)
                                  ],
                                  border: Border.all(color: Colors.white, width: isCurrentColor ? 2 : 0.5)
                                ),
                                child: color == offColor
                                    ? const Icon(Icons.power_settings_new, color: Colors.white54)
                                    : null,
                              ),
                            );
                          },
                          availableColors: [
                            offColor,
                            Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
                            Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
                            Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
                            Colors.yellow, Colors.amber, Colors.orange,
                            Colors.white,
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.select_all),
                label: const Text('Set All LEDs'),
                onPressed: () async {
                  await HapticFeedback.lightImpact();
                  setDialogState(() => _ledColors = List.generate(12, (_) => _currentColor));
                  _sendCommand({
                    "command": "SET_LED_COLOR",
                    "params": {
                      "led_id": "all",
                      "r": _currentColor == offColor ? 0 : _currentColor.red,
                      "g": _currentColor == offColor ? 0 : _currentColor.green,
                      "b": _currentColor == offColor ? 0 : _currentColor.blue
                    }
                  });
                },
              ),
              TextButton(child: const Text('Done'), onPressed: () => Navigator.of(context).pop()),
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
    HapticFeedback.lightImpact();
    setState(() => _isGripperOpen = !_isGripperOpen);
    _sendCommand({"command": "SET_GRIPPER", "params": {"state": _isGripperOpen ? "open" : "closed"}});
  }

  Widget _buildFlyoutButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon), label: Text(label),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48), backgroundColor: Colors.grey.shade800, foregroundColor: Colors.white),
    );
  }

  void _sendHeadCommand() {
    int yaw = (90 + (_headX * 75)).clamp(75, 105).toInt();
    int pitch = (90 + (-_headY * 75)).clamp(20, 170).toInt();
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
        title: const Text('Set Expression'),
        content: _buildControlCard(null, [
          _iconButton(Icons.sentiment_very_satisfied, "happy", Colors.green),
          _iconButton(Icons.sentiment_dissatisfied, "sad", Colors.blue),
          _iconButton(Icons.help_outline, "confused", Colors.orange),
          _iconButton(Icons.whatshot, "mad", Colors.red),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  void _showSoundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Play Sound'),
        content: _buildControlCard(null, [
          _soundButton(Icons.music_note, 1),
          _soundButton(Icons.notifications, 2),
          _soundButton(Icons.warning, 3),
          _soundButton(Icons.mic, 0),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
            title: const Text('Special Modes'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlCard('Line Follower', [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: const Text("Start/Stop"),
                          onPressed: () => _sendCommand({
                            "command": "SET_AUTONOMOUS_STATE",
                            "params": {"mode": "line_follower", "active": true},
                          }),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          child: const Text("Calibrate"),
                          onPressed: () => _sendCommand({
                            "command": "CALIBRATE_SENSORS",
                            "params": {},
                          }),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildControlCard('Wonder Pack Gestures', [
                    _gestureSwitch(
                      "Gripper",
                      "gripper",
                      _gestureGripper,
                      setDialogState,
                    ),
                    _gestureSwitch(
                      "Sketcher",
                      "sketcher",
                      _gestureSketcher,
                      setDialogState,
                    ),
                    _gestureSwitch(
                      "Launcher",
                      "launcher",
                      _gestureLauncher,
                      setDialogState,
                    ),
                  ]),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
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
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
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
            label: const Text(
              'E-STOP',
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
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
          ),
        ),
      ],
    );
  }
}
