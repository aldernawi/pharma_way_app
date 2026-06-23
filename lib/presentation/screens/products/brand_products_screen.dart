import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/brand_model.dart';
import '../../../data/models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import 'product_details_screen.dart';
import '../../../data/repositories/product_repository_impl.dart';

// Enhanced Brand Products State
class BrandProductsState {
  final List<ProductModel> products;
  final List<CategoryBasicInfo> availableCategories;
  final List<CompanyBasicInfo> availableCompanies;
  final int? selectedCategoryId;
  final int? selectedCompanyId;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final String sortOrder;
  final bool isLoading;
  final String? error;

  BrandProductsState({
    this.products = const [],
    this.availableCategories = const [],
    this.availableCompanies = const [],
    this.selectedCategoryId,
    this.selectedCompanyId,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.isLoading = false,
    this.error,
  });

  BrandProductsState copyWith({
    List<ProductModel>? products,
    List<CategoryBasicInfo>? availableCategories,
    List<CompanyBasicInfo>? availableCompanies,
    int? selectedCategoryId,
    int? selectedCompanyId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    bool? isLoading,
    String? error,
    bool clearCategoryFilter = false,
    bool clearCompanyFilter = false,
    bool clearPriceFilter = false,
  }) {
    return BrandProductsState(
      products: products ?? this.products,
      availableCategories: availableCategories ?? this.availableCategories,
      availableCompanies: availableCompanies ?? this.availableCompanies,
      selectedCategoryId: clearCategoryFilter ? null : (selectedCategoryId ?? this.selectedCategoryId),
      selectedCompanyId: clearCompanyFilter ? null : (selectedCompanyId ?? this.selectedCompanyId),
      minPrice: clearPriceFilter ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceFilter ? null : (maxPrice ?? this.maxPrice),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Brand Products Notifier
class BrandProductsNotifier extends StateNotifier<BrandProductsState> {
  final ProductRepositoryImpl _repository;
  final int brandId;

  BrandProductsNotifier(this._repository, this.brandId) : super(BrandProductsState()) {
    loadProducts();
  }

  bool _initialLoaded = false;

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _repository.getProductsByBrand(
        brandId,
        categoryId: state.selectedCategoryId,
        companyId: state.selectedCompanyId,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sortBy: state.sortBy,
        sortOrder: state.sortOrder,
      );

      // Only populate available categories/companies on initial (unfiltered) load
      if (!_initialLoaded) {
        final categoriesMap = <int, CategoryBasicInfo>{};
        final companiesMap = <int, CompanyBasicInfo>{};
        for (final p in products) {
          if (p.category != null) categoriesMap[p.category!.id] = p.category!;
          if (p.company != null) companiesMap[p.company!.id] = p.company!;
        }

        _initialLoaded = true;
        state = state.copyWith(
          products: products,
          availableCategories: categoriesMap.values.toList(),
          availableCompanies: companiesMap.values.toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          products: products,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void filterByCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategoryFilter: categoryId == null,
    );
    loadProducts();
  }

  void filterByCompany(int? companyId) {
    state = state.copyWith(
      selectedCompanyId: companyId,
      clearCompanyFilter: companyId == null,
    );
    loadProducts();
  }

  void applyAllFilters({
    int? categoryId,
    int? companyId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      selectedCompanyId: companyId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy ?? state.sortBy,
      sortOrder: sortOrder ?? state.sortOrder,
      clearCategoryFilter: categoryId == null,
      clearCompanyFilter: companyId == null,
      clearPriceFilter: minPrice == null && maxPrice == null,
    );
    loadProducts();
  }

  void clearAllFilters() {
    state = state.copyWith(
      clearCategoryFilter: true,
      clearCompanyFilter: true,
      clearPriceFilter: true,
      sortBy: 'created_at',
      sortOrder: 'desc',
    );
    loadProducts();
  }
}

// Provider for brand products
final brandProductsProvider = StateNotifierProvider.family<BrandProductsNotifier, BrandProductsState, int>((ref, brandId) {
  return BrandProductsNotifier(ref.read(productRepositoryProvider), brandId);
});

class BrandProductsScreen extends ConsumerWidget {
  final BrandModel brand;

  const BrandProductsScreen({
    super.key,
    required this.brand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(brandProductsProvider(brand.id));
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(brand.displayNameOrDefault),
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
                          ref.read(brandProductsProvider(brand.id).notifier).loadProducts();
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
                                ref.read(brandProductsProvider(brand.id).notifier).clearAllFilters();
                              },
                              child: const Text('إزالة الكل', style: TextStyle(fontSize: 12)),
                            ),
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
                                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد منتجات',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لا توجد منتجات متاحة لهذه الماركة حالياً',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
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
                                        builder: (context) => ProductDetailsScreen(productId: product.id),
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

  bool _hasActiveFilters(BrandProductsState state) {
    return state.selectedCategoryId != null ||
        state.selectedCompanyId != null ||
        state.minPrice != null ||
        state.maxPrice != null ||
        state.sortBy != 'created_at' ||
        state.sortOrder != 'desc';
  }

  String _getActiveFiltersText(BrandProductsState state) {
    final filters = <String>[];
    if (state.selectedCategoryId != null) filters.add('الفئة');
    if (state.selectedCompanyId != null) filters.add('الشركة');
    if (state.minPrice != null || state.maxPrice != null) filters.add('السعر');
    if (state.sortBy != 'created_at') filters.add('الترتيب');
    return 'الفلاتر النشطة: ${filters.join(', ')}';
  }

  void _showFiltersBottomSheet(BuildContext context, WidgetRef ref) {
    final state = ref.read(brandProductsProvider(brand.id));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FiltersBottomSheet(
        brandId: brand.id,
        currentState: state,
      ),
    );
  }
}

// Filters Bottom Sheet
class _FiltersBottomSheet extends ConsumerStatefulWidget {
  final int brandId;
  final BrandProductsState currentState;

  const _FiltersBottomSheet({
    required this.brandId,
    required this.currentState,
  });

  @override
  ConsumerState<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<_FiltersBottomSheet> {
  late int? selectedCategoryId;
  late int? selectedCompanyId;
  late TextEditingController minPriceController;
  late TextEditingController maxPriceController;
  late String sortBy;
  late String sortOrder;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.currentState.selectedCategoryId;
    selectedCompanyId = widget.currentState.selectedCompanyId;
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
                    style: Theme.of(context).textTheme.titleLarge,
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
                    // Category filter
                    if (state.availableCategories.isNotEmpty) ...[
                      Text('الفئة', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('الكل'),
                            selected: selectedCategoryId == null,
                            onSelected: (selected) {
                              setState(() => selectedCategoryId = null);
                            },
                          ),
                          ...state.availableCategories.map((category) {
                            return ChoiceChip(
                              label: Text(category.displayNameOrDefault),
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
                    // Company filter
                    if (state.availableCompanies.isNotEmpty) ...[
                      Text('الشركة', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('الكل'),
                            selected: selectedCompanyId == null,
                            onSelected: (selected) {
                              setState(() => selectedCompanyId = null);
                            },
                          ),
                          ...state.availableCompanies.map((company) {
                            return ChoiceChip(
                              label: Text(company.name),
                              selected: selectedCompanyId == company.id,
                              onSelected: (selected) {
                                setState(() => selectedCompanyId = selected ? company.id : null);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Price range
                    Text('نطاق السعر', style: Theme.of(context).textTheme.titleMedium),
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
                    Text('الترتيب', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: sortBy,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ترتيب حسب',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'created_at', child: Text('الأحدث')),
                        DropdownMenuItem(value: 'price', child: Text('السعر')),
                        DropdownMenuItem(value: 'name', child: Text('الاسم')),
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
                      items: const [
                        DropdownMenuItem(value: 'asc', child: Text('تصاعدي')),
                        DropdownMenuItem(value: 'desc', child: Text('تنازلي')),
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
                        ref.read(brandProductsProvider(widget.brandId).notifier).clearAllFilters();
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
                        final notifier = ref.read(brandProductsProvider(widget.brandId).notifier);
                        final minP = minPriceController.text.isEmpty ? null : double.tryParse(minPriceController.text);
                        final maxP = maxPriceController.text.isEmpty ? null : double.tryParse(maxPriceController.text);

                        // Apply all filters in a single call
                        notifier.applyAllFilters(
                          categoryId: selectedCategoryId,
                          companyId: selectedCompanyId,
                          minPrice: minP,
                          maxPrice: maxP,
                          sortBy: sortBy,
                          sortOrder: sortOrder,
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
