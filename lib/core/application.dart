import 'package:flutter/material.dart';
import 'package:internet_of_things/core/routes/config.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: RoutesConfig.config,
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
