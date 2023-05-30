import 'package:dio/dio.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/repositories/tle_api.dart';

class SatelliteInfoRepository{

  APITle api = APITle();

  Future<String> fetchData(int norad) async{
    try{
      Response response = await api.sendRequest.get(norad.toString()+"&FORMAT=TLE");
      return response.data;
    }
    catch(e) {
      throw e;
    }
  }

}
