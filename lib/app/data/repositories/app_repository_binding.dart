import 'package:get/get.dart';
import 'package:bulkretail/app/core/network/api_client.dart';
import 'package:bulkretail/app/core/network/supabase/supabase_service.dart';
import 'package:bulkretail/app/core/services/subscription_service.dart';
import 'auth_repository.dart';
import 'couple_repository.dart';
import 'interaction_repository.dart';
import 'notification_repository.dart';
import 'product_repository.dart';
import 'user_repository.dart';

class AppRepositoryBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient — permanent, created immediately, shared by all repositories
    Get.put<ApiClient>(ApiClient(), permanent: true);

    if (!Get.isRegistered<SubscriptionService>()) {
      Get.put<SubscriptionService>(SubscriptionService(), permanent: true);
    }

    // Repositories — lazy, created only when first Get.find() is called.
    // SupabaseService is registered in main() before runApp.
    Get.lazyPut<IAuthRepository>(
      () => AuthRepository(Get.find<SupabaseService>()),
      fenix: true,
    );

    Get.lazyPut<IUserRepository>(
      () => UserRepository(Get.find<SupabaseService>()),
      fenix: true,
    );

    Get.lazyPut<ICoupleRepository>(
      () => CoupleRepository(Get.find<SupabaseService>()),
      fenix: true,
    );

    Get.lazyPut<IProductRepository>(
          () => ProductRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<INotificationRepository>(
      () => NotificationRepository(Get.find<SupabaseService>()),
      fenix: true,
    );

    Get.lazyPut<IInteractionRepository>(
      () => InteractionRepository(Get.find<SupabaseService>()),
      fenix: true,
    );
  }
}
