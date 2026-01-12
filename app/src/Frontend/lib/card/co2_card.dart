import 'package:flutter/material.dart';
import '../model/data.dart';

class Co2Card extends StatefulWidget {
  final Information information;

  const Co2Card({
    super.key,
    required this.information
  });

  @override
  State<Co2Card> createState() => _Co2CardState();
}

class _Co2CardState extends State<Co2Card> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Color get _color {
    final value = double.parse(widget.information.firstValue);
    if (value < 800) return Colors.greenAccent;
    if (value < 1200) return Colors.yellowAccent;
    if (value < 2000) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  void initState() {
    super.initState();

    // Animation nur aktivieren, wenn CO₂ zu hoch
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (double.parse(widget.information.firstValue) > 2000) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(Co2Card oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (double.parse(widget.information.firstValue) > 2000 && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (double.parse(widget.information.firstValue) <= 2000 && _controller.isAnimating) {
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
        final double glow = (double.parse(widget.information.firstValue) > 2000)
            ? 0.4 + 0.3 * double.parse(widget.information.firstValue)
            : 0.2; // leichtes Glühen
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
                  widget.information.room.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.co2,
                  size: 40,
                  color: _color,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.information.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.information.firstValue} ppm",
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