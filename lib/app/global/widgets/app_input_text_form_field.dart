import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app_text.dart';

InputDecoration buildAppInputDecoration({
  required BuildContext context,
  String? hintText,
  String? errorText,
  String? suffixText,
  Widget? suffixIcon,
  Widget? prefixIcon,
  Color? fillColor,
  EdgeInsetsGeometry? contentPadding,
  double borderRadius = 10,
  bool showBorder = true,
  Color? enabledBorderColor,
  double focusedBorderWidth = 0.8,
}) {
  final radius = BorderRadius.circular(borderRadius);
  final enabledColor = enabledBorderColor ?? AppColor.hintText;

  OutlineInputBorder borderFor(Color color, {double width = 0.5}) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: showBorder
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
    );
  }

  return InputDecoration(
    errorText: errorText,
    suffixText: suffixText,
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    suffixStyle: Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColor.hintText),
    hintText: hintText?.tr,
    filled: true,
    fillColor: fillColor ?? Colors.white,
    contentPadding: contentPadding,
    hintStyle: Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColor.hintText),
    border: borderFor(Colors.black),
    enabledBorder: borderFor(enabledColor),
    focusedBorder: borderFor(AppColor.primary, width: focusedBorderWidth),
  );
}

class AppInputTextFormField extends StatelessWidget {
  const AppInputTextFormField({
    super.key,
    this.label,
    this.labelWidget,
    this.labelColor,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.suffixText,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.errorText,
    this.obscureText,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.fillColor,
    this.contentPadding,
    this.borderRadius = 10,
    this.showBorder = true,
    this.enabledBorderColor,
    this.textAlign,
    this.cursorColor,
    this.style,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.labelSpacing = 5,
  });

  final String? label;
  final Widget? labelWidget;
  final Color? labelColor;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? suffixText;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final bool? obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final bool showBorder;
  final Color? enabledBorderColor;
  final TextAlign? textAlign;
  final Color? cursorColor;
  final TextStyle? style;
  final AutovalidateMode autovalidateMode;
  final double labelSpacing;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      readOnly: readOnly,
      onTap: onTap,
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      cursorColor: cursorColor ?? AppColor.primary,
      autovalidateMode: autovalidateMode,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines,
      textAlign: textAlign ?? TextAlign.start,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText ?? false,
      decoration: buildAppInputDecoration(
        context: context,
        hintText: hintText,
        errorText: errorText,
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        fillColor: fillColor,
        contentPadding: contentPadding,
        borderRadius: borderRadius,
        showBorder: showBorder,
        enabledBorderColor: enabledBorderColor,
      ),
    );

    if (label == null && labelWidget == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelWidget != null)
          labelWidget!
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label!,
                style: context.titleSmall.copyWith(
                  color: labelColor ?? Colors.black,
                ),
              ),
              if (validator != null)
                AppText(
                  '*',
                  style: context.titleSmall.copyWith(
                    color: Colors.red.shade800,
                  ),
                ),
            ],
          ),
        SizedBox(height: labelSpacing),
        field,
      ],
    );
  }
}

@Deprecated('Use AppInputTextFormField instead')
typedef InputFieldWithLabel = AppInputTextFormField;

class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    super.key,
    this.label = 'Password',
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppInputTextFormField(
      label: widget.label,
      hintText: widget.hintText ?? 'Enter password',
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      errorText: widget.errorText,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColor.hintText,
          size: 20.sp,
        ),
      ),
    );
  }
}
