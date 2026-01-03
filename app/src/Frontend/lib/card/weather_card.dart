import 'package:flutter/material.dart';
import '../model/data.dart';

class WeatherCard extends StatelessWidget {
  final String condition; // z. B. "sunny", "rainy", "cloudy"
  final double temperature; // z. B. 21.5
  final String title; // z. B. "Ingolstadt"

  const WeatherCard({
    super.key,
    required this.condition,
    required this.temperature,
    required this.title,
  });

  IconData _getWeatherIcon() {
    switch (condition.toLowerCase()) {
      case 'sonnig':
      case 'sunny':
        return Icons.wb_sunny_outlined;
      case 'drizzle':
      case 'rain_showers':
      case 'regen':
      case 'rainy':
        return Icons.grain; // Regen
      case 'wolken':
      case 'partly_cloudy':
      case 'cloudy':
        return Icons.cloud_outlined;
      case 'sturm':
      case 'thunderstorm':
      case 'thunderstorm_with_hail':
      case 'storm':
        return Icons.flash_on;
      case 'schnee':
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }

  Color _getIconColor() {
    switch (condition.toLowerCase()) {
      case 'sonnig':
      case 'sunny':
        return Colors.orangeAccent;
      case 'regen':
      case 'rainy':
        return Colors.blueAccent;
      case 'wolken':
      case 'cloudy':
        return Colors.grey;
      case 'sturm':
      case 'storm':
        return Colors.deepPurpleAccent;
      case 'schnee':
      case 'snow':
        return Colors.lightBlueAccent;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _getIconColor();
    final Color bgColor = const Color(0xFF3A3A3A);
    final Color borderColor = accent.withOpacity(0.8);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
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
            Icon(
              _getWeatherIcon(),
              size: 36,
              color: accent,
            ),
            const SizedBox(height: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${temperature.toStringAsFixed(1)} °C',
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
            const SizedBox(height: 4),
            Text(
              "Wetter",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}