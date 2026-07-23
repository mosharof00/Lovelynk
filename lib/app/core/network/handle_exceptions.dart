import 'dart:async';
import 'dart:io';

import 'package:bulkretail/app/global/widgets/global_snackbar.dart';

import '../utils/logger.dart';
import 'api_exception.dart';

void handleException(dynamic error, {String? context}) {
  if (error is ApiException) {
    // 401 is already handled by AuthInterceptor — skip silently
    if (error.statusCode == 401) {
      Log.w(
        '[${context ?? 'API'}] 401 caught in handleException — handled by interceptor',
      );
      return;
    }

    final message = switch (error.statusCode) {
      404 => "Requested resource not found.",
      500 => "Something went wrong! Please try again later.",
      400 => error.message.isNotEmpty ? error.message : "Bad request.",
      _ => error.message.isNotEmpty ? error.message : "An error occurred.",
    };

    Log.e('[${context ?? 'API'}] ${error.statusCode}: ${error.message}');
    globalSnackBar(title: "Error!", message: message);
  } else if (error is SocketException) {
    Log.e('[${context ?? 'API'}] SocketException: $error');
    globalSnackBar(
      title: "No Internet",
      message: "Check your connection and try again.",
    );
  } else if (error is TimeoutException) {
    Log.e('[${context ?? 'API'}] TimeoutException: $error');
    globalSnackBar(
      title: "Timeout",
      message: "Request timed out. Please try again.",
    );
  } else {
    // Unknown — log full error for debugging, show generic message to user
    Log.e('[${context ?? 'API'}] Unexpected error: $error');
    globalSnackBar(title: "Error!", message: "Something unexpected happened.");
  }
}
