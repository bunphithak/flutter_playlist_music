import 'package:dio/dio.dart';
import 'package:get/get.dart' show Get, LocalesIntl;
import 'package:get_storage/get_storage.dart';

class DioInterceptor extends InterceptorsWrapper {
  DioInterceptor({required this.dio}) {
    _cancelToken = CancelToken();
  }

  final Dio? dio;
  final getStorage = GetStorage();
  // final AuthController authController = AuthController();
  late CancelToken _cancelToken;
  bool _isRequestsCancelled = false;
  bool _isHandlingAuth = false;
  final currentLocale = Get.locale?.languageCode ?? 'en';

  void cancelAllRequests() {
    if (!_isRequestsCancelled) {
      _cancelToken.cancel('All requests cancelled due to 403 error');
      _isRequestsCancelled = true;
      _cancelToken = CancelToken();
    }
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isRequestsCancelled) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Requests are blocked due to previous 403 error',
        ),
      );
    }

    try {
      // final tokens = await getStorage.read(AppStorageKey.COOKIE);
      // if (tokens != null) {
      //   options.headers['cookie'] = tokens;
      // }
      options.headers['Accept-Language'] = currentLocale;

      options.cancelToken = _cancelToken;
      return super.onRequest(options, handler);
    } catch (e) {
      return super.onRequest(options, handler);
    }
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    print(
        'ON RESPONSE [${response.statusCode}] => PATH: ${response.realUri} | DATA: ${response.data}');
    return super.onResponse(response, handler);
  }

  @override
  Future<void> onError(DioException error, ErrorInterceptorHandler handler) async {
    print(
        'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.uri} | Message: ${error.message}');

    // Prevent multiple simultaneous auth handling
    if (_isHandlingAuth) {
      return super.onError(error, handler);
    }

    // switch (error.response?.statusCode) {
    //   case 401:
    //     try {
    //       _isHandlingAuth = true;
    //       await authController.refreshToken();
    //       final tokens = await getStorage.read(AppStorageKey.COOKIE);
    //
    //       if (tokens != null) {
    //         final options = error.response!.requestOptions;
    //         options.headers['cookie'] = tokens;
    //         options.headers['Accept-Language'] = currentLocale;
    //         final opts = Options(
    //           method: error.requestOptions.method,
    //           headers: error.requestOptions.headers,
    //         );
    //
    //         final cloneReq = await dio!.request(
    //           error.requestOptions.path,
    //           options: opts,
    //           data: error.requestOptions.data,
    //           queryParameters: error.requestOptions.queryParameters,
    //         );
    //
    //         _isHandlingAuth = false;
    //         return handler.resolve(cloneReq);
    //       }
    //     } catch (e) {
    //       _isHandlingAuth = false;
    //
    //     }
    //     break;
    //
    //   case 403:
    //     cancelAllRequests();
    //
    //     break;
    //
    //   case 425:
    //   case 406:
    //   // Handle specific error cases if needed
    //     break;
    // }
    return super.onError(error, handler);
  }
}

// Updated AuthController method