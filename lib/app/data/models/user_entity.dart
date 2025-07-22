import 'dart:convert';

/// [USER] Details model
class UserEntity {
  /// Constructor
  UserEntity({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.lastName,
    this.username,
    this.phone,
    this.countryCode,
    this.token,
  });

  /// Factory method to create a [UserEntity] from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id: json['id'],
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt']),
    firstName: json['first_name'],
    lastName: json['last_name'],
    username: json['username'],
    phone: json['phone'],
    countryCode: json['country_code'],
    token: json['token'],
  );

  /// Id
  final String? id;

  /// Created at
  final DateTime? createdAt;

  /// Updated at
  final DateTime? updatedAt;

  /// First name
  final String? firstName;

  /// Last name
  final String? lastName;

  /// Username
  final String? username;

  /// Phone number
  final String? phone;

  /// Country code
  final String? countryCode;

  /// Auth token
  final String? token;

  /// To json
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'phone': phone,
    'country_code': countryCode,
  };

  /// To json
  String asString() => json.encode(toJson());

  /// Full name of the user
  String get fullName {
    final String first = firstName ?? '';
    final String last = lastName ?? '';
    return '$first $last'.trim();
  }
}
