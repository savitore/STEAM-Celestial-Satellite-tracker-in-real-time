import 'dart:convert';

import 'package:get_it/get_it.dart';

import '../models/lg_settings_entity.dart';
import '../utils/storage_keys.dart';
import 'local_storage_service.dart';


/// Service that deals with the settings management.
class LGSettingsService {
  /// Property that defines the local storage service.
  LocalStorageService get _localStorageService =>
      GetIt.I<LocalStorageService>();

  /// Sets the given [settings] into the local storage.
  Future<void> setSettings(LGSettingsEntity settings) async {
    await _localStorageService.setItem(StorageKeys.settings, settings.toMap());
  }

  /// Gets the local storage settings.
  LGSettingsEntity getSettings() {
    String? settings = _localStorageService.getItem(StorageKeys.settings);

    return settings != null
        ? LGSettingsEntity.fromMap(json.decode(settings))
        : LGSettingsEntity();
  }
}
