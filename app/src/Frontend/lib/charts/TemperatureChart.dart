import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TemperatureChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const TemperatureChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("Keine Daten verfügbar"));
    }

    // Daten in FlSpot umwandeln
    final spots = data.map((e) {
      final DateTime t = e["time"];
      final double temp = (e["temp"] as num).toDouble();
      return FlSpot(t.millisecondsSinceEpoch.toDouble(), temp);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // X-Achsenbereich
    double minX = spots.first.x;
    double maxX = spots.last.x;
    double interval = (maxX - minX) / 5;
    if (interval <= 0) interval = 1;

    // Y-Achsenbereich
    final temps = spots.map((e) => e.y).toList();
    final minY = temps.reduce((a, b) => a < b ? a : b) - 1;
    final maxY = temps.reduce((a, b) => a > b ? a : b) + 1;

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,

          gridData: FlGridData(show: true),

          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final dt =
                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  final txt =
                      "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

                  return Text(
                    txt,
                    style: const TextStyle(fontSize: 11),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    "${value.toStringAsFixed(1)}°C",
                    style: const TextStyle(fontSize: 11),
                  );
                },
              ),
            ),
          ),

          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade600),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 4,
              color: Colors.redAccent,
              dotData: const FlDotData(show: true),

              // 🌈 Der richtige Gradient für fl_chart 1.1.1
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withOpacity(0.30),
                    Colors.redAccent.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}