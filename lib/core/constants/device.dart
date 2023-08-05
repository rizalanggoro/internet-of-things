import 'package:flutter/material.dart';
import 'package:internet_of_things/core/enums/device_type.dart';
import 'package:internet_of_things/core/models/device.dart';

class ConstantDevice {
  static final values = <ModelDevice>[
    ModelDevice(
      id: 'ESP8266-Matrix',
      deviceType: EnumDeviceType.matrix,
      title: 'LED Matrix',
      iconData: Icons.grid_on_rounded,
    ),
    ModelDevice(
      id: 'ESP8266-Desk',
      deviceType: EnumDeviceType.ledStrip,
      title: 'Desk LED',
      iconData: Icons.light_rounded,
    ),
  ];
}
