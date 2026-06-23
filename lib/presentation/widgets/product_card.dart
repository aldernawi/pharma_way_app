import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final bool showQuickAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showQuickAdd = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider).items;
    final cartItem = cartItems.where((item) => item.product.id == product.id).firstOrNull;
    final quantityInCart = cartItem?.quantity ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrlFull,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primaryLighter,
                      child: const Icon(
                        Icons.medication,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  // Stock badge
                  if (!product.isInStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppColors.radiusSm),
                        ),
                        child: Text(
                          'نفذ من المخزون',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    )
                  else if (product.isLowStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(AppColors.radiusSm),
                        ),
                        child: Text(
                          'كمية محدودة',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product name
                    Flexible(
                      child: Text(
                        product.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (product.company != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          product.company!.name,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Price and Add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price
                        Flexible(
                          child: Text(
                            '${product.price.toStringAsFixed(2)} د.ل',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Quick add / quantity counter
                        if (showQuickAdd && product.isInStock)
                          quantityInCart == 0
                            ? _buildAddButton(context, ref)
                            : _buildQuantityCounter(context, ref, quantityInCart),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppColors.radiusSm),
          onTap: () {
            ref.read(cartProvider.notifier).addToCart(product);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تمت إضافة ${product.displayName} للسلة'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: const Icon(Icons.add, size: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildQuantityCounter(BuildContext context, WidgetRef ref, int quantity) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease / Remove
          SizedBox(
            width: 32,
            height: 36,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(AppColors.radiusSm)),
                onTap: () {
                  if (quantity > 1) {
                    ref.read(cartProvider.notifier).decrementQuantity(product.id);
                  } else {
                    ref.read(cartProvider.notifier).removeFromCart(product.id);
                  }
                },
                child: Icon(
                  quantity > 1 ? Icons.remove : Icons.delete_outline,
                  size: 16,
                  color: quantity > 1 ? AppColors.primary : AppColors.error,
                ),
              ),
            ),
          ),
          // Quantity
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // Increase
          SizedBox(
            width: 32,
            height: 36,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(AppColors.radiusSm)),
                onTap: () {
                  if (quantity < product.stockQuantity) {
                    ref.read(cartProvider.notifier).incrementQuantity(product.id);
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم الوصول للحد الأقصى من المخزون'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.add, size: 16, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
