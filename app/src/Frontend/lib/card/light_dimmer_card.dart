import 'package:flutter/material.dart';

class LightDimmerCard extends StatelessWidget {
  final String title;
  final double brightness; // 0.0 bis 100.0
  final String room;

  const LightDimmerCard({
    super.key,
    required this.room,
    required this.title,
    required this.brightness,
  });

  static const double _bottomPadding = 10.0;
  static const int _steps = 20;

  @override
  Widget build(BuildContext context) {
    final Color accent = Color.lerp(
      Colors.grey.shade600,
      const Color(0xFF00BCD4),
      brightness / 100,
    )!;
    final Color bgColor = const Color(0xFF3A3A3A);
    final Color borderColor = brightness > 0
        ? const Color(0xFF425565)
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

            // Gestufter Balken
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barHeight = constraints.maxHeight - _bottomPadding;
                  final stepHeight = barHeight / _steps;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(_steps, (index) {
                      final threshold = (index + 1) / _steps * 100;
                      final isActive = brightness >= threshold;
                      final stepColor = isActive
                          ? accent
                          : Colors.grey.shade800;
                      return Container(
                        width: 30,
                        height: stepHeight - 2,
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        decoration: BoxDecoration(
                          color: stepColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color: accent.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                            BoxShadow(
                              color: accent.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                          ]
                              : [],
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Titel + Prozentanzeige
            Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${brightness.toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}