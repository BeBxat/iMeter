// หน้ากราฟสถิติย้อนหลัง

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/database_service.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<FlSpot> voltageData = [];
  List<FlSpot> currentData = [];
  List<FlSpot> powerData = [];

  @override
  void initState() {
    super.initState();
    loadChartData();
  }

  void loadChartData() async {
    List<Map<String, dynamic>> data = await DatabaseService.getLast30DaysData();

    setState(() {
      voltageData =
          data.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value['voltage']);
          }).toList();

      currentData =
          data.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value['current']);
          }).toList();

      powerData =
          data.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value['power']);
          }).toList();
    });
  }

  Widget buildChart(List<FlSpot> data, String title, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 200,
          child:
              data.isEmpty
                  ? Center(
                    child: Text(
                      "ไม่มีข้อมูล",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : LineChart(
                    LineChartData(
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.8), color],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                        ),
                      ],
                    ),
                  ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สถิติย้อนหลัง 30 วัน")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildChart(voltageData, "แรงดันไฟฟ้า (V)", Colors.blue),
            buildChart(currentData, "กระแสไฟ (A)", Colors.green),
            buildChart(powerData, "พลังงาน (kWh)", Colors.red),
          ],
        ),
      ),
    );
  }
}
