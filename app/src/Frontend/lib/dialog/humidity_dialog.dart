import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../model/data.dart';

class HumidityDialog extends StatelessWidget {
  final Information information;
  final double maxHumidity; // Grenzwert für Alarm

  const HumidityDialog({
    super.key,
    required this.information,
    this.maxHumidity = 80,
  });

  bool get isAlarm =>
      double.tryParse(information.firstValue) != null &&
          double.parse(information.firstValue) >= maxHumidity;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent, // transparent für Gradient + Lottie
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Header ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.blueGrey.shade800,
              ),
              child: Row(
                children: [
                  const Icon(Icons.opacity, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      information.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Raum: ${information.room}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),

            // --- Animation bei Alarm ---
            if (isAlarm)
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/alert.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              )
            else
              Icon(
                Icons.opacity,
                size: 120,
                color: Colors.blue.shade300,
              ),

            const SizedBox(height: 16),

            // --- Luftfeuchtigkeit Anzeige ---
            Text(
              "${information.firstValue}%",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isAlarm ? Colors.red.shade900 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAlarm ? "Luftfeuchtigkeit zu hoch!" : "Normal",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isAlarm ? Colors.red.shade900 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}