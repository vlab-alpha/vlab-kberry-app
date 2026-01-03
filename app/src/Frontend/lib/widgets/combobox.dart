import 'package:flutter/material.dart';
import '../model/data.dart';

class ComboBox extends StatelessWidget {
  final InformationType selectedType;
  final ValueChanged<InformationType> onChanged;

  const ComboBox({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Map<InformationType, IconData> typeIcons = {
      InformationType.alle: Icons.dashboard,
      InformationType.temperature: Icons.thermostat,
      InformationType.light: Icons.lightbulb,
      InformationType.jalousie: Icons.blinds,
      InformationType.humidity: Icons.water_drop,
      InformationType.usage: Icons.bar_chart,
      InformationType.plug: Icons.power,
      InformationType.weather: Icons.wb_sunny,
      InformationType.dimmer: Icons.brightness_6_rounded,
      InformationType.fan: Icons.flip_camera_android,
      InformationType.scene: Icons.play_circle,
      InformationType.camera: Icons.camera_alt,
      InformationType.launcher: Icons.rocket_launch,
      InformationType.co2: Icons.co2,
      InformationType.led: Icons.color_lens,
      InformationType.energy: Icons.energy_savings_leaf,
    };

    return DropdownButton<InformationType>(
      value: selectedType,
      isExpanded: true,
      onChanged: (InformationType? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      items: InformationType.values.map((InformationType type) {
        return DropdownMenuItem<InformationType>(
          value: type,
          child: Row(
            children: [
              Icon(typeIcons[type], color: Color(0xFF6C6C6C)),
              const SizedBox(width: 8),
              Text(
                type.name.toUpperCase(),
                style: TextStyle(color: Color(0xFF6C6C6C)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
