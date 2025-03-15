//# ฟังก์ชันช่วยแปลงข้อมูล BLE

class HexConverter {
  static String bytesToHex(List<int> bytes) {
    return bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
  }
}
