import 'package:flutter/material.dart';
import 'package:SmartHome/model/data.dart';

class TemperatureCard extends StatelessWidget {
  final Information information;

  const TemperatureCard({super.key, required this.information});

  int get percent => int.tryParse(information.firstValue) ?? 0;

  double get temperature =>
      double.tryParse(information.secondValue ?? "0.0") ?? 0.0;

  bool get isHeating => percent > 0;

  Color getBgColor() {
    return isHeating ? Colors.orange.shade800 : Colors.green.shade300;
  }

  String get heaterType {
    if (percent <= 0) {
      return "aus"; // 0% = aus
    } else if (percent <= 20) {
      return "sehr sanft";
    } else if (percent <= 50) {
      return "moderat";
    } else if (percent <= 80) {
      return "kräftig";
    } else {
      return "maximal";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = Colors.orangeAccent;
    final Color bgColor = const Color(0xFF3A3A3A);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: getBgColor(), width: 5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Raumname
            Text(
              information.room.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),

            // Icon
            Icon(Icons.thermostat, size: 36, color: accent),
            const SizedBox(height: 10),

            // Titel
            Text(
              information.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 6),

            // Temperaturwert
            Text(
              temperature.toStringAsFixed(2) + "°",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accent,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            Text(
              heaterType,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
