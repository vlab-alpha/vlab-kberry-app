import 'package:flutter/material.dart';
import 'package:SmartHome/model/data.dart';

class UsageCard extends StatelessWidget {
  final Information information;

  const UsageCard({super.key, required this.information});

  @override
  Widget build(BuildContext context) {
    final Color accent = Colors.greenAccent; // Akzentfarbe für Nutzung
    final Color bgColor = const Color(0xFF3A3A3A);
    final Color borderColor = Colors.green.shade700;

    double _usagePercent() => double.tryParse(information.value) ?? 0.0;

    bool _isUsed() => bool.tryParse(information.extraValue ?? "false") ?? false;

    Color _color() => _isUsed() ? Colors.redAccent : Colors.greenAccent;
    Color _borderColor() => _isUsed() ? Colors.redAccent.shade700 :Colors.green.shade700;

    // Leichter Glow basierend auf Usage
    final double glowOpacity = (_usagePercent() / 100).clamp(0.1, 0.6);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _borderColor(), width: 5),
        boxShadow: [
          BoxShadow(
            color: _color().withOpacity(glowOpacity),
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
              information.room().toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              Icons.people,
              size: 36,
              color: _color(),
            ),
            const SizedBox(height: 8),
            Text(
              information.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _color(),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${_usagePercent().toStringAsFixed(1)}%",
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
