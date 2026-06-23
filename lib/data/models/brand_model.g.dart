// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandModel _$BrandModelFromJson(Map<String, dynamic> json) => BrandModel(
  id: JsonConverters.toInt(json['id']),
  name: json['name'] as String,
  nameAr: json['name_ar'] as String?,
  description: json['description'] as String?,
  logoUrl: json['logo_url'] as String?,
  website: json['website'] as String?,
  isActive: JsonConverters.toBool(json['is_active']),
  displayName: json['display_name'] as String?,
);

Map<String, dynamic> _$BrandModelToJson(BrandModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'description': instance.description,
      'logo_url': instance.logoUrl,
      'website': instance.website,
      'is_active': instance.isActive,
      'display_name': instance.displayName,
    };

BrandListResponse _$BrandListResponseFromJson(Map<String, dynamic> json) =>
    BrandListResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>)
          .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BrandListResponseToJson(BrandListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
