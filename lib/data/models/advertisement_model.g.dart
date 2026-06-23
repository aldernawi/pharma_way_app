// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advertisement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvertisementModel _$AdvertisementModelFromJson(Map<String, dynamic> json) =>
    AdvertisementModel(
      id: JsonConverters.toInt(json['id']),
      pharmaceuticalCompanyId: JsonConverters.toInt(
        json['pharmaceutical_company_id'],
      ),
      packageId: JsonConverters.toInt(json['package_id']),
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      linkUrl: json['link_url'] as String?,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String,
      displayPosition: json['display_position'] as String?,
      createdAt: json['created_at'] as String?,
      package: json['package'] == null
          ? null
          : PackageModel.fromJson(json['package'] as Map<String, dynamic>),
      company: json['company'] == null
          ? null
          : CompanyBasicModel.fromJson(json['company'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdvertisementModelToJson(AdvertisementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pharmaceutical_company_id': instance.pharmaceuticalCompanyId,
      'package_id': instance.packageId,
      'title': instance.title,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'link_url': instance.linkUrl,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'status': instance.status,
      'display_position': instance.displayPosition,
      'created_at': instance.createdAt,
      'package': instance.package,
      'company': instance.company,
    };

PackageModel _$PackageModelFromJson(Map<String, dynamic> json) => PackageModel(
  id: JsonConverters.toInt(json['id']),
  name: json['name'] as String,
  price: JsonConverters.buildDouble(json['price']),
  daysCount: JsonConverters.toInt(json['days_count']),
  type: json['type'] as String,
);

Map<String, dynamic> _$PackageModelToJson(PackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'days_count': instance.daysCount,
      'type': instance.type,
    };

CompanyBasicModel _$CompanyBasicModelFromJson(Map<String, dynamic> json) =>
    CompanyBasicModel(
      id: JsonConverters.toInt(json['id']),
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$CompanyBasicModelToJson(CompanyBasicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo_url': instance.logoUrl,
    };

AdvertisementListResponse _$AdvertisementListResponseFromJson(
  Map<String, dynamic> json,
) => AdvertisementListResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>)
      .map((e) => AdvertisementModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AdvertisementListResponseToJson(
  AdvertisementListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
