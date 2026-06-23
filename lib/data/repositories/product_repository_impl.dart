import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  Future<List<ProductModel>> getProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return await _remoteDataSource.getProducts(
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByCompany(
    int companyId, {
    int? brandId,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return await _remoteDataSource.getProductsByCompany(
        companyId,
        brandId: brandId,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> getProductById(int id) async {
    try {
      return await _remoteDataSource.getProductById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      return await _remoteDataSource.searchProducts(query);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(
    int categoryId, {
    int? brandId,
    int? companyId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return await _remoteDataSource.getProductsByCategory(
        categoryId,
        brandId: brandId,
        companyId: companyId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByBrand(
    int brandId, {
    int? categoryId,
    int? companyId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return await _remoteDataSource.getProductsByBrand(
        brandId,
        categoryId: categoryId,
        companyId: companyId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      rethrow;
    }
  }
}
