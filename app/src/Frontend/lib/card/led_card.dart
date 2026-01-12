import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:SmartHome/model/data.dart';

class LedCard extends StatelessWidget {
  final Information information;

  const LedCard({super.key, required this.information});

  @override
  Widget build(BuildContext context) {
    // Hex-Farbe aus information.value
    final hex = information.firstValue ?? "#00000000"; // default schwarz
    final rgbw = _hexToRgbw(hex);

    final int r = rgbw[0];
    final int g = rgbw[1];
    final int b = rgbw[2];
    final int w = rgbw[3];

    final Color ledColor = Color.fromARGB(
      255,
      (r + w).clamp(0, 255),
      (g + w).clamp(0, 255),
      (b + w).clamp(0, 255),
    );

    final double glowOpacity = (w / 255).clamp(0.2, 0.6);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ledColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: ledColor.withOpacity(glowOpacity),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            information.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ledColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ledColor.withOpacity(0.7),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _colorBar("R", r, Colors.red),
              _colorBar("G", g, Colors.green),
              _colorBar("B", b, Colors.blue),
              _colorBar("W", w, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  /// Wandelt Hexstring (#RRGGBB oder #RRGGBBWW) in RGBW List<int>
  List<int> _hexToRgbw(String hex) {
    hex = hex.replaceAll("#", "").toUpperCase();

    // Falls der String zu lang ist, kürzen
    if (hex.length > 8) hex = hex.substring(0, 8);

    int r = 0, g = 0, b = 0, w = 0;

    if (hex.length == 6) {
      // RRGGBB
      r = int.parse(hex.substring(0, 2), radix: 16);
      g = int.parse(hex.substring(2, 4), radix: 16);
      b = int.parse(hex.substring(4, 6), radix: 16);
    } else if (hex.length == 8) {
      // Prüfe, ob es ARGB oder RGBW ist
      // Wenn Alpha sehr klein (< 50), ignoriere es und behandle als RGBW
      int a = int.parse(hex.substring(0, 2), radix: 16);
      if (a < 50) {
        r = int.parse(hex.substring(2, 4), radix: 16);
        g = int.parse(hex.substring(4, 6), radix: 16);
        b = int.parse(hex.substring(6, 8), radix: 16);
        w = a; // Verwende Alpha als Weißanteil
      } else {
        // normales ARGB
        r = int.parse(hex.substring(2, 4), radix: 16);
        g = int.parse(hex.substring(4, 6), radix: 16);
        b = int.parse(hex.substring(6, 8), radix: 16);
        w = 0;
      }
    }

    return [r, g, b, w];
  }

  Widget _colorBar(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 50 * (value / 255),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
        Text("$value", style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}