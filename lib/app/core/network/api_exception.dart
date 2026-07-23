import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return ApiException("Connection timeout");
    }

    if (e.type == DioExceptionType.badResponse) {
      String message = "Server error";
      final data = e.response?.data;
      if (data is Map) {
        message = data['message'] ?? "Server error";
      } else if (data is String) {
        message = data;
      }
      return ApiException(message, statusCode: e.response?.statusCode);
    }

    if (e.type == DioExceptionType.unknown) {
      return ApiException("No Internet connection");
    }
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException("Request timed out");
    }
    if (e.type == DioExceptionType.cancel) {
      return ApiException("Request was cancelled");
    }

    return ApiException("Something went wrong");
  }
}
