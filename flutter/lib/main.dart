import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_of_things/core/app_bloc_observer.dart';
import 'package:internet_of_things/core/application.dart';
import 'package:internet_of_things/core/di/dependency_injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  await initializeDependencyInjection();

  runApp(const Application());
}
