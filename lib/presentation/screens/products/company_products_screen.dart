import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/company_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../products/product_details_screen.dart';

class CompanyProductsScreen extends ConsumerWidget {
  final CompanyModel company;

  const CompanyProductsScreen({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(companyProductsProvider(company.id));
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(company.name),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersBottomSheet(context, ref),
          ),
          // Cart icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ في تحميل المنتجات',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(companyProductsProvider(company.id).notifier).loadProducts();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Active filters indicator
                    if (_hasActiveFilters(productsState))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: AppColors.primaryLighter,
                        child: Row(
                          children: [
                            const Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getActiveFiltersText(productsState),
                                style: const TextStyle(fontSize: 12, color: AppColors.primary),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(companyProductsProvider(company.id).notifier).clearFilter();
                              },
                              child: const Text('إزالة الكل', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    // Brand Filters (Quick Access)
                    if (productsState.availableBrands.isNotEmpty)
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          border: Border(
                            bottom: BorderSide(color: AppColors.divider),
                          ),
                        ),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            // All button
                            _buildFilterChip(
                              context,
                              ref,
                              'الكل',
                              productsState.selectedBrandId == null,
                              () {
                                ref.read(companyProductsProvider(company.id).notifier).clearFilter();
                              },
                            ),
                            const SizedBox(width: 8),
                            // Brand filters
                            ...productsState.availableBrands.map((brand) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _buildFilterChip(
                                  context,
                                  ref,
                                  brand.nameAr ?? brand.name,
                                  productsState.selectedBrandId == brand.id,
                                  () {
                                    ref.read(companyProductsProvider(company.id).notifier)
                                        .filterByBrand(brand.id);
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    // Products Grid
                    Expanded(
                      child: productsState.products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد منتجات',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: productsState.products.length,
                              itemBuilder: (context, index) {
                                final product = productsState.products[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailsScreen(
                                          productId: product.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  bool _hasActiveFilters(CompanyProductsState state) {
    return state.hasActiveFilters;
  }

  String _getActiveFiltersText(CompanyProductsState state) {
    final filters = <String>[];
    if (state.selectedBrandId != null) filters.add('البراند');
    if (state.selectedCategoryId != null) filters.add('الفئة');
    if (state.minPrice != null || state.maxPrice != null) filters.add('السعر');
    if (state.sortBy != 'created_at') filters.add('الترتيب');
    return 'الفلاتر النشطة: ${filters.join(', ')}';
  }

  void _showFiltersBottomSheet(BuildContext context, WidgetRef ref) {
    final state = ref.read(companyProductsProvider(company.id));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FiltersBottomSheet(
        companyId: company.id,
        currentState: state,
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

// Filters Bottom Sheet
class _FiltersBottomSheet extends ConsumerStatefulWidget {
  final int companyId;
  final CompanyProductsState currentState;

  const _FiltersBottomSheet({
    required this.companyId,
    required this.currentState,
  });

  @override
  ConsumerState<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<_FiltersBottomSheet> {
  late int? selectedBrandId;
  late int? selectedCategoryId;
  late TextEditingController minPriceController;
  late TextEditingController maxPriceController;
  late String sortBy;
  late String sortOrder;

  @override
  void initState() {
    super.initState();
    selectedBrandId = widget.currentState.selectedBrandId;
    selectedCategoryId = widget.currentState.selectedCategoryId;
    minPriceController = TextEditingController(
      text: widget.currentState.minPrice?.toString() ?? '',
    );
    maxPriceController = TextEditingController(
      text: widget.currentState.maxPrice?.toString() ?? '',
    );
    sortBy = widget.currentState.sortBy;
    sortOrder = widget.currentState.sortOrder;
  }

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.currentState;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الفلاتر',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Brand filter
                    if (state.availableBrands.isNotEmpty) ...[
                      Text('البراند', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('الكل', style: TextStyle(color: AppColors.textPrimary)),
                            selected: selectedBrandId == null,
                            onSelected: (selected) {
                              setState(() => selectedBrandId = null);
                            },
                          ),
                          ...state.availableBrands.map((brand) {
                            return ChoiceChip(
                              label: Text(brand.nameAr ?? brand.name, style: const TextStyle(color: AppColors.textPrimary)),
                              selected: selectedBrandId == brand.id,
                              onSelected: (selected) {
                                setState(() => selectedBrandId = selected ? brand.id : null);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Category filter
                    if (state.availableCategories.isNotEmpty) ...[
                      Text('الفئة', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('الكل', style: TextStyle(color: AppColors.textPrimary)),
                            selected: selectedCategoryId == null,
                            onSelected: (selected) {
                              setState(() => selectedCategoryId = null);
                            },
                          ),
                          ...state.availableCategories.map((category) {
                            return ChoiceChip(
                              label: Text(category.displayNameOrDefault, style: const TextStyle(color: AppColors.textPrimary)),
                              selected: selectedCategoryId == category.id,
                              onSelected: (selected) {
                                setState(() => selectedCategoryId = selected ? category.id : null);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Price range
                    Text('نطاق السعر', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minPriceController,
                            decoration: const InputDecoration(
                              labelText: 'من',
                              border: OutlineInputBorder(),
                              suffixText: 'ر.س',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: maxPriceController,
                            decoration: const InputDecoration(
                              labelText: 'إلى',
                              border: OutlineInputBorder(),
                              suffixText: 'ر.س',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Sort options
                    Text('الترتيب', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: sortBy,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ترتيب حسب',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      items: const [
                        DropdownMenuItem(value: 'created_at', child: Text('الأحدث', style: TextStyle(color: AppColors.textPrimary))),
                        DropdownMenuItem(value: 'price', child: Text('السعر', style: TextStyle(color: AppColors.textPrimary))),
                        DropdownMenuItem(value: 'name', child: Text('الاسم', style: TextStyle(color: AppColors.textPrimary))),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => sortBy = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: sortOrder,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'الاتجاه',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      items: const [
                        DropdownMenuItem(value: 'asc', child: Text('تصاعدي', style: TextStyle(color: AppColors.textPrimary))),
                        DropdownMenuItem(value: 'desc', child: Text('تنازلي', style: TextStyle(color: AppColors.textPrimary))),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => sortOrder = value);
                      },
                    ),
                  ],
                ),
              ),
              // Apply & Reset buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(companyProductsProvider(widget.companyId).notifier).clearFilter();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('إعادة تعيين'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final minP = minPriceController.text.isEmpty ? null : double.tryParse(minPriceController.text);
                        final maxP = maxPriceController.text.isEmpty ? null : double.tryParse(maxPriceController.text);

                        ref.read(companyProductsProvider(widget.companyId).notifier).applyAllFilters(
                          brandId: selectedBrandId,
                          categoryId: selectedCategoryId,
                          minPrice: minP,
                          maxPrice: maxP,
                          sortBy: sortBy,
                          sortOrder: sortOrder,
                          clearBrand: selectedBrandId == null,
                          clearCategory: selectedCategoryId == null,
                          clearPrice: minP == null && maxP == null,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('تطبيق الفلاتر'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
