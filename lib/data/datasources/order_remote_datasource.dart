import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_helper.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  final DioClient _dioClient;

  OrderRemoteDataSource(this._dioClient);

  // Create orders from cart - Laravel splits by company automatically
  Future<List<OrderModel>> createOrders(List<CreateOrderItem> items, {String? idempotencyKey}) async {
    try {
      // Laravel CartController expects: { products: [{id, quantity}], idempotency_key? }
      final products = items.map((item) => {
        'id': item.productId,
        'quantity': item.quantity,
      }).toList();

      final data = <String, dynamic>{
        'products': products,
      };

      if (idempotencyKey != null) {
        data['idempotency_key'] = idempotencyKey;
      }

      final response = await _dioClient.post(
        ApiEndpoints.checkout,
        data: data,
      );

      return ApiHelper.extractList(
        response.data,
        (json) => OrderModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get all orders for current pharmacy
  Future<List<OrderModel>> getOrders({
    OrderStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _dioClient.get(
        ApiEndpoints.orders,
        queryParameters: queryParams,
      );
      
      return ApiHelper.extractList(
        response.data, 
        (json) => OrderModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get order by ID
  Future<OrderModel> getOrderById(int id) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.orderById(id),
      );
      
      return ApiHelper.extractData(
        response.data,
        (json) => OrderModel.fromJson(json),
      ) ?? OrderModel.fromJson({});
    } catch (e) {
      rethrow;
    }
  }

  // Get orders by company
  Future<List<OrderModel>> getOrdersByCompany(
    int companyId, {
    OrderStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _dioClient.get(
        '${ApiEndpoints.companies}/$companyId/orders',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      return ApiHelper.extractList(
        response.data,
        (json) => OrderModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(int id, {String? reason}) async {
    try {
      final request = CancelOrderRequest(cancellationReason: reason);
      
      await _dioClient.post(
        '${ApiEndpoints.orders}/$id/cancel',
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Mark order as delivered
  Future<OrderModel> markAsDelivered(int id) async {
    try {
      final response = await _dioClient.patch(
        ApiEndpoints.markOrderDelivered(id),
      );
      
      return ApiHelper.extractData(
         response.data,
         (json) => OrderModel.fromJson(json),
      ) ?? OrderModel.fromJson({});
    } catch (e) {
      rethrow;
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final response = await _dioClient.get(
        '${ApiEndpoints.orders}/statistics',
      );
      
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  // Reorder (create new order from existing order)
  Future<OrderModel> reorder(int orderId) async {
    try {
      final response = await _dioClient.post(
        '${ApiEndpoints.orders}/$orderId/reorder',
      );
      
      return ApiHelper.extractData(
         response.data,
         (json) => OrderModel.fromJson(json),
      ) ?? OrderModel.fromJson({});
    } catch (e) {
      rethrow;
    }
  }
}
