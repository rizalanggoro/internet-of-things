import 'package:flutter/material.dart';

class Utils {
  BuildContext context;

  Utils({required this.context});

  TextTheme get textTheme => Theme.of(context).textTheme;

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  String getFormattedUptime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    int minutes = (seconds / 60).floor();
    int hours = (minutes / 60).floor();

    int remainingSeconds = seconds % 60;
    int remainingMinutes = minutes % 60;

    String hoursString = (hours > 0) ? '$hours jam ' : '';
    String minutesString = (minutes > 0) ? '$remainingMinutes menit ' : '';
    String secondsString = '$remainingSeconds detik';

    return '$hoursString$minutesString$secondsString';
  }
}
