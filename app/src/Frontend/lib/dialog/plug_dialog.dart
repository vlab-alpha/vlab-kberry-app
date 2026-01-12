import 'package:flutter/material.dart';
import '../model/data.dart';
import '../dialog/setting_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';

class PlugDialog extends ConsumerStatefulWidget {
  final Information information;

  const PlugDialog({super.key, required this.information});

  @override
  ConsumerState<PlugDialog> createState() => _PlugDialogState();
}

class _PlugDialogState extends ConsumerState<PlugDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isPlugOn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    isPlugOn = widget.information.firstValue == "true";
    _getPlugStatus((status) {
      setState(() {
        isPlugOn = status;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void togglePlug() {
    _setPlugStatus(!isPlugOn);
  }

  Future<void> _getPlugStatus(void Function(bool status) onMessage) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.getPlugStatus(
      widget.information.positionPath,
      widget.information.title,
      onMessage,
    );
  }

  Future<void> _setPlugStatus(bool plugStatus) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setPlugStatus(
      widget.information.positionPath,
      widget.information.title,
      plugStatus,
      (status) {
        setState(() {
          isPlugOn = status;
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
      insetPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
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
                  const Icon(Icons.power_outlined, color: Colors.white),
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
              // feste Höhe für TabBarView; Inhalte passen sich mit Padding / ListView an
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
                          isPlugOn ? Icons.power : Icons.power_off,
                          size: 80,
                          color: isPlugOn ? Colors.green : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: togglePlug,
                          icon: Icon(
                            isPlugOn ? Icons.power_off : Icons.power,
                            size: 18,
                          ),
                          label: Text(isPlugOn ? "Ausschalten" : "Einschalten"),
                          style: FilledButton.styleFrom(
                            backgroundColor: isPlugOn
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
