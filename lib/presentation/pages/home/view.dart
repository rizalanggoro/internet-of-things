import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_of_things/presentation/pages/home/cubit.dart';
import 'package:internet_of_things/presentation/pages/home/state.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet of things'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // card connection status
            BlocBuilder<HomeCubit, HomeState>(
              bloc: context.read<HomeCubit>()..openMqttConnection(),
              builder: (context, state) {
                var status = 'Disconnected!';
                if (state is HomeStateConnected) {
                  status = 'Connected!';
                } else if (state is HomeStateConnecting) {
                  status = 'Connecting...';
                } else if (state is HomeStateDisconnected) {
                  status = 'Disconnected!';
                }

                return Card(
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: ListTile(
                    onTap: () {
                      if (state is HomeStateConnected) {
                        context.read<HomeCubit>().closeMqttConnection();
                      } else if (state is HomeStateDisconnected) {
                        context.read<HomeCubit>().openMqttConnection();
                      }
                    },
                    title: const Text('Connection status'),
                    subtitle: Text(status),
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.wifi_rounded,
                      ),
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Text('Devices'),
            ),
          ],
        ),
      ),
    );
  }
}
