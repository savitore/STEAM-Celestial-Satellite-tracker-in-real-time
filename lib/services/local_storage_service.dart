import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for storing and reading data from the local storage.
class LocalStorageService {
  /// Property that defines the local storage instance.
  SharedPreferences? _storage;

  /// Property that defines whether the local storage is available.
  bool get storageAvailable => _storage != null;

  /// Loads the local storage instance.
  Future<void> loadStorage() async {
    _storage = await SharedPreferences.getInstance();
    // _storage!.clear();
  }

  /// Sets a [value] into the local storage [key] according to its type.
  Future<void> setItem(String key, dynamic value) async {
    final type = value.runtimeType;

    switch (type) {
      case int:
        await _storage!.setInt(key, value);
        break;
      case double:
        await _storage!.setDouble(key, value);
        break;
      case bool:
        await _storage!.setBool(key, value);
        break;
      case String:
        await _storage!.setString(key, value);
        break;
      case List<String>:
        await _storage!.setStringList(key, value);
        break;
      default:
        await _storage!.setString(key, json.encode(value));
    }
  }

  /// Gets an item from the local storage according to the given [key].
  dynamic getItem(String key) {
    return _storage!.get(key);
  }

  /// Removes an item from the local storage according to the given [key].
  Future<void> removeItem(String key) async {
    await _storage!.remove(key);
  }

  /// Returns whether there's a [key] set into the local storage.
  bool hasItem(String key) {
    return _storage!.containsKey(key);
  }
}
