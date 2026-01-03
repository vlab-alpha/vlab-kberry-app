import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TempPoint {
  final DateTime time;
  final double temp;
  TempPoint(this.time, this.temp);
}

class TemperatureChart extends StatelessWidget {

  final List<TempPoint> points;
  const TemperatureChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: points.length.toDouble() - 1,
        minY: points.map((p) => p.temp).reduce((a, b) => a < b ? a : b) - 1,
        maxY: points.map((p) => p.temp).reduce((a, b) => a > b ? a : b) + 1,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: points
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.temp))
                .toList(),
            isCurved: true,
            barWidth: 2,
            color: Colors.orange,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}