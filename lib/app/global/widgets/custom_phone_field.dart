// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import 'app_text_style.dart';
//
// class CustomPhoneField extends StatelessWidget {
//   const CustomPhoneField({
//     super.key,
//     required this.numberController,
//     required this.countryList,
//     required this.selectedCountryIndex,
//     required this.isLoading,
//     this.validatorNumber,
//     this.skipRequired = false,
//   });
//   final TextEditingController numberController;
//   final List<CountryModel> countryList;
//   final RxInt selectedCountryIndex;
//   final RxBool isLoading;
//   final String? validatorNumber;
//   final bool? skipRequired;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // Country Selector
//         InkWell(
//           onTap: () {
//             if (isLoading.value == false) {
//               _openCountryPicker(context);
//             }
//           },
//           child: Container(
//             height: 55.h,
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8.r),
//                 border: Border.all(color: Colors.grey.shade200)),
//             child: Obx(() {
//               if (isLoading.value) {
//                 return shimmerLoadingWidget(
//                   height: 20.h,
//                   width: 80.w,
//                   borderRadius: 5.r,
//                 );
//               } else {
//                 return Row(
//                   children: [
//                     // Flag from network
//                     cachedImageWidget(
//                       imgUrl: countryList[selectedCountryIndex.value].flagUrl!,
//                       height: 15.h,
//                       width: 20.w,
//                     ),
//                     SizedBox(width: 5.w),
//                     // Dial code
//                     AppTextStyle(
//                       text:
//                       '+${countryList[selectedCountryIndex.value].dialCode}',
//                     ),
//                     SizedBox(width: 5.w),
//                     Icon(
//                       Icons.arrow_drop_down,
//                       color: Colors.black,
//                       size: 20.sp,
//                     ),
//                   ],
//                 );
//               }
//             }),
//           ),
//         ),
//         SizedBox(width: 8.w),
//         Expanded(
//           child: AppInputField(
//             controller: numberController,
//             hintText: 'Enter number'.tr,
//             keyboardType: TextInputType.number,
//             validator: (value) {
//
//               if(skipRequired == true  && numberController.text.isEmpty){
//                 ///  to skip required this field
//                 return null;
//               }
//               if (value == null || value.isEmpty) {
//                 return 'Phone number cannot be empty'.tr;
//               } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                 return 'Please enter a valid phone number'.tr;
//               } else if (value.length <
//                   countryList[selectedCountryIndex.value]
//                       .minLength!
//                       .toInt() ||
//                   value.length >
//                       countryList[selectedCountryIndex.value].maxLength!) {
//                 return 'Number should be between ${countryList[selectedCountryIndex.value].minLength} and ${countryList[selectedCountryIndex.value].maxLength} digits'
//                     .tr;
//               }else if(validatorNumber == value){
//                 return 'This is your existing number.';
//               }
//               return null;
//             },
//           ),
//         )
//       ],
//     );
//   }
//
//   void _openCountryPicker(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.white,
//         contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
//         title: const AppTextStyle(
//           text: "Select Country",
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//         content: SizedBox(
//           width: Get.width,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ...List.generate(countryList.length, (index) {
//                   final country = countryList[index];
//                   return Column(
//                     children: [
//                       ListTile(
//                         leading: cachedImageWidget(
//                           imgUrl: country.flagUrl!,
//                           width: 25.w,
//                           height: 20.h,
//                         ),
//                         title: AppTextStyle(
//                           text: country.name!,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         trailing: AppTextStyle(
//                           text: '+${country.dialCode}',
//                           fontSize: 12,
//                         ),
//                         onTap: () {
//                           selectedCountryIndex.value = index;
//                           Navigator.pop(context);
//                         },
//                       ),
//                       globalDivider(),
//                     ],
//                   );
//                 })
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
