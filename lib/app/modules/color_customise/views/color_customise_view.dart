import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/color_customise_controller.dart';

class ColorCustomiseView extends GetView<ColorCustomiseController> {
  const ColorCustomiseView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ColorCustomiseView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ColorCustomiseView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
