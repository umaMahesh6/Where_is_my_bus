import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttLocationMessage {
  final String busId;
  final double latitude;
  final double longitude;
  final int timestampMs;

  MqttLocationMessage({
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
        'busId': busId,
        'lat': latitude,
        'lng': longitude,
        'ts': timestampMs,
      };

  static MqttLocationMessage? fromJson(String jsonStr) {
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return MqttLocationMessage(
        busId: map['busId'] as String,
        latitude: (map['lat'] as num).toDouble(),
        longitude: (map['lng'] as num).toDouble(),
        timestampMs: map['ts'] as int,
      );
    } catch (_) {
      return null;
    }
  }
}

class MqttService {
  final String clientId;
  final String host;
  final int port;
  final bool secure;

  late final MqttServerClient _client;
  final StreamController<MqttLocationMessage> _messagesController =
      StreamController.broadcast();

  Stream<MqttLocationMessage> get locationStream => _messagesController.stream;

  MqttService({
    required this.clientId,
    this.host = 'broker.emqx.io',
    this.port = 1883,
    this.secure = false,
  }) {
    _client = MqttServerClient(host, clientId);
    _client.port = port;
    _client.secure = secure;
    _client.keepAlivePeriod = 30;
    _client.logging(on: false);
    _client.onConnected = () {};
    _client.onDisconnected = () {};
    _client.onSubscribed = (_) {};
  }

  Future<void> connect() async {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;
    await _client.connect();
  }

  Future<void> disconnect() async {
    _client.disconnect();
  }

  String topicForBus(String busId) => 'punjab/bus/$busId';

  Future<void> subscribeBus(String busId) async {
    await connect();
    final topic = topicForBus(busId);
    _client.subscribe(topic, MqttQos.atLeastOnce);
    _client.updates?.listen((events) {
      for (final event in events) {
        final rec = event.payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(rec.payload.message);
        final msg = MqttLocationMessage.fromJson(pt);
        if (msg != null) _messagesController.add(msg);
      }
    });
  }

  Future<void> publishLocation(MqttLocationMessage message) async {
    await connect();
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(json.encode(message.toJson()));
    _client.publishMessage(
      topicForBus(message.busId),
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );
  }
}


