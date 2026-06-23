// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: JsonConverters.toInt(json['id']),
  name: JsonConverters.buildString(json['name']),
  nameAr: json['name_ar'] as String?,
  description: json['description'] as String?,
  descriptionAr: json['description_ar'] as String?,
  price: JsonConverters.buildDouble(json['price']),
  stockQuantity: JsonConverters.toInt(json['stock_quantity']),
  imageUrl: json['image_url'] as String?,
  barcode: json['barcode'] as String?,
  pharmaceuticalCompanyId: JsonConverters.toInt(
    json['pharmaceutical_company_id'],
  ),
  categoryId: JsonConverters.parseInt(json['category_id']),
  brandId: JsonConverters.parseInt(json['brand_id']),
  isActive: json['is_active'] as bool?,
  createdAt: json['created_at'] as String?,
  company: json['company'] == null
      ? null
      : CompanyBasicInfo.fromJson(json['company'] as Map<String, dynamic>),
  category: json['category'] == null
      ? null
      : CategoryBasicInfo.fromJson(json['category'] as Map<String, dynamic>),
  brand: json['brand'] == null
      ? null
      : BrandBasicInfo.fromJson(json['brand'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'description': instance.description,
      'description_ar': instance.descriptionAr,
      'price': instance.price,
      'stock_quantity': instance.stockQuantity,
      'image_url': instance.imageUrl,
      'barcode': instance.barcode,
      'pharmaceutical_company_id': instance.pharmaceuticalCompanyId,
      'category_id': instance.categoryId,
      'brand_id': instance.brandId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'company': instance.company,
      'category': instance.category,
      'brand': instance.brand,
    };

CompanyBasicInfo _$CompanyBasicInfoFromJson(Map<String, dynamic> json) =>
    CompanyBasicInfo(
      id: JsonConverters.toInt(json['id']),
      name: JsonConverters.buildString(json['name']),
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$CompanyBasicInfoToJson(CompanyBasicInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo_url': instance.logoUrl,
    };

CategoryBasicInfo _$CategoryBasicInfoFromJson(Map<String, dynamic> json) =>
    CategoryBasicInfo(
      id: JsonConverters.toInt(json['id']),
      name: JsonConverters.buildString(json['name']),
      nameAr: json['name_ar'] as String?,
    );

Map<String, dynamic> _$CategoryBasicInfoToJson(CategoryBasicInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
    };

BrandBasicInfo _$BrandBasicInfoFromJson(Map<String, dynamic> json) =>
    BrandBasicInfo(
      id: JsonConverters.toInt(json['id']),
      name: JsonConverters.buildString(json['name']),
      nameAr: json['name_ar'] as String?,
    );

Map<String, dynamic> _$BrandBasicInfoToJson(BrandBasicInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
    };

ProductListResponse _$ProductListResponseFromJson(Map<String, dynamic> json) =>
    ProductListResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: ProductListResponse._extractProductList(json['data']),
    );

Map<String, dynamic> _$ProductListResponseToJson(
  ProductListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
