import 'package:flutter/material.dart';
import 'package:internet_of_things/core/constants/color.dart';

class WidgetCircleIconButton extends StatelessWidget {
  final EdgeInsets? margin;
  final IconData iconData;
  final void Function()? onTap;

  const WidgetCircleIconButton({
    super.key,
    this.margin,
    required this.iconData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withOpacity(.12),
        ),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            width: 48,
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
