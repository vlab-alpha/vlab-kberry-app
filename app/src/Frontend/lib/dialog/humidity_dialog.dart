import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../charts/HumdityChart.dart';
import '../model/data.dart';
import '../dialog/setting_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';
import 'dart:async';
import 'log_view.dart';

class HumidityDialog extends  ConsumerStatefulWidget {

  final Information information;

  const HumidityDialog({super.key, required this.information});

  @override
  ConsumerState<HumidityDialog> createState() => _HumidityDialogState();
}


class _HumidityDialogState extends ConsumerState<HumidityDialog> with SingleTickerProviderStateMixin {
  final double maxHumidity = 400; // Grenzwert für Alarm

  late TabController _tabController;

  bool _loading = true;
  bool _timeoutReached = false;

  bool get isAlarm =>
      double.tryParse(widget.information.firstValue) != null &&
          double.parse(widget.information.firstValue) >= maxHumidity;

  Future<void> _getHumidityStatistics(
      void Function(List<Map<String, dynamic>> data) onMessage,
      ) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.getHumidityStatistics(widget.information.positionPath, onMessage);
  }

  Future<List<Map<String, dynamic>>> _getHumidityStatisticsAsync() async {
    final completer = Completer<List<Map<String, dynamic>>>();
    await _getHumidityStatistics((data) {
      completer.complete(data);
    });
    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.delayed(const Duration(seconds: 5), () {
      if (_loading) {
        _timeoutReached = true;
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Humidity data konnten nicht geladen werden.'),
          ),
        );
      }
    });
    _loading = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: _loading
          ? SizedBox(
        width: 200,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CircularProgressIndicator()],
        ),
      )
          : _buildDialogContent(),
    );
  }


  Widget _buildDialogContent() {
    return Container(
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
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Header ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.blueGrey.shade800,
            ),
            child: Row(
              children: [
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

          // --- Tabs ---
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueGrey.shade700,
            labelColor: Colors.blueGrey.shade900,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.stream), text: "Steuerung"),
              Tab(icon: Icon(Icons.auto_graph_rounded), text: "Statistics"),
              Tab(icon: Icon(Icons.receipt_long), text: "Logs"),
            ],
          ),

          // Control
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Raum: ${widget.information.room}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),

                // --- Animation bei Alarm ---
                if (isAlarm)
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/alert.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Icon(
                    Icons.opacity,
                    size: 120,
                    color: Colors.blue.shade300,
                  ),

                const SizedBox(height: 16),

                // --- Luftfeuchtigkeit Anzeige ---
                Text(
                  "${widget.information.firstValue}%",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isAlarm ? Colors.red.shade900 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAlarm ? "Luftfeuchtigkeit zu hoch!" : "Normal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAlarm ? Colors.red.shade900 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // statistics
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getHumidityStatisticsAsync(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                return const Center(
                  child: Text("Fehler beim Laden der Daten"),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: HumidityChart(data: snapshot.data!),
                );
              }
            },
          ),

          LogView(
            positionPath: widget.information.positionPath,
          ),
        ],
      ),
    );
  }

}