// # Export ข้อมูลเป็น CSV/Excel

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../services/database_service.dart';

class ExportService {
  static Future<String> exportToCSV() async {
    List<Map<String, dynamic>> data = await DatabaseService.getLast30DaysData();

    List<List<dynamic>> csvData = [
      ["Timestamp", "Voltage (V)", "Current (A)", "Power (kWh)"]
    ];

    for (var row in data) {
      csvData.add([row["timestamp"], row["voltage"], row["current"], row["power"]]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/imeter_data.csv";
    File file = File(path);
    await file.writeAsString(csv);

    return path;
  }
}
