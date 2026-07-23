import 'package:dio/dio.dart';
import 'package:bulkretail/app/core/utils/logger.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoint.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    dio.interceptors.add(AuthInterceptor(dio));
    // dio.interceptors.add(
    //   LogInterceptor(
    //     request: true,
    //     requestBody: true,
    //     responseBody: true,
    //     error: true,
    //   ),
    // );
  }

  Future<T> handleRequest<T>(
    Future<Response> Function() request,
    T Function(dynamic data) mapper,
    String apiName,
  ) async {
    try {
      Log.i('[$apiName] Request started');
      final response = await request();
      Log.d(response);
      return mapper(response.data);
    } on DioException catch (e) {
      Log.e('[$apiName] DioException: $e');
      throw ApiException.fromDio(e);
    } catch (e, stacktrace) {
      Log.e('[$apiName] Unexpected error: $e\n$stacktrace');
      throw ApiException('Unexpected error: $e');
    }
  }
}
