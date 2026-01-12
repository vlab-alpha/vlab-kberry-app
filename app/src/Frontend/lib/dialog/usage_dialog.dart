import 'package:flutter/material.dart';
import '../model/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';
import 'dart:async';

class UsageDialog extends ConsumerStatefulWidget {
  final Information information;

  const UsageDialog({super.key, required this.information});

  @override
  ConsumerState<UsageDialog> createState() => _UsageDialogState();
}

class _UsageDialogState extends ConsumerState<UsageDialog>
    with SingleTickerProviderStateMixin {
  String isUsed = "Unknown";
  int lastUsedMinutes = 0;
  double usageAverage = 0.0;

  @override
  void initState() {
    super.initState();
    _getUsageStatistics((isUsedP, lastUsedMinutesP, usageAverageP) {
      setState(() {
        isUsed = isUsedP;
        lastUsedMinutes = lastUsedMinutesP;
        usageAverage = usageAverageP;
      });
    });
  }

  Future<void> _getUsageStatistics(void Function(String, int, double) onMessage) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.getUsage(widget.information.positionPath, onMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      // transparent für Gradient + Lottie
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Header ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: Colors.blueGrey.shade800,
              ),
              child: Row(
                children: [
                  const SizedBox(height: 8),
                  const Icon(Icons.opacity, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.information.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              "Raum: ${widget.information.room}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),

            Icon(Icons.people, size: 120, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text(
              "${usageAverage.toStringAsFixed(2)}%",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Genutzt vor $lastUsedMinutes Minuten",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
            Text(
              "Wird Benutzt $isUsed",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
