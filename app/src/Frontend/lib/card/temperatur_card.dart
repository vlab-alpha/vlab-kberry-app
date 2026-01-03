import 'package:flutter/material.dart';

class TemperatureCard extends StatelessWidget {
  final String title;
  final String value;
  final String room;

  const TemperatureCard({
    super.key,
    required this.room,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = Colors.orangeAccent;
    final Color bgColor = const Color(0xFF3A3A3A);
    final Color borderColor = Colors.orange.shade700;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 5),
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
              room.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),

            // Icon
            Icon(
              Icons.thermostat,
              size: 36,
              color: accent,
            ),
            const SizedBox(height: 10),

            // Titel
            Text(
              title,
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
              value+"°",
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
          ],
        ),
      ),
    );
  }
}