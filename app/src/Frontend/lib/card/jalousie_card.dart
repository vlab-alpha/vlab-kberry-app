import 'dart:ui';
import 'package:flutter/material.dart';

class JalousieCard extends StatelessWidget {
  final double position; // 0 = geschlossen, 100 = ganz offen
  final String room;
  final String title;

  const JalousieCard({
    super.key,
    required this.room,
    required this.position,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = position > 0 ? const Color(0xFF00BCD4) : Colors.grey.shade600;
    final Color bgColor = const Color(0xFF3A3A3A);
    final Color borderColor = position > 0 ? const Color(0xFF055D68) : Colors.grey.shade800;

    IconData icon;
    if (position == 0) {
      icon = Icons.vertical_align_bottom;
    } else if (position == 100) {
      icon = Icons.vertical_align_top;
    } else {
      icon = Icons.drag_handle;
    }

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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Raumname
            Text(
              room.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),

            // Icon für Position
            Icon(
              icon,
              size: 36,
              color: accent,
            ),
            const SizedBox(height: 10),

            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                thumbColor: accent,
                activeTrackColor: accent.withOpacity(0.7),
                inactiveTrackColor: Colors.grey.shade800,
              ),
              child: Slider(
                value: position,
                onChanged: (val) {},
                min: 0,
                max: 100,
                divisions: 10,
                label: "${(position).round()}%",
              ),
            ),

            const SizedBox(height: 8),

            // Titel
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