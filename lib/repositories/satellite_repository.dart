import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/tle_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/repositories/satellite_api.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/repositories/tle_api.dart';

import '../services/local_storage_service.dart';
import '../utils/storage_keys.dart';

class SatelliteRepository{

  API api = API();
  APITLE apiTle = APITLE();
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();

  Future<List<dynamic>> fetchData({bool refresh=false}) async{
    try{

      final hasLocal = _localStorageService.hasItem(StorageKeys.satellites);
      if(!refresh && hasLocal){
        List<dynamic> loadedDataMaps = json.decode(_localStorageService.getItem(StorageKeys.satellites));
        return loadedDataMaps.map((map) => SatelliteModel.fromJson(map as Map<String, dynamic>)).toList();
      }
      Response response = await api.sendRequest.get("");
      List<dynamic> dataMaps = response.data;
      _localStorageService.setItem(StorageKeys.satellites, dataMaps);
      return dataMaps.map((map) => SatelliteModel.fromJson(map as Map<String, dynamic>)).toList();
    }
    catch(e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchDataTle({bool refresh=false}) async{
    try{

      final hasLocal = _localStorageService.hasItem(StorageKeys.tle);
      if(!refresh && hasLocal){
        List<dynamic> loadedDataMaps = json.decode(_localStorageService.getItem(StorageKeys.tle));
        return loadedDataMaps.map((map) => TLEModel.fromJson(map as Map<String, dynamic>)).toList();
      }
      Response response = await apiTle.sendRequest.get("");
      List<dynamic> dataMaps = response.data;
      _localStorageService.setItem(StorageKeys.tle, dataMaps);
      return dataMaps.map((map) => TLEModel.fromJson(map as Map<String, dynamic>)).toList();
    }
    catch(e) {
      rethrow;
    }
  }

}
