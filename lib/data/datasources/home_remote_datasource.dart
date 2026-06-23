import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_helper.dart';
import '../models/company_model.dart';
import '../models/advertisement_model.dart';
import '../models/brand_model.dart';

class HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSource(this._dioClient);

  // Get all companies
  Future<List<CompanyModel>> getCompanies({int page = 1, int perPage = 15}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.companies,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      
      return ApiHelper.extractList(
        response.data, 
        (json) => CompanyModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get top companies
  Future<List<CompanyModel>> getTopCompanies() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.topCompanies);
      return ApiHelper.extractList(
        response.data, 
        (json) => CompanyModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get golden advertisements (max 2)
  Future<List<AdvertisementModel>> getGoldenAds() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.goldenAds);
      return ApiHelper.extractList(
        response.data, 
        (json) => AdvertisementModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get silver advertisements (carousel)
  Future<List<AdvertisementModel>> getSilverAds() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.silverAds);
      return ApiHelper.extractList(
        response.data, 
        (json) => AdvertisementModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get active advertisements
  Future<List<AdvertisementModel>> getActiveAds() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.activeAds);
      return ApiHelper.extractList(
        response.data, 
        (json) => AdvertisementModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get all brands
  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.brands);
      return ApiHelper.extractList(
        response.data, 
        (json) => BrandModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
