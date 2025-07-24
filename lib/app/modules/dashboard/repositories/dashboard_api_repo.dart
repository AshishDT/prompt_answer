import 'package:dio/dio.dart';
import '../../../data/models/api_reponse.dart';
import '../../../data/remote/api_service/api_wrapper.dart';
import '../../../data/remote/api_service/init_api_service.dart';
import '../../../ui/components/app_snackbar.dart';

/// DashBoard API Repository
class DashBoardApiRepo {
  /// Get details
  static Future<dynamic> getDetails({
    required String id,
  }) async =>
      APIWrapper.handleApiCall<dynamic>(
        APIService.get<Map<String, dynamic>>(
          path: '$id',
        ).then(
          (Response<Map<String, dynamic>>? response) {
            if (response?.isOk != true || response?.data == null) {
              return null;
            }

            final ApiResponse<dynamic> data = ApiResponse<dynamic>.fromJson(
              response!.data!,
              fromJsonT: (dynamic json) => json,
            );

            if (data.success ?? false) {
              return data.data;
            }

            appSnackbar(
              message:
                  data.message ?? 'Something went wrong! Please try again.',
              snackbarState: SnackbarState.danger,
            );
            return null;
          },
        ),
      );
}
