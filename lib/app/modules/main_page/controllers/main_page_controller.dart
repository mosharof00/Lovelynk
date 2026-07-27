import 'package:bulkretail/app/modules/color_customise/views/color_customise_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:bulkretail/app/modules/products/views/products_view.dart';
import 'package:get/get.dart';

import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';

class MainPageController extends GetxController {
  final selectedIndex = 0.obs;

  final List<Widget> pages = const [HomeView(), ProductsView(), ColorCustomiseView(), ProfileView()];

  void changePage(int index) => selectedIndex.value = index;
}
