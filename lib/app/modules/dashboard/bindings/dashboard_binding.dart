import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

/// Dashboard Binding
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
  }
}
