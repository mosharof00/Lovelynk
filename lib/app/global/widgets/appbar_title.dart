import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';

import 'app_text.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: context.titleLarge.copyWith(color: color),
      textAlign: TextAlign.center,
    );
  }
}