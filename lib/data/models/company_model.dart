import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/json_converters.dart';

part 'company_model.g.dart';

@JsonSerializable()
class CompanyModel {
  @JsonKey(fromJson: JsonConverters.toInt)
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
  @JsonKey(name: 'orders_count', fromJson: JsonConverters.parseInt)
  final int? ordersCount;
  @JsonKey(name: 'products_count', fromJson: JsonConverters.parseInt)
  final int? productsCount;
  @JsonKey(name: 'advertisements_count', fromJson: JsonConverters.parseInt)
  final int? advertisementsCount;

  CompanyModel({
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
    this.ordersCount,
    this.productsCount,
    this.advertisementsCount,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => 
      _$CompanyModelFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyModelToJson(this);

  bool get isActive => status == 'active';
  
  String get logoUrlFull {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return '${AppConstants.storageUrl}/images/company-logo.png';
    }
    if (logoUrl!.startsWith('http://') || logoUrl!.startsWith('https://')) {
      return logoUrl!;
    }
    return '${AppConstants.storageUrl}/$logoUrl';
  }
}
@JsonSerializable()
class CompanyListResponse {
  final bool success;
  final String? message;
  final List<CompanyModel> data;

  CompanyListResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory CompanyListResponse.fromJson(Map<String, dynamic> json) => 
      _$CompanyListResponseFromJson(json);
}
