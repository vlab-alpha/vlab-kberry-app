// import 'mqtt_dummy.dart';
// import 'package:flutter/material.dart';
//
// class MqttDemoPage extends StatefulWidget {
//   const MqttDemoPage({super.key});
//
//   @override
//   State<MqttDemoPage> createState() => _MqttDemoPageState();
// }
//
// class _MqttDemoPageState extends State<MqttDemoPage> {
//   late SimpleWsMqttClient mqttClient;
//
//   @override
//   void initState() {
//     super.initState();
//     mqttClient = SimpleWsMqttClient(
//       brokerIp: '192.168.178.164',
//       port: 9001,
//       clientId: 'flutter_client',
//     );
//     mqttClient.connect();
//   }
//
//   @override
//   void dispose() {
//     mqttClient.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('MQTT Demo')),
//       body: const Center(child: Text('MQTT Client läuft, siehe Logs')),
//     );
//   }
// }