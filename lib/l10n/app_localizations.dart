import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Astroid Remote'**
  String get appTitle;

  /// Button text to connect to Bluetooth device
  ///
  /// In en, this message translates to:
  /// **'CONNECT'**
  String get connectButton;

  /// Button text to disconnect from Bluetooth device
  ///
  /// In en, this message translates to:
  /// **'DISCONNECT'**
  String get disconnectButton;

  /// Button text to open remote control
  ///
  /// In en, this message translates to:
  /// **'REMOTE'**
  String get remoteButton;

  /// Title of the settings screen
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// Setting label for haptic feedback toggle
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Description for haptic feedback setting
  ///
  /// In en, this message translates to:
  /// **'Feel button presses'**
  String get hapticFeedbackDesc;

  /// Button to replay the tutorial
  ///
  /// In en, this message translates to:
  /// **'Show Tutorial'**
  String get showTutorial;

  /// Description for show tutorial button
  ///
  /// In en, this message translates to:
  /// **'Replay the app walkthrough'**
  String get showTutorialDesc;

  /// Button to show about dialog
  ///
  /// In en, this message translates to:
  /// **'About & Licenses'**
  String get aboutLicenses;

  /// Description for about button
  ///
  /// In en, this message translates to:
  /// **'App info and legal notices'**
  String get aboutLicensesDesc;

  /// Status message when connected to a device
  ///
  /// In en, this message translates to:
  /// **'Connected to: {deviceName}'**
  String connectedTo(String deviceName);

  /// Status message when not connected
  ///
  /// In en, this message translates to:
  /// **'No Robot Connected'**
  String get noRobotConnected;

  /// Tutorial title for connect button
  ///
  /// In en, this message translates to:
  /// **'Connect to Robot'**
  String get showcaseConnectTitle;

  /// Tutorial description for connect button
  ///
  /// In en, this message translates to:
  /// **'Tap here to scan for and connect to your Astroid robot via Bluetooth.'**
  String get showcaseConnectDesc;

  /// Tutorial title for status indicator
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get showcaseStatusTitle;

  /// Tutorial description for status indicator
  ///
  /// In en, this message translates to:
  /// **'This shows whether your robot is connected. When connected, you can access the remote control.'**
  String get showcaseStatusDesc;

  /// Tutorial title for settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get showcaseSettingsTitle;

  /// Tutorial description for settings button
  ///
  /// In en, this message translates to:
  /// **'Adjust app settings, toggle haptic feedback, or replay this tutorial anytime.'**
  String get showcaseSettingsDesc;

  /// Version label in settings
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// App description in about dialog
  ///
  /// In en, this message translates to:
  /// **'A remote control app for Astroid robots. Connect via Bluetooth and control your robot with intuitive controls.'**
  String get aboutDescription;

  /// Copyright notice
  ///
  /// In en, this message translates to:
  /// **'© 2025 Asteria Academy'**
  String get copyright;

  /// Setting label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Description for language setting
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get languageDesc;

  /// Tutorial title for disconnect button
  ///
  /// In en, this message translates to:
  /// **'Disconnect Button'**
  String get showcaseDisconnectTitle;

  /// Tutorial description for disconnect button
  ///
  /// In en, this message translates to:
  /// **'Tap here to disconnect from your robot and return to connection screen. You can replay this tutorial from Settings.'**
  String get showcaseDisconnectDesc;

  /// Tutorial title for remote button
  ///
  /// In en, this message translates to:
  /// **'Remote Control'**
  String get showcaseRemoteTitle;

  /// Tutorial description for remote button
  ///
  /// In en, this message translates to:
  /// **'Tap here to open the remote control interface and control your robot. You can replay this tutorial from Settings.'**
  String get showcaseRemoteDesc;

  /// Title of the connect screen
  ///
  /// In en, this message translates to:
  /// **'Connect to Robot'**
  String get connectScreenTitle;

  /// Connection status message
  ///
  /// In en, this message translates to:
  /// **'Connected to: {deviceName}'**
  String connectedToDevice(String deviceName);

  /// Battery level display
  ///
  /// In en, this message translates to:
  /// **'Battery: {level}%'**
  String batteryLevel(String level);

  /// Disconnect button text
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Message when robot is connected and ready
  ///
  /// In en, this message translates to:
  /// **'Robot is Ready!'**
  String get robotReady;

  /// Message prompting user to go back to home screen
  ///
  /// In en, this message translates to:
  /// **'Go back and start your adventure.'**
  String get goBackStart;

  /// Message while scanning for robots
  ///
  /// In en, this message translates to:
  /// **'Searching for Astroid robots...'**
  String get searchingRobots;

  /// Message when no robots found
  ///
  /// In en, this message translates to:
  /// **'No Robots Found'**
  String get noRobotsFound;

  /// Instructions when no robots found
  ///
  /// In en, this message translates to:
  /// **'Make sure your robot is turned on and press Scan.'**
  String get ensureRobotOn;

  /// Text shown during scan
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// Button text to start scanning
  ///
  /// In en, this message translates to:
  /// **'Scan for Robots'**
  String get scanForRobots;

  /// Success message when connected
  ///
  /// In en, this message translates to:
  /// **'Successfully connected to {deviceName}'**
  String successfullyConnected(String deviceName);

  /// Error message when connection fails
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Please try again.'**
  String get connectionFailed;

  /// Success message on connecting screen
  ///
  /// In en, this message translates to:
  /// **'Successfully Connected!'**
  String get successfullyConnectedExclaim;

  /// Connection confirmation message
  ///
  /// In en, this message translates to:
  /// **'Connected to {deviceName}'**
  String connectedToDeviceConnecting(String deviceName);

  /// Title when connection fails
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailedTitle;

  /// Error message when unable to connect
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the robot.'**
  String get couldNotConnect;

  /// Button to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Status message while connecting
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Message while establishing connection
  ///
  /// In en, this message translates to:
  /// **'Establishing link with {deviceName}'**
  String establishingLink(String deviceName);

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Message shown when disconnecting from robot
  ///
  /// In en, this message translates to:
  /// **'Disconnecting...'**
  String get disconnecting;

  /// Label for drive joystick
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get driveJoystick;

  /// Label for head joystick
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get headJoystick;

  /// Button text to close gripper
  ///
  /// In en, this message translates to:
  /// **'Close Gripper'**
  String get closeGripper;

  /// Button text to open gripper
  ///
  /// In en, this message translates to:
  /// **'Open Gripper'**
  String get openGripper;

  /// Button label for robot expressions
  ///
  /// In en, this message translates to:
  /// **'Expressions'**
  String get expressions;

  /// Button label for robot sounds
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// Button label for LED color control
  ///
  /// In en, this message translates to:
  /// **'LED Color'**
  String get ledColor;

  /// Button label for special modes
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get modes;

  /// Dialog title for LED control
  ///
  /// In en, this message translates to:
  /// **'LED Control'**
  String get ledControl;

  /// Instruction to tap LED segment
  ///
  /// In en, this message translates to:
  /// **'Tap a segment'**
  String get tapSegment;

  /// Instruction to select a color
  ///
  /// In en, this message translates to:
  /// **'Select a color'**
  String get selectColor;

  /// Button to set all LEDs to same color
  ///
  /// In en, this message translates to:
  /// **'Set All LEDs'**
  String get setAllLeds;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Dialog title for setting robot expression
  ///
  /// In en, this message translates to:
  /// **'Set Expression'**
  String get setExpression;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Dialog title for playing sounds
  ///
  /// In en, this message translates to:
  /// **'Play Sound'**
  String get playSound;

  /// Dialog title for special modes
  ///
  /// In en, this message translates to:
  /// **'Special Modes'**
  String get specialModes;

  /// Line follower mode label
  ///
  /// In en, this message translates to:
  /// **'Line Follower'**
  String get lineFollower;

  /// Start/Stop button text
  ///
  /// In en, this message translates to:
  /// **'Start/Stop'**
  String get startStop;

  /// Calibrate button text
  ///
  /// In en, this message translates to:
  /// **'Calibrate'**
  String get calibrate;

  /// Wonder Pack gestures section label
  ///
  /// In en, this message translates to:
  /// **'Wonder Pack Gestures'**
  String get wonderPackGestures;

  /// Gripper gesture label
  ///
  /// In en, this message translates to:
  /// **'Gripper'**
  String get gripper;

  /// Sketcher gesture label
  ///
  /// In en, this message translates to:
  /// **'Sketcher'**
  String get sketcher;

  /// Launcher gesture label
  ///
  /// In en, this message translates to:
  /// **'Launcher'**
  String get launcher;

  /// Emergency stop button text
  ///
  /// In en, this message translates to:
  /// **'E-STOP'**
  String get emergencyStop;

  /// Button text for 'Next' in tutorials
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// Button text for 'Previous' in tutorials
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get btnPrevious;

  /// Button text for 'Skip' in tutorials
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get btnSkip;

  /// Button text for 'Finish' in tutorials
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get btnFinish;

  /// Instruction to pick a color for LED segment
  ///
  /// In en, this message translates to:
  /// **'Pick a color for the LED segment.'**
  String get pickAColor;

  /// Select Custom Color button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
