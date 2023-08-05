import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_of_things/core/config.dart';
import 'package:internet_of_things/core/constants/color.dart';
import 'package:internet_of_things/core/constants/device.dart';
import 'package:internet_of_things/core/routes/routes.dart';
import 'package:internet_of_things/core/utils.dart';
import 'package:internet_of_things/presentation/pages/home/cubit.dart';
import 'package:internet_of_things/presentation/pages/home/state.dart';
import 'package:internet_of_things/presentation/widgets/avatar.dart';
import 'package:internet_of_things/presentation/widgets/card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Utils _utils;

  @override
  Widget build(BuildContext context) {
    _utils = Utils(context: context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // safe area
            SafeArea(child: Container()),

            _appBar(),
            _cardConnectionStatus(),

            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 32,
              ),
              child: Text(
                'Perangkat',
                style: TextStyle(
                  fontSize: _utils.textTheme.titleMedium!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 8,
              ),
              child: Text(
                'Beberapa perangkat internet yang tertaut dan dapat '
                'dikendalikan dengan protokol MQTT',
                style: TextStyle(
                  fontSize: _utils.textTheme.bodyMedium!.fontSize,
                  color: Colors.black.withOpacity(.64),
                ),
              ),
            ),

            // list devices
            _listViewDevices(),
          ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Internet of things',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: _utils.textTheme.headlineSmall!.fontSize,
            ),
          ),
          Text(
            Config.broker,
            style: TextStyle(
              color: Colors.black.withOpacity(.64),
              fontSize: _utils.textTheme.bodyMedium!.fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listViewDevices() {
    return ListView.builder(
      itemBuilder: (context, index) {
        final device = ConstantDevice.values[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (context.read<HomeCubit>().state is HomeStateConnected) {
                context.push(
                  Routes.device,
                  extra: device,
                );
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
                    margin: const EdgeInsets.only(right: 16),
                    child: Icon(
                      device.iconData,
                      color: ConstantColor.primary,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: _utils.textTheme.titleMedium!.fontSize,
                          ),
                        ),
                        Text(
                          'ID: ${device.id}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(.64),
                            fontSize: _utils.textTheme.bodyMedium!.fontSize,
                          ),
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
        );
      },
      itemCount: ConstantDevice.values.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
    );
  }

  Widget _cardConnectionStatus() {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: context.read<HomeCubit>(),
      builder: (context, state) {
        var title = 'Terputus!';
        var subtitle = '';
        if (state is HomeStateConnected) {
          title = 'Terhubung!';
          subtitle = 'Tekan untuk memutuskan koneksi';
        } else if (state is HomeStateConnecting) {
          title = 'Menghubungkan...';
          subtitle = 'Mohon tunggu sebentar';
        } else if (state is HomeStateDisconnected) {
          title = 'Terputus!';
          subtitle = 'Tekan untuk menghubungkan ke server';
        }

        return WidgetCard(
          margin: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (state is HomeStateConnected) {
                  context.read<HomeCubit>().closeMqttConnection();
                } else if (state is HomeStateDisconnected) {
                  context.read<HomeCubit>().openMqttConnection();
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
                        Icons.wifi_rounded,
                        color: ConstantColor.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: _utils.textTheme.titleMedium!.fontSize,
                            ),
                          ),
                          Text(
                            subtitle,
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
              ),
            ),
          ),
        );
      },
    );
  }
}
