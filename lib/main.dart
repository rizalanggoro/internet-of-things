import 'package:flutter/material.dart';
import 'package:internet_of_things/core/application.dart';
import 'package:internet_of_things/core/di/dependency_injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencyInjection();

  runApp(const Application());
}
