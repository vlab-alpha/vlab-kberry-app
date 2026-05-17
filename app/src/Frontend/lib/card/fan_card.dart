import 'package:flutter/material.dart';

class FanCard extends StatefulWidget {
  final String room; // Raumbezeichnung
  final String title; // z.B. "Lüfter"
  final bool isOn; // An/Aus
  final int speed; // 0-100 %

  const FanCard({
    super.key,
    required this.room,
    required this.title,
    required this.isOn,
    required this.speed,
  });

  @override
  State<FanCard> createState() => _FanCardState();
}

class _FanCardState extends State<FanCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Color get _color {
    if (!widget.isOn) return Colors.grey.shade700;
    if (widget.speed < 40) return Colors.lightBlueAccent;
    if (widget.speed < 70) return Colors.blueAccent;
    return Colors.deepPurpleAccent;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isOn) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FanCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOn && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isOn && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF3A3A3A);
    final borderColor = _color;
    final glowColor = _color;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double glow = widget.isOn ? 0.3 + 0.2 * widget.speed / 100 : 0.2;
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 5),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(glow),
                blurRadius: 18,
                spreadRadius: 3,
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
                  widget.room.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.flip_camera_android, // stilisiertes Lüfter-Icon
                  size: 40,
                  color: _color,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isOn ? "AN - ${widget.speed} %" : "AUS",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}