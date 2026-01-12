import 'package:flutter/material.dart';
import '../model/data.dart';

class EnergyCard extends StatelessWidget {
  final Information information;

  const EnergyCard({
    super.key,
    required this.information,
  });

  double get consumption => double.tryParse(information.firstValue) ?? 0.0; // kWh pro Tag

  Color get _color {
    if (consumption < 2) return Colors.greenAccent;
    if (consumption < 5) return Colors.yellowAccent;
    if (consumption < 10) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String get _consumptionLevel {
    if (consumption < 2) return "Niedrig";
    if (consumption < 5) return "Normal";
    if (consumption < 10) return "Hoch";
    return "Sehr hoch";
  }

  IconData get _icon {
    if (consumption < 2) return Icons.bolt;
    if (consumption < 5) return Icons.bolt_outlined;
    if (consumption < 10) return Icons.battery_charging_full;
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF3A3A3A);
    final Color borderColor = _color;
    final Color accent = _color;

    // Dynamischer Glow für hohe Werte
    final double glowOpacity = (consumption / 10).clamp(0.2, 0.6);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(glowOpacity),
            blurRadius: 14,
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
              _icon,
              size: 40,
              color: accent,
            ),
            const SizedBox(height: 8),
            Text(
              information.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${consumption.toStringAsFixed(2)} kWh",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _consumptionLevel,
              style: TextStyle(
                fontSize: 13,
                color: accent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "pro Tag",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}