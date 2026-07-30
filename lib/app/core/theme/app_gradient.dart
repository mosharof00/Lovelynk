import 'package:flutter/material.dart';

import 'app_color.dart';

/// Reusable brand gradients for the Lovelynk app.
/// All gradients mirror the logo: pink (primary) ↔ blue (secondary).
class AppGradient {
  AppGradient._();

  // ── Primary brand gradient (left-to-right: pink → blue) ──────────────────
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColor.primary, AppColor.secondary],
  );

  // ── Diagonal variant (bottom-left → top-right) ────────────────────────────
  static const LinearGradient brandDiagonal = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [AppColor.primary, AppColor.secondary],
  );

  // ── Soft pastel version for backgrounds / cards ───────────────────────────
  static const LinearGradient brandSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColor.primaryLight, Color(0xFFD9F2FF)],
  );

  // ── Vertical page background gradient ────────────────────────────────────
  static const LinearGradient pageBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF0F6), Color(0xFFF3EEFF), AppColor.background],
    stops: [0.0, 0.45, 1.0],
  );

  // ── Full-screen app background: soft pink (top-left) → soft blue (bottom-right)
  // Matches the client-provided reference image.
  static const LinearGradient appBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD6E8), // soft pink
      Color(0xFFEAEBFF), // soft lavender
      Color(0xFFD4EEFF), // soft blue
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
