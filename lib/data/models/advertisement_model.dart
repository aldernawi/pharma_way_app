import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/json_converters.dart';

part 'advertisement_model.g.dart';

@JsonSerializable()
class AdvertisementModel {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  @JsonKey(name: 'pharmaceutical_company_id', fromJson: JsonConverters.toInt)
  final int pharmaceuticalCompanyId;
  @JsonKey(name: 'package_id', fromJson: JsonConverters.toInt)
  final int packageId;
  final String title;
  final String? description;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'link_url')
  final String? linkUrl;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  final String status;
  @JsonKey(name: 'display_position')
  final String? displayPosition;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  // Relationships
  final PackageModel? package;
  final CompanyBasicModel? company;

  AdvertisementModel({
    required this.id,
    required this.pharmaceuticalCompanyId,
    required this.packageId,
    required this.title,
    this.description,
    required this.imageUrl,
    this.linkUrl,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.displayPosition,
    this.createdAt,
    this.package,
    this.company,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) => 
      _$AdvertisementModelFromJson(json);
  Map<String, dynamic> toJson() => _$AdvertisementModelToJson(this);

  bool get isActive => status == 'active';
  bool get isGolden => package?.type == 'golden';
  bool get isSilver => package?.type == 'silver';
  
  String get imageUrlFull {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return '${AppConstants.storageUrl}/$imageUrl';
  }
}

@JsonSerializable()
class PackageModel {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  final String name;
  @JsonKey(fromJson: JsonConverters.buildDouble)
  final double price;
  @JsonKey(name: 'days_count', fromJson: JsonConverters.toInt)
  final int daysCount;
  final String type;

  PackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.daysCount,
    required this.type,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => 
      _$PackageModelFromJson(json);
  Map<String, dynamic> toJson() => _$PackageModelToJson(this);
}

@JsonSerializable()
class CompanyBasicModel {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  final String name;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  CompanyBasicModel({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory CompanyBasicModel.fromJson(Map<String, dynamic> json) => 
      _$CompanyBasicModelFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyBasicModelToJson(this);
}

@JsonSerializable()
class AdvertisementListResponse {
  final bool success;
  final String? message;
  final List<AdvertisementModel> data;

  AdvertisementListResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory AdvertisementListResponse.fromJson(Map<String, dynamic> json) => 
      _$AdvertisementListResponseFromJson(json);
}
