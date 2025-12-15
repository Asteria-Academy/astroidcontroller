import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/bluetooth_service.dart';
import 'services/preferences_service.dart';
import 'services/sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = PreferencesService.instance;
  await prefs.init();
  await SoundService.instance.init(
    bgmEnabled: prefs.isMusicEnabled(),
    bgmVolume: prefs.getMusicVolume(),
    sfxEnabled: prefs.isSfxEnabled(),
    sfxVolume: prefs.getSfxVolume(),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ChangeNotifierProvider(
      create: (_) => BluetoothService.instance,
      child: const MyApp(),
    ),
  );
}
