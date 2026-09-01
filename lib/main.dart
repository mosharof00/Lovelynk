import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'app/core/config/app_config.dart';
import 'app/core/services/compass_service.dart';
import 'app/core/services/local_store_service.dart';
import 'app/core/services/subscription_service.dart';
import 'app/core/services/widget_deep_link_service.dart';
import 'app/core/services/widget_data_service.dart';
import 'app/core/widgets/widget_style_store.dart';
import 'app/core/widgets/widget_sync_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/repositories/app_repository_binding.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase FIRST
  // await Firebase.initializeApp(
  //   name: 'meeza',
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  ///    Initialize Supabase
  // await Supabase.initialize(
  //   url: AppConfig.SUPABASE_URL,
  //   anonKey: AppConfig.SUPABASE_ANON_KEY,
  // );

  await HiveService.initHive();

  Get.put<SubscriptionService>(SubscriptionService(), permanent: true);
  Get.put<WidgetDataService>(WidgetDataService().init(), permanent: true);
  Get.put<CompassService>(CompassService().init(), permanent: true);
  await Get.putAsync<WidgetStyleStore>(
    () => WidgetStyleStore().init(),
    permanent: true,
  );
  await Get.putAsync<WidgetSyncService>(
    () => WidgetSyncService().init(),
    permanent: true,
  );
  await Get.putAsync<WidgetDeepLinkService>(
    () => WidgetDeepLinkService().init(),
    permanent: true,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => GetMaterialApp(
        textDirection: TextDirection.ltr,
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,

        theme: AppTheme.light(),
        themeMode: ThemeMode.light,

        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,

        // init all repository bindings
        initialBinding: AppRepositoryBinding(),
      ),
    );
  }
}
