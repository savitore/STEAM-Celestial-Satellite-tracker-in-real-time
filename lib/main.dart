import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/splash.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/file_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/lg_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/lg_settings_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/local_storage_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/satellite_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/ssh_service.dart';

/// Registers all services into the application.
void setupServices() {
  GetIt.I.registerLazySingleton(() => LocalStorageService());
  GetIt.I.registerLazySingleton(() => LGSettingsService());
  GetIt.I.registerLazySingleton(() => SSHService());
  GetIt.I.registerLazySingleton(() => LGService());
  GetIt.I.registerLazySingleton(() => SatelliteService());
  GetIt.I.registerLazySingleton(() => FileService());
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();

  await GetIt.I<LocalStorageService>().loadStorage();

  GetIt.I<SSHService>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  /// Sets the Liquid Galaxy logos into the rig.
  void setLogos() async {
    try {
      await GetIt.I<LGService>().setLogos();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setLogos();

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenPage(),
    );
  }
}

