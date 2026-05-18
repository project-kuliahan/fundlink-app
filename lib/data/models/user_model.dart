import 'package:fundlink_app/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    this.emailVerifiedAt,
    this.twoFactorSecret,
    this.twoFactorRecoveryCodes,
    this.twoFactorConfirmedAt,
    this.createdAt,
    this.updatedAt,
    super.phone,
    required super.role,
    this.unitId,
    this.unitName,
  });

  final DateTime? emailVerifiedAt;
  final dynamic twoFactorSecret;
  final dynamic twoFactorRecoveryCodes;
  final dynamic twoFactorConfirmedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? unitId;
  final String? unitName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      emailVerifiedAt: DateTime.tryParse(json["email_verified_at"] ?? ""),
      twoFactorSecret: json["two_factor_secret"],
      twoFactorRecoveryCodes: json["two_factor_recovery_codes"],
      twoFactorConfirmedAt: json["two_factor_confirmed_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      phone: json["phone"],
      role: json["role"] ?? "user",
      unitId: json["unit_id"],
      unitName: json["unit"]?["name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "two_factor_secret": twoFactorSecret,
    "two_factor_recovery_codes": twoFactorRecoveryCodes,
    "two_factor_confirmed_at": twoFactorConfirmedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "phone": phone,
    "role": role,
    "unit_id": unitId,
    "unit": unitName != null ? {"name": unitName} : null,
  };
}
