import 'package:get/get.dart';

import '../modules/activities/bindings/activities_binding.dart';
import '../modules/activities/views/activities_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/color_customise/bindings/color_customise_binding.dart';
import '../modules/color_customise/views/color_customise_view.dart';
import '../modules/connect_with_partner/bindings/connect_with_partner_binding.dart';
import '../modules/connect_with_partner/views/connect_with_partner_view.dart';
import '../modules/emoji_summary/bindings/emoji_summary_binding.dart';
import '../modules/emoji_summary/views/emoji_summary_view.dart';
import '../modules/heartbeat_summary/bindings/heartbeat_summary_binding.dart';
import '../modules/heartbeat_summary/views/heartbeat_summary_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home_screen_guide/bindings/home_screen_guide_binding.dart';
import '../modules/home_screen_guide/views/home_screen_guide_view.dart';
import '../modules/kiss_summary/bindings/kiss_summary_binding.dart';
import '../modules/kiss_summary/views/kiss_summary_view.dart';
import '../modules/lock_screen_guide/bindings/lock_screen_guide_binding.dart';
import '../modules/lock_screen_guide/views/lock_screen_guide_view.dart';
import '../modules/main_page/bindings/main_page_binding.dart';
import '../modules/main_page/views/main_page_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/products/bindings/products_binding.dart';
import '../modules/products/views/products_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/subscriptions/bindings/subscriptions_binding.dart';
import '../modules/subscriptions/views/subscriptions_view.dart';
import '../modules/widgets/bindings/widgets_binding.dart';
import '../modules/widgets/views/widgets_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCTS,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_PAGE,
      page: () => const MainPageView(),
      binding: MainPageBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.CONNECT_WITH_PARTNER,
      page: () => const ConnectWithPartnerView(),
      binding: ConnectWithPartnerBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
      children: [
        GetPage(
          name: _Paths.LOGIN,
          page: () => const LoginView(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: _Paths.REGISTER,
          page: () => const RegisterView(),
          binding: RegisterBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.COLOR_CUSTOMISE,
      page: () => const ColorCustomiseView(),
      binding: ColorCustomiseBinding(),
    ),
    GetPage(
      name: _Paths.WIDGETS,
      page: () => const WidgetsView(),
      binding: WidgetsBinding(),
    ),
    GetPage(
      name: _Paths.SUBSCRIPTIONS,
      page: () => const SubscriptionsView(),
      binding: SubscriptionsBinding(),
    ),
    GetPage(
      name: _Paths.HOME_SCREEN_GUIDE,
      page: () => const HomeScreenGuideView(),
      binding: HomeScreenGuideBinding(),
    ),
    GetPage(
      name: _Paths.LOCK_SCREEN_GUIDE,
      page: () => const LockScreenGuideView(),
      binding: LockScreenGuideBinding(),
    ),
    GetPage(
      name: _Paths.HEARTBEAT_SUMMARY,
      page: () => const HeartbeatSummaryView(),
      binding: HeartbeatSummaryBinding(),
    ),
    GetPage(
      name: _Paths.KISS_SUMMARY,
      page: () => const KissSummaryView(),
      binding: KissSummaryBinding(),
    ),
    GetPage(
      name: _Paths.EMOJI_SUMMARY,
      page: () => const EmojiSummaryView(),
      binding: EmojiSummaryBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVITIES,
      page: () => const ActivitiesView(),
      binding: ActivitiesBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
  ];
}
