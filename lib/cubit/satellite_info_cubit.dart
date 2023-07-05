import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/satellite_info_repository.dart';
import '../services/ssh_service.dart';

class SatelliteInfoCubit extends Cubit<SatelliteInfoState>{
  int norad;
  SatelliteInfoCubit(this.norad) : super( SatelliteLoadingState() ){
    fetchData(norad);
  }

  SatelliteInfoRepository satelliteInfoRepository = SatelliteInfoRepository();

  void fetchData(int norad) async {
    try{
      String tle = await satelliteInfoRepository.fetchData(norad);
      List<String> tleLines =tle.split('\n');
      emit(SatelliteLoadedState(tle: tleLines,TLE: tle));
    }
    on DioException catch(e) {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if(connectivityResult == ConnectivityResult.none){
        emit(SatelliteErrorState('Check your internet connection!'));
      }
      else {
        emit(SatelliteErrorState(e.type.toString()));
      }
    }
  }

}