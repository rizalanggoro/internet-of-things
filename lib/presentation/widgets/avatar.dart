import 'package:flutter/material.dart';
import 'package:internet_of_things/core/constants/color.dart';

class WidgetAvatar extends StatelessWidget {
  final EdgeInsets? margin;
  final Widget child;

  const WidgetAvatar({
    super.key,
    this.margin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ConstantColor.primary.withOpacity(.12),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      height: 40,
      width: 40,
      margin: margin,
      child: child,
    );
  }
}
