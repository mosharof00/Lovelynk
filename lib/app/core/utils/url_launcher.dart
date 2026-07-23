import 'package:bulkretail/app/global/widgets/global_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {
  static Future<void> url(String? url) async {
    if (url == null || url.isEmpty) {
      _showError("No URL provided");
      return;
    }

    try {
      Uri uri = Uri.parse(url);

      // Add https if missing
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$url');
      }

      if (!await canLaunchUrl(uri)) {
        _showError("Cannot handle this type of link");
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showError("Failed to open link: ${e.toString()}");
    }
  }

  static void _showError(String message) {
    globalSnackBar(title: 'Error', message: message);
  }
}
