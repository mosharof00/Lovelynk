import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../gen/assets.gen.dart';
import 'shimmer_loading.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.imgUrl,
    this.height,
    this.width,
    this.fit,
    this.borderRadius,
    this.specificBorderRadius,
  });

  final String imgUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? borderRadius;
  final BorderRadiusGeometry? specificBorderRadius;

  bool get _isSvg => imgUrl.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          specificBorderRadius ?? BorderRadius.circular(borderRadius ?? 0),
      child: _isSvg ? _svgImage() : _cachedImage(),
    );
  }

  Widget _svgImage() {
    return SvgPicture.network(
      imgUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain,
      placeholderBuilder: (_) =>
          ShimmerBox(height: height, width: width, borderRadius: borderRadius),
    );
  }

  Widget _cachedImage() {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (_, __) =>
          ShimmerBox(height: height, width: width, borderRadius: borderRadius),
      errorWidget: (_, __, ___) => Image.asset(
        Assets.images.placeholderImage.path,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
    );
  }
}
