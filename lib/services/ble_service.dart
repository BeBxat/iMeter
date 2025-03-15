//# จัดการการเชื่อมต่อ BLE # ควบคุมการเชื่อมต่อ BLE

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class BLEService {
  static BluetoothDevice? connectedDevice;
  static BluetoothCharacteristic? meterCharacteristic;
  static List<BluetoothDevice> visibleDevices = [];
  static final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();
  static Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;

  static Future<void> requestBluetoothPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isPermissionGranted = prefs.getBool('bluetooth_permission_granted');

    if (isPermissionGranted == true) {
      return;
    }

    if (await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted) {
      await prefs.setBool('bluetooth_permission_granted', true);
      return;
    }

    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted) {
      await prefs.setBool('bluetooth_permission_granted', true);
    }
  }

  static Future<void> scanForDevices() async {
    visibleDevices.clear();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (!visibleDevices.contains(r.device)) {
          visibleDevices.add(r.device);
        }
        if (r.device.name == "iMeter_ST-1EMH") {
          print("พบ iMeter: ${r.device.id}");
          connectedDevice = r.device;
          await connectToIMeter();
          FlutterBluePlus.stopScan();
          break;
        }
      }
    });
  }

  static Future<void> connectToDevice(BluetoothDevice device) async {
    connectedDevice = device;
    await connectToIMeter();
    _connectionStatusController.add(
      "เชื่อมต่อกับ ${device.name.isNotEmpty ? device.name : device.id}",
    );
  }

  static Future<void> disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      meterCharacteristic = null;
      _connectionStatusController.add("ยังไม่ได้เชื่อมต่อ");
    }
  }

  static Future<void> connectToIMeter() async {
    if (connectedDevice == null) return;

    await connectedDevice!.connect();
    print("เชื่อมต่อสำเร็จ: ${connectedDevice!.id}");

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == "e973f2e2-b19e-11e2-9e96-0800200c9a66") {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() ==
              "d973f2e1-b19e-11e2-9e96-0800200c9a66") {
            meterCharacteristic = characteristic;
            print("พบ Characteristic ของมิเตอร์!");
          }
        }
      }
    }
  }

  static Future<void> sendCommandToIMeter(List<int> command) async {
    if (meterCharacteristic == null) {
      print("ยังไม่ได้เชื่อมต่อ BLE");
      return;
    }

    await meterCharacteristic!.write(command);
    print(
      "ส่งคำสั่งไปยัง iMeter: ${command.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}",
    );
  }
}
