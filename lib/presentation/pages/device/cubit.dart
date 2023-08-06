import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_of_things/core/config.dart';
import 'package:internet_of_things/core/di/dependency_injector.dart';
import 'package:internet_of_things/core/models/mode.dart';
import 'package:internet_of_things/core/models/mqtt.dart';
import 'package:internet_of_things/domain/repositories/mqtt.dart';
import 'package:internet_of_things/presentation/pages/device/state.dart';
import 'package:mqtt_client/mqtt_client.dart';

class DeviceCubit extends Cubit<DeviceState> {
  final String deviceId;

  final RepositoryMqtt _repositoryMqtt = dependencyInjector();
  final List<String> _queueTopics = [];
  StreamSubscription? _subscriptionPublishedMessage,
      _subscriptionReceivedMessage;

  @override
  Future<void> close() {
    log('DeviceCubit closed!');

    _subscriptionPublishedMessage?.cancel();
    _subscriptionReceivedMessage?.cancel();
    _initializeSubscribe(isSubscribe: false);

    return super.close();
  }

  DeviceCubit({
    required this.deviceId,
  }) : super(DeviceStateInitial()) {
    emit(DeviceStateReadLoading());

    // subscribe to device topics
    _initializeSubscribe(isSubscribe: true);

    // listen published message
    final streamPublishedMessage = _repositoryMqtt.watchPublishedMessage();
    if (streamPublishedMessage != null) {
      _subscriptionPublishedMessage?.cancel();
      _subscriptionPublishedMessage = streamPublishedMessage.listen((event) {
        final topic = event.variableHeader?.topicName;
        if (topic != null) {
          if (_queueTopics.contains(topic)) {
            _queueTopics.remove(topic);
          }
        }

        if (_queueTopics.isEmpty) {
          emit(DeviceStateSendSuccess());
        }
      });
    }

    // listen received message
    final streamReceivedMessage = _repositoryMqtt.watchReceivedMessage();
    if (streamReceivedMessage != null) {
      _subscriptionReceivedMessage?.cancel();
      _subscriptionReceivedMessage = streamReceivedMessage.listen((event) {
        final topic = event[0].topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
          (event[0].payload as MqttPublishMessage).payload.message,
        );

        final topics = topic.split('/');
        if (topics[3] == 'pub') {
          // ESP -> broker -> Flutter
          if (topics[4] == 'uptime') {
            emit(DeviceStateUptimeChanged(
              value: int.parse(payload),
            ));
          }

          if (topics[4] == 'heap') {
            emit(DeviceStateHeapChanged(
              value: int.parse(payload),
            ));
          }

          if (topics[4] == 'config') {
            try {
              final json = jsonDecode(payload);

              final String colorStr = json['color'] ?? '0.0.0';
              final in1 = colorStr.indexOf('.');
              final in2 = colorStr.lastIndexOf('.');

              int r = int.parse(colorStr.substring(0, in1));
              int g = int.parse(colorStr.substring(in1 + 1, in2));
              int b = int.parse(colorStr.substring(in2 + 1));

              final String autoMode = json['auto_mode'] ?? 'off';

              emit(DeviceStateReadSuccess(
                mqtt: ModelMqtt(
                  deviceId: deviceId,
                  mode: int.parse(json['mode'] ?? '0'),
                  brightness: int.parse(json['brightness'] ?? '100'),
                  speed: int.parse(json['speed']),
                  color: Color.fromARGB(255, r, g, b),
                  autoMode: autoMode == 'on',
                ),
              ));
            } catch (error) {
              log(error.toString());
              emit(DeviceStateReadFailure());
            }
          }
        }
      });
    }

    _getDeviceConfig();
  }

  void _initializeSubscribe({
    required bool isSubscribe,
  }) {
    final prefixPub = '${Config.basePrefix}/$deviceId/pub';

    final pubTopicUptime = '$prefixPub/uptime';
    final pubTopicHeap = '$prefixPub/heap';
    final pubTopicConfig = '$prefixPub/config';

    if (isSubscribe) {
      _repositoryMqtt.subscribe(topic: pubTopicConfig);
      _repositoryMqtt.subscribe(topic: pubTopicHeap);
      _repositoryMqtt.subscribe(topic: pubTopicUptime);
    } else {
      _repositoryMqtt.unsubscribe(topic: pubTopicConfig);
      _repositoryMqtt.unsubscribe(topic: pubTopicHeap);
      _repositoryMqtt.unsubscribe(topic: pubTopicUptime);
    }
  }

  void _getDeviceConfig() {
    final topic = '${Config.basePrefix}/$deviceId/sub/config';
    _repositoryMqtt.publishMessage(
      topic: topic,
      message: 'config',
    );
  }

  void changeAutoMode({
    required bool isEnable,
  }) {
    emit(DeviceStateAutoChanged(
      isEnable: isEnable,
    ));
  }

  void changeMode({
    required ModelMode mode,
  }) =>
      emit(DeviceStateModeChanged(
        mode: mode,
      ));

  void changeBrightness({
    required double value,
  }) =>
      emit(DeviceStateBrightnessChanged(
        value: value,
      ));

  void increaseSpeed({
    required int currentSpeed,
  }) {
    if (currentSpeed < 16000) {
      emit(DeviceStateSpeedChanged(
        value: currentSpeed * 2,
      ));
    }
  }

  void decreaseSpeed({
    required int currentSpeed,
  }) {
    if (currentSpeed > 128) {
      emit(DeviceStateSpeedChanged(
        value: currentSpeed ~/ 2,
      ));
    }
  }

  void changeColor({
    required Color color,
  }) {
    emit(DeviceStateColorChanged(
      value: color,
    ));
  }

  void send({
    required ModelMqtt mqtt,
  }) {
    final prefixSub = '${Config.basePrefix}/${mqtt.deviceId}/sub';
    final subTopicMode = '$prefixSub/mode';
    final subTopicBrightness = '$prefixSub/brightness';
    final subTopicSpeed = '$prefixSub/speed';
    final subTopicColor = '$prefixSub/color';
    final subTopicAutoMode = '$prefixSub/auto_mode';

    emit(DeviceStateSendLoading());

    _queueTopics.add(subTopicMode);
    _repositoryMqtt.publishMessage(
      topic: subTopicMode,
      message: mqtt.mode.toString(),
    );

    _queueTopics.add(subTopicBrightness);
    _repositoryMqtt.publishMessage(
      topic: subTopicBrightness,
      message: mqtt.brightness.toString(),
    );

    _queueTopics.add(subTopicSpeed);
    _repositoryMqtt.publishMessage(
      topic: subTopicSpeed,
      message: mqtt.speed.toString(),
    );

    _queueTopics.add(subTopicColor);
    _repositoryMqtt.publishMessage(
      topic: subTopicColor,
      message: '${mqtt.color.red}.${mqtt.color.green}.${mqtt.color.blue}',
    );

    _queueTopics.add(subTopicAutoMode);
    _repositoryMqtt.publishMessage(
      topic: subTopicAutoMode,
      message: mqtt.autoMode ? 'on' : 'off',
    );
  }

  void saveConfig() {
    final prefixSub = '${Config.basePrefix}/$deviceId/sub';
    final subTopicSave = '$prefixSub/save';

    emit(DeviceStateSendLoading());

    _queueTopics.add(subTopicSave);
    _repositoryMqtt.publishMessage(
      topic: subTopicSave,
      message: 'save',
    );
  }
}
