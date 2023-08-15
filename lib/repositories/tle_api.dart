import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class APITLE{

  final Dio _dio = Dio();


  APITLE(){
    _dio.options.baseUrl = "https://db.satnogs.org/api/tle/?format=json";
    _dio.interceptors.add(PrettyDioLogger());
  }

  Dio get sendRequest => _dio;

}