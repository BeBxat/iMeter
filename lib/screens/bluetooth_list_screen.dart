import 'package:flutter/material.dart';
import '../services/ble_service.dart';

class BluetoothListScreen extends StatefulWidget {
  const BluetoothListScreen({super.key});

  @override
  _BluetoothListScreenState createState() => _BluetoothListScreenState();
}

class _BluetoothListScreenState extends State<BluetoothListScreen> {
  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  Future<void> _scanForDevices() async {
    await BLEService.scanForDevices();
    setState(() {});
  }

  Future<void> _connectToDevice(device) async {
    await BLEService.connectToDevice(device);
    Navigator.of(
      context,
    ).pop(device.name.isNotEmpty ? device.name : device.id.toString());
  }

  Future<void> _disconnectFromDevice() async {
    await BLEService.disconnectFromDevice();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เลือกอุปกรณ์")),
      body: Column(
        children: [
          if (BLEService.connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _disconnectFromDevice,
                icon: const Icon(Icons.bluetooth_disabled),
                label: const Text("ยกเลิกการเชื่อมต่อ"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 15,
                  shadowColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          Expanded(
            child:
                BLEService.visibleDevices.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: BLEService.visibleDevices.length,
                      itemBuilder: (context, index) {
                        var device = BLEService.visibleDevices[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            leading: Icon(
                              Icons.bluetooth,
                              color: Colors.deepPurpleAccent,
                              size: 30,
                            ),
                            title: Text(
                              device.name.isNotEmpty
                                  ? device.name
                                  : device.id.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              device.id.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.deepPurpleAccent,
                            ),
                            onTap: () => _connectToDevice(device),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
