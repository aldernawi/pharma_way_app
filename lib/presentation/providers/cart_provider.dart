import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/cart_model.dart';
import '../../data/models/product_model.dart';

// Cart Notifier
class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(Cart()) {
    _loadCart();
  }

  // Load cart from local storage
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');
      if (cartJson != null) {
        final cartData = jsonDecode(cartJson);
        state = Cart.fromJson(cartData);
      }
    } catch (e) {
      // If error, start with empty cart
      state = Cart();
    }
  }

  // Save cart to local storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(state.toJson());
      await prefs.setString('cart', cartJson);
    } catch (e) {
      // Handle error silently
    }
  }

  // Add product to cart
  void addToCart(ProductModel product, {int quantity = 1}) {
    final items = List<CartItem>.from(state.items);
    
    // Check if product already in cart
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      // Update quantity
      final existingItem = items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      if (newQuantity <= product.stockQuantity) {
        items[existingIndex] = CartItem(
          product: product,
          quantity: newQuantity,
        );
      }
    } else {
      // Add new item
      if (quantity <= product.stockQuantity) {
        items.add(CartItem(product: product, quantity: quantity));
      }
    }
    
    state = Cart(items: items);
    _saveCart();
  }

  // Remove product from cart
  void removeFromCart(int productId) {
    final items = state.items.where((item) => item.product.id != productId).toList();
    state = Cart(items: items);
    _saveCart();
  }

  // Update quantity
  void updateQuantity(int productId, int quantity) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    
    if (index != -1) {
      if (quantity > 0 && quantity <= items[index].product.stockQuantity) {
        items[index] = CartItem(
          product: items[index].product,
          quantity: quantity,
        );
        state = Cart(items: items);
        _saveCart();
      }
    }
  }

  // Increment quantity
  void incrementQuantity(int productId) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    
    if (index != -1 && items[index].canIncrement) {
      items[index] = CartItem(
        product: items[index].product,
        quantity: items[index].quantity + 1,
      );
      state = Cart(items: items);
      _saveCart();
    }
  }

  // Decrement quantity
  void decrementQuantity(int productId) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    
    if (index != -1 && items[index].canDecrement) {
      items[index] = CartItem(
        product: items[index].product,
        quantity: items[index].quantity - 1,
      );
      state = Cart(items: items);
      _saveCart();
    }
  }

  // Clear cart
  void clearCart() {
    state = Cart();
    _saveCart();
  }

  // Check if product is in cart
  bool isInCart(int productId) {
    return state.items.any((item) => item.product.id == productId);
  }

  // Get quantity of product in cart
  int getQuantity(int productId) {
    final item = state.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: ProductModel(
        id: 0,
        name: '',
        nameAr: '',
        price: 0,
        stockQuantity: 0,
        pharmaceuticalCompanyId: 0,
        isActive: false,
      )),
    );
    return item.product.id != 0 ? item.quantity : 0;
  }
}

// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});
