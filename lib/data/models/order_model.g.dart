// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: JsonConverters.toInt(json['id']),
  orderId: JsonConverters.toInt(json['order_id']),
  productId: JsonConverters.toInt(json['product_id']),
  quantity: JsonConverters.toInt(json['quantity']),
  price: JsonConverters.buildDouble(json['price']),
  subtotal: JsonConverters.buildDouble(json['subtotal']),
  createdAt: json['created_at'] as String?,
  product: json['product'] == null
      ? null
      : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'product_id': instance.productId,
  'quantity': instance.quantity,
  'price': instance.price,
  'subtotal': instance.subtotal,
  'created_at': instance.createdAt,
  'product': instance.product,
};

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: JsonConverters.toInt(json['id']),
  pharmacyId: JsonConverters.toInt(json['pharmacy_id']),
  pharmaceuticalCompanyId: JsonConverters.toInt(
    json['pharmaceutical_company_id'],
  ),
  orderNumber: json['order_number'] as String?,
  totalAmount: JsonConverters.buildDouble(json['total_amount']),
  status: _parseOrderStatus(json['status']),
  notes: json['notes'] as String?,
  deliveryAddress: json['delivery_address'] as String?,
  deliveryPhone: json['delivery_phone'] as String?,
  approvedAt: json['approved_at'] as String?,
  shippedAt: json['shipped_at'] as String?,
  deliveredAt: json['delivered_at'] as String?,
  cancelledAt: json['cancelled_at'] as String?,
  cancellationReason: json['cancellation_reason'] as String?,
  completedAt: json['completed_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  pharmacy: json['pharmacy'] == null
      ? null
      : PharmacyBasicInfo.fromJson(json['pharmacy'] as Map<String, dynamic>),
  company: json['company'] == null
      ? null
      : CompanyBasicInfo.fromJson(json['company'] as Map<String, dynamic>),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pharmacy_id': instance.pharmacyId,
      'pharmaceutical_company_id': instance.pharmaceuticalCompanyId,
      'order_number': instance.orderNumber,
      'total_amount': instance.totalAmount,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'delivery_address': instance.deliveryAddress,
      'delivery_phone': instance.deliveryPhone,
      'approved_at': instance.approvedAt,
      'shipped_at': instance.shippedAt,
      'delivered_at': instance.deliveredAt,
      'cancelled_at': instance.cancelledAt,
      'cancellation_reason': instance.cancellationReason,
      'completed_at': instance.completedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'pharmacy': instance.pharmacy,
      'company': instance.company,
      'items': instance.items,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.approved: 'approved',
  OrderStatus.processing: 'processing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.rejected: 'rejected',
};

PharmacyBasicInfo _$PharmacyBasicInfoFromJson(Map<String, dynamic> json) =>
    PharmacyBasicInfo(
      id: JsonConverters.toInt(json['id']),
      name: JsonConverters.buildString(json['name']),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$PharmacyBasicInfoToJson(PharmacyBasicInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
    };

CreateOrderRequest _$CreateOrderRequestFromJson(Map<String, dynamic> json) =>
    CreateOrderRequest(
      pharmaceuticalCompanyId: (json['pharmaceutical_company_id'] as num)
          .toInt(),
      notes: json['notes'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      deliveryPhone: json['delivery_phone'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => CreateOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateOrderRequestToJson(CreateOrderRequest instance) =>
    <String, dynamic>{
      'pharmaceutical_company_id': instance.pharmaceuticalCompanyId,
      'notes': instance.notes,
      'delivery_address': instance.deliveryAddress,
      'delivery_phone': instance.deliveryPhone,
      'items': instance.items,
    };

CreateOrderItem _$CreateOrderItemFromJson(Map<String, dynamic> json) =>
    CreateOrderItem(
      productId: (json['product_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateOrderItemToJson(CreateOrderItem instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'price': instance.price,
    };

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: OrderModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

OrdersListResponse _$OrdersListResponseFromJson(Map<String, dynamic> json) =>
    OrdersListResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrdersListResponseToJson(OrdersListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

CancelOrderRequest _$CancelOrderRequestFromJson(Map<String, dynamic> json) =>
    CancelOrderRequest(
      cancellationReason: json['cancellation_reason'] as String?,
    );

Map<String, dynamic> _$CancelOrderRequestToJson(CancelOrderRequest instance) =>
    <String, dynamic>{'cancellation_reason': instance.cancellationReason};
