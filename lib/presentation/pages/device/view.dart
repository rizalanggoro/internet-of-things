import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_of_things/core/constants/color.dart';
import 'package:internet_of_things/core/constants/mode.dart';
import 'package:internet_of_things/core/extensions/x_device_type.dart';
import 'package:internet_of_things/core/models/device.dart';
import 'package:internet_of_things/core/models/mode.dart';
import 'package:internet_of_things/core/models/mqtt.dart';
import 'package:internet_of_things/core/routes/routes.dart';
import 'package:internet_of_things/core/utils.dart';
import 'package:internet_of_things/presentation/pages/device/cubit.dart';
import 'package:internet_of_things/presentation/pages/device/state.dart';
import 'package:internet_of_things/presentation/widgets/avatar.dart';
import 'package:internet_of_things/presentation/widgets/button.dart';
import 'package:internet_of_things/presentation/widgets/button_secondary.dart';
import 'package:internet_of_things/presentation/widgets/icon_button_secondary.dart';
import 'package:internet_of_things/presentation/widgets/card.dart';
import 'package:internet_of_things/presentation/widgets/circle_icon_button.dart';

class DeviceView extends StatefulWidget {
  final ModelDevice device;

  const DeviceView({
    super.key,
    required this.device,
  });

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  late Utils _utils;

  bool _selectedAutoMode = false;
  ModelMode _selectedMode = ConstantMode.values.first;
  double _selectedBrightness = 100;
  int _selectedSpeed = 1024;
  Color _selectedColor = const Color.fromARGB(255, 100, 0, 255);

  @override
  Widget build(BuildContext context) {
    _utils = Utils(context: context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<DeviceCubit, DeviceState>(
        bloc: context.read<DeviceCubit>(),
        buildWhen: (previous, current) => current is DeviceStateRead,
        listener: (context, state) {
          if (state is DeviceStateReadSuccess) {
            final mqtt = state.mqtt;

            try {
              _selectedMode = widget.device.deviceType.isMatrix
                  ? ConstantMode.matrixValues
                      .where((element) => element.id == mqtt.mode)
                      .first
                  : ConstantMode.values
                      .where((element) => element.id == mqtt.mode)
                      .first;
            } catch (_) {
              _selectedMode = ConstantMode.values.first;
            }

            _selectedBrightness = mqtt.brightness.toDouble();
            _selectedSpeed = mqtt.speed;
            _selectedColor = mqtt.color;
            _selectedAutoMode = mqtt.autoMode;
          }
        },
        builder: (context, state) {
          if (state is DeviceStateReadLoading) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Mendapatkan konfigurasi\nperangkat...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(.64),
                      fontSize: _utils.textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is DeviceStateReadFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error!',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: _utils.textTheme.titleLarge!.fontSize,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal mendapatkan konfigurasi perangkat! Pastikan perangkat IoT dan smartphone Anda terhubung ke internet!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(.64),
                        fontSize: _utils.textTheme.bodyMedium!.fontSize,
                      ),
                    ),
                    const SizedBox(height: 24),
                    WidgetButton(
                      text: 'Kembali',
                      onTap: () => context.pop(),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is DeviceStateReadSuccess) {
            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // safe area
                      SafeArea(child: Container()),

                      _appBar(),

                      _cardAutoMode(),
                      _cardMode(),
                      _cardBrightness(),
                      _cardSpeed(),
                      _cardColor(),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 24,
                        ),
                        child: Text(
                          'Lainnya',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: _utils.textTheme.titleMedium!.fontSize,
                          ),
                        ),
                      ),
                      _cardSaveConfig(),
                      _cardHeap(),
                      _cardUptime(),

