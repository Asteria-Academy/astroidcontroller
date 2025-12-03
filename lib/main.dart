import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/bluetooth_service.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferencesService.instance.init();

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