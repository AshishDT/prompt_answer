part of '../data/remote/api_service/init_api_service.dart';

/// Extensions for Response
extension ResponseExtension on Response<dynamic> {
  /// Checks if the status of the API call is 200
  bool get isOk => <int>[200, 201].contains(statusCode);

  /// Checks if the data exists
  bool get hasData => data != null && data['data'] != null;

  /// Checks if the status is 200 / 201 and the data is not empty
  bool get allIzzWell => isOk && hasData;

  /// Checks if [allIzzWell] and the data is of type [Map<String, dynamic>]
  bool get isDataMap =>
      allIzzWell &&
          data['data'].runtimeType.toString().contains('_InternalLinkedHashMap');

  /// Checks if [allIzzWell] and the data is of type [List<dynamic>]
  String? get apiMessage => data['message'] as String?;
}

/// Extensions for DioException
extension DioExceptionExtension on DioException {
  /// API message
  String? get apiMessage {
    if (response?.data is String) {
      return response?.data as String;
    }
    return response?.data?['message'] as String?;
  }
}
