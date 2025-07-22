import 'package:get/get.dart';

/// To hide the keyboard
void hideKeyboard() {
  Get.focusScope?.unfocus();
}
