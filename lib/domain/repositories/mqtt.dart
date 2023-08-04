import 'package:mqtt_client/mqtt_client.dart';

abstract class RepositoryMqtt {
  Future<void> connect();
  Future<void> disconnect();
  Stream<List<MqttReceivedMessage<MqttMessage>>>? watchReceivedMessage();
  Future<Stream> watchPublishedMessage();
  void listenOnConnected(void Function() onConnected);
  void listenOnDisconnected(void Function() onDisconnected);
  void listenOnAutoReconnect(void Function() onAutoReconnect);
  void listenOnAutoReconnected(void Function() onAutoReconnected);
}
