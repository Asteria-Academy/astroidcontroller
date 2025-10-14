// lib/screens/connect_screen.dart

import 'package:astroidcontroller/router/app_router.dart';
import 'package:astroidcontroller/services/bluetooth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService, BluetoothConnectionState;
import 'package:provider/provider.dart';


class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final btService = context.watch<BluetoothService>();

    if (btService.connectionState == BluetoothConnectionState.connected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          Navigator.pushReplacementNamed(context, AppRoutes.remoteControl);
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1433),
      appBar: AppBar(
        title: const Text("Connect to Robot"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            _buildScanButton(context, btService),
            _buildScanResultList(context, btService),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context, BluetoothService btService) {
    final bool isScanning = btService.connectionState == BluetoothConnectionState.scanning;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: isScanning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.bluetooth_searching),
        label: Text(isScanning ? "Scanning..." : "Scan for Robots"),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 50),
          backgroundColor: isScanning ? Colors.grey[700] : Theme.of(context).primaryColor,
        ),
        onPressed: isScanning ? null : btService.startScan,
      ),
    );
  }

  Widget _buildScanResultList(BuildContext context, BluetoothService btService) {
    List<ScanResult> namedResults = btService.scanResults
        .where((r) => r.device.platformName.isNotEmpty)
        .toList();
    namedResults.sort((a, b) {
      if (a.device.platformName == "AstroidRobot-Beta") return -1;
      if (b.device.platformName == "AstroidRobot-Beta") return 1;
      return b.rssi.compareTo(a.rssi);
    });

    if (btService.connectionState == BluetoothConnectionState.scanning && namedResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Searching for Astroid robots...", style: TextStyle(color: Colors.white70)),
      );
    }

    if (namedResults.isEmpty && btService.connectionState != BluetoothConnectionState.scanning) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No robots found. Make sure your robot is on and press Scan.", style: TextStyle(color: Colors.white70)),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: namedResults.length,
        itemBuilder: (context, index) {
          final result = namedResults[index];
          final isAstroid = result.device.platformName == "AstroidRobot-Beta";

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            color: isAstroid ? const Color(0xFF1A3D6F) : const Color(0xFF1A244A),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isAstroid ? const BorderSide(color: Colors.cyanAccent, width: 1.5) : BorderSide.none),
            child: ListTile(
              leading: const Icon(Icons.smart_toy_outlined, color: Colors.white),
              title: Text(result.device.platformName,
                  style: TextStyle(fontWeight: isAstroid ? FontWeight.bold : FontWeight.normal, color: Colors.white)),
              subtitle: Text(result.device.remoteId.toString(), style: const TextStyle(color: Colors.white70)),
              trailing: Text("${result.rssi} dBm", style: const TextStyle(color: Colors.cyan)),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.connecting,
                  arguments: result.device,
                );
              },
            ),
          );
        },
      ),
    );
  }
}