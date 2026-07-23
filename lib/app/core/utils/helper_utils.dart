import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bulkretail/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

import '../../modules/main_page/controllers/main_page_controller.dart';
import '../../routes/app_pages.dart';
import '../services/local_store_service.dart';
import '../services/secure_storage_service.dart';
import 'logger.dart';


class HelperUtils {

  /// Default currency symbol
  static String currencySymbol = "\$";


  static String defaultProfileImage =
      // "https://i.pinimg.com/474x/18/b5/b5/18b5b599bb873285bd4def283c0d3c09.jpg";
      "https://axbajldpgtugenukkold.supabase.co/storage/v1/object/public/images/data/default_profile_image.png";
  static bool isOnboard = false;
  static bool isLoggedIn = false;
  static bool isAdmin = false;

  static String firebaseToken = "";
  static bool isLogin = false;
  static String token = "";
  static String userId = "";
  static String userRole = "";



  //
  // Save / login user (updates storage + runtime)
  // -----------------------------
  static Future<void> setUser({
    required String userId,
    required String token,
    String? role,
  }) async {
    final storage = SecureStorageService.instance;

    // Save to storage
    await storage.setUserID(userId);
    await storage.setToken(token);
    if (role != null) await storage.setUserRole(role);

    // Update runtime variables
    HelperUtils.userId = userId;
    HelperUtils.token = token;
    HelperUtils.userRole = role ?? '';
    HelperUtils.isLogin = true;

    Log.i(
      "✅ User set:\nUserId: $userId\nToken: $token\nRole: ${role ?? ''}\nIsLogin: true",
    );
  }

  // -----------------------------
  // Check if user is logged in (reads from storage)
  // -----------------------------
  static Future<bool> checkLoginStatus() async {
    final storage = SecureStorageService.instance;

    final storedId = await storage.getUserID();
    final storedToken = await storage.getToken();

    if (storedId != null && storedToken != null) {
      userId = storedId;
      token = storedToken;
      isLogin = true;
      Log.i("UserId: $userId\nToken: $token");
      return true;
    } else {
      isLogin = false;
      Log.w("Guest User! \nUserId: $storedId \nToken: $storedToken");
      return false;
    }
  }

  // -----------------------------
  // Clear user (logout)
  // -----------------------------
  static Future<void> clearUser() async {
    final storage = SecureStorageService.instance;
    await storage.clearAll();

    userId = "";
    token = "";
    userRole = "";
    isLogin = false;

    Log.i("✅ User cleared. Logged out.");
  }


  ///  Languages
  static Locale locateLanguage() {
    return Locale(language(), language().toUpperCase());
  }

  static String language() {
    return HiveService.getLanguage().split('_')[0] ?? 'en';
  }

  static Future<void> initMainControllers() async {

    if (!Get.isRegistered<MainPageController>()) {
      // Ensure MainPageController is permanent and not reinitialized
      Get.put(MainPageController(), permanent: true);
      Get.put(HomeController(), permanent: true);
    }
    await Future.delayed(Duration(milliseconds: 400));
  }

  static Future<void> deleteMainControllers() async {
    Get.put(MainPageController(), permanent: false);
    Get.delete<MainPageController>(force: true);

    // if (Get.isRegistered<CartController>()) {
    //   Get.delete<CartController>(force: true);
    // }
  }

  static Future<void> navigateToOrder() async {
    // Refresh cart since it's now empty after order placement
    // if (Get.isRegistered<CartController>()) {
    //   Get.find<CartController>().fetchCart();
    // }
    Get.offAllNamed(Routes.MAIN_PAGE);
    // Use a delay to ensure MainPageController is initialized then switch to My Orders tab (index 3)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (Get.isRegistered<MainPageController>()) {
        // Get.find<MainPageController>().changeTab(3);
      }
    });
  }
}
