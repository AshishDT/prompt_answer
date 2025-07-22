import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

/// Dashboard View
class DashboardView extends GetView<DashboardController> {
  /// Constructor for DashboardView
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('DashboardView'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'DashboardView is working',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
}
