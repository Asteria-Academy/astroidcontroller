// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Astroid Remote';

  @override
  String get connectButton => 'CONNECT';

  @override
  String get disconnectButton => 'DISCONNECT';

  @override
  String get remoteButton => 'REMOTE';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDesc => 'Feel button presses';

  @override
  String get showTutorial => 'Show Tutorial';

  @override
  String get showTutorialDesc => 'Replay the app walkthrough';

  @override
  String get aboutLicenses => 'About & Licenses';

  @override
  String get aboutLicensesDesc => 'App info and legal notices';

  @override
  String connectedTo(String deviceName) {
    return 'Connected to: $deviceName';
  }

  @override
  String get noRobotConnected => 'No Robot Connected';

  @override
  String get showcaseConnectTitle => 'Connect to Robot';

  @override
  String get showcaseConnectDesc =>
      'Tap here to scan for and connect to your Astroid robot via Bluetooth.';

  @override
  String get showcaseStatusTitle => 'Connection Status';

  @override
  String get showcaseStatusDesc =>
      'This shows whether your robot is connected. When connected, you can access the remote control.';

  @override
  String get showcaseSettingsTitle => 'Settings';

  @override
  String get showcaseSettingsDesc =>
      'Adjust app settings, toggle haptic feedback, or replay this tutorial anytime.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription =>
      'A remote control app for Astroid robots. Connect via Bluetooth and control your robot with intuitive controls.';

  @override
  String get copyright => '© 2025 Asteria Academy';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Change app language';

  @override
  String get showcaseDisconnectTitle => 'Disconnect Button';

  @override
  String get showcaseDisconnectDesc =>
      'Tap here to disconnect from your robot and return to connection screen. You can replay this tutorial from Settings.';

  @override
  String get showcaseRemoteTitle => 'Remote Control';

  @override
  String get showcaseRemoteDesc =>
      'Tap here to open the remote control interface and control your robot. You can replay this tutorial from Settings.';

  @override
  String get connectScreenTitle => 'Connect to Robot';

  @override
  String connectedToDevice(String deviceName) {
    return 'Connected to: $deviceName';
  }

  @override
  String batteryLevel(String level) {
    return 'Battery: $level%';
  }

  @override
  String get disconnect => 'Disconnect';

  @override
  String get robotReady => 'Robot is Ready!';

  @override
  String get goBackStart => 'Go back and start your adventure.';

  @override
  String get searchingRobots => 'Searching for Astroid robots...';

  @override
  String get noRobotsFound => 'No Robots Found';

  @override
  String get ensureRobotOn =>
      'Make sure your robot is turned on and press Scan.';

  @override
  String get scanning => 'Scanning...';

  @override
  String get scanForRobots => 'Scan for Robots';

  @override
  String successfullyConnected(String deviceName) {
    return 'Successfully connected to $deviceName';
  }

  @override
  String get connectionFailed => 'Connection failed. Please try again.';

  @override
  String get successfullyConnectedExclaim => 'Successfully Connected!';

  @override
  String connectedToDeviceConnecting(String deviceName) {
    return 'Connected to $deviceName';
  }

  @override
  String get connectionFailedTitle => 'Connection Failed';

  @override
  String get couldNotConnect => 'Could not connect to the robot.';

  @override
  String get goBack => 'Go Back';

  @override
  String get connecting => 'Connecting...';

  @override
  String establishingLink(String deviceName) {
    return 'Establishing link with $deviceName';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get disconnecting => 'Disconnecting...';

  @override
  String get driveJoystick => 'Drive';

  @override
  String get headJoystick => 'Head';

  @override
  String get closeGripper => 'Close Gripper';

  @override
  String get openGripper => 'Open Gripper';

  @override
  String get expressions => 'Expressions';

  @override
  String get sounds => 'Sounds';

  @override
  String get ledColor => 'LED Color';

  @override
  String get modes => 'Modes';

  @override
  String get ledControl => 'LED Control';

  @override
  String get tapSegment => 'Tap a segment';

  @override
  String get selectColor => 'Select a color';

  @override
  String get setAllLeds => 'Set All LEDs';

  @override
  String get done => 'Done';

  @override
  String get setExpression => 'Set Expression';

  @override
  String get close => 'Close';

  @override
  String get playSound => 'Play Sound';

  @override
  String get specialModes => 'Special Modes';

  @override
  String get lineFollower => 'Line Follower';

  @override
  String get startStop => 'Start/Stop';

  @override
  String get calibrate => 'Calibrate';

  @override
  String get wonderPackGestures => 'Wonder Pack Gestures';

  @override
  String get gripper => 'Gripper';

  @override
  String get sketcher => 'Sketcher';

  @override
  String get launcher => 'Launcher';

  @override
  String get emergencyStop => 'E-STOP';

  @override
  String get btnNext => 'Next';

  @override
  String get btnPrevious => 'Previous';

  @override
  String get btnSkip => 'Skip';

  @override
  String get btnFinish => 'Finish';

  @override
  String get pickAColor => 'Pick a color for the LED segment.';

  @override
  String get select => 'Select';
}
