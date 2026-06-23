import '../datasources/home_remote_datasource.dart';
import '../models/company_model.dart';
import '../models/advertisement_model.dart';
import '../models/brand_model.dart';

class HomeRepositoryImpl {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  Future<List<CompanyModel>> getCompanies({int page = 1, int perPage = 15}) async {
    try {
      return await _remoteDataSource.getCompanies(page: page, perPage: perPage);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CompanyModel>> getTopCompanies() async {
    try {
      return await _remoteDataSource.getTopCompanies();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AdvertisementModel>> getGoldenAds() async {
    try {
      return await _remoteDataSource.getGoldenAds();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AdvertisementModel>> getSilverAds() async {
    try {
      return await _remoteDataSource.getSilverAds();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BrandModel>> getBrands() async {
    try {
      return await _remoteDataSource.getBrands();
    } catch (e) {
      rethrow;
    }
  }
}
