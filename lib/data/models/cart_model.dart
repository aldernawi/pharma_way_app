import 'package:json_annotation/json_annotation.dart';
import 'product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => 
      _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get subtotal => product.price * quantity;
  
  bool get canIncrement => quantity < product.stockQuantity;
  bool get canDecrement => quantity > 1;
}

@JsonSerializable()
class Cart {
  final List<CartItem> items;

  Cart({this.items = const []});

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get isEmpty => items.isEmpty;
  
  bool get isNotEmpty => items.isNotEmpty;

  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }

  // Group items by company
  Map<int, List<CartItem>> get itemsByCompany {
    final Map<int, List<CartItem>> grouped = {};
    for (var item in items) {
      final companyId = item.product.pharmaceuticalCompanyId;
      if (!grouped.containsKey(companyId)) {
        grouped[companyId] = [];
      }
      grouped[companyId]!.add(item);
    }
    return grouped;
  }
}
