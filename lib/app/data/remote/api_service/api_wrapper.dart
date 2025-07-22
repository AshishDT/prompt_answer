import 'package:dio/dio.dart';
import '../../../ui/components/app_snackbar.dart';
import '../../config/logger.dart';

/// [APIWrapper] class is a helper class to handle API calls.
class APIWrapper {
  /// Handle API call
  static Future<T?> handleApiCall<T>(Future<T?> apiCall) async {
    try {
      final T? result = await apiCall;
      if (result != null) {
        return result;
      }
    } on DioException catch (e, t) {
      logE(
        'APIWrapper:  ${e.response?.data}  $e  $t',
      );
      final String errorMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message'] ?? 'Oops! Something went wrong.'
          : 'Oops! Something went wrong.';

      appSnackbar(
        message: errorMessage,
        snackbarState: SnackbarState.danger,
      );
      rethrow;
    }

    return null;
  }
}
