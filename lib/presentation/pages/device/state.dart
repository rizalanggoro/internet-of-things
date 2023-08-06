import 'package:flutter/material.dart';
import 'package:internet_of_things/core/models/mode.dart';
import 'package:internet_of_things/core/models/mqtt.dart';

sealed class DeviceState {}

class DeviceStateInitial extends DeviceState {}

// auto
sealed class DeviceStateAuto extends DeviceState {}

class DeviceStateAutoChanged extends DeviceStateAuto {
  final bool isEnable;

  DeviceStateAutoChanged({
    required this.isEnable,
  });
}

// read
sealed class DeviceStateRead extends DeviceState {}

class DeviceStateReadLoading extends DeviceStateRead {}

class DeviceStateReadSuccess extends DeviceStateRead {
  final ModelMqtt mqtt;

  DeviceStateReadSuccess({
    required this.mqtt,
  });
}

class DeviceStateReadFailure extends DeviceStateRead {}

// mode
sealed class DeviceStateMode extends DeviceState {}

class DeviceStateModeChanged extends DeviceStateMode {
  final ModelMode mode;

  DeviceStateModeChanged({
    required this.mode,
  });
}

// brightness
sealed class DeviceStateBrightness extends DeviceState {}

class DeviceStateBrightnessChanged extends DeviceStateBrightness {
  final double value;

  DeviceStateBrightnessChanged({
    required this.value,
  });
}

// speed
sealed class DeviceStateSpeed extends DeviceState {}

class DeviceStateSpeedChanged extends DeviceStateSpeed {
  final int value;

  DeviceStateSpeedChanged({
    required this.value,
  });
}

// color
sealed class DeviceStateColor extends DeviceState {}

class DeviceStateColorChanged extends DeviceStateColor {
  final Color value;

  DeviceStateColorChanged({
    required this.value,
  });
}

// heap
sealed class DeviceStateHeap extends DeviceState {}

class DeviceStateHeapChanged extends DeviceStateHeap {
  final int value;

  DeviceStateHeapChanged({
    required this.value,
  });
}

// uptime
sealed class DeviceStateUptime extends DeviceState {}

class DeviceStateUptimeChanged extends DeviceStateUptime {
  final int value;

  DeviceStateUptimeChanged({
    required this.value,
  });
}

// send
sealed class DeviceStateSend extends DeviceState {}

class DeviceStateSendLoading extends DeviceStateSend {}

class DeviceStateSendSuccess extends DeviceStateSend {}
