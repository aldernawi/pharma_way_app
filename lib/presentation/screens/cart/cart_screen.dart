import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/cart_model.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('سلة التسوق (${cart.totalItems})'),
        actions: [
          if (cart.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تفريغ السلة'),
                    content: const Text('هل أنت متأكد من تفريغ السلة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('تفريغ'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('تفريغ'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: _buildGroupedItems(context, ref, cart),
                  ),
                ),
                _buildStickyCheckout(context, ref, cart),
              ],
            ),
    );
  }

  List<Widget> _buildGroupedItems(BuildContext context, WidgetRef ref, cart) {
    final itemsByCompany = cart.itemsByCompany;
    final List<Widget> widgets = [];

    for (final entry in itemsByCompany.entries) {
      final companyId = entry.key;
      final items = entry.value;
      final companyName = items.first.product.company?.name ?? 'شركة #$companyId';

      // Company header
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(AppColors.radiusSm),
          ),
          child: Row(
            children: [
              const Icon(Icons.business, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  companyName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                '${items.length} منتج',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),
      );

      // Items for this company
      for (final item in items) {
        widgets.add(_buildCartItem(context, ref, item));
      }
    }

    return widgets;
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'السلة فارغة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة المنتجات للسلة',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('تصفح المنتجات'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, item) {
    final product = item.product;

    return Slidable(
      key: ValueKey(product.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              ref.read(cartProvider.notifier).removeFromCart(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف ${product.displayName} من السلة')),
              );
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'حذف',
            borderRadius: BorderRadius.circular(AppColors.radiusLg),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrlFull,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.surfaceVariant,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.primaryLighter,
                    child: const Icon(Icons.medication, color: AppColors.primary, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(2)} د.ل',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Quantity stepper
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(AppColors.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStepperButton(
                                icon: Icons.remove,
                                onPressed: item.canDecrement
                                    ? () => ref.read(cartProvider.notifier).decrementQuantity(product.id)
                                    : null,
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 36),
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.quantity}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              _buildStepperButton(
                                icon: Icons.add,
                                onPressed: item.canIncrement
                                    ? () => ref.read(cartProvider.notifier).incrementQuantity(product.id)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        // Subtotal
                        Text(
                          '${item.subtotal.toStringAsFixed(2)} د.ل',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, VoidCallback? onPressed}) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: onPressed != null ? AppColors.primary : AppColors.textDisabled,
      ),
    );
  }

  Widget _buildStickyCheckout(BuildContext context, WidgetRef ref, cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppColors.radiusLg)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    '${cart.total.toStringAsFixed(2)} د.ل',
                    key: ValueKey(cart.total),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _CheckoutSheet(cart: cart),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusLg),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text(
                          'إتمام الطلب',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
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
}

// Checkout Bottom Sheet (replaces dialog for better UX)
class _CheckoutSheet extends ConsumerStatefulWidget {
  final Cart cart;

  const _CheckoutSheet({required this.cart});

  @override
  ConsumerState<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<_CheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user?.pharmacy != null) {
      _addressController.text = user!.pharmacy!.address;
      _phoneController.text = user.pharmacy!.phone;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companiesCount = widget.cart.itemsByCompany.length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppColors.radiusLg)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _isSuccess ? _buildSuccessState(context) : Form(key: _formKey, child: _buildFormState(context, companiesCount)),
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 48, color: AppColors.success),
        ),
        const SizedBox(height: 20),
        Text(
          'تم إنشاء الطلبات بنجاح!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'يمكنك متابعة حالة طلباتك من صفحة الطلبات',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/orders');
            },
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('عرض الطلبات'),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFormState(BuildContext context, int companiesCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'إتمام الطلب',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('عدد المنتجات:', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '${widget.cart.totalItems}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الإجمالي:', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '${widget.cart.total.toStringAsFixed(2)} د.ل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'سيتم إنشاء $companiesCount ${companiesCount == 1 ? "طلب" : "طلبات"} (طلب لكل شركة)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        // Delivery Address
        TextField(
          controller: _addressController,
          enabled: !_isProcessing,
          decoration: const InputDecoration(
            labelText: 'عنوان التوصيل',
            hintText: 'أدخل عنوان التوصيل',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        // Phone
        TextFormField(
          controller: _phoneController,
          enabled: !_isProcessing,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف *',
            hintText: '09XXXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'رقم الهاتف مطلوب';
            }
            final phone = value.trim();
            if (phone.length != 10) {
              return 'رقم الهاتف يجب أن يكون 10 أرقام';
            }
            final validPrefixes = ['091', '092', '093', '094'];
            final hasValidPrefix = validPrefixes.any((p) => phone.startsWith(p));
            if (!hasValidPrefix) {
              return 'يجب أن يبدأ الرقم بـ 091 أو 092 أو 093 أو 094';
            }
            if (!RegExp(r'^\d+$').hasMatch(phone)) {
              return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Notes
        TextField(
          controller: _notesController,
          enabled: !_isProcessing,
          decoration: const InputDecoration(
            labelText: 'ملاحظات (اختياري)',
            hintText: 'أضف ملاحظات للطلب',
            prefixIcon: Icon(Icons.note_outlined),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        // Actions
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('إلغاء'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'تأكيد الطلب',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleCheckout() async {
    if (_isProcessing) return; // Prevent double submit

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final success = await ref.read(ordersProvider.notifier).createOrdersFromCart(
          widget.cart,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          deliveryAddress: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          deliveryPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );

    if (mounted) {
      if (success) {
        // Clear cart only after confirmed success
        ref.read(cartProvider.notifier).clearCart();
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
        });
      } else {
        setState(() => _isProcessing = false);
        final error = ref.read(ordersProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'حدث خطأ في إنشاء الطلبات'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
