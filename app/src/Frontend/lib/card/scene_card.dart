import 'package:flutter/material.dart';
import '../model/data.dart';
import '../util.dart';

class SceneCard extends StatefulWidget {
  final Information information;
  final Future<void> Function(String positionPath, String title) executeScene;

  const SceneCard({
    super.key,
    required this.information,
    required this.executeScene,
  });

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard>
    with SingleTickerProviderStateMixin {
  bool _activated = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerScene() async {
    widget.executeScene(
      widget.information.positionPath,
      widget.information.title,
    );
    // Aktiviere Glow
    setState(() => _activated = true);
    _controller.forward(from: 0);

    // Nach 1.5 Sek. wieder deaktivieren
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _activated = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = const Color(0xFFFFA726); // warmes Orange
    final Color bgColor = const Color(0xFF3A3A3A);
    final Color borderColor = const Color(0xFF7B5F2F);

    return GestureDetector(
      onTap: _triggerScene,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _activated ? accent : borderColor,
            width: 5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(_activated ? 0.6 : 0.0),
              blurRadius: _activated ? 25 : 0,
              spreadRadius: _activated ? 6 : 0,
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
                widget.information.room.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),

              // Optionales Szenen-Symbol (z. B. Sonne, Mond, Film etc.)
              Icon(
                IconUtil.getIconFromString(
                  widget.information.secondValue ?? "ac_unit",
                ),
                size: 30,
                color: accent,
              ),
              const SizedBox(height: 6),

              // Play-Button
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final glow = Tween<double>(begin: 1.0, end: 1.3)
                      .animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOut,
                        ),
                      )
                      .value;
                  return Transform.scale(
                    scale: glow,
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 42,
                      color: _activated ? accent : Colors.grey.shade600,
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              Text(
                widget.information.firstValue,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accent,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Szene",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
