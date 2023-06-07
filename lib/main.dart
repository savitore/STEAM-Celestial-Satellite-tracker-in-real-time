import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/lg_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/lg_settings_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/local_storage_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/ssh_service.dart';
import 'screens/home.dart';

/// Registers all services into the application.
void setupServices() {
  GetIt.I.registerLazySingleton(() => LocalStorageService());
  GetIt.I.registerLazySingleton(() => LGSettingsService());
  GetIt.I.registerLazySingleton(() => SSHService());
  GetIt.I.registerLazySingleton(() => LGService());
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();

  await GetIt.I<LocalStorageService>().loadStorage();
  // await dotenv.load(fileName: ".env");

  GetIt.I<SSHService>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

