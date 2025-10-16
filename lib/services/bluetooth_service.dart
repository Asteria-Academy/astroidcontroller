// lib/services/bluetooth_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

// Standard Nordic UART Service UUIDs
final fbp.Guid nordicUartServiceUuid = fbp.Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
final fbp.Guid nordicUartRxCharUuid = fbp.Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"); // App -> Robot
final fbp.Guid nordicUartTxCharUuid = fbp.Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"); // Robot -> App

enum BluetoothConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  connectionFailed,
}

class BluetoothService with ChangeNotifier {
  BluetoothService._privateConstructor();
  static final BluetoothService instance = BluetoothService._privateConstructor();

  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  BluetoothConnectionState get connectionState => _connectionState;

  bool get isConnected => _connectionState == BluetoothConnectionState.connected;

  StreamSubscription? _scanResultsSubscription;
  StreamSubscription? _connectionStateSubscription;
  
  Timer? _batteryRequestTimer;

  List<fbp.ScanResult> _scanResults = [];
  List<fbp.ScanResult> get scanResults => _scanResults;

  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;

  int? _batteryLevel;
  int? get batteryLevel => _batteryLevel;

  fbp.BluetoothCharacteristic? _rxCharacteristic;
  fbp.BluetoothCharacteristic? _txCharacteristic;

  void _updateConnectionState(BluetoothConnectionState newState) {
    _connectionState = newState;
    notifyListeners();
  }

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

  Future<bool> connect(fbp.BluetoothDevice device) async {
    if (_connectionState == BluetoothConnectionState.connecting ||
        _connectionState == BluetoothConnectionState.connected) {
      return false;
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
      
      _startBatteryUpdates();

      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          debugPrint("Device disconnected unexpectedly.");
          _cleanUpConnection();
        }
      });
      return true;
    } catch (e) {
      debugPrint("Connection failed with exception: $e");
      _updateConnectionState(BluetoothConnectionState.connectionFailed);
      _cleanUpConnection();
      return false;
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
    _stopBatteryUpdates(); 
    
    _connectedDevice = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    
    _batteryLevel = null;
    
    _updateConnectionState(BluetoothConnectionState.disconnected);
  }

  Future<void> _discoverServicesAndCharacteristics(fbp.BluetoothDevice device) async {
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
      _txCharacteristic!.lastValueStream.listen(_onDataReceived);
    }

    if (_rxCharacteristic == null || _txCharacteristic == null) {
      debugPrint("Error: Could not find all required characteristics. Disconnecting.");
      disconnect();
      throw "UART Service characteristics not found.";
    }
  }

  void _onDataReceived(List<int> value) {
    if (value.isEmpty) return;
    
    try {
      final message = String.fromCharCodes(value);
      debugPrint("Received data from robot: $message");
      
      final jsonData = jsonDecode(message) as Map<String, dynamic>;

      if (jsonData['status'] == 'BATTERY' && jsonData.containsKey('level')) {
        final newLevel = jsonData['level'] as int?;
        if (_batteryLevel != newLevel) {
          _batteryLevel = newLevel;
          debugPrint('Battery level updated: $_batteryLevel%');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Failed to parse incoming data: $e');
    }
  }

  void _startBatteryUpdates() {
    _stopBatteryUpdates();
    
    _batteryRequestTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (isConnected) {
        _requestBatteryStatus();
      } else {
        timer.cancel();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), _requestBatteryStatus);
  }

  void _stopBatteryUpdates() {
    _batteryRequestTimer?.cancel();
    _batteryRequestTimer = null;
  }
  
  void _requestBatteryStatus() {
    debugPrint('Requesting battery status...');
    sendCommand({
      "command": "GET_BATTERY_STATUS",
      "params": {},
    });
  }

  Future<void> sendCommand(Map<String, dynamic> command) async {
    if (_rxCharacteristic == null) {
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