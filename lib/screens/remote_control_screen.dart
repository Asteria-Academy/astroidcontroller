// lib/screens/remote_control_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class RemoteControlScreen extends StatefulWidget {
  const RemoteControlScreen({super.key});

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> {
  Timer? _driveTimer;
  Timer? _headTimer;
  BluetoothService? _bluetoothService;

  bool _isGripperOpen = true;
  Color _currentLedColor = Colors.deepPurpleAccent;
  double _driveX = 0, _driveY = 0;
  double _headX = 0, _headY = 0;
  bool _gestureGripper = false;
  bool _gestureSketcher = false;
  bool _gestureLauncher = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _bluetoothService ??= context.read<BluetoothService>();
    } catch (e) {
      debugPrint("BluetoothService not available: $e");
    }
  }

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
  }

  @override
  void dispose() {
    _driveTimer?.cancel();
    _headTimer?.cancel();
    _bluetoothService?.sendCommand({
      "command": "DRIVE_DIRECT",
      "params": {"left_speed": 0, "right_speed": 0},
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btService = context.watch<BluetoothService>();
    final isConnected =
        btService.connectionState == BluetoothConnectionState.connected;
    final deviceName =
        btService.connectedDevice?.platformName ?? 'Not Connected';
    final batteryLevel = btService.batteryLevel;

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
                // 1. Top App Bar
                _TopAppBar(
                  isConnected: isConnected,
                  deviceName: deviceName,
                  batteryLevel: batteryLevel,
                  onBackPressed: () => Navigator.of(context).pop(),
                  onEstopPressed: () =>
                      _sendCommand({"command": "ESTOP", "params": {}}),
                ),

                // 2. Main Content Area (Joysticks and Buttons)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Left Joystick
                        _buildJoystick(
                          "Drive",
                          (details) => setState(() {
                            _driveX = details.x;
                            _driveY = details.y;
                          }),
                          () {
                            setState(() {
                              _driveX = 0;
                              _driveY = 0;
                            });
                            _sendCommand({
                              "command": "DRIVE_DIRECT",
                              "params": {"left_speed": 0, "right_speed": 0},
                            });
                          },
                        ),

                        // Center Buttons
                        _buildCenterControlPanel(),

                        // Right Joystick
                        _buildJoystick(
                          "Head",
                          (details) => setState(() {
                            _headX = details.x;
                            _headY = details.y;
                          }),
                          () => setState(() {
                            _headX = 0;
                            _headY = 0;
                          }),
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

  // NEW: Widget for the central column of buttons for better organization
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
        _buildFlyoutButton(Icons.lightbulb, "LED Color", _showColorPicker),
      ],
    );
  }

  // --- All other helper methods (_buildJoystick, _showColorPicker, etc.) remain unchanged ---
  // --- Just copy them from your original file below this line ---

  // NOTE: I've copied them here for your convenience.

  void _sendCommand(Map<String, dynamic> command) {
    _bluetoothService?.sendCommand(command);
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

  void _sendHeadCommand() {
    int yaw = (95 + (_headX * 75)).clamp(20, 170).toInt();
    int pitch = (95 + (-_headY * 75)).clamp(20, 170).toInt();
    if (_headX.abs() > 0.1 || _headY.abs() > 0.1) {
      // Deadzone
      _sendCommand({
        "command": "SET_HEAD_POSITION",
        "params": {"pitch": pitch, "yaw": yaw},
      });
    }
  }

  void _toggleGripper() {
    setState(() => _isGripperOpen = !_isGripperOpen);
    _sendCommand({
      "command": "SET_GRIPPER",
      "params": {"state": _isGripperOpen ? "open" : "closed"},
    });
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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set LED Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentLedColor,
            onColorChanged: (color) => setState(() => _currentLedColor = color),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Set Color'),
            onPressed: () {
              _sendCommand({
                "command": "SET_LED_COLOR",
                "params": {
                  "led_id": "all",
                  "r": _currentLedColor.red,
                  "g": _currentLedColor.green,
                  "b": _currentLedColor.blue,
                },
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlyoutButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(180, 48),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildJoystick(
    String label,
    void Function(StickDragDetails) listener,
    VoidCallback onStickDragEnd,
  ) {
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
        Joystick(
          listener: listener,
          onStickDragEnd: onStickDragEnd,
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
      ],
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

// =========================================================================
// NEW WIDGET: The custom App Bar you requested
// =========================================================================
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

  // Helper to build the battery indicator
  Widget _buildBatteryIndicator(int? level) {
    IconData batteryIcon;
    if (level == null)
      batteryIcon = Icons.battery_unknown;
    else if (level > 90)
      batteryIcon = Icons.battery_full;
    else if (level > 75)
      batteryIcon = Icons.battery_6_bar;
    else if (level > 50)
      batteryIcon = Icons.battery_4_bar;
    else if (level > 25)
      batteryIcon = Icons.battery_2_bar;
    else
      batteryIcon = Icons.battery_alert;

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
