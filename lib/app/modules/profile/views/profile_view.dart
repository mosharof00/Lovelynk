import 'package:flutter/material.dart';
import 'package:bulkretail/app/global/layouts/product_layout.dart';
import 'package:bulkretail/app/global/widgets/appbar_title.dart';
import 'package:bulkretail/app/global/widgets/global_loading.dart';
import 'package:bulkretail/app/global/widgets/show_empty_result.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AppBarTitle("Profile View")),

      body: Obx(() {
        if (controller.isLoading.value) {
          return GlobalLoading();
        } else if (controller.productList.isEmpty) {
          return ShowEmptyResult(
            title: "Products not found",
            refreshOnTap: () {
              controller.fetchData();
            },
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchData();
            },
            child: MasonryGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 5.h,
                bottom: 20.h,
              ),
              itemCount: controller.productList.length,
              itemBuilder: (context, index) =>
                  ProductLayout(product: controller.productList[index]),
            ),
          );
        }
      }),
    );
  }
}
