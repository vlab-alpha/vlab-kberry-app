import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../model/data.dart';

class Co2Dialog extends StatelessWidget {
  final Information information;
  final double maxCo2; // Grenzwert für Alarm

  const Co2Dialog({
    super.key,
    required this.information,
    this.maxCo2 = 2000, // typischer CO₂-Grenzwert
  });

  double get ppmValue => double.tryParse(information.firstValue) ?? 0.0;

  bool get isAlarm => ppmValue >= maxCo2;

  Color get _levelColor {
    if (ppmValue < 800) return Colors.greenAccent;
    if (ppmValue < 1200) return Colors.yellowAccent;
    if (ppmValue < 2000) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String get _statusText {
    if (ppmValue < 800) return "Gute Luftqualität";
    if (ppmValue < 1200) return "Leicht erhöht";
    if (ppmValue < 2000) return "Zu hoch";
    return "Kritischer Wert!";
  }

  String get _level {
    if (ppmValue < 800) {
      return "Sehr gut";
    } else if (ppmValue < 1000) {
      return "Gut";
    } else if (ppmValue < 1400) {
      return "Mäßig";
    } else if (ppmValue < 2000) {
      return "Schlecht";
    } else {
      return "Sehr schlecht";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
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
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
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
                color: Colors.teal.shade800, // CO₂-Farbton
              ),
              child: Row(
                children: [
                  const Icon(Icons.co2, color: Colors.white),
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
                  'assets/co2_alert.json', // -> eigene Warn-Animation
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              )
            else
              Icon(
                Icons.co2,
                size: 120,
                color: _levelColor,
              ),

            const SizedBox(height: 16),

            // --- CO₂-Werte ---
            Text(
              "${ppmValue.toStringAsFixed(0)} ppm",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isAlarm ? Colors.red.shade900 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // --- Stufe (z. B. Hoch, Kritisch) ---
            Text(
              _level,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _levelColor,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              _statusText,
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