import 'package:bulkretail/app/global/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/subscriptions_controller.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbarTitle: "Subscriptions",

      body: const Center(
        child: Text(
          'SubscriptionsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
