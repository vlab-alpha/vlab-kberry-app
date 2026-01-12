import 'package:flutter/material.dart';
import '../model/data.dart';
import '../dialog/setting_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';
import 'floor_heater_position_bar.dart';
import '../charts/TemperatureChart.dart';
import 'dart:async';

class TemperatureDialog extends ConsumerStatefulWidget {
  final Information information;

  const TemperatureDialog({super.key, required this.information});

  @override
  ConsumerState<TemperatureDialog> createState() => _TemperatureDialogState();
}

class _TemperatureDialogState extends ConsumerState<TemperatureDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isComfort = true;

  bool _loading = true;
  bool _timeoutReached = false;
  double targetTemperature = 21.0;
  double currentTemperature = 22.3;
  bool isError = false;
  int position = 0;
  Betriebsart betriebsart = Betriebsart.STANDBY;
  double max = 25;
  double min = 10;

  double get sollwert {
    final soll = double.tryParse(widget.information.firstValue) ?? 10.0;
    return soll <= 10.0 ? 10.0 : soll;
  }

  double get temperature {
    final soll = double.tryParse(widget.information.firstValue) ?? 10.0;
    return soll <= 10.0 ? 10.0 : soll;
  }

  String getModeMessage() {
    switch (betriebsart) {
      case Betriebsart.COMFORT:
        return "Komfort";
      case Betriebsart.STANDBY:
        return "Nacht";
      case Betriebsart.FROST_PROTECTION:
        return "Frostschutz";
      case Betriebsart.NIGHT:
        return "Nacht";
    }
  }

  IconData get tempDirection => currentTemperature > targetTemperature + 0.3
      ? Icons.arrow_circle_down
      : Icons.arrow_circle_up;

  Color get tempDirectionColor => currentTemperature > targetTemperature + 0.3
      ? Colors.redAccent.shade700
      : Colors.green.shade700;

  IconData get mode {
    switch (betriebsart) {
      case Betriebsart.COMFORT:
        return Icons.bed_outlined;
      case Betriebsart.STANDBY:
        return Icons.stop_circle;
      case Betriebsart.FROST_PROTECTION:
        return Icons.ac_unit;
      case Betriebsart.NIGHT:
        return Icons.nightlight;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    currentTemperature = double.tryParse(widget.information.firstValue) ?? 21.0;
    targetTemperature = 10.0;

    Future.delayed(const Duration(seconds: 5), () {
      if (_loading) {
        _timeoutReached = true;
        if (mounted) Navigator.of(context).pop(); // Dialog schließen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Temperaturdaten konnten nicht geladen werden.'),
          ),
        );
      }
    });
    _loading = true;
    _getFloorHeater((FloorHeater floorHeater) {
      setState(() {
        currentTemperature = floorHeater.temperatur;
        targetTemperature = floorHeater.sollwert <= 10.0
            ? 10.0
            : floorHeater.sollwert;
        position = floorHeater.position;
        betriebsart = floorHeater.betriebsart;
        isComfort = betriebsart == Betriebsart.COMFORT;
        _loading = false; // Daten sind geladen
      });
    });
  }

  Future<void> _getFloorHeater(
    void Function(FloorHeater floorheater) onMessage,
  ) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.getFloorHeater(widget.information.positionPath, onMessage);
  }

  Future<void> _getTemperaturStatistics(
    void Function(List<Map<String, dynamic>> data) onMessage,
  ) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.getTemperaturStatistics(widget.information.positionPath, onMessage);
  }

  Future<List<Map<String, dynamic>>> _getTemperaturStatisticsAsync() async {
    final completer = Completer<List<Map<String, dynamic>>>();
    await _getTemperaturStatistics((data) {
      completer.complete(data);
    });
    return completer.future;
  }

  Future<void> _setFloorHeater(double targetTemperature) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setFloorHeater(widget.information.positionPath, targetTemperature, (
      bool success,
    ) {
      final text = success
          ? 'Temperatur übernommen'
          : 'Temperatur konnte nicht übernommen werden!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    });
  }

  void _changeTargetTemperature(double value) {
    _setFloorHeater(value);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor() {
    if (isError) return Colors.redAccent;
    if (currentTemperature > targetTemperature + 0.3) return Colors.redAccent;
    return Colors.green;
  }

  String _statusText() {
    if (isError) return "Error …";
    if (currentTemperature > targetTemperature + 0.3) return "Zu warm";
    return "Temperatur im Wohlfühlbereich";
  }

  void toggleMode() {
    _setMode(Betriebsart.COMFORT);
  }

  Future<void> _setMode(Betriebsart mode) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;

    service.setFloorHeaterMode(
      widget.information.positionPath,
      mode, (status) {
        setState(() {
          isComfort = true;
        });
      },
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Einstellungen übernommen')));
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                const Icon(Icons.thermostat, color: Colors.white),
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
              Tab(icon: Icon(Icons.power_settings_new), text: "Steuerung"),
              Tab(icon: Icon(Icons.settings), text: "Einstellungen"),
              Tab(icon: Icon(Icons.auto_graph_rounded), text: "Statistics"),
            ],
          ),

          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Settings
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thermostat,
                            color: _statusColor(),
                            size: 64,
                          ),
                          const SizedBox(width: 12),
                          FloorHeaterPositionBar(
                            position: position, // Wert 0–100 vom Regler
                            height: 100,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Aktuell: ${currentTemperature.toStringAsFixed(1)}°C",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                "Soll: ${targetTemperature.toStringAsFixed(1)}°C",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(mode, color: Colors.black38),
                                  Text(
                                    "${getModeMessage()} - Modus",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(tempDirection, color: tempDirectionColor),
                                  Text(
                                    _statusText(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),

                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: toggleMode,
                        icon: Icon(
                          isComfort ? Icons.sunny : Icons.nightlight,
                          size: 18,
                        ),
                        label: Text(
                          isComfort ? "Nachtmodus" : "Komfort",
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: isComfort
                              ? Colors.black45
                              : Colors.green.shade400,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: targetTemperature,
                        min: min,
                        max: max,
                        divisions: 20,
                        label: "${targetTemperature.toStringAsFixed(1)}°C",
                        onChanged: (value) {
                          setState(() => targetTemperature = value);
                        },
                        onChangeEnd: (value) {
                          _setFloorHeater(value);
                        },
                      ),
                    ],
                  ),
                ),

                // Settings
                SettingsView(
                  positionPath: widget.information.positionPath,
                  type: widget.information.type,
                ),

                // Statistics
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getTemperaturStatisticsAsync(),
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
                        child: TemperatureChart(data: snapshot.data!),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
