import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({
    super.key,
    required this.onTap,
    required this.isChecked,
    this.size,
  });

  final VoidCallback onTap;
  final bool isChecked;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 25.sp,
      onPressed: onTap,
      child: Container(
        height: size ?? 15.h,
        width: size ?? 15.w,
        decoration: BoxDecoration(
          color: isChecked ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(3.r),
          border: Border.all(width: 1.w, color: AppColor.primary),
        ),
        child: isChecked
            ? Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: size ?? 14.sp,
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
