import 'package:get/get_utils/src/platform/platform.dart';

/// Design configuration
class DesignConfig {
  ///Width of the canvas from design
  static double get kDesignWidth => GetPlatform.isWeb ? 1440 :390;

  ///Height of the canvas from design
  static  double get  kDesignHeight => GetPlatform.isWeb ? 1024 :844;
}
