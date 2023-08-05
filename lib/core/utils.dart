import 'package:flutter/material.dart';

class Utils {
  BuildContext context;

  Utils({required this.context});

  TextTheme get textTheme => Theme.of(context).textTheme;

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
}
