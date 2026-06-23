// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  pharmacyId: JsonConverters.parseInt(json['pharmacy_id']),
  pharmaceuticalCompanyId: JsonConverters.parseInt(
    json['pharmaceutical_company_id'],
  ),
  fcmToken: json['fcm_token'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  pharmacy: json['pharmacy'] == null
      ? null
      : PharmacyModel.fromJson(json['pharmacy'] as Map<String, dynamic>),
  pharmaceuticalCompany: json['pharmaceutical_company'] == null
      ? null
      : PharmaceuticalCompanyModel.fromJson(
          json['pharmaceutical_company'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'pharmacy_id': instance.pharmacyId,
  'pharmaceutical_company_id': instance.pharmaceuticalCompanyId,
  'fcm_token': instance.fcmToken,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'pharmacy': instance.pharmacy,
  'pharmaceutical_company': instance.pharmaceuticalCompany,
};

PharmacyModel _$PharmacyModelFromJson(Map<String, dynamic> json) =>
    PharmacyModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      contactPerson: json['contact_person'] as String?,
      status: json['status'] as String,
      subscriptionPlanId: (json['subscription_plan_id'] as num?)?.toInt(),
      subscriptionEndDate: json['subscription_end_date'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
    );

Map<String, dynamic> _$PharmacyModelToJson(PharmacyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'contact_person': instance.contactPerson,
      'status': instance.status,
      'subscription_plan_id': instance.subscriptionPlanId,
      'subscription_end_date': instance.subscriptionEndDate,
      'subscription_status': instance.subscriptionStatus,
    };

PharmaceuticalCompanyModel _$PharmaceuticalCompanyModelFromJson(
  Map<String, dynamic> json,
) => PharmaceuticalCompanyModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  logoUrl: json['logo_url'] as String?,
  adminName: json['admin_name'] as String,
  adminPhone: json['admin_phone'] as String,
  status: json['status'] as String,
  subscriptionStatus: json['subscription_status'] as String?,
);

Map<String, dynamic> _$PharmaceuticalCompanyModelToJson(
  PharmaceuticalCompanyModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'logo_url': instance.logoUrl,
  'admin_name': instance.adminName,
  'admin_phone': instance.adminPhone,
  'status': instance.status,
  'subscription_status': instance.subscriptionStatus,
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
  fcmToken: json['fcm_token'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'fcm_token': instance.fcmToken,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      role: json['role'] as String,
      pharmacyId: (json['pharmacy_id'] as num?)?.toInt(),
      pharmaceuticalCompanyId: (json['pharmaceutical_company_id'] as num?)
          ?.toInt(),
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
      'role': instance.role,
      'pharmacy_id': instance.pharmacyId,
      'pharmaceutical_company_id': instance.pharmaceuticalCompanyId,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : AuthData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

AuthData _$AuthDataFromJson(Map<String, dynamic> json) => AuthData(
  token: json['token'] as String,
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthDataToJson(AuthData instance) => <String, dynamic>{
  'token': instance.token,
  'user': instance.user,
};
