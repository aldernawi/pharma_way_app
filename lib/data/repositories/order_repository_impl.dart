import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';

class OrderRepositoryImpl {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  // Create orders from cart - sends all items at once, Laravel splits by company
  Future<List<OrderModel>> createOrdersFromCart(
    Cart cart, {
    String? notes,
    String? deliveryAddress,
    String? deliveryPhone,
    String? idempotencyKey,
  }) async {
    try {
      final allItems = cart.items.map((cartItem) {
        return CreateOrderItem(
          productId: cartItem.product.id,
          quantity: cartItem.quantity,
          price: cartItem.product.price,
        );
      }).toList();

      return await _remoteDataSource.createOrders(
        allItems,
        idempotencyKey: idempotencyKey,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get all orders
  Future<List<OrderModel>> getOrders({
    OrderStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return await _remoteDataSource.getOrders(
        status: status,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get order by ID
  Future<OrderModel> getOrderById(int id) async {
    try {
      return await _remoteDataSource.getOrderById(id);
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
      return await _remoteDataSource.getOrdersByCompany(
        companyId,
        status: status,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(int id, {String? reason}) async {
    try {
      await _remoteDataSource.cancelOrder(id, reason: reason);
    } catch (e) {
      rethrow;
    }
  }

  // Mark order as delivered
  Future<OrderModel> markAsDelivered(int id) async {
    try {
      return await _remoteDataSource.markAsDelivered(id);
    } catch (e) {
      rethrow;
    }
  }

  // Get order statistics
  Future<OrderStatistics> getOrderStatistics() async {
    try {
      final data = await _remoteDataSource.getOrderStatistics();
      return OrderStatistics.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Reorder
  Future<OrderModel> reorder(int orderId) async {
    try {
      return await _remoteDataSource.reorder(orderId);
    } catch (e) {
      rethrow;
    }
  }

  // Get orders by status
  Future<List<OrderModel>> getActiveOrders() async {
    try {
      final orders = await getOrders();
      return orders.where((order) => order.isActive).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderModel>> getCompletedOrders() async {
    try {
      return await getOrders(status: OrderStatus.delivered);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderModel>> getCancelledOrders() async {
    try {
      return await getOrders(status: OrderStatus.cancelled);
    } catch (e) {
      rethrow;
    }
  }
}

// Order Statistics Model
class OrderStatistics {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int processingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalAmount;
  final double averageOrderValue;

  OrderStatistics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.processingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalAmount,
    required this.averageOrderValue,
  });

  factory OrderStatistics.fromJson(Map<String, dynamic> json) {
    return OrderStatistics(
      totalOrders: json['total_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      confirmedOrders: json['confirmed_orders'] ?? 0,
      processingOrders: json['processing_orders'] ?? 0,
      shippedOrders: json['shipped_orders'] ?? 0,
      deliveredOrders: json['delivered_orders'] ?? 0,
      cancelledOrders: json['cancelled_orders'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      averageOrderValue: (json['average_order_value'] ?? 0).toDouble(),
    );
  }

  int get activeOrders => pendingOrders + confirmedOrders + processingOrders + shippedOrders;
}
