import 'ble_service.dart';
import '../utils/hex_converter.dart';

class MeterService {
  static Future<String> readIMeterData() async {
    if (BLEService.meterCharacteristic == null) {
      return "ยังไม่ได้เชื่อมต่อ BLE";
    }

    List<int> value = await BLEService.meterCharacteristic!.read();
    String hexData = HexConverter.bytesToHex(value);

    return "ค่าที่อ่านได้: $hexData";
  }
}
