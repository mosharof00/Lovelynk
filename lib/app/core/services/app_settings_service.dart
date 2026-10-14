import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../global/widgets/global_snackbar.dart';
import '../network/supabase/supabase_endpoints.dart';
import '../utils/logger.dart';
import '../utils/url_launcher.dart';

/// Public, admin-editable settings from `app_settings` (legal links, support
/// email). Readable before sign-in; loaded in the background on launch.
class AppSettingsService extends GetxService {
  static AppSettingsService get to => Get.find<AppSettingsService>();

  final _values = <String, dynamic>{}.obs;

  String? get termsUrl => _string('terms_url');
  String? get privacyUrl => _string('privacy_url');
  String? get supportEmail => _string('support_email');

  AppSettingsService init() {
    load();
    return this;
  }

  Future<void> load() async {
    try {
      final rows = await Supabase.instance.client
          .from(SupabaseTable.appSettings)
          .select('key, value')
          .eq('is_public', true);
      _values.assignAll({
        for (final row in rows) row['key'] as String: row['value'],
      });
    } catch (e) {
      Log.w('[AppSettings] load failed: $e');
    }
  }

  Future<void> openTerms() => _open(termsUrl, 'Terms of Use');

  Future<void> openPrivacy() => _open(privacyUrl, 'Privacy Policy');

  Future<void> contactSupport() async {
    final email = supportEmail;
    if (email == null) return _notAvailable('Contact Us');
    await UrlLauncher.url('mailto:$email?subject=LoveLynk%20support');
  }

  Future<void> _open(String? url, String label) async {
    if (url == null) return _notAvailable(label);
    await UrlLauncher.url(url);
  }

  void _notAvailable(String label) {
    load();
    globalSnackBar(title: label, message: 'Not available yet. Please try again later.');
  }

  String? _string(String key) {
    final value = _values[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }
}
