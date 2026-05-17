import 'package:flutter/material.dart';
import '../model/data.dart';
import '../dialog/setting_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';
import 'log_view.dart';

class FanDialog extends ConsumerStatefulWidget {
  final Information information;

  const FanDialog({super.key, required this.information});

  @override
  ConsumerState<FanDialog> createState() => _FanDialogState();
}

class _FanDialogState extends ConsumerState<FanDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFanOn = false;
  int _pauseMinutes = 30;
  int speed = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    isFanOn = widget.information.firstValue == "true";
    speed = int.tryParse(widget.information.secondValue ?? "0") ?? 0;
    _getFanStatus((bool status, int currentSpeed) {
      setState(() {
        isFanOn = status;
        speed = currentSpeed;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getFanStatus(
    void Function(bool status, int speed) onMessage,
  ) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.getFanStatus(widget.information.positionPath, onMessage);
  }

  Future<void> _setFanStatus(bool fanOn) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setFanStatus(widget.information.positionPath, fanOn, (
      status,
      currentSpeed,
      isChanged,
    ) {
      if (!isChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Ändern des Zustands'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        isFanOn = status;
        speed = currentSpeed;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Einstellungen übernommen')));
    });
  }

  Future<void> _pauseFan(Duration duration) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.pauseFan(widget.information.positionPath, duration, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lüfter pausiert für ${duration.inSeconds} Sekunden'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
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
                  const Icon(Icons.toys, color: Colors.white),
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
                Tab(icon: Icon(Icons.receipt_long), text: "Logs"),
              ],
            ),

            // --- Tab-Inhalt ---
            SizedBox(
              height: 240,
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

                        FilledButton.icon(
                          onPressed: () => _setFanStatus(!isFanOn),
                          icon: Icon(
                            isFanOn
                                ? Icons.mode_fan_off
                                : Icons.flip_camera_android,
                            size: 18,
                          ),
                          label: Text(isFanOn ? "Ausschalten" : "Einschalten"),
                          style: FilledButton.styleFrom(
                            backgroundColor: isFanOn
                                ? Colors.redAccent.shade100
                                : Colors.green.shade300,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // --- Eingabe der Pausezeit ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Minuten",
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _pauseMinutes = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _pauseMinutes > 0
                                  ? () => _pauseFan(
                                      Duration(minutes: _pauseMinutes),
                                    )
                                  : null,
                              icon: const Icon(Icons.pause, size: 18),
                              label: const Text("Pause"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.orangeAccent.shade200,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "Geschwindigkeit: $speed %",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- TAB 2: Einstellungen ---
                  SettingsView(
                    positionPath: widget.information.positionPath,
                    type: widget.information.type,
                  ),

                  // --- TAB 3: Logs ---
                  LogView(positionPath: widget.information.positionPath),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
