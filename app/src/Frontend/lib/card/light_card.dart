import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:SmartHome/model/data.dart';

class LightsCard extends StatelessWidget {
  final Information information;

  static const String svgOff = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 490.1 490.1">
  <path d="M148.4 393.45h193.3c81.8 0 148.4-66.6 148.4-148.4s-66.6-148.4-148.4-148.4H148.4C66.6 96.65 0 163.25 0 245.05s66.6 148.4 148.4 148.4m0-257h193.3c59.9 0 108.6 48.7 108.6 108.6s-48.7 108.6-108.6 108.6H148.4c-59.9 0-108.6-48.7-108.6-108.6-.1-59.9 48.7-108.6 108.6-108.6m-71.7 108.6c0-41.4 33.6-75 75-75s75 33.6 75 75-33.6 75-75 75-75-33.6-75-75"/>
</svg>
''';

  static const String svgOn = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 490.1 490.1">
  <path d="M0 245.05c0 71.8 58.2 130.1 130.1 130.1H360c71.8 0 130.1-58.2 130.1-130.1 0-71.8-58.2-130.1-130.1-130.1H130.1C58.2 114.95 0 173.25 0 245.05m288.8 0c0-39 31.6-70.6 70.6-70.6s70.6 31.6 70.6 70.6-31.6 70.6-70.6 70.6-70.6-31.6-70.6-70.6"/>
</svg>
''';

  bool get isOn => bool.tryParse(information.firstValue) ?? false;

  double get lux => double.tryParse(information.secondValue ?? "0.0") ?? 0.0;

  const LightsCard({super.key, required this.information});

  Color getLuxColor() {
    // Lux begrenzen
    final clampedLux = lux.clamp(0, 10000);

    // 0..1 normalisieren
    final t = clampedLux / 10000;

    // Hue: Blau (220°) → Gelb (55°)
    final hue = 220 - (165 * t);

    return HSVColor.fromAHSV(
      1.0,
      hue,
      0.8,
      0.9,
    ).toColor();
  }

  Color getBorderColor() {
    return getLuxColor().withAlpha(80);
  }

  @override
  Widget build(BuildContext context) {
    double getLux() => double.tryParse(information.secondValue ?? "0.0") ?? 0.0;

    final double glowOpacity = (getLux() / 100).clamp(0.1, 0.6);

    final Color accent = isOn ? const Color(0xFF00BCD4) : Colors.grey.shade600;
    final Color bgColor = const Color(0xFF3A3A3A); // dunkles Panel
    final Color borderColor = isOn
        ? const Color(0xFF448187)
        : Colors.grey.shade800;

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
              isOn ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 36,
              color: accent,
            ),
            const SizedBox(height: 8),
            SvgPicture.string(
              isOn ? svgOn : svgOff,
              width: 48,
              height: 48,
              colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
            ),
            const SizedBox(height: 10),
            Text(
              information.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
