// // lib/app/core/widgets/document_upload_field.dart
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path/path.dart' as p;
// import '../../../gen/assets.gen.dart';
// import '../theme/app_color.dart';
// import 'app_text_style.dart';
// import 'custom_svg_image.dart';
//
// class DocumentUploadField extends StatelessWidget {
//   final String label;
//   final RxnString filePathObs;
//   final VoidCallback onTap;
//   final VoidCallback onRemove;
//   final bool isRequired;
//   final bool readOnly;
//   final Color? fieldColor;
//
//   const DocumentUploadField({
//     super.key,
//     required this.label,
//     required this.filePathObs,
//     required this.onTap,
//     required this.onRemove,
//     this.isRequired = true,
//     this.readOnly = false,
//     this.fieldColor,
//   });
//
//   String _formatFileSize(String filePath) {
//     try {
//       final bytes = File(filePath).lengthSync();
//       if (bytes < 1024) return '$bytes B';
//       if (bytes < 1024 * 1024) {
//         return '${(bytes / 1024).toStringAsFixed(2)} KB';
//       }
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
//     } catch (_) {
//       return '';
//     }
//   }
//
//   bool _isImage(String filePath) {
//     final ext = p.extension(filePath).toLowerCase();
//     return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
//   }
//
//   Future<void> _openFile(String filePath) async {
//     await OpenFilex.open(filePath);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Label ──────────────────────────────────────────
//         Row(
//           children: [
//             AppTextStyle(
//               text: label,
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.black,
//             ),
//             if (isRequired)
//               AppTextStyle(
//                 text: ' *',
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.red.shade800,
//               ),
//           ],
//         ),
//         4.verticalSpace,
//
//         // ── Upload box ─────────────────────────────────────
//         Obx(() {
//           final filePath = filePathObs.value;
//           final isUploaded = filePath != null;
//
//           return GestureDetector(
//             onTap: () {
//               if (isUploaded) {
//                 // Open file for viewing
//                 _openFile(filePath);
//               } else if (!readOnly) {
//                 // Pick a new file
//                 onTap();
//               }
//             },
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(
//                 horizontal: 14.w,
//                 vertical: 12.h,
//               ),
//               decoration: BoxDecoration(
//                   color: isUploaded
//                       ? AppColors.primary.withAlpha(10)
//                       : fieldColor ?? Colors.white,
//                   borderRadius: BorderRadius.circular(10.r),
//                   border: Border.all(color: isUploaded
//                       ? AppColors.primary
//                       : readOnly
//                       ? AppColors.hintText.withAlpha(80)
//                       : AppColors.hintText,)
//               ),
//               child: isUploaded
//                   ? _uploadedState(
//                 filePath: filePath,
//                 fileSize: _formatFileSize(filePath),
//                 isImage: _isImage(filePath),
//                 onRemove: readOnly ? null : onRemove,
//               )
//                   : _emptyState(readOnly: readOnly),
//             ),
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _emptyState({required bool readOnly}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         customSvgImage(
//           imagePath: Assets.icons.uploadIcon,
//           color: readOnly ? AppColors.hintText.withAlpha(80) : AppColors.hintText,
//         ),
//         6.horizontalSpace,
//         AppTextStyle(
//           text: readOnly ? 'Not uploaded' : 'Upload file (Image or PDF)',
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w400,
//           color: readOnly ? AppColors.hintText.withAlpha(80) : AppColors.hintText,
//         ),
//       ],
//     );
//   }
//
//   Widget _uploadedState({
//     required String filePath,
//     required String fileSize,
//     required bool isImage,
//     required VoidCallback? onRemove,
//   }) {
//     final fileName = p.basename(filePath);
//
//     return Row(
//       children: [
//         // Thumbnail for image, doc icon for PDF
//         if (isImage)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(6.r),
//             child: Image.file(
//               File(filePath),
//               width: 36.w,
//               height: 36.w,
//               fit: BoxFit.cover,
//             ),
//           )
//         else
//           customSvgImage(
//             imagePath: Assets.icons.docIcon,
//             color: AppColors.primary,
//           ),
//         10.horizontalSpace,
//
//         // File name + size
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AppTextStyle(
//                 text: fileName,
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               if (fileSize.isNotEmpty)
//                 AppTextStyle(
//                   text: fileSize,
//                   fontSize: 11.sp,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.hintText,
//                 ),
//             ],
//           ),
//         ),
//
//         // View hint or remove button
//         if (onRemove != null)
//           GestureDetector(
//             onTap: onRemove,
//             child: customSvgImage(
//               imagePath: Assets.icons.crossCircleIcon,
//               color: AppColors.hintText,
//             ),
//           )
//         else
//           Row(
//             children: [
//               customSvgImage(
//                 imagePath: Assets.icons.eyeOpenIcon,
//                 width: 16.w,
//                 height: 16.w,
//                 color: AppColors.primary,
//               ),
//               4.horizontalSpace,
//               AppTextStyle(
//                 text: 'View',
//                 fontSize: 11.sp,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.primary,
//               ),
//             ],
//           ),
//       ],
//     );
//   }
// }