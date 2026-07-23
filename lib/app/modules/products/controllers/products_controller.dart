import 'package:flutter/cupertino.dart';
import 'package:bulkretail/app/data/models/products_model.dart';
import 'package:get/get.dart';

import '../../../core/network/handle_exceptions.dart';
import '../../../data/repositories/product_repository.dart';

///   Using PaginatedFetchMixin
// class ProductsController extends GetxController with PaginatedFetchMixin {
//   final IProductRepository _repo = Get.find<IProductRepository>();
//
//   final productList = <Product>[].obs;
//
//   @override
//   Future<void> fetchPage(int page) async {
//     final response = await _repo.getProducts(
//       limit: pagination,
//       skip: page * pagination,
//     );
//
//     final products = response.products ?? [];
//
//     if (page == pageBase) {
//       productList.value = products;
//     } else {
//       productList.addAll(products);
//     }
//
//     if (products.length < pagination) isEndPage = true;
//   }
//
//   @override
//   void onFetchError(dynamic e) => handleException(e);
// }

class ProductsController extends GetxController {
  final IProductRepository _productRepo = Get.find<IProductRepository>();

  final productList = <Product>[].obs;

  final isFetching = false.obs;
  final isLoadingMore = false.obs;
  bool isEndPage = false;
  bool _isInitialFetch = true;
  final int pagination = 10;
  int currentPage = 0;
  final scrollController = ScrollController();

  Future<void> fetchData({bool isRefresh = true}) async {
    if (isLoadingMore.value) return;

    if (isRefresh) {
      currentPage = 0;
      isEndPage = false;
      if (_isInitialFetch) {
        isFetching.value = true;
      }
    } else {
      isLoadingMore.value = true;
    }

    try {
      final response = await _productRepo.getProducts(
        limit: pagination,
        skip: currentPage * pagination,
      );

      final products = response.products ?? [];

      if (currentPage == 0) {
        productList.value = products;
      } else {
        productList.addAll(products);
      }

      if (products.length < pagination) isEndPage = true;
      currentPage++;
    } catch (e) {
      handleException(e);
    } finally {
      isFetching.value = false;
      isLoadingMore.value = false;
      _isInitialFetch = false;
    }
  }

  void onScrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isEndPage &&
        !isLoadingMore.value &&
        !isFetching.value) {
      fetchData(isRefresh: false);
    }
  }

  @override
  void onInit() {
    scrollController.addListener(onScrollListener);
    fetchData();
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.removeListener(onScrollListener);
    scrollController.dispose();
    super.onClose();
  }
}
