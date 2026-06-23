import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/json_converters.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  @JsonKey(fromJson: JsonConverters.buildString)
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  final String? description;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  @JsonKey(fromJson: JsonConverters.buildDouble)
  final double price;
  @JsonKey(name: 'stock_quantity', fromJson: JsonConverters.toInt)
  final int stockQuantity;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? barcode;
  @JsonKey(name: 'pharmaceutical_company_id', fromJson: JsonConverters.toInt)
  final int pharmaceuticalCompanyId;
  @JsonKey(name: 'category_id', fromJson: JsonConverters.parseInt)
  final int? categoryId;
  @JsonKey(name: 'brand_id', fromJson: JsonConverters.parseInt)
  final int? brandId;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  // Relationships
  final CompanyBasicInfo? company;
  final CategoryBasicInfo? category;
  final BrandBasicInfo? brand;

  ProductModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    this.barcode,
    required this.pharmaceuticalCompanyId,
    this.categoryId,
    this.brandId,
    this.isActive,
    this.createdAt,
    this.company,
    this.category,
    this.brand,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => 
      _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 10;
  
  String get imageUrlFull {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return '${AppConstants.storageUrl}/images/product-placeholder.png';
    }
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl!;
    }
    return '${AppConstants.storageUrl}/$imageUrl';
  }
      
  String get displayName => (nameAr != null && nameAr!.isNotEmpty) ? nameAr! : name;
  String get displayDescription => descriptionAr ?? description ?? '';
}

@JsonSerializable()
class CompanyBasicInfo {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  @JsonKey(fromJson: JsonConverters.buildString)
  final String name;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  CompanyBasicInfo({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory CompanyBasicInfo.fromJson(Map<String, dynamic> json) => 
      _$CompanyBasicInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyBasicInfoToJson(this);
}

@JsonSerializable()
class CategoryBasicInfo {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  @JsonKey(fromJson: JsonConverters.buildString)
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;

  CategoryBasicInfo({
    required this.id,
    required this.name,
    this.nameAr,
  });

  factory CategoryBasicInfo.fromJson(Map<String, dynamic> json) => 
      _$CategoryBasicInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryBasicInfoToJson(this);
  
  String get displayNameOrDefault => (nameAr != null && nameAr!.isNotEmpty) ? nameAr! : name;
}

@JsonSerializable()
class BrandBasicInfo {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  @JsonKey(fromJson: JsonConverters.buildString)
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;

  BrandBasicInfo({
    required this.id,
    required this.name,
    this.nameAr,
  });

  factory BrandBasicInfo.fromJson(Map<String, dynamic> json) => 
      _$BrandBasicInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BrandBasicInfoToJson(this);
}

@JsonSerializable()
class ProductListResponse {
  final bool success;
  final String? message;

  @JsonKey(fromJson: _extractProductList)
  final List<ProductModel> data;

  ProductListResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductListResponseFromJson(json);

  static List<ProductModel> _extractProductList(dynamic jsonData) {
    if (jsonData is List) {
      return jsonData
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (jsonData is Map && jsonData['data'] is List) {
      return (jsonData['data'] as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
