/// Generic API response model
class ApiResponse<T> {
  /// Constructor
  ApiResponse({
    this.success,
    this.message,
    this.data,
  });

  /// Factory method to create a [ApiResponse] from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJsonT,
  }) =>
      ApiResponse<T>(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'])
            : null,
      );

  /// Success
  final bool? success;

  /// Message
  final String? message;

  /// Data
  final T? data;

  /// To json
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
        'success': success,
        'message': message,
        'data': data != null ? toJsonT(data as T) : null,
      };
}
