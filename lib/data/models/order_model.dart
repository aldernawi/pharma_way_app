import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_converters.dart';
import 'product_model.dart';

part 'order_model.g.dart';

// Safe parser for OrderStatus - returns pending as fallback instead of throwing
OrderStatus _parseOrderStatus(dynamic value) {
  if (value == null) return OrderStatus.pending;
  const map = {
    'pending': OrderStatus.pending,
    'approved': OrderStatus.approved,
    'processing': OrderStatus.processing,
    'shipped': OrderStatus.shipped,
    'delivered': OrderStatus.delivered,
    'completed': OrderStatus.completed,
    'cancelled': OrderStatus.cancelled,
    'rejected': OrderStatus.rejected,
  };
  return map[value.toString()] ?? OrderStatus.pending;
}

// Order Status Enum
enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('processing')
  processing,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('rejected')
  rejected,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.approved:
        return 'تمت الموافقة';
      case OrderStatus.processing:
        return 'قيد التجهيز';
      case OrderStatus.shipped:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.rejected:
        return 'مرفوض';
    }
  }

  bool get canCancel {
    return this == OrderStatus.pending;
  }

  bool get isCompleted {
    return this == OrderStatus.delivered || this == OrderStatus.completed;
  }

  bool get isCancelled {
    return this == OrderStatus.cancelled || this == OrderStatus.rejected;
  }

  bool get isActive {
    return !isCompleted && !isCancelled;
  }
}

// Order Item Model
@JsonSerializable()
class OrderItem {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  @JsonKey(name: 'order_id', fromJson: JsonConverters.toInt)
  final int orderId;
  @JsonKey(name: 'product_id', fromJson: JsonConverters.toInt)
  final int productId;
  @JsonKey(fromJson: JsonConverters.toInt)
  final int quantity;
  @JsonKey(fromJson: JsonConverters.buildDouble)
  final double price;
  @JsonKey(fromJson: JsonConverters.buildDouble)
  final double subtotal;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  // Relationship
  final ProductModel? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.createdAt,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => 
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

// Order Model
@JsonSerializable()
class OrderModel {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  @JsonKey(name: 'pharmacy_id', fromJson: JsonConverters.toInt)
  final int pharmacyId;
  @JsonKey(name: 'pharmaceutical_company_id', fromJson: JsonConverters.toInt)
  final int pharmaceuticalCompanyId;
  @JsonKey(name: 'order_number')
  final String? orderNumber;
  @JsonKey(name: 'total_amount', fromJson: JsonConverters.buildDouble)
  final double? totalAmount;
  @JsonKey(fromJson: _parseOrderStatus)
  final OrderStatus status;
  final String? notes;
  @JsonKey(name: 'delivery_address')
  final String? deliveryAddress;
  @JsonKey(name: 'delivery_phone')
  final String? deliveryPhone;
  @JsonKey(name: 'approved_at')
  final String? approvedAt;
  @JsonKey(name: 'shipped_at')
  final String? shippedAt;
  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;
  @JsonKey(name: 'cancelled_at')
  final String? cancelledAt;
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // Relationships
  final PharmacyBasicInfo? pharmacy;
  final CompanyBasicInfo? company;
  final List<OrderItem>? items;

  OrderModel({
    required this.id,
    required this.pharmacyId,
    required this.pharmaceuticalCompanyId,
    this.orderNumber,
    this.totalAmount,
    required this.status,
    this.notes,
    this.deliveryAddress,
    this.deliveryPhone,
    this.approvedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.pharmacy,
    this.company,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => 
      _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  int get itemsCount => items?.length ?? 0;
  
  int get totalQuantity => items?.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0;

  bool get canCancel => status.canCancel;
  bool get isCompleted => status.isCompleted;
  bool get isCancelled => status.isCancelled;
  bool get isActive => status.isActive;
  bool get canMarkAsDelivered => status == OrderStatus.shipped;
  bool get canMarkAsCompleted => status == OrderStatus.delivered;
}

// Pharmacy Basic Info
@JsonSerializable()
class PharmacyBasicInfo {
  @JsonKey(fromJson: JsonConverters.toInt)
  final int id;
  @JsonKey(fromJson: JsonConverters.buildString)
  final String name;
  final String? address;
  final String? phone;

  PharmacyBasicInfo({
    required this.id,
    required this.name,
    this.address,
    this.phone,
  });

  factory PharmacyBasicInfo.fromJson(Map<String, dynamic> json) => 
      _$PharmacyBasicInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PharmacyBasicInfoToJson(this);
}

// Create Order Request
@JsonSerializable()
class CreateOrderRequest {
  @JsonKey(name: 'pharmaceutical_company_id')
  final int pharmaceuticalCompanyId;
  final String? notes;
  @JsonKey(name: 'delivery_address')
  final String? deliveryAddress;
  @JsonKey(name: 'delivery_phone')
  final String? deliveryPhone;
  final List<CreateOrderItem> items;

  CreateOrderRequest({
    required this.pharmaceuticalCompanyId,
    this.notes,
    this.deliveryAddress,
    this.deliveryPhone,
    required this.items,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

@JsonSerializable()
class CreateOrderItem {
  @JsonKey(name: 'product_id')
  final int productId;
  final int quantity;
  final double price;

  CreateOrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory CreateOrderItem.fromJson(Map<String, dynamic> json) => 
      _$CreateOrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderItemToJson(this);
}

// Order Response
@JsonSerializable()
class OrderResponse {
  final bool success;
  final String? message;
  final OrderModel data;

  OrderResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => 
      _$OrderResponseFromJson(json);
}

// Orders List Response
@JsonSerializable()
class OrdersListResponse {
  final bool success;
  final String? message;
  final List<OrderModel> data;

  OrdersListResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory OrdersListResponse.fromJson(Map<String, dynamic> json) => 
      _$OrdersListResponseFromJson(json);
}

// Cancel Order Request
@JsonSerializable()
class CancelOrderRequest {
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;

  CancelOrderRequest({
    this.cancellationReason,
  });

  factory CancelOrderRequest.fromJson(Map<String, dynamic> json) => 
      _$CancelOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CancelOrderRequestToJson(this);
}
