class AppConfig {
  /// Logo
  static String appLogo = "assets/logos/app_logo.png";
  static String splashLogo = "assets/logos/app_logo.png";
  static String appName = "Lovelynk";
  static const domainUrl = "https://flutter.pixelstack.cloud";

  /// ProjectID
  static String projectID = "";

  /// Supabase (LoveLynk project, eu-west-1).
  /// The publishable key is public by design; data is protected by RLS.
  /// Never put the secret / service_role key in the app.
  static const supabaseUrl = "https://yvfolpaqchdmqdluprpo.supabase.co";
  static const supabasePublishableKey =
      "sb_publishable_yfy3DXszilr6sNixQnhDyA_cI88FmiK";

  /// Must match Dashboard → Authentication → Email → "Email OTP Length".
  static const emailOtpLength = 6;

  /// Seconds before "Resend code" is enabled again.
  static const otpResendCooldownSeconds = 60;

  // ── RevenueCat ────────────────────────────────────────────────────────
  /// RevenueCat Public SDK API key for Apple (starts with 'appl_').
  /// Can be provided via `--dart-define=REVENUECAT_APPLE_KEY=appl_xxx`.
  static const revenueCatAppleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: 'appl_placeholder_key',
  );

  /// Main entitlement identifier configured in RevenueCat dashboard.
  static const entitlementPlus = 'premium';

  /// Store product identifiers.
  static const productMonthly = 'lovelynk_monthly';
  static const productYearly = 'lovelynk_yearly';
}
