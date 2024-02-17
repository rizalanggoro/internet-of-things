import 'package:mqtt_client/mqtt_client.dart';

abstract class RepositoryMqtt {
  Future<void> connect();
  Future<void> disconnect();
  Stream<List<MqttReceivedMessage<MqttMessage>>>? watchReceivedMessage();
  Stream<MqttPublishMessage>? watchPublishedMessage();
  void listenOnConnected(void Function() onConnected);
  void listenOnDisconnected(void Function() onDisconnected);
  void listenOnAutoReconnect(void Function() onAutoReconnect);
  void listenOnAutoReconnected(void Function() onAutoReconnected);
  void publishMessage({
    required String topic,
    required String message,
  });
  void subscribe({required String topic});
  void unsubscribe({required String topic});
}
