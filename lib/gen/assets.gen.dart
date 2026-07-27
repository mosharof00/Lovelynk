// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/back_arrow_icon.svg
  String get backArrowIcon => 'assets/icons/back_arrow_icon.svg';

  /// File path: assets/icons/block_fill_icon.svg
  String get blockFillIcon => 'assets/icons/block_fill_icon.svg';

  /// File path: assets/icons/block_icon.svg
  String get blockIcon => 'assets/icons/block_icon.svg';

  /// File path: assets/icons/color_customize_fill_icon.svg
  String get colorCustomizeFillIcon =>
      'assets/icons/color_customize_fill_icon.svg';

  /// File path: assets/icons/color_customize_icon.svg
  String get colorCustomizeIcon => 'assets/icons/color_customize_icon.svg';

  /// File path: assets/icons/home_fill_icon.svg
  String get homeFillIcon => 'assets/icons/home_fill_icon.svg';

  /// File path: assets/icons/home_icon.svg
  String get homeIcon => 'assets/icons/home_icon.svg';

  /// File path: assets/icons/love_icon.svg
  String get loveIcon => 'assets/icons/love_icon.svg';

  /// File path: assets/icons/love_multi.svg
  String get loveMulti => 'assets/icons/love_multi.svg';

  /// File path: assets/icons/profile_fill_icon.svg
  String get profileFillIcon => 'assets/icons/profile_fill_icon.svg';

  /// File path: assets/icons/profile_icon.svg
  String get profileIcon => 'assets/icons/profile_icon.svg';

  /// File path: assets/icons/widget_fill_icon.svg
  String get widgetFillIcon => 'assets/icons/widget_fill_icon.svg';

  /// File path: assets/icons/widget_icon.svg
  String get widgetIcon => 'assets/icons/widget_icon.svg';

  /// List of all assets
  List<String> get values => [
    backArrowIcon,
    blockFillIcon,
    blockIcon,
    colorCustomizeFillIcon,
    colorCustomizeIcon,
    homeFillIcon,
    homeIcon,
    loveIcon,
    loveMulti,
    profileFillIcon,
    profileIcon,
    widgetFillIcon,
    widgetIcon,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/connect_with_partner_image.png
  AssetGenImage get connectWithPartnerImage =>
      const AssetGenImage('assets/images/connect_with_partner_image.png');

  /// File path: assets/images/empty_box.png
  AssetGenImage get emptyBox =>
      const AssetGenImage('assets/images/empty_box.png');

  /// File path: assets/images/onboard_image.png
  AssetGenImage get onboardImage =>
      const AssetGenImage('assets/images/onboard_image.png');

  /// File path: assets/images/onboard_image_2.png
  AssetGenImage get onboardImage2 =>
      const AssetGenImage('assets/images/onboard_image_2.png');

  /// File path: assets/images/placeholder_image.jpg
  AssetGenImage get placeholderImage =>
      const AssetGenImage('assets/images/placeholder_image.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [
    connectWithPartnerImage,
    emptyBox,
    onboardImage,
    onboardImage2,
    placeholderImage,
  ];
}

class $AssetsLogosGen {
  const $AssetsLogosGen();

  /// File path: assets/logos/app_icon.png
  AssetGenImage get appIcon => const AssetGenImage('assets/logos/app_icon.png');

  /// File path: assets/logos/app_logo.png
  AssetGenImage get appLogo => const AssetGenImage('assets/logos/app_logo.png');

  /// List of all assets
  List<AssetGenImage> get values => [appIcon, appLogo];
}

abstract final class Assets {
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLogosGen logos = $AssetsLogosGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