                      const SizedBox(height: 48 + 48),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buttonApply(),
                ),
                BlocBuilder<DeviceCubit, DeviceState>(
                  bloc: context.read<DeviceCubit>(),
                  buildWhen: (previous, current) => current is DeviceStateSend,
                  builder: (context, state) {
                    if (state is DeviceStateSendLoading) {
                      return _publishingContainer();
                    }

                    return Container();
                  },
                )
              ],
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget _cardAutoMode() {
    return WidgetCard(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
        child: Row(
          children: [
            WidgetAvatar(
              child: Icon(
                Icons.autorenew_rounded,
                color: ConstantColor.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode otomatis',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: _utils.textTheme.titleMedium!.fontSize,
                    ),
                  ),
                  Text(
                    'Putar semua mode secara bergantian',
                    style: TextStyle(
                      color: Colors.black.withOpacity(.64),
                      fontSize: _utils.textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                ],
              ),
            ),
            BlocConsumer<DeviceCubit, DeviceState>(
              bloc: context.read<DeviceCubit>(),
              buildWhen: (previous, current) => current is DeviceStateAuto,
              listener: (context, state) {
                if (state is DeviceStateAutoChanged) {
                  _selectedAutoMode = state.isEnable;
                }
              },
              builder: (context, state) {
                return Switch(
                  value: _selectedAutoMode,
                  onChanged: (value) =>
                      context.read<DeviceCubit>().changeAutoMode(
                            isEnable: value,
                          ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _publishingContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.72),
      ),
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Text(
        'Mencoba menerapkan perubahan. Mohon tunggu sebentar...',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: _utils.textTheme.titleMedium!.fontSize,
        ),
      ),
    );
  }

  Widget _cardUptime() {
    return WidgetCard(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
        child: Row(
          children: [
            WidgetAvatar(
              child: Icon(
                Icons.av_timer_rounded,
                color: ConstantColor.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waktu menyala',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: _utils.textTheme.titleMedium!.fontSize,
                    ),
                  ),
                  BlocBuilder<DeviceCubit, DeviceState>(
                    bloc: context.read<DeviceCubit>(),
                    buildWhen: (previous, current) =>
                        current is DeviceStateUptime,
                    builder: (context, state) {
                      var uptime = 0;
                      if (state is DeviceStateUptimeChanged) {
                        uptime = state.value;
                      }

                      return Text(
                        _utils.getFormattedUptime(uptime),
                        style: TextStyle(
                          color: Colors.black.withOpacity(.64),
                          fontSize: _utils.textTheme.bodyMedium!.fontSize,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardSaveConfig() {
    return WidgetCard(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 24,
            ),
            child: Row(
              children: [
                WidgetAvatar(
                  child: Icon(
                    Icons.save_rounded,
                    color: ConstantColor.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: _utils.textTheme.titleMedium!.fontSize,
                        ),
                      ),
                      Text(
                        'Simpan pengaturan saat ini ke dalam memori mikrokontroler',
                        style: TextStyle(
                          color: Colors.black.withOpacity(.64),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          WidgetButtonSecondary(
            margin: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 20,
            ),
            text: 'Simpan',
            onTap: () => context.read<DeviceCubit>().saveConfig(),
          ),
        ],
      ),
    );
  }

  Widget _buttonApply() {
    return BlocBuilder<DeviceCubit, DeviceState>(
      bloc: context.read<DeviceCubit>(),
      buildWhen: (previous, current) => current is DeviceStateSend,
      builder: (context, state) {
        bool isSending = false;
        if (state is DeviceStateSendLoading) {
          isSending = true;
        } else if (state is DeviceStateSendSuccess) {
          isSending = false;
        }

        return WidgetButton(
          margin: const EdgeInsets.all(24),
          text: isSending ? 'Mengirim...' : 'Kirim',
          onTap: isSending
              ? null
              : () => context.read<DeviceCubit>().send(
                    mqtt: ModelMqtt(
                      deviceId: widget.device.id,
                      mode: _selectedMode.id,
                      brightness: _selectedBrightness.toInt(),
                      speed: _selectedSpeed,
                      color: _selectedColor,
                      autoMode: _selectedAutoMode,
                    ),
                  ),
        );
      },
    );
  }

  Widget _cardHeap() {
    return WidgetCard(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: Row(
          children: [
            WidgetAvatar(
              child: Icon(
                Icons.memory_rounded,
                color: ConstantColor.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Memori bebas',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: _utils.textTheme.titleMedium!.fontSize,
                    ),
                  ),
                  BlocBuilder<DeviceCubit, DeviceState>(
                    bloc: context.read<DeviceCubit>(),
                    buildWhen: (previous, current) =>
                        current is DeviceStateHeap,
                    builder: (context, state) {
                      var heap = 0;
                      if (state is DeviceStateHeapChanged) {
                        heap = state.value;
                      }

                      return Text(
                        _utils.getFormattedFileSize(heap),
                        style: TextStyle(
                          color: Colors.black.withOpacity(.64),
                          fontSize: _utils.textTheme.bodyMedium!.fontSize,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardColor() {
    return WidgetCard(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: 16,
            ),
            child: Row(
              children: [
                WidgetAvatar(
                  child: Icon(
                    Icons.color_lens_rounded,
                    color: ConstantColor.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warna',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: _utils.textTheme.titleMedium!.fontSize,
                      ),
                    ),
                    BlocConsumer<DeviceCubit, DeviceState>(
                      bloc: context.read<DeviceCubit>(),
                      buildWhen: (previous, current) =>
                          current is DeviceStateColor,
                      listener: (context, state) {
                        if (state is DeviceStateColorChanged) {
                          _selectedColor = state.value;
                        }
                      },
                      builder: (context, state) {
                        return Text(
                          'R: ${_selectedColor.red}, '
                          'G: ${_selectedColor.green}, '
                          'B: ${_selectedColor.blue}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(.64),
                            fontSize: _utils.textTheme.bodyMedium!.fontSize,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (value) => context.read<DeviceCubit>().changeColor(
                  color: value,
                ),
            enableAlpha: false,
            hexInputBar: false,
            labelTypes: const [],
            pickerAreaBorderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSpeed() {
    return WidgetCard(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
        child: Column(
          children: [
            Row(
              children: [
                WidgetAvatar(
                  child: Icon(
                    Icons.speed_rounded,
                    color: ConstantColor.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kecepatan',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: _utils.textTheme.titleMedium!.fontSize,
                        ),
                      ),
                      BlocConsumer<DeviceCubit, DeviceState>(
                        bloc: context.read<DeviceCubit>(),
                        buildWhen: (previous, current) =>
                            current is DeviceStateSpeed,
                        listener: (context, state) {
                          if (state is DeviceStateSpeedChanged) {
                            _selectedSpeed = state.value;
                          }
                        },
                        builder: (context, state) {
                          return Text(
                            '$_selectedSpeed ms',
                            style: TextStyle(
                              color: Colors.black.withOpacity(.64),
                              fontSize: _utils.textTheme.bodyMedium!.fontSize,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: WidgetIconButtonSecondary(
                    iconData: Icons.remove_rounded,
                    onTap: () => context.read<DeviceCubit>().decreaseSpeed(
                          currentSpeed: _selectedSpeed,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: WidgetIconButtonSecondary(
                    iconData: Icons.add_rounded,
                    onTap: () => context.read<DeviceCubit>().increaseSpeed(
                          currentSpeed: _selectedSpeed,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardBrightness() {
    return WidgetCard(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
            ),
            child: Row(
              children: [
                WidgetAvatar(
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    color: ConstantColor.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kecerahan',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: _utils.textTheme.titleMedium!.fontSize,
                        ),
                      ),
                      BlocBuilder<DeviceCubit, DeviceState>(
                        bloc: context.read<DeviceCubit>(),
                        buildWhen: (previous, current) =>
                            current is DeviceStateBrightness,
                        builder: (context, state) {
                          return Text(
                            '${_selectedBrightness.toInt()} dari 250',
                            style: TextStyle(
                              color: Colors.black.withOpacity(.64),
                              fontSize: _utils.textTheme.bodyMedium!.fontSize,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          BlocConsumer<DeviceCubit, DeviceState>(
            bloc: context.read<DeviceCubit>(),
            buildWhen: (previous, current) => current is DeviceStateBrightness,
            listener: (context, state) {
              if (state is DeviceStateBrightnessChanged) {
                _selectedBrightness = state.value;
              }
            },
            builder: (context, state) {
              return Slider(
                value: _selectedBrightness,
                onChanged: (value) =>
                    context.read<DeviceCubit>().changeBrightness(
                          value: value,
                        ),
                max: 250,
                min: 0,
                divisions: 10,
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _cardMode() {
    return WidgetCard(
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await context.push(
              Routes.selectMode,
              extra: {
                'initialMode': _selectedMode,
                'deviceType': widget.device.deviceType,
              },
            );
            if (result != null && result is ModelMode) {
              if (context.mounted) {
                context.read<DeviceCubit>().changeMode(
                      mode: result,
                    );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 24,
            ),
            child: Row(
              children: [
                WidgetAvatar(
                  child: Icon(
                    Icons.category_rounded,
                    color: ConstantColor.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: _utils.textTheme.titleMedium!.fontSize,
                        ),
                      ),
                      BlocConsumer<DeviceCubit, DeviceState>(
                        bloc: context.read<DeviceCubit>(),
                        buildWhen: (previous, current) =>
                            current is DeviceStateMode,
                        listener: (context, state) {
                          if (state is DeviceStateModeChanged) {
                            _selectedMode = state.mode;
                          }
                        },
                        builder: (context, state) {
                          return Text(
                            _selectedMode.title,
                            style: TextStyle(
                              color: Colors.black.withOpacity(.64),
                              fontSize: _utils.textTheme.bodyMedium!.fontSize,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black.withOpacity(.48),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Row(
        children: [
          WidgetCircleIconButton(
            iconData: Icons.chevron_left_rounded,
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.device.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: _utils.textTheme.titleLarge!.fontSize,
                  ),
                ),
                Text(
                  'ID: ${widget.device.id}',
                  style: TextStyle(
                    color: Colors.black.withOpacity(.64),
                    fontSize: _utils.textTheme.bodyMedium!.fontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
