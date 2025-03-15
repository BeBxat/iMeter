//# หน้าสำหรับแสดงค่าจากมิเตอร์ # หน้าดูค่าจาก iMeter  meter_screen.dart

import 'package:flutter/material.dart';
import '../services/meter_service.dart';
import '../services/ble_service.dart';

class MeterScreen extends StatefulWidget {
  const MeterScreen({super.key});

  @override
  _MeterScreenState createState() => _MeterScreenState();
}

class _MeterScreenState extends State<MeterScreen> {
  String meterData = "รอข้อมูล...";
  bool isLoading = false;

  void readMeterData() async {
    setState(() {
      isLoading = true;
    });

    // Example command to send to iMeter
    List<int> command = [0x01, 0x03, 0x00, 0x00, 0x00, 0x0A];
    await BLEService.sendCommandToIMeter(command);

    String data = await MeterService.readIMeterData();
    setState(() {
      meterData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ข้อมูลมิเตอร์")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? CircularProgressIndicator()
                : Text(meterData, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : readMeterData,
              icon: const Icon(Icons.refresh),
              label: const Text("อ่านค่าจาก iMeter"),
            ),
          ],
        ),
      ),
    );
  }
}
