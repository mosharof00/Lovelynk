import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/get_currency_extension.dart';
import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:bulkretail/app/global/widgets/app_text.dart';
import 'package:bulkretail/app/global/widgets/cached_image.dart';
import 'package:bulkretail/app/global/widgets/get_image_url.dart';
import 'package:bulkretail/app/global/widgets/view_rating_stars.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../data/models/products_model.dart';

class ProductLayout extends StatelessWidget {
  const ProductLayout({
    super.key,
    required this.product,
    this.imgHeight,
    this.imgWidth,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;
  final double? imgHeight;
  final double? imgWidth;

  @override
  Widget build(BuildContext context) {
    double price = product.price ?? 0;
    double discount = product.discountPercentage ?? 0;

    double finalPrice = price * (1 - (discount / 100));

    return InkWell(
      onTap:
          onTap ??
          () {
            Get.back();
          },
      child: Container(
        width: imgWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.r,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(15.r),
                  ),
                  child: CachedImage(
                    imgUrl: GetImageUrl.url(product.thumbnail ?? ''),
                    height: imgHeight ?? 130.h,
                    width: imgWidth ?? Get.width,
                    fit: BoxFit.cover,
                  ),
                ),
                product.discountPercentage == null ||
                        product.discountPercentage == 0
                    ? SizedBox.shrink()
                    : Positioned(
                        top: 8.h,
                        left: 0.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5.r),
                              bottomRight: Radius.circular(5.r),
                            ),
                          ),
                          child: AppText(
                            "${product.discountPercentage}%",
                            style: context.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                ///   Wishlist
                // Positioned(
                //   top: 0.h,
                //   right: 0.w,
                //   child: IconButton(
                //     padding: EdgeInsets.zero,
                //
                //     style: ButtonStyle(
                //       backgroundColor: WidgetStatePropertyAll(
                //         Colors.transparent,
                //       ),
                //     ),
                //     onPressed: () {
                //       if (HelperUtils.isLogin) {
                //         homeController.toggleWishlist(productId: product.id!);
                //       } else {
                //         showAuthDialog();
                //       }
                //     },
                //     icon: Obx(
                //           () => Icon(
                //         homeController.wishListedProductId.contains(product.id!)
                //             ? Icons.favorite_sharp
                //             : Icons.favorite_border_sharp,
                //         color:
                //         homeController.wishListedProductId.contains(
                //           product.id!,
                //         )
                //             ? Colors.red.shade800
                //             : Colors.grey.shade400,
                //         size: 20.sp,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            5.height,
            Padding(
              padding: EdgeInsets.all(5.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5.h,
                children: [
                  AppText(
                    product.title ?? "N/A",
                    style: context.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Row(
                    children: [
                      AppText(
                        finalPrice.getCurrency(),
                        style: context.titleMedium.copyWith(
                          color: AppColor.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      5.width,
                      if (product.discountPercentage != null &&
                          product.discountPercentage != 0)
                        AppText(
                          price.getCurrency(),
                          style: context.labelSmall.copyWith(
                            color: AppColor.grey410,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  if ((product.rating ?? 0) > 0)
                    ViewSingleRatingStar(rating: product.rating!.toDouble()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
