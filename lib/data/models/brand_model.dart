import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/json_converters.dart';

part 'brand_model.g.dart';

@JsonSerializable()
class BrandModel {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  final String? description;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  final String? website;
  @JsonKey(name: 'is_active', fromJson: JsonConverters.toBool)
  final bool isActive;
  @JsonKey(name: 'display_name')
  final String? displayName;

  BrandModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.logoUrl,
    this.website,
    required this.isActive,
    this.displayName,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => 
      _$BrandModelFromJson(json);
  Map<String, dynamic> toJson() => _$BrandModelToJson(this);

  String get displayNameOrDefault => displayName ?? nameAr ?? name;
  
  String? get logoUrlFull {
    if (logoUrl == null) return null;
    if (logoUrl!.startsWith('http://') || logoUrl!.startsWith('https://')) {
      return logoUrl;
    }
    return '${AppConstants.storageUrl}/$logoUrl';
  }
}

@JsonSerializable()
class BrandListResponse {
  final bool success;
  final String? message;
  final List<BrandModel> data;

  BrandListResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory BrandListResponse.fromJson(Map<String, dynamic> json) => 
      _$BrandListResponseFromJson(json);
}
