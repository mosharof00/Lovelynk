import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/glass_test_controller.dart';

class GlassTestView extends GetView<GlassTestController> {
  const GlassTestView({super.key});

  static const _cardStyle = LiquidGlassStyle(
    shape: LiquidGlassShape.continuousRoundedRectangle(
      cornerRadius: 24,
      borderWidth: 1.2,
    ),
    appearance: LiquidGlassAppearance(
      color: Color(0x22FFFFFF),
      saturation: 1.08,
      blur: LiquidGlassBlur(sigmaX: 4, sigmaY: 4),
    ),
    refraction: LiquidGlassRefraction(
      magnification: 1.04,
      refractionType: OpticalRefraction(
        refraction: 1.5,
        refractionWidth: 26,
        depth: 0.55,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Liquid glass test'),
      ),
      body: LiquidGlassView(
        backgroundWidget: const _TestBackground(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            child: Column(
              children: [
                AppText(
                  'Drag the cards to see refraction.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
                20.verticalSpace,
                LiquidGlassDraggable(
                  child: SizedBox(
                    width: double.infinity,
                    height: 92.h,
                    child: LiquidGlassLens(
                      style: _cardStyle,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26.r,
                              backgroundColor: AppColor.primaryLight,
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColor.primary,
                              ),
                            ),
                            14.horizontalSpace,
                            Expanded(
                              child: AppText(
                                'Profile card',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColor.hintText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                16.verticalSpace,
                LiquidGlassDraggable(
                  child: SizedBox(
                    width: double.infinity,
                    height: 140.h,
                    child: LiquidGlassLens(
                      style: _cardStyle,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Your Relationship',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            12.verticalSpace,
                            AppText(
                              'Partner Profile',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                              ),
                            ),
                            6.verticalSpace,
                            AppText(
                              'Our Anniversary  ·  12 Oct 2022',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                16.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: LiquidGlassDraggable(
                        child: SizedBox(
                          height: 120.h,
                          child: LiquidGlassLens(
                            style: _cardStyle,
                            child: Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: AppColor.primary,
                                size: 36.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: LiquidGlassDraggable(
                        child: SizedBox(
                          height: 120.h,
                          child: LiquidGlassLens(
                            style: _cardStyle,
                            child: Center(
                              child: AppText(
                                'Send Kiss',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TestBackground extends StatelessWidget {
  const _TestBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColor.background),
        Positioned(
          top: -40.h,
          left: -40.w,
          child: _Blob(color: const Color(0xFF48CAE4), size: 220.r),
        ),
        Positioned(
          top: 180.h,
          right: -50.w,
          child: _Blob(color: AppColor.primary.withValues(alpha: 0.55), size: 200.r),
        ),
        Positioned(
          bottom: 80.h,
          left: 20.w,
          child: _Blob(color: AppColor.secondary.withValues(alpha: 0.7), size: 180.r),
        ),
        Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: 0.45,
            child: Image.asset(
              Assets.images.lockScreenDemo.path,
              width: 260.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
