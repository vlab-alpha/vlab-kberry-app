import 'package:flutter/material.dart';
import '../model/data.dart';
import '../dialog/setting_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';
import 'dart:async';

class LightDimmerDialog extends ConsumerStatefulWidget {
  final Information information;

  const LightDimmerDialog({super.key, required this.information});

  @override
  ConsumerState<LightDimmerDialog> createState() => _LightDimmerDialogState();
}

class _LightDimmerDialogState extends ConsumerState<LightDimmerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int brightness = 50; // aktuelle Helligkeit (0–100)
  int targetBrightness = 50; // Sollwert
  int minBrightness = 0; // Mindesthelligkeit
  int maxBrightness = 100; // Maximalhelligkeit
  bool isOn = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Beispielwerte aus Information laden
    brightness = int.tryParse(widget.information.firstValue) ?? 50;
    targetBrightness = brightness;
    _getDimmer((Dimmer dimmer) {
      setState(() {
        minBrightness = dimmer.min < dimmer.max ? dimmer.min : dimmer.max;
        maxBrightness = dimmer.max < dimmer.min ? dimmer.min : dimmer.max;
        targetBrightness = dimmer.value;
      });
    });
  }

  Future<void> _setDimmer(int percent) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setDimmer(
      widget.information.positionPath,
      widget.information.title,
      percent.toDouble(),
      (int feedBackBrightness) {
        setState(() {
          brightness = feedBackBrightness;
          isOn = feedBackBrightness > 0;
        });
      },
    );
  }

  Future<void> _getDimmer(
    void Function(Dimmer brightness) onMessage,
  ) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.getDimmer(widget.information.positionPath, onMessage);
  }

  void _updateBrightness(int value) {
    setState(() {
      targetBrightness = value;
      isOn = value > 0;
    });
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _setDimmer(targetBrightness);
    });
  }

  Color _lightColor() {
    final normalized =
        (targetBrightness - minBrightness) / (maxBrightness - minBrightness);
    return Color.lerp(Colors.grey.shade700, Colors.yellowAccent, normalized)!;
  }

  String _statusText() {
    if (!isOn || targetBrightness <= 0) return "Aus";
    if (targetBrightness >= maxBrightness - 1) return "Maximale Helligkeit";
    if (targetBrightness <= minBrightness + 1) return "Gedimmt";
    return "Helligkeit aktiv";
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
      child: Container(
        width: 400,
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
                color: Colors.amber.shade700,
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white),
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
              indicatorColor: Colors.amber.shade700,
              labelColor: Colors.amber.shade900,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.tune), text: "Steuerung"),
                Tab(icon: Icon(Icons.settings), text: "Einstellungen"),
              ],
            ),

            // --- Tab Inhalte ---
            SizedBox(
              height: 260,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- TAB 1: Steuerung ---
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
                              Icons.lightbulb_outline,
                              color: _lightColor(),
                              size: 64,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Aktuell: ${brightness.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  "Soll: ${targetBrightness.toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _statusText(),
                                  style: TextStyle(
                                    color: _lightColor(),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: targetBrightness.toDouble(),
                          min: minBrightness.toDouble(),
                          max: maxBrightness.toDouble(),
                          divisions: (maxBrightness - minBrightness).toInt(),
                          label: "${targetBrightness.toStringAsFixed(0)}%",
                          activeColor: _lightColor(),
                          onChanged: (value) => _updateBrightness(value.toInt()),
                        ),
                      ],
                    ),
                  ),

                  // --- TAB 2: Einstellungen ---
                  SettingsView(
                    positionPath: widget.information.positionPath,
                    type: widget.information.type,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
