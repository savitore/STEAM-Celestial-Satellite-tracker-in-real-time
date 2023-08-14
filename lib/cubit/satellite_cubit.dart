import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/tle_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/storage_keys.dart';

import '../repositories/countries_iso.dart';
import '../repositories/satellite_repository.dart';
import '../services/local_storage_service.dart';

class SatelliteCubit extends Cubit<SatelliteState> {
  SatelliteCubit() : super(SatelliteLoadingState()) {
    fetchData();
  }

  SatelliteRepository satelliteRepository = SatelliteRepository();
  late List<SatelliteModel> _satellites;
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();

  void fetchData({bool refresh=false}) async {

    try {
      List<SatelliteModel> satellites = await satelliteRepository.fetchData(refresh: refresh) as List<SatelliteModel>;
      List<TLEModel> tle = await satelliteRepository.fetchDataTle(refresh: refresh) as List<TLEModel>;
      List iso = ISO().iso;
      for (int i = 0; i < satellites.length; i++) {
        String countries = satellites[i].countries.toString();
        List _countries = countries.split(',');
        if (satellites[i].countries.toString() != 'null' ||
            satellites[i].countries.toString() != '') {
          for (int j = 0; j < iso.length; j++) {
            Map<String, String> data = iso[j];
            for (int k = 0; k < _countries.length; k++) {
              if (data['Code'] == _countries[k]) {
                _countries[k] = data['Name'];
              }
            }
          }
        }
        satellites[i].countries = '';
        if (_countries.length == 1) {
          satellites[i].countries = satellites[i].countries! + _countries[0];
        } else {
          for (int l = 0; l < _countries.length-1; l++) {
            satellites[i].countries =
                '${satellites[i].countries! + _countries[l]}, ';
          }
          satellites[i].countries =
          satellites[i].countries! + _countries[_countries.length-1];
        }
        for(int t =0; t< tle.length; t++){
          if(satellites[i].noradCatId==tle[t].noradId){
            satellites[i].line0=tle[t].line0;
            satellites[i].line1=tle[t].line1;
            satellites[i].line2=tle[t].line2;
          }
        }
        if(_localStorageService.hasItem(StorageKeys.location)){
          double latitude = _localStorageService.getItem(StorageKeys.latitude);
          double longitude = _localStorageService.getItem(StorageKeys.longitude);
          double altitude = _localStorageService.getItem(StorageKeys.altitude);
          if(satellites[i].line0.toString()!="null"){
            final tleModel = TLEModel(line0: satellites[i].line0.toString(), line1: satellites[i].line1.toString(), line2: satellites[i].line2.toString(), satelliteId: satellites[i].satId.toString(), noradId: satellites[i].noradCatId!, updated: satellites[i].updated.toString());
            satellites[i].azimuth=tleModel.getServoAngles(latitude, longitude, altitude)['az'];
            satellites[i].elevation=tleModel.getServoAngles(latitude, longitude, altitude)['el'];
          }

        }
      }
      satellites.sort((a,b) => a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase()));
      _satellites = satellites;
      List<String> operators = [];
      for(int i=0; i<satellites.length;i++){
        operators.add(satellites[i].operator.toString());
      }
      Set<String> unique = operators.toSet();
      operators =unique.toList();
      operators.remove('None');
      operators.sort((a,b) => a.compareTo(b));
      operators.add('None');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('operators', operators);
      emit(SatelliteLoadedState(satellites));

    } on DioException catch (e) {

      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        emit(SatelliteErrorState('Check your internet connection!'));
      } else {
        emit(SatelliteErrorState(e.type.toString()));
      }

    }
  }


  Future<void> filterSearchData(String filterText, String country, String status, bool decayed, bool launched, bool deployed, String operator, bool featured, bool launchNew, bool launchOld, bool range3d) async {

    List<SatelliteModel> filteredList = _satellites;
    filteredList = filteredList.where((data) =>
    data.name!.toLowerCase().contains(filterText.toLowerCase()) ||
        data.noradCatId.toString().toLowerCase().contains(filterText.toLowerCase()) ||
        data.satId!.toLowerCase().contains(filterText.toLowerCase()))
        .toList();
    if(country!='ALL'){
      filteredList = filteredList.where((data) =>
          data.countries.toString().toLowerCase().contains(country.toLowerCase()))
          .toList();
    }
    if(status!='ALL'){
      filteredList = filteredList.where((data) =>
          data.status.toString().toLowerCase().contains(status.toLowerCase()))
          .toList();
    }
    if(operator!='ALL'){
      filteredList = filteredList.where((data) =>
          data.operator.toString().contains(operator))
          .toList();
    }
    if(decayed==true){
      filteredList = filteredList.where((data) =>
      data.decayed.toString()!='null')
          .toList();
    }
    if(launched==true){
      filteredList = filteredList.where((data) =>
      data.launched.toString()!='null')
          .toList();
    }
    if(deployed==true){
      filteredList = filteredList.where((data) =>
      data.deployed.toString()!='null')
          .toList();
    }
    if (featured) {
      filteredList.sort((a, b) => a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase()));
    } else if (launchNew) {
      filteredList.sort((b, a) => a.launched
          .toString()
          .toLowerCase()
          .compareTo(b.launched.toString().toLowerCase()));
    } else if (launchOld) {
      filteredList.sort((a, b) => a.launched
          .toString()
          .toLowerCase()
          .compareTo(b.launched.toString().toLowerCase()));
    }
    if(range3d){
      double latitude = _localStorageService.getItem(StorageKeys.latitude);
      double longitude = _localStorageService.getItem(StorageKeys.longitude);
      double altitude = _localStorageService.getItem(StorageKeys.altitude);
      for(int i =0; i< filteredList.length; i++){
        if(filteredList[i].line0.toString()!="null"){
          final tleModel = TLEModel(line0: filteredList[i].line0.toString(), line1: filteredList[i].line1.toString(), line2: filteredList[i].line2.toString(), satelliteId: filteredList[i].satId.toString(), noradId: filteredList[i].noradCatId!, updated: filteredList[i].updated.toString());
          filteredList[i].azimuth=tleModel.getServoAngles(latitude, longitude, altitude)['az'];
          filteredList[i].elevation=tleModel.getServoAngles(latitude, longitude, altitude)['el'];
        }
      }
      filteredList = filteredList.where((data) =>
      data.line0.toString() != "null" && data.elevation! >5)
          .toList();
    }

    emit(FilteredSatelliteState(filteredList));

  }


}
