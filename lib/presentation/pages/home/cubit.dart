import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:internet_of_things/core/di/dependency_injector.dart';
import 'package:internet_of_things/domain/repositories/mqtt.dart';
import 'package:internet_of_things/presentation/pages/home/state.dart';
import 'package:mqtt_client/mqtt_client.dart';

class HomeCubit extends Cubit<HomeState> {
  final RepositoryMqtt _repositoryMqtt = dependencyInjector();

  HomeCubit() : super(HomeStateInitial()) {
    _repositoryMqtt.listenOnConnected(() {
      log('Connected!');
      emit(HomeStateConnected());
    });

    _repositoryMqtt.listenOnDisconnected(() {
      log('Disconnected!');
      emit(HomeStateDisconnected());
    });

    _repositoryMqtt.listenOnAutoReconnect(() {
      log('AutoReconnect!');
      emit(HomeStateConnecting());
    });

    _repositoryMqtt.listenOnAutoReconnected(() {
      log('AutoReconnected!');
      emit(HomeStateConnected());
    });
  }

  void closeMqttConnection() {
    _repositoryMqtt.disconnect();
    emit(HomeStateDisconnected());
  }

  void openMqttConnection() async {
    try {
      emit(HomeStateConnecting());
      await _repositoryMqtt.connect();
    } catch (error) {
      log(error.toString());

      emit(HomeStateDisconnected());
      _repositoryMqtt.disconnect();
    }
  }
}
