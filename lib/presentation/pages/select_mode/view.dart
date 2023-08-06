import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_of_things/core/constants/color.dart';
import 'package:internet_of_things/core/constants/mode.dart';
import 'package:internet_of_things/core/enums/device_type.dart';
import 'package:internet_of_things/core/extensions/x_device_type.dart';
import 'package:internet_of_things/core/models/mode.dart';
import 'package:internet_of_things/core/utils.dart';
import 'package:internet_of_things/presentation/widgets/avatar.dart';
import 'package:internet_of_things/presentation/widgets/circle_icon_button.dart';

class SelectModeView extends StatefulWidget {
  final ModelMode initialMode;
  final EnumDeviceType deviceType;

  const SelectModeView({
    super.key,
    required this.initialMode,
    required this.deviceType,
  });

  @override
  State<SelectModeView> createState() => _SelectModeViewState();
}

class _SelectModeViewState extends State<SelectModeView> {
  late Utils _utils;

  @override
  Widget build(BuildContext context) {
    _utils = Utils(context: context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // safe area
            SafeArea(child: Container()),

            _appBar(),
            _listViewModes(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _listViewModes() {
    final list = widget.deviceType.isLedStrip
        ? ConstantMode.values
        : ConstantMode.matrixValues;

    return ListView.builder(
      itemBuilder: (context, index) {
        final mode = list[index];
        final isSelected = mode.id == widget.initialMode.id;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pop(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 24,
              ),
              child: Row(
                children: [
                  WidgetAvatar(
                    child: isSelected
                        ? Icon(
                            Icons.done_rounded,
                            color: ConstantColor.primary,
                          )
                        : Container(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: _utils.textTheme.titleMedium!.fontSize,
                          ),
                        ),
                        if (mode.subtitle != null)
                          Text(
                            mode.subtitle!,
                            style: TextStyle(
                              color: Colors.black.withOpacity(.64),
                              fontSize: _utils.textTheme.bodyMedium!.fontSize,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      itemCount: list.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          WidgetCircleIconButton(
            iconData: Icons.chevron_left_rounded,
            onTap: () => {},
          ),
          const SizedBox(width: 16),
          Text(
            'Pilih mode',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: _utils.textTheme.titleLarge!.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
