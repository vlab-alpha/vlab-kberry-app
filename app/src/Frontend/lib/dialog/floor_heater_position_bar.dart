// floor_heater_position_bar.dart
import 'package:flutter/material.dart';

class FloorHeaterPositionBar extends StatelessWidget {
  final int position; // 0 bis 100
  final double width;
  final double height;

  const FloorHeaterPositionBar({
    super.key,
    required this.position,
    this.width = 30,
    this.height = 150,
  });

  static const int _steps = 20;

  @override
  Widget build(BuildContext context) {
    final Color accent = Colors.orangeAccent;

    return SizedBox(
      width: width,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barHeight = constraints.maxHeight;
          final stepHeight = barHeight / _steps;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(_steps, (index) {
              final threshold = (index + 1) / _steps * 100;
              final isActive = position >= threshold;
              final stepColor = isActive ? accent : Colors.grey.shade300;

              return Container(
                width: width,
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
    );
  }
}