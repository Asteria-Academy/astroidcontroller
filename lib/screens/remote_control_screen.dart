// lib/screens/remote_control_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
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

  bool _isGripperOpen = true;
  Color _currentLedColor = Colors.deepPurpleAccent;
  double _driveX = 0, _driveY = 0;
  double _headX = 0, _headY = 0;

  bool _gestureGripper = false;
  bool _gestureSketcher = false;
  bool _gestureLauncher = false;

  @override
  void initState() {
    super.initState();
    _driveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => _sendDriveCommand());
    _headTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => _sendHeadCommand());
  }

  @override
  void dispose() {
    _driveTimer?.cancel();
    _headTimer?.cancel();
    _sendCommand({"command": "DRIVE_DIRECT", "params": {"left_speed": 0, "right_speed": 0}});
    super.dispose();
  }

  void _sendCommand(Map<String, dynamic> command) {
    if (mounted) {
      context.read<BluetoothService>().sendCommand(command);
    }
  }

  void _sendDriveCommand() {
    double y = -_driveY;
    double x = _driveX;
    double speed = y * 100;
    double turn = x * 100;
    int leftSpeed = (speed + turn).clamp(-100, 100).toInt();
    int rightSpeed = (speed - turn).clamp(-100, 100).toInt();
    if (leftSpeed != 0 || rightSpeed != 0 || _driveX != 0 || _driveY != 0) {
      _sendCommand({"command": "DRIVE_DIRECT", "params": {"left_speed": leftSpeed, "right_speed": rightSpeed}});
    }
  }

  void _sendHeadCommand() {
    int yaw = (95 + (_headX * 75)).clamp(20, 170).toInt();
    int pitch = (95 + (-_headY * 75)).clamp(20, 170).toInt();
    if (_headX != 0 || _headY != 0) {
      _sendCommand({"command": "SET_HEAD_POSITION", "params": {"pitch": pitch, "yaw": yaw}});
    }
  }

  void _toggleGripper() {
    setState(() => _isGripperOpen = !_isGripperOpen);
    _sendCommand({"command": "SET_GRIPPER", "params": {"state": _isGripperOpen ? "open" : "closed"}});
  }

  void _setGestureMode(String mode, bool active) {
    setState(() {
      if (mode == "gripper") _gestureGripper = active;
      if (mode == "sketcher") _gestureSketcher = active;
      if (mode == "launcher") _gestureLauncher = active;
    });
    _sendCommand({"command": "SET_GESTURE_MODE", "params": {"mode": mode, "active": active}});
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
          _iconButton(Icons.edit, "custom", Colors.grey),
        ]),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
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
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
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
                    ElevatedButton(child: const Text("Start/Stop"), onPressed: () => _sendCommand({"command": "SET_AUTONOMOUS_STATE", "params": {"mode": "line_follower", "active": true}})),
                    const SizedBox(width: 10),
                    ElevatedButton(child: const Text("Calibrate"), onPressed: () => _sendCommand({"command": "CALIBRATE_SENSORS", "params": {}})),
                  ]),
                  const SizedBox(height: 20),
                  _buildControlCard('Wonder Pack Gestures', [
                    _gestureSwitch("Gripper", "gripper", _gestureGripper, setDialogState),
                    _gestureSwitch("Sketcher", "sketcher", _gestureSketcher, setDialogState),
                    _gestureSwitch("Launcher", "launcher", _gestureLauncher, setDialogState),
                  ])
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
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
              // ignore: deprecated_member_use
              _sendCommand({ "command": "SET_LED_COLOR", "params": {"led_id": "all", "r": _currentLedColor.red, "g": _currentLedColor.green, "b": _currentLedColor.blue}});
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final btState = context.watch<BluetoothService>().connectionState;
    if (btState != BluetoothConnectionState.connected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return const Scaffold(body: Center(child: Text("Disconnecting...")));
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const Spacer(flex: 2), 
                
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildJoystick("Drive", (details) => setState(() { _driveX = details.x; _driveY = details.y; }), () {
                        setState(() { _driveX = 0; _driveY = 0; });
                        _sendCommand({"command": "DRIVE_DIRECT", "params": {"left_speed": 0, "right_speed": 0}});
                      }),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(_isGripperOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                            label: Text(_isGripperOpen ? "Close Gripper" : "Open Gripper"),
                            onPressed: _toggleGripper,
                            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 50)),
                          ),
                          const SizedBox(height: 24),
                          _buildFlyoutButton(Icons.sentiment_very_satisfied, "Expressions", _showExpressionsDialog),
                          const SizedBox(height: 12),
                          _buildFlyoutButton(Icons.music_note, "Sounds", _showSoundsDialog),
                          const SizedBox(height: 12),
                          _buildFlyoutButton(Icons.smart_toy, "Modes", _showModesDialog),
                          const SizedBox(height: 12),
                          _buildFlyoutButton(Icons.lightbulb, "LED Color", _showColorPicker),
                        ],
                      ),

                      _buildJoystick("Head", (details) => setState(() { _headX = details.x; _headY = details.y; }), () => setState(() { _headX = 0; _headY = 0; })),
                    ],
                  ),
                ),
                const Spacer(flex: 1), 
              ],
            ),
            _buildTopOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<BluetoothService>().disconnect(),
            ),
            ElevatedButton(
              onPressed: () => _sendCommand({"command": "ESTOP", "params": {}}),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('EMERGENCY STOP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildFlyoutButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(180, 50),
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildJoystick(String label, void Function(StickDragDetails) listener, VoidCallback onStickDragEnd) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Joystick(
          listener: listener,
          onStickDragEnd: onStickDragEnd,
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
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
            const SizedBox(height: 8),
          ],
          Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 10, children: children),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, String iconName, Color color) {
    return ElevatedButton(
      onPressed: () {
        _sendCommand({"command": "DISPLAY_ICON", "params": {"icon_name": iconName}});
      },
      style: ElevatedButton.styleFrom(backgroundColor: color, shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
      child: Icon(icon, size: 24),
    );
  }

  Widget _soundButton(IconData icon, int soundId) {
    return ElevatedButton(
      onPressed: () {
        _sendCommand({"command": "PLAY_INTERNAL_SOUND", "params": {"sound_id": soundId}});
      },
      style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
      child: Icon(icon, size: 24),
    );
  }

  Widget _gestureSwitch(String label, String mode, bool value, void Function(void Function()) setDialogState) {
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
        )
      ],
    );
  }
}