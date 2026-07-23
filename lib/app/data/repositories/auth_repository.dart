import 'package:dio/dio.dart';
import 'package:bulkretail/app/core/network/api_client.dart';
import 'package:bulkretail/app/core/network/api_endpoints.dart';
import 'package:bulkretail/app/data/models/auth_models/login_model.dart';

abstract class IAuthRepository {
  Future<LoginModel> login(String email, String password);
}

class AuthRepository implements IAuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  @override
  Future<LoginModel> login(String email, String password) {
    final data = FormData.fromMap({'email': email, 'password': password});
    return _client.handleRequest(
      () => _client.dio.post(ApiEndpoint.login, data: data),
      (dynamic data) => LoginModel.fromJson(data),
      'Login',
    );
  }
}
