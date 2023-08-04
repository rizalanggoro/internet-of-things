import 'package:internet_of_things/core/config.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ProviderMqtt {
  late MqttClient _client;

  MqttClient get client => _client;

  Future<void> initialize() async {
    var clientIdentifier =
        'com.anggoro.iot/flutter-app/${DateTime.now().toIso8601String()}';
    _client = MqttServerClient(Config.broker, clientIdentifier);
    _client.logging(on: true);
    _client.autoReconnect = true;
  }
}
