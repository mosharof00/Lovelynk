import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';


// ── Base shimmer block ────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.margin,
  });

  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.primary.withAlpha(20),
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white12
          : Colors.white70,
      period: const Duration(milliseconds: 1500),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
        ),
      ),
    );
  }
}

// ── Vertical list shimmer ─────────────────────────────────────────────────────

class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 100,
    this.borderRadius,
    this.spacing,
    this.padding,
  });

  final int itemCount;
  final double itemHeight;
  final double? borderRadius;
  final double? spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing ?? 8.h),
      itemBuilder: (_, __) =>
          ShimmerBox(height: itemHeight, borderRadius: borderRadius),
    );
  }
}

// ── Horizontal list shimmer ───────────────────────────────────────────────────

class ShimmerHorizontalList extends StatelessWidget {
  const ShimmerHorizontalList({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 150,
    this.itemWidth,
    this.borderRadius,
    this.spacing,
    this.padding,
  });

  final int itemCount;
  final double itemHeight;
  final double? itemWidth;
  final double? borderRadius;
  final double? spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        padding: padding ?? EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: spacing ?? 10.w),
        itemBuilder: (_, __) => ShimmerBox(
          height: itemHeight,
          width: itemWidth ?? 140.w,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

// ── Grid shimmer ──────────────────────────────────────────────────────────────

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 230,
    this.crossAxisCount = 2,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.borderRadius,
    this.padding,
  });

  final int itemCount;
  final double itemHeight;
  final int crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: padding ?? EdgeInsets.zero,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing ?? 10.h,
      crossAxisSpacing: crossAxisSpacing ?? 10.w,
      itemCount: itemCount,
      itemBuilder: (_, __) =>
          ShimmerBox(height: itemHeight, borderRadius: borderRadius),
    );
  }
}
