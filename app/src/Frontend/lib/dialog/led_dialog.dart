import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/data.dart';
import 'package:async/async.dart';
import '../service_provider.dart';

class LedControlDialog extends ConsumerStatefulWidget {
  final Information information;

  const LedControlDialog({super.key, required this.information});

  @override
  ConsumerState<LedControlDialog> createState() => _LedControlDialogState();
}

class _LedControlDialogState extends ConsumerState<LedControlDialog> {
  late int _r;
  late int _g;
  late int _b;
  late int _w;

  @override
  void initState() {
    super.initState();
    final hex = widget.information.value;
    final rgba = _hexToRgbw(hex);
    _r = rgba[0];
    _g = rgba[1];
    _b = rgba[2];
    _w = rgba[3];
  }

  Future<void> setRGBW(String hex) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.setRGBW(widget.information.positionPath, hex, (hex){
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('LED eingestellt')));
    });
  }

  // HEX in RGBW umwandeln
  List<int> _hexToRgbw(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex += '00'; // Wenn W fehlt, 0 setzen
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

  // RGBW zurück in HEX
  String _rgbwToHex(int r, int g, int b, int w) {
    return '#'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'
        '${w.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color get _ledColor =>
      Color.fromARGB(255, (_r + _w).clamp(0, 255), (_g + _w).clamp(0, 255), (_b + _w).clamp(0, 255));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2E2E2E),
      title: const Text('LED Control', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _ledColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _ledColor.withOpacity(0.7), blurRadius: 12, spreadRadius: 2),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _slider('R', Colors.red, _r, (val) => setState(() => _r = val)),
            _slider('G', Colors.green, _g, (val) => setState(() => _g = val)),
            _slider('B', Colors.blue, _b, (val) => setState(() => _b = val)),
            _slider('W', Colors.white, _w, (val) => setState(() => _w = val)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            setRGBW(_rgbwToHex(_r, _g, _b, _w));
          },
          child: const Text('Set', style: TextStyle(color: Colors.greenAccent)),
        ),
      ],
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