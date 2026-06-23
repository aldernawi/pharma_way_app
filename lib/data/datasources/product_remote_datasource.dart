import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_helper.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSource(this._dioClient);
  
  // Get all products
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.products,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      
      return ApiHelper.extractList(
        response.data, 
        (json) => ProductModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get products by company with filters
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
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (brandId != null) queryParams['brand_id'] = brandId;
      if (categoryId != null) queryParams['category'] = categoryId;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await _dioClient.get(
        ApiEndpoints.companyProducts(companyId),
        queryParameters: queryParams,
      );
      
      return ApiHelper.extractList(
        response.data, 
        (json) => ProductModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get product by ID
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.productById(id),
      );
      
      return ApiHelper.extractData(
        response.data,
        (json) => ProductModel.fromJson(json),
      ) ?? ProductModel.fromJson({}); // Fallback or rethrow if strictly required
    } catch (e) {
      rethrow;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.productSearch,
        queryParameters: {'query': query},
      );
      
      return ApiHelper.extractList(
        response.data, 
        (json) => ProductModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get products by category with filters
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
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (brandId != null) queryParams['brand_id'] = brandId;
      if (companyId != null) queryParams['company_id'] = companyId;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await _dioClient.get(
        ApiEndpoints.productsByCategory(categoryId),
        queryParameters: queryParams,
      );
      
      return ApiHelper.extractList(
        response.data, 
        (json) => ProductModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get products by brand with filters
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
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (categoryId != null) queryParams['category'] = categoryId;
      if (companyId != null) queryParams['company_id'] = companyId;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await _dioClient.get(
        ApiEndpoints.brandProducts(brandId),
        queryParameters: queryParams,
      );
      
      return ApiHelper.extractList(
        response.data, 
        (json) => ProductModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
