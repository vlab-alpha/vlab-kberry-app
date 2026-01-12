import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../model/data.dart';

class WeatherDialog extends StatelessWidget {
  final Information information;

  const WeatherDialog({
    super.key,
    required this.information,
  });

  /// Gibt die passende Lottie-Datei für den aktuellen Wetterzustand zurück
  String _getWeatherAnimation() {
    final value = information.firstValue.toLowerCase();

    switch (value.toLowerCase()) {
      case 'sonnig':
      case 'sunny':
        return 'assets/weather_sunny.json';
      case 'drizzle':
      case 'rain_showers':
      case 'regen':
      case 'rainy':
        return 'assets/weather_rain.json';
      case 'wolken':
      case 'partly_cloudy':
      case 'cloudy':
        return 'assets/weather_cloudy.json';
      case 'sturm':
      case 'thunderstorm':
      case 'thunderstorm_with_hail':
      case 'storm':
        return 'assets/weather_storm.json';
      case 'schnee':
      case 'snow':
        return 'assets/weather_snow.json';
      default:
        return 'assets/weather_unknown.json';
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
              offset: const Offset(0, 4),
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
                color: Colors.blueGrey.shade800,
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud, color: Colors.white),
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

            // --- Inhalt ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Raum: ${information.room}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Lottie Animation ---
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      _getWeatherAnimation(),
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Wetterwert oder Beschreibung ---
                  Text(
                    information.firstValue,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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