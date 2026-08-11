import 'package:flutter/material.dart';
import 'package:bulkretail/app/global/layouts/product_layout.dart';
import 'package:bulkretail/app/global/widgets/custom_appbar.dart';
import 'package:bulkretail/app/global/widgets/global_loading.dart';
import 'package:bulkretail/app/global/widgets/paginated_views.dart';
import 'package:bulkretail/app/global/widgets/show_empty_result.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Products', showBackButton: true),
      body: Obx(
        () => PaginatedGridView(
          scrollController: controller.scrollController,
          itemCount: controller.productList.length,
          isFetching: controller.isFetching.value,
          isLoadingMore: controller.isLoadingMore.value,
          isEmpty: controller.productList.isEmpty,
          onRefresh: () => controller.fetchData(),
          gridType: PaginatedGridType.masonry,
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          fetchingWidget: GlobalLoading(),
          loadMoreWidget: GlobalLoading(),
          emptyWidget: ShowEmptyResult(
            title: 'No products found!',
            desc: 'Please try again later',
            refreshOnTap: () => controller.fetchData(),
          ),
          itemBuilder: (context, index) =>
              ProductLayout(product: controller.productList[index]),
        ),
      ),
    );
  }
}
