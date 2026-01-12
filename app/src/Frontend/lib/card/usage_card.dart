import 'package:flutter/material.dart';
import 'package:SmartHome/model/data.dart';

class UsageCard extends StatelessWidget {
  final Information information;

  const UsageCard({super.key, required this.information});

  String get usageTime {
    final seconds = int.tryParse(information.firstValue) ?? 0;

    if (seconds < 60) {
      return '${seconds}s';
    }

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes < 60) {
      return remainingSeconds == 0
          ? '${minutes}m'
          : '${minutes}m ${remainingSeconds}s';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return remainingMinutes == 0
        ? '${hours}h'
        : '${hours}h ${remainingMinutes}m';
  }

  bool get isUsed => bool.tryParse(information.secondValue ?? "false") ?? false;

  String get subTitle => isUsed ? "Besetzt" : "Nicht Besetzt";



  Color getUsageTimeColor() {
    final seconds = int.tryParse(information.firstValue) ?? 0;

    if (seconds < 60) {
      return Colors.grey.shade500;
    } else if (seconds < 600) {
      return Colors.blue.shade400;
    } else if (seconds < 3600) {
      return Colors.green.shade500;
    } else if (seconds < 21600) {
      return Colors.orange.shade600;
    } else {
      return Colors.red.shade600;
    }
  }

  Color get color => isUsed ? Colors.redAccent.shade700 :Colors.green.shade700;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF3A3A3A);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 4),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 8,
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
              Icons.people,
              size: 36,
              color: getUsageTimeColor(),
            ),
            const SizedBox(height: 8),
            Text(
              information.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              usageTime,
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
            Text(
              subTitle,
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
