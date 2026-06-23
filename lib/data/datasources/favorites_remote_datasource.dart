import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_helper.dart';
import '../models/product_model.dart';

class FavoritesRemoteDataSource {
  final DioClient _dioClient = DioClient();

  Future<List<ProductModel>> getFavorites() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.favorites);
      
      return ApiHelper.extractList(
        response.data,
        (json) => ProductModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> addFavorite(int productId) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.favorites,
        data: {'product_id': productId},
      );
      
      return ApiHelper.extractData(
        response.data,
        (json) => ProductModel.fromJson(json),
      ) ?? ProductModel.fromJson({});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavorite(int productId) async {
    try {
      await _dioClient.delete('${ApiEndpoints.favorites}/$productId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _dioClient.delete('${ApiEndpoints.favorites}/clear-all');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isFavorite(int productId) async {
    try {
      final response = await _dioClient.get('${ApiEndpoints.favorites}/check/$productId');
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return data['data']['is_favorite'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
