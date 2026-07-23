import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.softWrap,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      maxLines: maxLines,
      overflow: maxLines != null ? overflow : null,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}
