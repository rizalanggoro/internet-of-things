import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_of_things/core/routes/routes.dart';
import 'package:internet_of_things/presentation/pages/device/view.dart';
import 'package:internet_of_things/presentation/pages/home/cubit.dart';
import 'package:internet_of_things/presentation/pages/home/view.dart';

class RoutesConfig {
  static final config = GoRouter(
    routes: pages,
  );
  static final pages = [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => BlocProvider(
        create: (context) => HomeCubit(),
        child: const HomeView(),
      ),
    ),
    GoRoute(
      path: Routes.device,
      builder: (context, state) => const DeviceView(),
    ),
  ];
}
