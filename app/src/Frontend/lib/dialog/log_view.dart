import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';

class LogEntry {
  final DateTime timestamp;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.message,
  });
}

class LogView extends ConsumerStatefulWidget {
  final String positionPath;

  const LogView({
    super.key,
    required this.positionPath,
  });

  @override
  ConsumerState<LogView> createState() => _LogViewState();
}

class _LogViewState extends ConsumerState<LogView> {
  List<LogEntry> logs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;

    setState(() => loading = true);

    service.getLogs(widget.positionPath, (List<Map<String, dynamic>> data) {
      setState(() {
        logs = data.map((e) {
          return LogEntry(
            timestamp: DateTime.parse(e["timestamp"]),
            message: e["message"] ?? "",
          );
        }).toList();

        // Neueste zuerst
        logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        loading = false;
      });
    });
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}."
        "${dt.month.toString().padLeft(2, '0')}."
        "${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:"
        "${dt.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (logs.isEmpty) {
      return const Center(child: Text("Keine Logs verfügbar"));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: RefreshIndicator(
        onRefresh: _loadLogs,
        child: ListView.separated(
          itemCount: logs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final log = logs[index];

            return ListTile(
              dense: true,
              leading: const Icon(Icons.receipt_long, color: Colors.blueGrey),
              title: Text(
                log.message,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                _formatDate(log.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}