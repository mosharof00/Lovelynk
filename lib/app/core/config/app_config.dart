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

  //Push Notification key

}
