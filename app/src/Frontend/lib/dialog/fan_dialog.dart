import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';
import '../model/data.dart';
import '../dialog/setting_view.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    isFanOn = widget.information.firstValue == "ON";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings(bool fanOn) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setFanStatus(widget.information.positionPath, fanOn, (status) {
      if (status != fanOn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einstellungen übernommen')),
        );
        setState(() {
          isFanOn = status;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Konnte nicht übernommen werden!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  void toggleFan() {
    _saveSettings(!isFanOn);
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
            // --- Header mit Titel ---
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
                  const Icon(Icons.lightbulb_outline, color: Colors.white),
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
                        Icon(
                          isFanOn
                              ? Icons.flip_camera_android
                              : Icons.mode_fan_off_outlined,
                          size: 80,
                          color: isFanOn
                              ? Colors.blue.shade700
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: toggleFan,
                          icon: Icon(
                            isFanOn
                                ? Icons.flip_camera_android
                                : Icons.mode_fan_off_outlined,
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
