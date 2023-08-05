import 'package:flutter/material.dart';

class ModelMqtt {
  String deviceId;

  int mode;
  int brightness;
  int speed;
  Color color;

  ModelMqtt({
    required this.deviceId,
    required this.mode,
    required this.brightness,
    required this.speed,
    required this.color,
  });
}
