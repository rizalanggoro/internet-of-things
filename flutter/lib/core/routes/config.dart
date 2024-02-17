import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_of_things/core/enums/device_type.dart';
import 'package:internet_of_things/core/models/device.dart';
import 'package:internet_of_things/core/models/mode.dart';
import 'package:internet_of_things/core/routes/routes.dart';
import 'package:internet_of_things/presentation/pages/device/cubit.dart';
import 'package:internet_of_things/presentation/pages/device/view.dart';
import 'package:internet_of_things/presentation/pages/home/cubit.dart';
import 'package:internet_of_things/presentation/pages/home/view.dart';
import 'package:internet_of_things/presentation/pages/select_mode/view.dart';

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
      builder: (context, state) => BlocProvider(
        create: (context) => DeviceCubit(
          deviceId: (state.extra! as ModelDevice).id,
        ),
        child: DeviceView(
          device: state.extra! as ModelDevice,
        ),
      ),
    ),
    GoRoute(
      path: Routes.selectMode,
      builder: (context, state) {
        final map = state.extra! as Map;

        final initialMode = map['initialMode'] as ModelMode;
        final deviceType = map['deviceType'] as EnumDeviceType;

        return SelectModeView(
          initialMode: initialMode,
          deviceType: deviceType,
        );
      },
    ),
  ];
}
