import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_converters.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  
  @JsonKey(name: 'pharmacy_id', fromJson: JsonConverters.parseInt)
  final int? pharmacyId;
  
  @JsonKey(name: 'pharmaceutical_company_id', fromJson: JsonConverters.parseInt)
  final int? pharmaceuticalCompanyId;
  
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // Relationships
  final PharmacyModel? pharmacy;
  @JsonKey(name: 'pharmaceutical_company')
  final PharmaceuticalCompanyModel? pharmaceuticalCompany;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.pharmacyId,
    this.pharmaceuticalCompanyId,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.pharmacy,
    this.pharmaceuticalCompany,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isSuperAdmin => role == 'super_admin';
  bool get isPharmacyAdmin => role == 'pharmacy_admin';
  bool get isCompanyAdmin => role == 'company_admin';
}

@JsonSerializable()
class PharmacyModel {
  final int id;
  final String name;
  final String address;
  final String phone;
  @JsonKey(name: 'contact_person')
  final String? contactPerson;
  final String status;
  @JsonKey(name: 'subscription_plan_id')
  final int? subscriptionPlanId;
  @JsonKey(name: 'subscription_end_date')
  final String? subscriptionEndDate;
  @JsonKey(name: 'subscription_status')
  final String? subscriptionStatus;

  PharmacyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.contactPerson,
    required this.status,
    this.subscriptionPlanId,
    this.subscriptionEndDate,
    this.subscriptionStatus,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) => _$PharmacyModelFromJson(json);
  Map<String, dynamic> toJson() => _$PharmacyModelToJson(this);

  bool get isActive => status == 'active';
  bool get hasActiveSubscription => subscriptionStatus == 'active';
}

@JsonSerializable()
class PharmaceuticalCompanyModel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @JsonKey(name: 'admin_name')
  final String adminName;
  @JsonKey(name: 'admin_phone')
  final String adminPhone;
  final String status;
  @JsonKey(name: 'subscription_status')
  final String? subscriptionStatus;

  PharmaceuticalCompanyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.logoUrl,
    required this.adminName,
    required this.adminPhone,
    required this.status,
    this.subscriptionStatus,
  });

  factory PharmaceuticalCompanyModel.fromJson(Map<String, dynamic> json) => _$PharmaceuticalCompanyModelFromJson(json);
  Map<String, dynamic> toJson() => _$PharmaceuticalCompanyModelToJson(this);

  bool get isActive => status == 'active';
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  LoginRequest({
    required this.email,
    required this.password,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  final String role;
  @JsonKey(name: 'pharmacy_id')
  final int? pharmacyId;
  @JsonKey(name: 'pharmaceutical_company_id')
  final int? pharmaceuticalCompanyId;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
    this.pharmacyId,
    this.pharmaceuticalCompanyId,
  });

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}

@JsonSerializable()
class AuthData {
  final String token;
  final UserModel user;

  AuthData({
    required this.token,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);
}
