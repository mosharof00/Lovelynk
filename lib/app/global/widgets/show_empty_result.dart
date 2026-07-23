import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import 'app_text.dart';
import 'global_button.dart';

class ShowEmptyResult extends StatelessWidget {
  const ShowEmptyResult({
    super.key,
    this.height,
    this.width,
    this.title,
    this.desc,
    this.widget,
    this.refreshOnTap,
  });

  final double? height;
  final double? width;
  final String? title;
  final String? desc;
  final Widget? widget;
  final VoidCallback? refreshOnTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Assets.images.emptyBox.path,
              height: 100.h,
              width: 100.w,
            ),
            20.height,
            AppText(
              title ?? 'No response found!',
              style: context.titleSmall,
              textAlign: TextAlign.center,
            ),
            5.height,
            if (desc != null)
              AppText(
                desc!,
                style: context.bodyMedium.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            if (refreshOnTap != null)
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: GlobalButton(
                  height: 35.h,
                  width: 150.w,
                  onTap: refreshOnTap!,
                  text: "Refresh",
                ),
              ),
            if (widget != null) ...[30.height, widget!],
          ],
        ),
      ),
    );
  }
}
