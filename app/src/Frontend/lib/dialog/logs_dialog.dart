import 'package:flutter/material.dart';
import '../core/app_logger.dart';

class AppLogsDialog extends StatefulWidget {
  const AppLogsDialog({super.key});

  @override
  State<AppLogsDialog> createState() => _AppLogsDialogState();
}

class _AppLogsDialogState extends State<AppLogsDialog> {
  final logger = AppLogger();

  @override
  void initState() {
    super.initState();
    logger.addListener(_update);
  }

  @override
  void dispose() {
    logger.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("App Logs"),
      content: SizedBox(
        width: 500,
        height: 400,
        child: logger.logs.isEmpty
            ? const Center(child: Text("Keine Logs vorhanden"))
            : ListView.builder(
          itemCount: logger.logs.length,
          itemBuilder: (_, index) {
            return Text(
              logger.logs[index],
              style: const TextStyle(fontSize: 12),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => logger.clear(),
          child: const Text("Clear"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}