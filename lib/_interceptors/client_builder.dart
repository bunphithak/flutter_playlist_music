import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dio_interceptors.dart';

class ClientBuilder {
  Future<Dio> createClient() async {
    Dio dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? '',
      connectTimeout: const Duration(seconds: 3000),
      receiveTimeout: const Duration(seconds: 5000),
    ));
    await _createClientWithInterceptors(dio);
    return dio;
  }

  _createClientWithInterceptors(Dio dio) async {
    dio.interceptors.addAll([
      DioInterceptor(dio: dio),
      LogInterceptor(responseBody: true, requestBody: true),
    ]);
  }
}
