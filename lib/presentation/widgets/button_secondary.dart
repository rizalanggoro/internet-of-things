import 'package:flutter/material.dart';
import 'package:internet_of_things/core/constants/color.dart';
import 'package:internet_of_things/core/utils.dart';

class WidgetButtonSecondary extends StatelessWidget {
  final EdgeInsets? margin;
  final void Function()? onTap;
  final String text;

  const WidgetButtonSecondary({
    super.key,
    this.margin,
    this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final utils = Utils(context: context);

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
            child: Text(
              text,
              style: TextStyle(
                color: ConstantColor.primary,
                fontSize: utils.textTheme.bodyMedium!.fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
