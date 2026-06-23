import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final int orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderDetailsProvider(orderId));

    if (orderState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (orderState.error != null || orderState.order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ في تحميل الطلب',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('رجوع'),
              ),
            ],
          ),
        ),
      );
    }

    final order = orderState.order!;

    return Scaffold(
      appBar: AppBar(
        title: Text('طلب #${order.orderNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share(
                'طلب #${order.orderNumber}\n'
                'المبلغ: ${order.totalAmount?.toStringAsFixed(2) ?? '0.00'} د.ل\n'
                'الحالة: ${order.status.displayName}',
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(orderDetailsProvider(orderId).notifier).refresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(context, order),
              const SizedBox(height: 16),
              
              // Company Info
              _buildCompanyCard(context, order),
              const SizedBox(height: 16),
              
              // Order Items
              _buildItemsSection(context, order),
              const SizedBox(height: 16),
              
              // Delivery Info
              if (order.deliveryAddress != null || order.deliveryPhone != null)
                _buildDeliveryCard(context, order),
              
              // Notes
              if (order.notes != null) ...[
                const SizedBox(height: 16),
                _buildNotesCard(context, order),
              ],
              
              const SizedBox(height: 16),
              
              // Summary
              _buildSummaryCard(context, order),
              
              // Actions
              if (order.canCancel) ...[
                const SizedBox(height: 16),
                _buildCancelButton(context, ref, order),
              ],
              
              // Mark as Delivered button for shipped orders
              if (order.canMarkAsDelivered) ...[
                const SizedBox(height: 16),
                _buildMarkDeliveredButton(context, ref, order),
              ],
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, OrderModel order) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (order.status) {
      case OrderStatus.pending:
        backgroundColor = AppColors.warning.withValues(alpha:0.1);
        textColor = AppColors.warning;
        icon = Icons.schedule;
        break;
      case OrderStatus.approved:
        backgroundColor = AppColors.info.withValues(alpha:0.1);
        textColor = AppColors.info;
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.completed:
        backgroundColor = AppColors.statusCompleted.withValues(alpha:0.1);
        textColor = AppColors.statusCompleted;
        icon = Icons.verified;
        break;
      case OrderStatus.processing:
        backgroundColor = AppColors.primary.withValues(alpha:0.1);
        textColor = AppColors.primary;
        icon = Icons.inventory_2_outlined;
        break;
      case OrderStatus.shipped:
        backgroundColor = AppColors.secondary.withValues(alpha:0.1);
        textColor = AppColors.secondary;
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        backgroundColor = AppColors.success.withValues(alpha:0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        backgroundColor = AppColors.error.withValues(alpha:0.1);
        textColor = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: textColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
              Text(
                _formatDate(order.createdAt ?? ''),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withValues(alpha:0.7),
                    ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context, OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الشركة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (order.company != null) ...[
              Row(
                children: [
                  const Icon(Icons.business, size: 20, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.company!.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المنتجات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (order.items != null && order.items!.isNotEmpty)
              ...order.items!.map((item) => _buildOrderItem(context, item))
            else
              Text(
                'لا توجد منتجات',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.displayName ?? 'منتج',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} × ${item.price.toStringAsFixed(2)} د.ل',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
              '${item.subtotal.toStringAsFixed(2)} د.ل',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات التوصيل',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (order.deliveryAddress != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.deliveryAddress!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (order.deliveryPhone != null)
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 20, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Text(
                    order.deliveryPhone!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملاحظات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              order.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, OrderModel order) {
    return Card(
      color: AppColors.primaryLighter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عدد المنتجات',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${order.itemsCount}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي القطع',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${order.totalQuantity}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${order.totalAmount?.toStringAsFixed(2) ?? '0.00'} د.ل',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref, OrderModel order) {
    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _CancelOrderDialog(
            orderId: order.id,
            orderNumber: order.orderNumber,
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined),
            SizedBox(width: 8),
            Text('إلغاء الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkDeliveredButton(BuildContext context, WidgetRef ref, OrderModel order) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _MarkDeliveredDialog(
            orderId: order.id,
            orderNumber: order.orderNumber,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline),
            SizedBox(width: 8),
            Text('تأكيد استلام الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy - hh:mm a', 'ar').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

// Mark Delivered Dialog
class _MarkDeliveredDialog extends ConsumerWidget {
  final int orderId;
  final String? orderNumber;

  const _MarkDeliveredDialog({
    required this.orderId,
    this.orderNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('تأكيد استلام الطلب'),
      content: Text('هل أنت متأكد من استلام الطلب #${orderNumber ?? orderId}؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await ref.read(ordersProvider.notifier).markAsDelivered(orderId);
            
            if (success && context.mounted) {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تأكيد استلام الطلب بنجاح')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
          ),
          child: const Text('تأكيد الاستلام'),
        ),
      ],
    );
  }
}

// Cancel Order Dialog
class _CancelOrderDialog extends ConsumerStatefulWidget {
  final int orderId;
  final String? orderNumber;

  const _CancelOrderDialog({
    required this.orderId,
    this.orderNumber,
  });

  @override
  ConsumerState<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends ConsumerState<_CancelOrderDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إلغاء الطلب'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('هل أنت متأكد من إلغاء الطلب #${widget.orderNumber}؟'),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'سبب الإلغاء (اختياري)',
              hintText: 'اكتب سبب الإلغاء...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await ref.read(ordersProvider.notifier).cancelOrder(
                  widget.orderId,
                  reason: _reasonController.text.trim().isEmpty
                      ? null
                      : _reasonController.text.trim(),
                );
            
            if (success && context.mounted) {
              // Close the dialog
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء الطلبية بنجاح'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              
              // Go back to orders screen
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('تأكيد الإلغاء'),
        ),
      ],
    );
  }
}
