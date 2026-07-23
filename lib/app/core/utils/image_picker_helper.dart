import 'package:bulkretail/app/core/utils/logger.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<XFile?> pickSingleFile(
      {required ImageSource imageSource}) async {
    final XFile? pickedImage =
    await ImagePicker().pickImage(source: imageSource);
    if (pickedImage != null) {
      Log.i(pickedImage);
      return pickedImage;
    } else {
      Log.e("Picked file is null");
      return null;
    }
  }

  static Future<List<XFile>?> pickMultiFile() async {
    final List<XFile>? pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages != null) {
      Log.i(pickedImages);
      return pickedImages;
    } else {
      Log.e("Picked file is null");
      return null;
    }
  }
}