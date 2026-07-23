import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

Widget customSvgImage({
  required String imagePath,
  Color? color,
  double? height,
  double? width,
}) {
  return SvgPicture.asset(
    imagePath,
    height: height,
    width: width,
    colorFilter: color != null
        ? ColorFilter.mode(color, BlendMode.srcIn)
        : null,
  );
}
