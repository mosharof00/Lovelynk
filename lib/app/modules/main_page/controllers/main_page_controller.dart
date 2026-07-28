import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../color_customise/views/color_customise_view.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../widgets/views/widgets_view.dart';

class MainPageController extends GetxController {
  final selectedIndex = 0.obs;

  final List<Widget> pages = const [
    HomeView(),
    WidgetsView(),
    ColorCustomiseView(),
    ProfileView(),
  ];

  void changePage(int index) => selectedIndex.value = index;
}
