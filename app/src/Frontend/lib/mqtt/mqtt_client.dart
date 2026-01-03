import 'dart:async';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'dart:convert';

class Mqtt5Client {
  final String brokerIp;
  final int port;
  late MqttServerClient client;

  final Map<String, void Function(String payload, String topic)> _response = {};
  final Map<String, void Function(String payload, String topic)> _subscription = {};

  Mqtt5Client({
    required this.brokerIp,
    required this.port,
  });

  Future<bool> connect() async {
    client = MqttServerClient(this.brokerIp, 'flutter client');
    client.port = this.port;

    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.socketTimeout = 2000;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final property = MqttUserProperty();
    property.pairName = 'Example name';
    property.pairValue = 'Example value';
    final connMess = MqttConnectMessage()
        .withClientIdentifier('MQTT5DartClient')
        .startClean() // Or startSession() for a persistent session
        .withUserProperties([property]);

    try {
      await client.connect();
    } on MqttNoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
    }
    var success = false;
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      success = true;
      /// All returned properties in the connect acknowledge message are available.
      /// Get our user properties from the connect acknowledge message.
      if (client.connectionStatus!.connectAckMessage.userProperty!.isNotEmpty) {
        print(
          'EXAMPLE::Connected - user property name - ${client.connectionStatus!.connectAckMessage.userProperty![0].pairName}',
        );

      }
    } else {
      client.disconnect();
      exit(-1);
    }

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttUtilities.bytesToStringAsString(recMess.payload.message!);
      final topic = c[0].topic;
      final subscriptionKey = _subscription.keys.firstWhere(
            (key) => topic?.startsWith(key)??false,
        orElse: () => '',
      );
      if(subscriptionKey.isNotEmpty) {
        _subscription[subscriptionKey]?.call(pt, topic??"");
      } else if(_response.containsKey(topic)) {
        _response[topic]?.call(pt, topic??"");
        _response.remove(topic);
      } else {
        print("Unknown topic $topic");
      }
      // print(
      //   'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->',
      // );
    });
    print("SUCCESS: $success");
    return success;
  }

  void subscribeAll(String topic, void Function(String, String) onMessage) {
    _subscription[topic] = onMessage;
    client.subscribe("$topic/#", MqttQos.atMostOnce);
  }

  void request(String topic, String payload, void Function(String, String) onMessage) {
    final requestTopic = "request/$topic";
    final responseTopic = "response/$topic";
    _response[responseTopic] = onMessage;
    client.subscribe(responseTopic, MqttQos.atMostOnce);
    final builder = MqttPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(requestTopic, MqttQos.atMostOnce, builder.payload!);
  }

  void publish(String topic, String payload) {
    final builder = MqttPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  void disconnect() {
    client.disconnect();
    print('⚠️ MQTT getrennt');
  }

  void onConnected() {
    print(
      'EXAMPLE::OnConnected client callback - Client connection was successful',
    );
  }

  void onSubscribed(message) {
    print(
      'EXAMPLE::onSubscribed client callback - Client connection was successful $message',
    );
  }

  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {

    }
    exit(0);
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
  }
}