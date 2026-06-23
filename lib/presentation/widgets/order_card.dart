import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.approved:
        return AppColors.statusApproved;
      case OrderStatus.processing:
        return AppColors.statusProcessing;
      case OrderStatus.shipped:
        return AppColors.statusShipped;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
      case OrderStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.approved:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.inventory_2_outlined;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.completed:
        return Icons.verified;
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status indicator + Order number + Badge
              Row(
                children: [
                  // Status color dot
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(AppColors.radiusSm),
                    ),
                    child: Icon(_statusIcon, size: 20, color: _statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب #${order.orderNumber ?? order.id}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (order.company != null)
                          Text(
                            order.company!.name,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              // Divider
              Container(
                height: 1,
                color: AppColors.divider,
              ),
              const SizedBox(height: 12),
              // Bottom row: date + items + total
              Row(
                children: [
                  // Date
                  Icon(Icons.calendar_today, size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt ?? ''),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                  const SizedBox(width: 16),
                  // Items count
                  Icon(Icons.shopping_bag_outlined, size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${order.itemsCount} منتج',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                  const Spacer(),
                  // Total
                  Text(
                    '${order.totalAmount?.toStringAsFixed(2) ?? '0.00'} د.ل',
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
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
      ),
      child: Text(
        order.status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _statusColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy', 'ar').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
