import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartHome/card/light_card.dart';
import 'package:SmartHome/card/stream_card.dart';
import 'package:SmartHome/card/usage_card.dart';
import 'package:SmartHome/model/Position.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../card/jalousie_card.dart';
import '../card/switch_card.dart';
import '../card/temperatur_card.dart';
import '../card/weather_card.dart';
import '../dialog/dialog_manager.dart';
import '../model/data.dart';
import '../widgets/combobox.dart';
import '../card/light_dimmer_card.dart';
import '../service_provider.dart';
import '../widgets/position_menu.dart';
import 'package:logger/logger.dart';
import '../model/data.dart';
import '../card/card_manager.dart';

final log = Logger();

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final Map<String, Information> informationMap = {};
  final Map<String, List<String>> positionsPaths = {};
  String? selectedPositionPath;
  InformationType selectedType = InformationType.alle;
  bool _mqttConnected = false;

  Future<bool> connectAndInit() async {
    final mqtt = ref.read(smartHomeServiceProvider);
    try {
      final connected = await mqtt.connect();
      setState(() {
        _mqttConnected = connected;
      });
      if (!connected) return false;

      log.i("✅ MQTT verbunden");
      mqtt.subscribeToInformation((Information info, String topic) {
        setState(() {

          informationMap[topic] = info;
        });
      });
      return true;
    } catch (e) {
      _mqttConnected = false;
      log.t("❌ MQTT-Verbindung fehlgeschlagen: $e");
    }
    return false;
  }

  Future<void> _initAndLoad() async {
    final success = await connectAndInit();
    if (success) {
      loadPositionPaths();
    }
  }

  Future<void> executeScene(String positionPath, String title) async {
    if (!_mqttConnected) return; // nur wenn verbunden
    final mqtt = ref.read(smartHomeServiceProvider);
    var connected = await mqtt.connect();
    if (!connected) return;
    mqtt.publishScene(positionPath, title);
  }

  void loadPositionPaths() {
    log.t("Load Position Path");
    if (!_mqttConnected) return; // nur wenn verbunden
    final mqtt = ref.read(smartHomeServiceProvider);
    log.t("Execute Position Path");
    mqtt.getPositionPaths((List<String> positionPaths) {
      log.t("received Position Path");
      setState(() {
        positionsPaths["Positionen"] = positionPaths
            .map((path) => path.split("/")[0])
            .toSet()
            .toList();

        positionsPaths["Ebenen"] = positionPaths
            .where((path) => path.split("/").length > 1)
            .map((path) => path.split("/")[1])
            .toSet()
            .toList();

        positionsPaths["Räume"] = positionPaths
            .where((path) => path.split("/").length > 2)
            .map((path) => path.split("/")[2])
            .toSet()
            .toList();
      });
    });
  }

  List<Information> getInformation(InformationType type, String? positionPath) {
    return informationMap.values.where((info) {
      final matchesType = type == InformationType.alle || info.type == type;
      final matchesPosition =
          positionPath == null ||
          (info.positionPath != null &&
              info.positionPath!.toLowerCase().contains(
                positionPath.toLowerCase().trim(),
              ));
      return matchesType && matchesPosition;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    informationMap["reolink_1"] = Information(
      positionPath: "Haus/Eingang/Tür",
      type: InformationType.camera,
      password: null,
      title: "Türkamera",
      value:
          "rtsp://admin:dyjBu1-pawbin-biqbuc@192.168.178.99:554/h264Preview_01_main",
    );
    informationMap["phone"] = Information(
      type: InformationType.launcher,
      positionPath: "Haus/Eingang/Diele",
      title: "Telefon",
      value: "openSipgate",
      password: null,
      icon: "phone",
    );
    informationMap["camera"] = Information(
      type: InformationType.launcher,
      positionPath: "Haus/Eingang/Diele",
      title: "Reolink",
      value: "openReolinkApp",
      password: null,
      icon: "camera",
    );
    _initAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    final infoList = getInformation(selectedType, selectedPositionPath);

    return Scaffold(
      backgroundColor: const Color(0xFFDADADA),
      appBar: AppBar(
        title: const Text(
          'Radle Smart Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A5A5A),
            fontSize: 15,
          ),
        ),
        actions: [
          // MQTT Reload Button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "PositionPaths neu laden",
            onPressed: () async {
              if (_mqttConnected) {
                loadPositionPaths();
              } else {
                setState(() {
                  _mqttConnected =
                      false; // Optional: noch rot während des Verbindens
                });

                final success = await connectAndInit();
                setState(() {
                  _mqttConnected = success;
                });

                if (success) {
                  loadPositionPaths();
                }
              }
            },
          ),
          // Statusanzeige MQTT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.circle,
              color: _mqttConnected ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
        ],
        backgroundColor: Color(0xFFDADADA),
        foregroundColor: Color(0xFF606060),
      ),
      body: Row(
        children: [
          PositionMenu(
            positionsPaths: positionsPaths,
            selectedPositionPath: selectedPositionPath,
            onPositionSelected: (item) {
              setState(() => selectedPositionPath = item);
            },
          ),

          const VerticalDivider(width: 0, color: Color(0xFFCCCCCC)),

          // --- Hauptinhalt ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // volle Breite
                children: [
                  // --- ComboBox oben ---
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ComboBox(
                      selectedType: selectedType,
                      onChanged: (InformationType newType) {
                        setState(() {
                          selectedType = newType;
                        });
                      },
                    ),
                  ),

                  // --- Grid mit Cards ---
                  Expanded(
                    child: SingleChildScrollView(
                      child: StaggeredGrid.count(
                        crossAxisCount: 4, // Basis-Spalten
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        children: infoList.map((info) {
                          final isCamera = info.type == InformationType.camera;

                          return StaggeredGridTile.count(
                            crossAxisCellCount: isCamera ? 2 : 1,
                            mainAxisCellCount: isCamera ? 2 : 1,
                            child: InkWell(
                              onTap: () => showInfoPopup(context, info),
                              child: buildCard(info, (path, title) async {
                                await executeScene(path, title);
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
