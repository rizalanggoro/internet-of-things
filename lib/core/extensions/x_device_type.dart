import 'package:internet_of_things/core/enums/device_type.dart';

extension XDeviceType on EnumDeviceType {
  bool get isLedStrip => this == EnumDeviceType.ledStrip;
  bool get isMatrix => this == EnumDeviceType.matrix;
}
