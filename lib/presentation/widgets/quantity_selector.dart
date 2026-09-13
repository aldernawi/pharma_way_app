import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int stockQuantity;
  final TextEditingController quantityController;
  final ValueChanged<int> onQuantityChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.stockQuantity,
    required this.quantityController,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'الكمية',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuantityButton(context, Icons.remove, quantity > 1, () {
                if (quantity > 1) {
                  onQuantityChanged(quantity - 1);
                }
              }),
              Container(
                width: 80,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: IconButton(
                      tooltip: 'تأكيد الكمية',
                      icon: const Icon(Icons.check, color: AppColors.primary),
                      onPressed: () => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  onChanged: (value) {
                    final newQuantity = int.tryParse(value);
                    if (newQuantity != null &&
                        newQuantity > 0 &&
                        newQuantity <= stockQuantity) {
                      onQuantityChanged(newQuantity);
                    } else if (newQuantity != null &&
                        newQuantity > stockQuantity) {
                      onQuantityChanged(stockQuantity);
                      quantityController.text = stockQuantity.toString();
                      quantityController.selection = TextSelection.fromPosition(
                        TextPosition(offset: quantityController.text.length),
                      );
                    }
                  },
                  onSubmitted: (value) {
                    final newQuantity = int.tryParse(value);
                    if (newQuantity == null || newQuantity < 1) {
                      onQuantityChanged(1);
                      quantityController.text = '1';
                    } else if (newQuantity > stockQuantity) {
                      onQuantityChanged(stockQuantity);
                      quantityController.text = stockQuantity.toString();
                    }
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              _buildQuantityButton(
                context,
                Icons.add,
                quantity < stockQuantity,
                () {
                  if (quantity < stockQuantity) {
                    onQuantityChanged(quantity + 1);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: enabled ? null : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: enabled ? Colors.white : AppColors.textTertiary,
          size: 20,
        ),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
