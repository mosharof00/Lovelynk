import 'package:bulkretail/app/core/network/api_endpoints.dart';

class GetImageUrl {
  static String url(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('https')) return url;
    return '${ApiEndpoint.domainUrl}/$url';
  }
}
