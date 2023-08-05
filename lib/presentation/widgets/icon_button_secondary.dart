import 'package:flutter/material.dart';
import 'package:internet_of_things/core/constants/color.dart';

class WidgetIconButtonSecondary extends StatelessWidget {
  final EdgeInsets? margin;
  final void Function()? onTap;
  final IconData iconData;

  const WidgetIconButtonSecondary({
    super.key,
    this.margin,
    this.onTap,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: ConstantColor.primary.withOpacity(.04),
        border: Border.all(
          color: ConstantColor.primary.withOpacity(.12),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              iconData,
              color: ConstantColor.primary,
            ),
          ),
        ),
      ),
    );
  }
}
