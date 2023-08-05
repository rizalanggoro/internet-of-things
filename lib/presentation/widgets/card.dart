import 'package:flutter/material.dart';

class WidgetCard extends StatelessWidget {
  final EdgeInsets? margin;
  final Widget child;

  const WidgetCard({
    super.key,
    this.margin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withOpacity(.12),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      margin: margin,
      child: child,
    );
  }
}
