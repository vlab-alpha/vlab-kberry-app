import 'package:flutter/material.dart';
import '../model/data.dart';
import '../dialog/setting_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';
import 'dart:async';

class JalousieDialog extends ConsumerStatefulWidget {
  final Information information;

  const JalousieDialog({super.key, required this.information});

  @override
  ConsumerState<JalousieDialog> createState() => _JalousieDialogState();
}

class _JalousieDialogState extends ConsumerState<JalousieDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double shutterPosition = 0.0; // 0 = oben, 100 = unten
  bool isMoving = false;
  bool isLocked = false;
  bool isLock = false;

  // Automatik
  bool autoDayNight = false;
  TimeOfDay morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay eveningTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // initial aus Information laden
    shutterPosition = double.tryParse(widget.information.firstValue) ?? 0.0;
    _getPosition((double position) {
      setState(() {
        shutterPosition = position;
        isMoving = false;
      });
    });
  }

  Future<void> _setPosition(double position) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setJalousie(widget.information.positionPath, position, (
      double position,
    ) {
      setState(() {
        shutterPosition = position;
      });
    });
  }

  Future<void> _down() async {
    await _setPosition(100.0);
  }

  Future<void> _up() async {
    await _setPosition(0.0);
  }

  Future<void> _getPosition(void Function(double position) onMessage) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.getJalousie(widget.information.positionPath, onMessage);
  }

  void _monitorPosition() {
    int secondsPassed = 0;
    const maxDuration = 20; // z. B. 20 Sekunden Timeout
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _getPosition((double position) {
        setState(() {
          shutterPosition = position;
        });
      });

      secondsPassed++;

      if (!isMoving || secondsPassed > maxDuration) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _moveUp() {
    if (isLocked) return;
    _up();
    setState(() => isMoving = true);
    _monitorPosition();
  }

  void _moveDown() {
    if (isLocked) return;
    _down();
    setState(() => isMoving = true);
    _monitorPosition();
  }

  void _lock() async {
    _setLock(true);
  }

  void _unlock() async {
    _setLock(false);
  }

  void _setLock(bool lock) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.lockJalousie(widget.information.positionPath, lock, (pLock) {
      setState(() {
        isLock = pLock;
      });
    });
  }

  void _stopp() async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setStoppJalousie(widget.information.positionPath, (
      double position,
    ) {
      setState(() {
        shutterPosition = position;
      });
    });
  }

  void _reference() async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setReferenceJalousie(widget.information.positionPath, (
      double position,
    ) {
      setState(() {
        shutterPosition = position;
      });
    });
  }

  // void _setPosition(double value) {
  //   if (isLocked) return;
  //   setState(() => shutterPosition = value);
  // }

  Future<void> _pickTime(bool isMorning) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isMorning ? morningTime : eveningTime,
    );
    if (picked != null) {
      setState(() {
        if (isMorning) {
          morningTime = picked;
        } else {
          eveningTime = picked;
        }
      });
    }
  }

  String _statusText() {
    if (isMoving) return "Bewegt sich …";
    if (shutterPosition == 0) return "Oben";
    if (shutterPosition == 100) return "Unten";
    return "Zwischenposition (${shutterPosition.round()}%)";
  }

  Color _statusColor() {
    if (isMoving) return Colors.orangeAccent;
    if (shutterPosition == 0) return Colors.green;
    if (shutterPosition == 100) return Colors.blueGrey;
    return Colors.amber.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 450, maxWidth: 600),
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
                  const Icon(Icons.blinds_rounded, color: Colors.white),
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
                Tab(icon: Icon(Icons.tune), text: "Steuerung"),
                Tab(icon: Icon(Icons.settings), text: "Einstellungen"),
              ],
            ),

            // --- Tab-Inhalt ---
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Steuerung-Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const NeverScrollableScrollPhysics(),
                    // kein Scrollen, nur anpassen
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Raum: ${widget.information.room}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FilledButton.icon(
                              onPressed: _moveUp,
                              icon: const Icon(Icons.arrow_upward),
                              label: const Text("Hoch"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _reference,
                              icon: const Icon(Icons.check),
                              label: const Text("Reference"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade200,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FilledButton.icon(
                              onPressed: _moveDown,
                              icon: const Icon(Icons.arrow_downward),
                              label: const Text("Runter"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blue.shade400,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _stopp,
                              icon: const Icon(Icons.stop),
                              label: const Text("Stopp"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FilledButton.icon(
                              onPressed: _lock,
                              icon: const Icon(Icons.lock),
                              label: const Text("Lock"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red.shade900,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _unlock,
                              icon: const Icon(Icons.lock_open),
                              label: const Text("Unlock"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _statusText(),
                          style: TextStyle(
                            color: _statusColor(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Slider(
                          value: shutterPosition,
                          min: 0,
                          max: 100,
                          divisions: 10,
                          label: "${shutterPosition.round()}%",
                          onChanged: _setPosition,
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
