import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/models/product_model.dart';

// Providers
final productDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(ref.watch(dioClientProvider));
});

final productRepositoryProvider = Provider<ProductRepositoryImpl>((ref) {
  return ProductRepositoryImpl(ref.watch(productDataSourceProvider));
});

// Company Products State
class CompanyProductsState {
  final List<ProductModel> products;
  final List<BrandBasicInfo> availableBrands;
  final List<CategoryBasicInfo> availableCategories;
  final int? selectedBrandId;
  final int? selectedCategoryId;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final String sortOrder;
  final bool isLoading;
  final String? error;
  final bool initialLoaded;

  CompanyProductsState({
    this.products = const [],
    this.availableBrands = const [],
    this.availableCategories = const [],
    this.selectedBrandId,
    this.selectedCategoryId,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.isLoading = false,
    this.error,
    this.initialLoaded = false,
  });

  CompanyProductsState copyWith({
    List<ProductModel>? products,
    List<BrandBasicInfo>? availableBrands,
    List<CategoryBasicInfo>? availableCategories,
    int? selectedBrandId,
    int? selectedCategoryId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    bool? isLoading,
    String? error,
    bool? initialLoaded,
    bool clearBrandFilter = false,
    bool clearCategoryFilter = false,
    bool clearPriceFilter = false,
  }) {
    return CompanyProductsState(
      products: products ?? this.products,
      availableBrands: availableBrands ?? this.availableBrands,
      availableCategories: availableCategories ?? this.availableCategories,
      selectedBrandId: clearBrandFilter ? null : (selectedBrandId ?? this.selectedBrandId),
      selectedCategoryId: clearCategoryFilter ? null : (selectedCategoryId ?? this.selectedCategoryId),
      minPrice: clearPriceFilter ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceFilter ? null : (maxPrice ?? this.maxPrice),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      initialLoaded: initialLoaded ?? this.initialLoaded,
    );
  }

  bool get hasActiveFilters =>
      selectedBrandId != null ||
      selectedCategoryId != null ||
      minPrice != null ||
      maxPrice != null ||
      sortBy != 'created_at' ||
      sortOrder != 'desc';
}

// Company Products Notifier
class CompanyProductsNotifier extends StateNotifier<CompanyProductsState> {
  final ProductRepositoryImpl _repository;
  final int companyId;

  CompanyProductsNotifier(this._repository, this.companyId) 
      : super(CompanyProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final products = await _repository.getProductsByCompany(
        companyId,
        brandId: state.selectedBrandId,
        categoryId: state.selectedCategoryId,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sortBy: state.sortBy,
        sortOrder: state.sortOrder,
      );
      
      // Only populate available brands/categories on initial (unfiltered) load
      if (!state.initialLoaded) {
        final brandsMap = <int, BrandBasicInfo>{};
        final categoriesMap = <int, CategoryBasicInfo>{};
        for (final p in products) {
          if (p.brand != null) brandsMap[p.brand!.id] = p.brand!;
          if (p.category != null) categoriesMap[p.category!.id] = p.category!;
        }

        state = state.copyWith(
          products: products,
          availableBrands: brandsMap.values.toList(),
          availableCategories: categoriesMap.values.toList(),
          isLoading: false,
          initialLoaded: true,
        );
      } else {
        state = state.copyWith(
          products: products,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void filterByBrand(int? brandId) {
    state = state.copyWith(
      selectedBrandId: brandId,
      clearBrandFilter: brandId == null,
    );
    loadProducts();
  }

  void filterByCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategoryFilter: categoryId == null,
    );
    loadProducts();
  }

  void applyAllFilters({
    int? brandId,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    bool clearBrand = false,
    bool clearCategory = false,
    bool clearPrice = false,
  }) {
    state = state.copyWith(
      selectedBrandId: clearBrand ? null : brandId,
      selectedCategoryId: clearCategory ? null : categoryId,
      minPrice: clearPrice ? null : minPrice,
      maxPrice: clearPrice ? null : maxPrice,
      sortBy: sortBy ?? state.sortBy,
      sortOrder: sortOrder ?? state.sortOrder,
      clearBrandFilter: clearBrand,
      clearCategoryFilter: clearCategory,
      clearPriceFilter: clearPrice,
    );
    loadProducts();
  }

  void clearFilter() {
    state = state.copyWith(
      clearBrandFilter: true,
      clearCategoryFilter: true,
      clearPriceFilter: true,
      sortBy: 'created_at',
      sortOrder: 'desc',
    );
    loadProducts();
  }
}

// Company Products Provider Factory
final companyProductsProvider = StateNotifierProvider.family<
    CompanyProductsNotifier, CompanyProductsState, int>((ref, companyId) {
  return CompanyProductsNotifier(
    ref.watch(productRepositoryProvider),
    companyId,
  );
});

// Product Details State
class ProductDetailsState {
  final ProductModel? product;
  final bool isLoading;
  final String? error;

  ProductDetailsState({
    this.product,
    this.isLoading = false,
    this.error,
  });

  ProductDetailsState copyWith({
    ProductModel? product,
    bool? isLoading,
    String? error,
  }) {
    return ProductDetailsState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Product Details Notifier
class ProductDetailsNotifier extends StateNotifier<ProductDetailsState> {
  final ProductRepositoryImpl _repository;
  final int productId;

  ProductDetailsNotifier(this._repository, this.productId) 
      : super(ProductDetailsState()) {
    loadProduct();
  }

  Future<void> loadProduct() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final product = await _repository.getProductById(productId);
      state = state.copyWith(
        product: product,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Product Details Provider Factory
final productDetailsProvider = StateNotifierProvider.family<
    ProductDetailsNotifier, ProductDetailsState, int>((ref, productId) {
  return ProductDetailsNotifier(
    ref.watch(productRepositoryProvider),
    productId,
  );
});
