import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service_provider.dart';
import '../model/data.dart';

class SettingsView extends ConsumerStatefulWidget {
  final String positionPath;
  final InformationType type;

  const SettingsView({
    super.key,
    required this.positionPath,
    required this.type,
  });

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  List<Setting> settings = [];
  List<Setting> originalSettings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    setState(() => loading = true);
    service.getSettings(widget.positionPath, widget.type, (fetchedSettings) {
      setState(() {
        settings = fetchedSettings;
        originalSettings = fetchedSettings.map((s) => Setting(
          type: s.type,
          title: s.title,
          icon: s.icon,
          value: Value(
            type: s.value.type,
            value: s.value.value,
            from: s.value.from,
            to: s.value.to,
          ),
        ))
            .toList();
        loading = false;
      });
    });
  }

  Future<void> _saveSettings(List<Setting> updated) async {
    final service = ref.read(smartHomeServiceProvider);
    final connected = await service.connect();
    if (!connected) return;
    service.saveSettings(widget.positionPath, widget.type, updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Einstellungen übernommen')),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (settings.isEmpty)
      return const Center(child: Text("Keine Einstellungen verfügbar"));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(child: ListView.separated(
            separatorBuilder: (_, __) => const Divider(),
            itemCount: settings.length,
            itemBuilder: (context, index) {
              final setting = settings[index];
              return _buildSettingItem(setting);
            },),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _saveSettings(settings),
                icon: const Icon(Icons.save),
                label: const Text("Übernehmen"),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    // Originalwerte wiederherstellen
                    settings = originalSettings
                        .map((s) => Setting(
                      type: s.type,
                      title: s.title,
                      icon: s.icon,
                      value: Value(
                        type: s.value.type,
                        value: s.value.value,
                        from: s.value.from,
                        to: s.value.to,
                      ),
                    ))
                        .toList();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Einstellungen zurückgesetzt')),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Zurücksetzen"),
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _buildSettingItem(Setting setting) {
    Widget control;

    switch (setting.type) {
      case SettingType.NumberSpan:
        control = _buildNumberSpan(setting);
        break;
      case SettingType.Checkbox:
        control = _buildCheckbox(setting);
        break;
      case SettingType.Time:
        control = _buildTimePicker(setting);
        break;
      case SettingType.TimeSpan:
        control = _buildTimeSpanPicker(setting);
        break;
      case SettingType.Date:
        control = _buildDatePicker(setting);
        break;
      case SettingType.DateSpan:
        control = _buildDateSpanPicker(setting);
        break;
      default:
        control = TextField(
          controller: TextEditingController(text: setting.value.value),
          decoration: InputDecoration(
            labelText: setting.title,
            border: OutlineInputBorder(),
            prefixIcon: Icon(
              _iconFromName(setting.icon!),
              color: Colors.blueGrey,
            ),
          ),
          onChanged: (val) => setting.value.value = val,
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (setting.icon != null && _iconFromName(setting.icon!) != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  _iconFromName(setting.icon!),
                  color: Colors.blueGrey,
                ),
              ),
            Text(
              setting.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        control,
      ],
    );
  }

  Widget _buildNumberSpan(Setting setting) {
    double from = (setting.value.parsedFrom ?? 0).toDouble();
    double to = (setting.value.parsedTo ?? 100).toDouble();
    double value = double.tryParse(setting.value.value.toString()) ?? 0;
    return Column(
      children: [
        _sliderRow(setting.title, value, from + 1, to, (v) {
          setState(
            () => setting.value = Value(
              type: setting.value.type,
              value: v.toString(),
              from: setting.value.from,
              to: setting.value.to,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCheckbox(Setting setting) {
    bool checked = setting.value.value.toLowerCase() == 'true';
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: (v) {
            setState(
              () => setting.value = Value(
                type: ValueType.Boolean,
                value: (v ?? false).toString(),
              ),
            );
          },
        ),
        const Text("Aktivieren"),
      ],
    );
  }

  Widget _buildTimePicker(Setting setting) {
    TimeOfDay initial = TimeOfDay.fromDateTime(
      DateTime.tryParse(setting.value.value) ?? DateTime.now(),
    );
    return Row(
      children: [
        Text(setting.value.value),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: initial,
            );
            if (picked != null) {
              setState(
                () => setting.value = Value(
                  type: ValueType.String,
                  value: picked.format(context),
                ),
              );
            }
          },
          child: const Text("Zeit wählen"),
        ),
      ],
    );
  }

  Widget _buildTimeSpanPicker(Setting setting) {
    TimeOfDay from = TimeOfDay.fromDateTime(
      DateTime.tryParse(setting.value.from ?? "") ?? DateTime.now(),
    );
    TimeOfDay to = TimeOfDay.fromDateTime(
      DateTime.tryParse(setting.value.to ?? "") ?? DateTime.now(),
    );

    return Column(
      children: [
        Row(
          children: [
            Text("Von: ${setting.value.from ?? ''}"),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: from,
                );
                if (picked != null) {
                  setState(
                    () => setting.value = Value(
                      type: ValueType.String,
                      value: setting.value.value,
                      from: picked.format(context),
                      to: setting.value.to,
                    ),
                  );
                }
              },
              child: const Text("Von wählen"),
            ),
          ],
        ),
        Row(
          children: [
            Text("Bis: ${setting.value.to ?? ''}"),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: to,
                );
                if (picked != null) {
                  setState(
                    () => setting.value = Value(
                      type: ValueType.String,
                      value: setting.value.value,
                      from: setting.value.from,
                      to: picked.format(context),
                    ),
                  );
                }
              },
              child: const Text("Bis wählen"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(Setting setting) {
    DateTime initial = DateTime.tryParse(setting.value.value) ?? DateTime.now();
    return Row(
      children: [
        Text(setting.value.value),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(
                () => setting.value = Value(
                  type: ValueType.String,
                  value: picked.toIso8601String(),
                ),
              );
            }
          },
          child: const Text("Datum wählen"),
        ),
      ],
    );
  }

  Widget _buildDateSpanPicker(Setting setting) {
    DateTime from =
        DateTime.tryParse(setting.value.from ?? "") ?? DateTime.now();
    DateTime to = DateTime.tryParse(setting.value.to ?? "") ?? DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            Text("Von: ${setting.value.from ?? ''}"),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: from,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(
                    () => setting.value = Value(
                      type: ValueType.String,
                      value: setting.value.value,
                      from: picked.toIso8601String(),
                      to: setting.value.to,
                    ),
                  );
                }
              },
              child: const Text("Von wählen"),
            ),
          ],
        ),
        Row(
          children: [
            Text("Bis: ${setting.value.to ?? ''}"),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: to,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(
                    () => setting.value = Value(
                      type: ValueType.String,
                      value: setting.value.value,
                      from: setting.value.from,
                      to: picked.toIso8601String(),
                    ),
                  );
                }
              },
              child: const Text("Bis wählen"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade700)),
            const Spacer(),
            Text("${value.toStringAsFixed(0)}%"),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 20,
          label: "${value.toStringAsFixed(0)}%",
          onChanged: onChanged,
        ),
      ],
    );
  }

  IconData? _iconFromName(String name) {
    const iconMap = {
      "light": Icons.lightbulb,
      "brightness": Icons.wb_sunny,
      "dimmer": Icons.tune,
      "power": Icons.power,
      "clock": Icons.access_time,
      "settings": Icons.settings,
      "ac_unit": Icons.ac_unit,
      "person_pin": Icons.person_pin,
      "arrow_circle_up": Icons.arrow_circle_up,
      "arrow_circle_down": Icons.arrow_circle_down,
      "nights_stay": Icons.nights_stay,
      "severe_cold": Icons.severe_cold,
      "local_fire_department": Icons.local_fire_department,
      "numbers": Icons.numbers,
      "nightlight_round": Icons.nightlight_round,
      "brightness_low": Icons.brightness_low,
      "auto_mode": Icons.auto_mode,
      "child_care": Icons.child_care,
      "person_pin_circle_outlined": Icons.person_pin_circle_outlined,
      "person_pin_circle": Icons.person_pin_circle,
      "timelapse": Icons.timelapse,
      "lightbulb_outline": Icons.lightbulb_outline,
      "lightbulb": Icons.lightbulb,
      "offline_bolt_outlined": Icons.offline_bolt_outlined,
      "offline_bolt_rounded": Icons.offline_bolt_rounded,
      "cloud": Icons.cloud,
      "night_shelter_outlined": Icons.night_shelter_outlined,
      "browse_gallery": Icons.browse_gallery,
      "co2": Icons.co2,
      "cloud_circle": Icons.cloud_circle,
      "warning_outlined": Icons.warning_outlined,
      "warning_amber_outlined": Icons.warning_amber_outlined,
      "join_inner": Icons.join_inner,
      "timelapse_outlined": Icons.timelapse_outlined,
      "arrow_downward": Icons.arrow_downward,
      "arrow_upward": Icons.arrow_upward,
    };
    return iconMap[name];
  }
}
