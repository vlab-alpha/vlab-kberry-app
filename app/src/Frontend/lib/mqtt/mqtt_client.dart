import 'dart:async';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

final log = Logger();

class Mqtt5Client {
  final String brokerIp;
  final int port;
  MqttServerClient? client;
  bool _reconnecting = false;
  StreamSubscription? _updatesSub;

  final Map<String, void Function(String payload, String topic)> _response = {};
  final Map<String, void Function(String payload, String topic)> _subscription =
      {};

  bool get isConnected =>
      client?.connectionStatus?.state == MqttConnectionState.connected;

  Mqtt5Client({required this.brokerIp, required this.port});

  Future<bool> connect() async {

    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      return true;
    }

    client = MqttServerClient(brokerIp, '');
    client!.port = port;

    client!.logging(on: true);
    client!.keepAlivePeriod = 30;
    client!.socketTimeout = 15000;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;
    client!.pongCallback = pong;
    client!.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('SmartHomeTablet')
        .startClean();
    try {
      await client!.connect();
    } on MqttNoConnectionException catch (e) {
      log.e("No MQTT Connection!", error: e);
      client?.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      log.e("Mqtt Socket Exception", error: e);
      client?.disconnect();
      return false;
    }
    var success = false;
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      success = true;
      if (client!.connectionStatus!.connectAckMessage.userProperty!.isNotEmpty) {
        log.i(
          "Connected - user property name  - ${client!.connectionStatus!.connectAckMessage.userProperty![0].pairName}",
        );
      }
    }

    _updatesSub?.cancel();
    _updatesSub = client?.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttUtilities.bytesToStringAsString(recMess.payload.message!);
      final topic = c[0].topic;
      final subscriptionKey = _subscription.keys.firstWhere(
        (key) => topic?.startsWith(key) ?? false,
        orElse: () => '',
      );
      if (subscriptionKey.isNotEmpty) {
        _subscription[subscriptionKey]?.call(pt, topic ?? "");
      } else if (_response.containsKey(topic)) {
        _response[topic]?.call(pt, topic ?? "");
        _response.remove(topic);
        if (topic != null) {
          client!.unsubscribeStringTopic(topic);
        }
      } else {
        log.e("Unknown topic $topic");
      }
    });
    log.i("MQTT $success!");
    return success;
  }

  void subscribeAll(String topic, void Function(String, String) onMessage) {
    _subscription[topic] = onMessage;
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      client!.subscribe("$topic/#", MqttQos.atMostOnce);
    }
  }

  void request(
    String topic,
    String payload,
    void Function(String, String) onMessage,
  ) {
    if (client?.connectionStatus?.state != MqttConnectionState.connected) {
      log.w("Request skipped, MQTT not connected");
      return;
    }
    final requestTopic = "request/$topic";
    final responseTopic = "response/$topic";
    _response[responseTopic] = onMessage;
    client!.subscribe(responseTopic, MqttQos.atMostOnce);
    final builder = MqttPayloadBuilder();
    builder.addUTF8String(payload);
    client!.publishMessage(requestTopic, MqttQos.atMostOnce, builder.payload!);
  }

  void publish(String topic, String payload) {
    if (client == null || client!.connectionStatus?.state != MqttConnectionState.connected) {
      log.w("Publish skipped, MQTT not connected");
      return;
    }
    final builder = MqttPayloadBuilder();
    builder.addUTF8String(payload);
    client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  void disconnect() {
    client?.disconnect();
    log.e("Disconnected MQTT Connection!");
  }

  void onConnected() {
    log.i("OnConnected client callback - Client connection was successful");
  }

  void onSubscribed(message) {
    log.i(
      "onSubscribed client callback - Client connection was successful $message",
    );
  }

  void onDisconnected() async {
    if (_reconnecting) return;
    _reconnecting = true;

    log.w("MQTT disconnected – trying reconnect...");
    if (_response.isNotEmpty) {
      log.w("Dropping ${_response.length} pending MQTT requests due to disconnect");
    }
    _response.clear();
    await Future.delayed(const Duration(seconds: 2));

    try {
      if(await connect()) {
        _resubscribeAll();
      }
    } finally {
      _reconnecting = false;
    }
  }

  void _resubscribeAll() {
    for (final topic in _subscription.keys) {
      client?.subscribe("$topic/#", MqttQos.atMostOnce);
    }
  }

  /// Pong callback
  void pong() {
    //print('EXAMPLE::Ping response client callback invoked');
  }
}
