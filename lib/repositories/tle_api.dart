import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class APITle {

  final Dio _dio = Dio();

  APITle(){
    _dio.options.baseUrl = "http://celestrak.org/NORAD/elements/gp.php?CATNR=";
    _dio.interceptors.add(PrettyDioLogger());
  }

  Dio get sendRequest => _dio;

}
