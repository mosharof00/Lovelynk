import '../config/app_config.dart';

class ApiEndpoint {
  ///  Base URL
  static const String domainUrl = AppConfig.domainUrl;
  static const String baseUrl = '$domainUrl/api';

  ///  Auth
  static const String register = '$baseUrl/register'; // post
  static const String login = '$baseUrl/login'; // post
  static const String logOut = '$baseUrl/dashboard/logout'; // post

  /// user profile
  static const String profileDetails = '$baseUrl/profile/details'; // get
  static const String profileUpdate = '$baseUrl/profile/update'; // post

  ///  product
  static const String productList = 'https://dummyjson.com/products'; // get
  static const String productDetails = '$baseUrl/product/details'; // get
}
