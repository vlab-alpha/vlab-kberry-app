import 'package:flutter/material.dart';

class FanCard extends StatelessWidget {
  final String title;
  final bool isOn;
  final String room;
  final IconData? customIcon; // optionales Icon

  // SVG für Lüfter aus
  static const String svgOff = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <circle cx="32" cy="32" r="30" stroke="gray" stroke-width="4" fill="none"/>
  <line x1="32" y1="32" x2="32" y2="2" stroke="gray" stroke-width="4"/>
</svg>
''';

  // SVG für Lüfter an
  static const String svgOn = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <circle cx="32" cy="32" r="30" stroke="cyan" stroke-width="4" fill="none"/>
  <line x1="32" y1="32" x2="32" y2="2" stroke="cyan" stroke-width="4"/>
  <line x1="32" y1="32" x2="62" y2="32" stroke="cyan" stroke-width="4"/>
  <line x1="32" y1="32" x2="12" y2="56" stroke="cyan" stroke-width="4"/>
</svg>
''';

  const FanCard({
    super.key,
    required this.room,
    required this.title,
    required this.isOn,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isOn ? Colors.deepPurple : Colors.grey.shade600;
    final Color bgColor = const Color(0xFF3A3A3A);
    final Color borderColor = isOn ? Colors.deepPurple : Colors.grey.shade800;

    Widget _buildIcon() {
      if (customIcon != null) {
        return Icon(customIcon, size: 36, color: accent);
      } else {
        return Icon(
          isOn ? Icons.toys : Icons.mode_fan_off,
          size: 36,
          color: accent,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isOn ? 0.4 : 0),
            blurRadius: isOn ? 20 : 0,
            spreadRadius: isOn ? 4 : 0,
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
              room.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              isOn ? Icons.flip_camera_android_sharp : Icons.mode_fan_off,
              size: 50,
              color: accent,
            ),

            const SizedBox(height: 10),
            Text(
              title,
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