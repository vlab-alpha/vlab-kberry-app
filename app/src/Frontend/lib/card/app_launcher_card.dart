import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../util.dart';

class AppLaunchCard extends StatelessWidget {
  final String title;
  final String methodName;
  final String icon;

  static const platform = MethodChannel('app.channel.shared.data');

  const AppLaunchCard({
    super.key,
    required this.title,
    required this.methodName,
    required this.icon,
  });

  Future<void> _launchApp() async {
    try {
      await platform.invokeMethod(methodName);
    } on PlatformException catch (e) {
      debugPrint("Fehler beim Öffnen der App: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF3A3A3A);
    final Color accent = Colors.redAccent;
    final Color borderColor = Colors.redAccent.shade700;

    return InkWell(
      onTap: _launchApp,
      borderRadius: BorderRadius.circular(6),
      child: Container(
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
              Text(
                "APP",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Icon(IconUtil.getIconFromString(icon), size: 36, color: accent),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
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
      ),
    );
  }
}