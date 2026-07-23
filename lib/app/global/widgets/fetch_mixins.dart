import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SimpleFetchMixin — for non-paginated APIs
//
// Use when the API returns all data in one call.
// Provides: isFetching (full-page loader), isLoadingMore is NOT needed here.
//
// Usage:
//   class CategoryController extends GetxController with SimpleFetchMixin {
//     @override
//     Future<void> fetchData() async {
//       try {
//         // your API call
//       } catch (e) {
//         onFetchError(e);
//       } finally {
//         isFetching.value = false;
//       }
//     }
//
//     @override
//     void onFetchError(dynamic e) => handleException(e);
//   }
// ─────────────────────────────────────────────────────────────────────────────

mixin SimpleFetchMixin on GetxController {
  /// True while the full-page fetch is in progress.
  /// Drives the full-screen loader in the widget.
  final isFetching = true.obs;

  /// Override this to implement your API call.
  Future<void> fetchData();

  /// Called when fetchData throws.
  /// Override to show snackbar, log, or call handleException(e).
  /// Default is a no-op — silence is intentional, not accidental.
  void onFetchError(dynamic e) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// PaginatedFetchMixin — for paginated APIs
//
// Use when the API supports limit/skip or page-based pagination.
// Provides: isFetching (full-page loader, first load only) +
//           isLoadingMore (bottom indicator) + scrollController +
//           pagination state + error hook.
//
// Lifecycle (automatic):
//   onInit  → attaches scroll listener + calls fetchData() for first load
//   onClose → removes scroll listener + disposes scrollController
//
// Usage:
//   class ProductsController extends GetxController with PaginatedFetchMixin {
//     final productList = <Product>[].obs;
//
//     @override
//     Future<void> fetchPage(int page) async {
//       final response = await _repo.getProducts(
//         limit: pagination,
//         skip: page * pagination,
//       );
//       final products = response.products ?? [];
//       if (page == 0) productList.value = products;
//       else productList.addAll(products);
//       if (products.length < pagination) isEndPage = true;
//     }
//
//     @override
//     void onFetchError(dynamic e) => handleException(e);
//   }
//
// Optional overrides:
//   int get pagination => 20;        // change page size
//   int get pageBase => 1;           // use 1-based page index for the API
// ─────────────────────────────────────────────────────────────────────────────

mixin PaginatedFetchMixin on GetxController {
  /// True only on the very first load.
  /// Drives the full-screen loader in the widget.
  /// Never becomes true again after the first fetch completes.
  final isFetching = false.obs;

  /// True while the next page is being fetched.
  /// Drives the bottom load-more indicator in the widget.
  final isLoadingMore = false.obs;

  /// True when all pages have been loaded — stops further scroll triggers.
  bool isEndPage = false;

  /// Internal gate — ensures full-screen loader only shows on first launch.
  bool _isInitialFetch = true;

  /// Number of items per page.
  /// Override in your controller if needed: int get pagination => 20;
  int get pagination => 10;

  /// Page index sent on the very first fetch.
  /// Override if your API is 1-based: int get pageBase => 1;
  int get pageBase => 0;

  /// Current page index — plain int, never observed in the UI directly.
  late int currentPage = pageBase;

  /// Owned here for safe lifecycle management.
  /// Pass to PaginatedGridView / PaginatedListView via scrollController param.
  final scrollController = ScrollController();

  /// Implement your API call and list update logic here.
  /// Called internally by fetchData — do not call directly.
  /// [page] is the current page index (respects pageBase).
  Future<void> fetchPage(int page);

  /// Called when fetchPage throws.
  /// Override to show a snackbar, log, or call handleException(e).
  /// Default is a no-op — silence is intentional, not accidental.
  void onFetchError(dynamic e) {}

  /// Triggers a data load.
  /// [isRefresh] = true  → resets to page 0 (or pageBase), used for
  ///                        pull-to-refresh and filter/search changes.
  /// [isRefresh] = false → appends next page, used by scroll listener.
  Future<void> fetchData({bool isRefresh = true}) async {
    if (isLoadingMore.value) return;

    if (isRefresh) {
      currentPage = pageBase;
      isEndPage = false;
      if (_isInitialFetch) {
        isFetching.value = true;
      }
    } else {
      isLoadingMore.value = true;
    }

    try {
      await fetchPage(currentPage);
      currentPage++;
    } catch (e) {
      onFetchError(e);
    } finally {
      isFetching.value = false;
      isLoadingMore.value = false;
      _isInitialFetch = false;
    }
  }

  /// Internal scroll listener — wired in onInit, removed in onClose.
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