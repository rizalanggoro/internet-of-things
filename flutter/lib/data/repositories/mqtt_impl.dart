import 'package:internet_of_things/core/di/dependency_injector.dart';
import 'package:internet_of_things/data/providers/mqtt.dart';
import 'package:internet_of_things/domain/repositories/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

class RepositoryMqttImpl implements RepositoryMqtt {
  final ProviderMqtt _providerMqtt = dependencyInjector();

  @override
  Future<void> connect() async {
    await _providerMqtt.client.connect();
  }

  @override
  Future<void> disconnect() async {
    _providerMqtt.client.disconnect();
  }

  @override
  Stream<List<MqttReceivedMessage<MqttMessage>>>? watchReceivedMessage() {
    return _providerMqtt.client.updates;
  }

  @override
  Stream<MqttPublishMessage>? watchPublishedMessage() {
    return _providerMqtt.client.published;
  }

  @override
  void listenOnConnected(void Function() onConnected) {
    _providerMqtt.client.onConnected = onConnected;
  }

  @override
  void listenOnDisconnected(void Function() onDisconnected) {
    _providerMqtt.client.onDisconnected = onDisconnected;
  }

  @override
  void listenOnAutoReconnect(void Function() onAutoReconnect) {
    _providerMqtt.client.onAutoReconnect = onAutoReconnect;
  }

  @override
  void listenOnAutoReconnected(void Function() onAutoReconnected) {
    _providerMqtt.client.onAutoReconnected = onAutoReconnected;
  }

  @override
  void publishMessage({
    required String topic,
    required String message,
  }) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    final payload = builder.payload;
    if (payload != null) {
      _providerMqtt.client.publishMessage(
        topic,
        MqttQos.exactlyOnce,
        payload,
      );
    }
  }

  @override
  void subscribe({
    required String topic,
  }) {
    _providerMqtt.client.subscribe(
      topic,
      MqttQos.exactlyOnce,
    );
  }

  @override
  void unsubscribe({required String topic}) {
    _providerMqtt.client.unsubscribe(topic);
  }
}
