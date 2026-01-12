import 'package:flutter/material.dart';
import 'package:SmartHome/model/data.dart';

class HumidityCard extends StatelessWidget {
  final Information information;

  const HumidityCard({
    super.key,
    required this.information
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = Colors.lightBlueAccent; // Akzentfarbe für Feuchtigkeit
    final Color bgColor = const Color(0xFF3A3A3A);

    // Leichter Glow basierend auf humidityPercent

    double getAverage() =>
        double.tryParse(information.secondValue ?? "0.0") ?? 0.0;

    final double glowOpacity = (getAverage() / 100).clamp(0.1, 0.6);

    Color getAccent() {
      if(getAverage() < 30) {
        return Colors.yellowAccent;
      }
      if(getAverage() < 40) {
        return Colors.orangeAccent;
      }
      if(getAverage() < 60) {
        return Color(0xFF3A3A3A);
      }
      if(getAverage() < 70) {
        return Colors.blueAccent;
      }
      return Colors.redAccent;
    }

    Color getBorderColor() {
      return getAccent().withAlpha(80);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: getBorderColor(), width: 5),
        boxShadow: [
          BoxShadow(
            color: getAccent().withOpacity(glowOpacity),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Icon(
              Icons.water_drop,
              size: 36,
              color: accent,
            ),
            const SizedBox(height: 8),
            Text(
              information.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: getAccent(),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${double.parse(information.firstValue).toStringAsFixed(2)}%",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 6,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}