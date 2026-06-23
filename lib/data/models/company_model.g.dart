// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyModel _$CompanyModelFromJson(Map<String, dynamic> json) => CompanyModel(
  id: JsonConverters.toInt(json['id']),
  name: json['name'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  logoUrl: json['logo_url'] as String?,
  adminName: json['admin_name'] as String,
  adminPhone: json['admin_phone'] as String,
  status: json['status'] as String,
  subscriptionStatus: json['subscription_status'] as String?,
  ordersCount: JsonConverters.parseInt(json['orders_count']),
  productsCount: JsonConverters.parseInt(json['products_count']),
  advertisementsCount: JsonConverters.parseInt(json['advertisements_count']),
);

Map<String, dynamic> _$CompanyModelToJson(CompanyModel instance) =>
    <String, dynamic>{
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
      'orders_count': instance.ordersCount,
      'products_count': instance.productsCount,
      'advertisements_count': instance.advertisementsCount,
    };

CompanyListResponse _$CompanyListResponseFromJson(Map<String, dynamic> json) =>
    CompanyListResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>)
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompanyListResponseToJson(
  CompanyListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
