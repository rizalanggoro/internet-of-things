import 'package:get_it/get_it.dart';
import 'package:internet_of_things/data/providers/mqtt.dart';
import 'package:internet_of_things/data/repositories/mqtt_impl.dart';
import 'package:internet_of_things/domain/repositories/mqtt.dart';

GetIt dependencyInjector = GetIt.instance;

Future<void> initializeDependencyInjection() async {
  // providers
  dependencyInjector.registerLazySingleton(() => ProviderMqtt());

  await dependencyInjector<ProviderMqtt>().initialize();

  // repositories
  dependencyInjector.registerLazySingleton<RepositoryMqtt>(
    () => RepositoryMqttImpl(),
  );
}
