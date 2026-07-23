import 'package:dio/dio.dart';
import 'package:bulkretail/app/global/widgets/global_snackbar.dart';
import 'package:get/get.dart' hide Response;
import '../../routes/app_pages.dart';
import '../utils/helper_utils.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = HelperUtils.token;

    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if the response indicates the user is unauthenticated even with a 200 status
    if (response.data is Map && response.data['message'] == "Unauthenticated.") {
      _handleUnauthorized();
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized();
    }

    handler.next(err);
  }

  void _handleUnauthorized() async {
    // Only trigger if we are currently considered "logged in" to avoid infinite loops or redundant logic
    if (HelperUtils.isLogin) {
      await HelperUtils.clearUser();
      HelperUtils.deleteMainControllers();

      // Show notification to user
      globalSnackBar(
        title: "Session Expired",
        message: "Your session has expired. Please login again.",
      );

      // Redirect to login
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}