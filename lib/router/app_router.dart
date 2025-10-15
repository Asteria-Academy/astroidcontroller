// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../screens/home_screen.dart';
import '../screens/connect_screen.dart';
import '../screens/connecting_screen.dart';
import '../screens/remote_control_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String connect = '/connect';
  static const String connecting = '/connecting';
  static const String remoteControl = '/remote-control';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());

    case AppRoutes.connect:
      return MaterialPageRoute(builder: (_) => const ConnectScreen());

    case AppRoutes.connecting:
      final device = settings.arguments as fbp.BluetoothDevice;
      return MaterialPageRoute(
        builder: (_) => ConnectingScreen(device: device),
      );

    case AppRoutes.remoteControl:
      return MaterialPageRoute(builder: (_) => const RemoteControlScreen());

    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
