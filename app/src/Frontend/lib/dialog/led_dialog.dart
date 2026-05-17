import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/data.dart';
import '../service_provider.dart';

class LedDialog extends ConsumerStatefulWidget {
  final Information information;

  const LedDialog({super.key, required this.information});

  @override
  ConsumerState<LedDialog> createState() => _LedDialogState();
}

class _LedDialogState extends ConsumerState<LedDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _r, _g, _b, _w;
  bool isLedOn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final hex = widget.information.firstValue;
    final rgba = _hexToRgbw(hex);
    _r = rgba[0];
    _g = rgba[1];
    _b = rgba[2];
    _w = rgba[3];

    isLedOn = _r + _g + _b + _w > 0;
  }

  Future<void> _setRGBW(String hex) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setRGBW(widget.information.positionPath, hex, (hex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LED eingestellt')),
      );
    });
  }

  List<int> _hexToRgbw(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex += '00'; // W auf 0 setzen
      final intVal = int.parse(hex, radix: 16);
      final r = (intVal >> 24) & 0xFF;
      final g = (intVal >> 16) & 0xFF;
      final b = (intVal >> 8) & 0xFF;
      final w = intVal & 0xFF;
      return [r, g, b, w];
    } catch (e) {
      return [0, 0, 0, 0];
    }
  }

  String _rgbwToHex(int r, int g, int b, int w) {
    return '#'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'
        '${w.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color get _ledColor =>
      isLedOn
          ? Color.fromARGB(255, (_r + _w).clamp(0, 255), (_g + _w).clamp(0, 255), (_b + _w).clamp(0, 255))
          : Colors.black;

  void _toggleLed(bool on) {
    setState(() {
      isLedOn = on;
      if (!on) {
        _r = _g = _b = _w = 0;
      }
    });
    _setRGBW(_rgbwToHex(_r, _g, _b, _w));
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                Tab(icon: Icon(Icons.settings), text: "RGBW"),
              ],
            ),

            // --- TabBarView ---
            SizedBox(
              height: 320,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- Steuerung Tab ---
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Raum: ${widget.information.room}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Icon(
                          Icons.lightbulb,
                          size: 80,
                          color: _ledColor,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: () => _toggleLed(true),
                              icon: const Icon(Icons.power, size: 18),
                              label: const Text("An"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green.shade300,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            FilledButton.icon(
                              onPressed: () => _toggleLed(false),
                              icon: const Icon(Icons.power_off, size: 18),
                              label: const Text("Aus"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.redAccent.shade100,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- RGBW Tab ---
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _ledColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _ledColor.withOpacity(0.7),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _slider('R', Colors.red, _r, (val) {
                          setState(() {
                            _r = val;
                            isLedOn = true;
                          });
                        }),
                        _slider('G', Colors.green, _g, (val) {
                          setState(() {
                            _g = val;
                            isLedOn = true;
                          });
                        }),
                        _slider('B', Colors.blue, _b, (val) {
                          setState(() {
                            _b = val;
                            isLedOn = true;
                          });
                        }),
                        _slider('W', Colors.white, _w, (val) {
                          setState(() {
                            _w = val;
                            isLedOn = true;
                          });
                        }),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            _setRGBW(_rgbwToHex(_r, _g, _b, _w));
                          },
                          child: const Text("Set", style: TextStyle(color: Colors.white)),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade700,
                            minimumSize: const Size(200, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, Color color, int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 255,
                activeColor: color,
                inactiveColor: color.withOpacity(0.3),
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Text(value.toString(), style: const TextStyle(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}