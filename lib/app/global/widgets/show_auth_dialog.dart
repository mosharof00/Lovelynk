import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bulkretail/app/core/utils/dialog_utils.dart';
import 'package:bulkretail/app/core/utils/helper_utils.dart';
import 'package:bulkretail/app/routes/app_pages.dart';
import 'package:get/get.dart';


void showAuthDialog() {
  return DialogUtils.showDialog(
    dialogType: DialogType.info,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: true,
    context: Get.context!,
    title: 'You are Unauthenticated!',
    description: 'Please Login / Signup',
    okOnPress: () {
      Get.offAllNamed(Routes.LOGIN);
      HelperUtils.deleteMainControllers();
    },
  );
}
