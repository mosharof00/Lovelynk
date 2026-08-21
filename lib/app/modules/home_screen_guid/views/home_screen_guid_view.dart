import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_screen_guid_controller.dart';

class HomeScreenGuidView extends GetView<HomeScreenGuidController> {
  const HomeScreenGuidView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScreenGuidView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'HomeScreenGuidView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
