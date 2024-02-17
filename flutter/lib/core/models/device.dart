import 'package:flutter/material.dart';
import 'package:internet_of_things/core/enums/device_type.dart';

class ModelDevice {
  String title;
  IconData iconData;
  String id;
  EnumDeviceType deviceType;

  ModelDevice({
    required this.title,
    required this.iconData,
    required this.id,
    required this.deviceType,
  });
}
