import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/models/order_model.dart';
import '../../data/models/cart_model.dart';

// Providers
final orderDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource(ref.watch(dioClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepositoryImpl>((ref) {
  return OrderRepositoryImpl(ref.watch(orderDataSourceProvider));
});

// Orders State
class OrdersState {
  final List<OrderModel> orders;
  final List<OrderModel> activeOrders;
  final List<OrderModel> completedOrders;
  final List<OrderModel> cancelledOrders;
  final OrderStatistics? statistics;
  final bool isLoading;
  final bool isCreating;
  final String? error;
  final String? successMessage;

  OrdersState({
    this.orders = const [],
    this.activeOrders = const [],
    this.completedOrders = const [],
    this.cancelledOrders = const [],
    this.statistics,
    this.isLoading = false,
    this.isCreating = false,
    this.error,
    this.successMessage,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? activeOrders,
    List<OrderModel>? completedOrders,
    List<OrderModel>? cancelledOrders,
    OrderStatistics? statistics,
    bool? isLoading,
    bool? isCreating,
    String? error,
    String? successMessage,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      activeOrders: activeOrders ?? this.activeOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      error: error,
      successMessage: successMessage,
    );
  }

  int get totalOrders => orders.length;
  int get activeOrdersCount => activeOrders.length;
  int get completedOrdersCount => completedOrders.length;
  int get cancelledOrdersCount => cancelledOrders.length;
}

// Orders Notifier
class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderRepositoryImpl _repository;

  OrdersNotifier(this._repository) : super(OrdersState()) {
    loadOrders();
  }

  // Load all orders
  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final orders = await _repository.getOrders();
      
      // Categorize orders
      final active = orders.where((o) => o.isActive).toList();
      final completed = orders.where((o) => o.isCompleted).toList();
      final cancelled = orders.where((o) => o.isCancelled).toList();

      state = state.copyWith(
        orders: orders,
        activeOrders: active,
        completedOrders: completed,
        cancelledOrders: cancelled,
        isLoading: false,
      );

      // Load statistics
      await loadStatistics();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      final stats = await _repository.getOrderStatistics();
      state = state.copyWith(statistics: stats);
    } catch (e) {
      state = state.copyWith(
        error: 'فشل تحميل الإحصائيات: $e',
      );
    }
  }

  // Create orders from cart
  Future<bool> createOrdersFromCart(
    Cart cart, {
    String? notes,
    String? deliveryAddress,
    String? deliveryPhone,
    String? idempotencyKey,
  }) async {
    state = state.copyWith(isCreating: true, error: null, successMessage: null);
    
    try {
      final orders = await _repository.createOrdersFromCart(
        cart,
        notes: notes,
        deliveryAddress: deliveryAddress,
        deliveryPhone: deliveryPhone,
        idempotencyKey: idempotencyKey,
      );

      state = state.copyWith(
        isCreating: false,
        successMessage: 'تم إنشاء ${orders.length} طلب بنجاح',
      );

      // Reload orders
      await loadOrders();
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      await _repository.cancelOrder(orderId, reason: reason);
      
      state = state.copyWith(
        successMessage: 'تم إلغاء الطلب بنجاح',
      );

      // Reload orders
      await loadOrders();
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Mark order as delivered (Pharmacy confirms delivery)
  Future<bool> markAsDelivered(int orderId) async {
    try {
      await _repository.markAsDelivered(orderId);
      
      state = state.copyWith(
        successMessage: 'تم تأكيد استلام الطلب بنجاح',
      );

      // Reload orders
      await loadOrders();
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Reorder
  Future<bool> reorder(int orderId) async {
    state = state.copyWith(isCreating: true, error: null);
    
    try {
      await _repository.reorder(orderId);
      
      state = state.copyWith(
        isCreating: false,
        successMessage: 'تم إعادة الطلب بنجاح',
      );

      // Reload orders
      await loadOrders();
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Filter orders by status
  void filterByStatus(OrderStatus? status) {
    if (status == null) {
      // Show all
      return;
    }

    final filtered = state.orders.where((o) => o.status == status).toList();
    
    // Update appropriate list based on status
    if (status.isActive) {
      state = state.copyWith(activeOrders: filtered);
    } else if (status.isCompleted) {
      state = state.copyWith(completedOrders: filtered);
    } else if (status.isCancelled) {
      state = state.copyWith(cancelledOrders: filtered);
    }
  }

  // Refresh
  Future<void> refresh() async {
    await loadOrders();
  }

  // Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

// Orders Provider
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.watch(orderRepositoryProvider));
});

// Order Details State
class OrderDetailsState {
  final OrderModel? order;
  final bool isLoading;
  final String? error;

  OrderDetailsState({
    this.order,
    this.isLoading = false,
    this.error,
  });

  OrderDetailsState copyWith({
    OrderModel? order,
    bool? isLoading,
    String? error,
  }) {
    return OrderDetailsState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Order Details Notifier
class OrderDetailsNotifier extends StateNotifier<OrderDetailsState> {
  final OrderRepositoryImpl _repository;
  final int orderId;

  OrderDetailsNotifier(this._repository, this.orderId) 
      : super(OrderDetailsState()) {
    loadOrder();
  }

  Future<void> loadOrder() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final order = await _repository.getOrderById(orderId);
      state = state.copyWith(
        order: order,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadOrder();
  }
}

// Order Details Provider Factory
final orderDetailsProvider = StateNotifierProvider.family<
    OrderDetailsNotifier, OrderDetailsState, int>((ref, orderId) {
  return OrderDetailsNotifier(
    ref.watch(orderRepositoryProvider),
    orderId,
  );
});

// Active orders count provider
final activeOrdersCountProvider = Provider<int>((ref) {
  final ordersState = ref.watch(ordersProvider);
  return ordersState.activeOrdersCount;
});

// Order statistics provider
final orderStatisticsProvider = Provider<OrderStatistics?>((ref) {
  final ordersState = ref.watch(ordersProvider);
  return ordersState.statistics;
});
