import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_color.dart';


class DialogUtils {
  static void showDialog({
    required BuildContext context,
    required String title,
    required String description,
    DialogType dialogType = DialogType.info,
    String? okText,
    String? cancelText,
    VoidCallback? okOnPress,
    VoidCallback? cancelOnPress,
    VoidCallback? onDismiss, // 👈 Added for tracking dismiss
    bool dismissOnTouchOutside = true, // 👈 configurable
    bool dismissOnBackKeyPress = true, // 👈 configurable
  }) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: title,
      desc: description,
      dismissOnTouchOutside: dismissOnTouchOutside,
      dismissOnBackKeyPress: dismissOnBackKeyPress,
      onDismissCallback: (type) {
        if (onDismiss != null) {
          onDismiss();
        }
      },
      titleTextStyle: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: Colors.black,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      descTextStyle: GoogleFonts.poppins(
          fontSize: 10.sp

      ),
      btnOkText: okText ?? "OK",
      btnOkOnPress: okOnPress,
      btnCancelOnPress: cancelOnPress,
      btnOkColor: AppColor.primary,
      btnCancelColor: Colors.grey,
      btnCancelText: cancelText ?? "Cancel",
    ).show();
  }
}