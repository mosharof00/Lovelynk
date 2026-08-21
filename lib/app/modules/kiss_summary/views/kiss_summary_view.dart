import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/kiss_summary_controller.dart';

class KissSummaryView extends GetView<KissSummaryController> {
  const KissSummaryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KissSummaryView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'KissSummaryView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
