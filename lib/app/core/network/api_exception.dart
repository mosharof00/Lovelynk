import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Machine-readable code (Supabase Auth error code or Postgres SQLSTATE).
  final String? code;

  ApiException(this.message, {this.statusCode, this.code});

  bool get isNetworkError => code == ApiErrorCode.network;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';

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

  /// Maps Supabase Auth / PostgREST / network errors to user-facing messages.
  factory ApiException.fromSupabase(Object error) {
    if (error is ApiException) return error;

    if (error is AuthRetryableFetchException ||
        error is SocketException ||
        error is TimeoutException) {
      return ApiException(
        'No internet connection. Please try again.',
        code: ApiErrorCode.network,
      );
    }

    if (error is AuthException) {
      return ApiException(
        _authMessage(error),
        statusCode: int.tryParse(error.statusCode ?? ''),
        code: error.code,
      );
    }

    if (error is PostgrestException) {
      return ApiException(_postgrestMessage(error), code: error.code);
    }

    return ApiException('Something went wrong. Please try again.');
  }

  /// https://supabase.com/docs/guides/auth/debugging/error-codes
  static String _authMessage(AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return 'Incorrect email or password.';
      case 'email_not_confirmed':
        return 'Please verify your email to continue.';
      case 'user_already_exists':
      case 'email_exists':
        return 'An account with this email already exists. Please sign in.';
      case 'otp_expired':
        return 'This code is invalid or has expired. Request a new one.';
      case 'weak_password':
        return 'Password is too weak. Use at least 8 characters with letters and numbers.';
      case 'over_email_send_rate_limit':
        return 'Too many emails sent. Please wait a moment and try again.';
      case 'over_request_rate_limit':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'user_banned':
        return 'This account has been suspended. Contact support.';
      case 'session_expired':
      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return 'Your session has expired. Please sign in again.';
      case 'signup_disabled':
        return 'Sign-ups are currently disabled.';
      default:
        return e.message.isNotEmpty ? e.message : 'Authentication failed.';
    }
  }

  static String _postgrestMessage(PostgrestException e) {
    switch (e.code) {
      case '42501':
        return e.message.isNotEmpty ? e.message : 'You do not have access.';
      case '28000':
      case 'PGRST301':
        return 'Your session has expired. Please sign in again.';
      default:
        return e.message.isNotEmpty ? e.message : 'Something went wrong.';
    }
  }
}

class ApiErrorCode {
  ApiErrorCode._();

  static const network = 'network_error';
  static const emailNotConfirmed = 'email_not_confirmed';
  static const notAppAccount = 'not_app_account';
  static const accountExists = 'user_already_exists';
}
