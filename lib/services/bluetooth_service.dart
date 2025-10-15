import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

// Standard Nordic UART Service UUIDs
final fbp.Guid nordicUartServiceUuid = fbp.Guid(
  "6E400001-B5A3-F393-E0A9-E50E24DCCA9E",
);
final fbp.Guid nordicUartRxCharUuid = fbp.Guid(
  "6E400002-B5A3-F393-E0A9-E50E24DCCA9E",
); // App -> Robot
final fbp.Guid nordicUartTxCharUuid = fbp.Guid(
  "6E400003-B5A3-F393-E0A9-E50E24DCCA9E",
); // Robot -> App

enum BluetoothConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  connectionFailed,
}

class BluetoothService with ChangeNotifier {
  BluetoothService._privateConstructor();
  static final BluetoothService instance =
      BluetoothService._privateConstructor();

  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  BluetoothConnectionState get connectionState => _connectionState;

  StreamSubscription? _scanResultsSubscription;
  StreamSubscription? _connectionStateSubscription;

  List<fbp.ScanResult> _scanResults = [];
  List<fbp.ScanResult> get scanResults => _scanResults;

  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;

  fbp.BluetoothCharacteristic? _rxCharacteristic;
  fbp.BluetoothCharacteristic? _txCharacteristic;

  void _updateConnectionState(BluetoothConnectionState newState) {
    _connectionState = newState;
    notifyListeners();
  }

  // **** THIS METHOD NOW EXACTLY MATCHES YOUR WORKING LOGIC ****
  Future<void> startScan() async {
    if (_connectionState == BluetoothConnectionState.scanning) return;

    if (fbp.FlutterBluePlus.adapterStateNow != fbp.BluetoothAdapterState.on) {
      debugPrint("Bluetooth adapter is off.");
      try {
        await fbp.FlutterBluePlus.turnOn();
      } catch (e) {
        debugPrint("Error turning on Bluetooth: $e");
        return;
      }
    }

    _updateConnectionState(BluetoothConnectionState.scanning);
    _scanResults = [];
    notifyListeners();

    try {
      // Performing a GENERIC scan, without the `withServices` filter.
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      debugPrint("Error starting scan: $e");
      _updateConnectionState(BluetoothConnectionState.disconnected);
      return;
    }

    _scanResultsSubscription = fbp.FlutterBluePlus.scanResults.listen(
      (results) {
        _scanResults = results;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Scan error: $e");
        stopScan();
      },
    );

    fbp.FlutterBluePlus.isScanning.where((val) => val == false).first.then((_) {
      _scanResultsSubscription?.cancel();
      if (_connectionState == BluetoothConnectionState.scanning) {
        _updateConnectionState(BluetoothConnectionState.disconnected);
      }
    });
  }

  void stopScan() {
    fbp.FlutterBluePlus.stopScan();
    _scanResultsSubscription?.cancel();
    if (_connectionState == BluetoothConnectionState.scanning) {
      _updateConnectionState(BluetoothConnectionState.disconnected);
    }
  }

  Future<void> connect(fbp.BluetoothDevice device) async {
    if (_connectionState == BluetoothConnectionState.connecting ||
        _connectionState == BluetoothConnectionState.connected) {
      return;
    }
    stopScan();
    _updateConnectionState(BluetoothConnectionState.connecting);

    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
        license: fbp.License.free,
      );
      _connectedDevice = device;
      await _discoverServicesAndCharacteristics(device);
      _updateConnectionState(BluetoothConnectionState.connected);

      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          debugPrint("Device disconnected unexpectedly.");
          _cleanUpConnection();
        }
      });
    } catch (e) {
      debugPrint("Connection failed with exception: $e");
      _updateConnectionState(BluetoothConnectionState.connectionFailed);
      _cleanUpConnection();
    }
  }

  Future<void> disconnect() async {
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
    }
    _cleanUpConnection();
  }

  void _cleanUpConnection() {
    _connectedDevice = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    _updateConnectionState(BluetoothConnectionState.disconnected);
  }

  Future<void> _discoverServicesAndCharacteristics(
    fbp.BluetoothDevice device,
  ) async {
    List<fbp.BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid == nordicUartServiceUuid) {
        for (var char in service.characteristics) {
          if (char.uuid == nordicUartRxCharUuid) _rxCharacteristic = char;
          if (char.uuid == nordicUartTxCharUuid) _txCharacteristic = char;
        }
      }
    }

    if (_txCharacteristic != null) {
      await _txCharacteristic!.setNotifyValue(true);
      _txCharacteristic!.lastValueStream.listen((value) {
        final String data = String.fromCharCodes(value);
        if (data.isNotEmpty) {
          debugPrint("Received data from robot: $data");
        }
      });
    }

    if (_rxCharacteristic == null || _txCharacteristic == null) {
      debugPrint(
        "Error: Could not find all required characteristics. Disconnecting.",
      );
      disconnect();
      throw "UART Service characteristics not found.";
    }
  }

  Future<void> sendCommand(Map<String, dynamic> command) async {
    if (_rxCharacteristic == null) {
      // Silently ignore commands when not connected (useful for demo/testing mode)
      // debugPrint("Cannot send command: RX characteristic not available.");
      return;
    }
    final String jsonCommand = jsonEncode(command);
    try {
      await _rxCharacteristic!.write(
        jsonCommand.codeUnits,
        withoutResponse: true,
      );
      debugPrint("Sent: $jsonCommand");
    } catch (e) {
      debugPrint("Error sending command: $e");
    }
  }
}
