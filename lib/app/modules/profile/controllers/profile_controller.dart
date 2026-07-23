import 'package:bulkretail/app/core/network/handle_exceptions.dart';
import 'package:bulkretail/app/data/models/products_model.dart';
import 'package:bulkretail/app/data/repositories/product_repository.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  //TODO: Implement ProfileController
  final IProductRepository _productRepo = Get.find<IProductRepository>();

  final productList = <Product>[].obs;
  final isLoading = false.obs;

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final response = await _productRepo.getProducts(limit: 20, skip: 0);

      ///   simple validation according to your API response
      if (response.products != null) {
        productList.value = response.products!;
      }
    } catch (e) {
      handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    fetchData();
    super.onInit();
  }
}
