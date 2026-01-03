import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../model/data.dart';

class EnergyDialog extends StatelessWidget {
  final Information information;
  final double maxConsumption; // Grenzwert für Alarm in kWh

  const EnergyDialog({
    super.key,
    required this.information,
    this.maxConsumption = 20, // z. B. >20 kWh/Tag = Warnung
  });

  double get energyValue => double.tryParse(information.value) ?? 0.0;
  bool get isAlarm => energyValue >= maxConsumption;

  Color get _levelColor {
    if (energyValue < 5) return Colors.greenAccent;
    if (energyValue < 10) return Colors.lightGreenAccent;
    if (energyValue < 20) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String get _statusText {
    if (energyValue < 5) return "Sehr geringer Verbrauch";
    if (energyValue < 10) return "Normaler Verbrauch";
    if (energyValue < 20) return "Erhöhter Verbrauch";
    return "Hoher Energieverbrauch!";
  }

  String get _level {
    if (energyValue < 5) return "Niedrig";
    if (energyValue < 10) return "Normal";
    if (energyValue < 20) return "Hoch";
    return "Extrem";
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
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.indigo.shade800, // Energetischer Farbton
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.white),
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
              "Bereich: ${information.room()}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),

            // --- Animation bei hohem Verbrauch ---
            if (isAlarm)
              SizedBox(
                width: 180,
                height: 180,
                child: Lottie.asset(
                  'assets/energy_alert.json', // -> passende Animation
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              )
            else
              Icon(
                Icons.bolt,
                size: 120,
                color: _levelColor,
              ),

            const SizedBox(height: 16),

            // --- Verbrauchsanzeige ---
            Text(
              "${energyValue.toStringAsFixed(1)} kWh / Tag",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: isAlarm ? Colors.red.shade900 : Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // --- Verbrauchsstufe ---
            Text(
              _level,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _levelColor,
              ),
            ),

            const SizedBox(height: 8),

            // --- Bewertungstext ---
            Text(
              _statusText,
              textAlign: TextAlign.center,
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