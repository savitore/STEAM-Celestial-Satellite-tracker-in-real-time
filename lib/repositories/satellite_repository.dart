import 'package:dio/dio.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/repositories/satellite_api.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';

class SatelliteRepository{

  API api = API();

  Future<List<SatelliteModel>> fetchData() async{
    try{
      Response response = await api.sendRequest.get("");
      List<dynamic> dataMaps = response.data;
      return dataMaps.map((map) => SatelliteModel.fromJson(map as Map<String, dynamic>)).toList();
    }
    catch(e) {
      throw e;
    }
  }

}
