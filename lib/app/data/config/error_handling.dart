import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'logger.dart';

/// To handle all the error app wide
void letMeHandleAllErrors(Object error, StackTrace? trace) {
  switch (error.runtimeType) {
    case DioException:
      final Response<dynamic>? res = (error as DioException).response;
      logE('Got error : ${res!.statusCode} -> ${res.statusMessage}');

      Get.snackbar(
        'Oops!',
        'Got error : ${res.statusCode} -> ${res.statusMessage}',
      );
      break;

    default:
      Get.snackbar('Oops!', 'Something went wrong');
      logE(error.toString());
      logE(trace);
      break;
  }
}
