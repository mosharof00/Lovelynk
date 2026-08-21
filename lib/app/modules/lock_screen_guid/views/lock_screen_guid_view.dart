import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/lock_screen_guid_controller.dart';

class LockScreenGuidView extends GetView<LockScreenGuidController> {
  const LockScreenGuidView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LockScreenGuidView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'LockScreenGuidView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
