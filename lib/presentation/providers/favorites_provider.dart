import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/favorites_remote_datasource.dart';
import '../../data/models/product_model.dart';

// Favorites State
class FavoritesState {
  final List<ProductModel> favorites;
  final bool isLoading;
  final String? error;

  FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<ProductModel>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Favorites Notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRemoteDataSource _dataSource;

  FavoritesNotifier(this._dataSource) : super(FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final favorites = await _dataSource.getFavorites();
      state = state.copyWith(
        favorites: favorites,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> toggleFavorite(int productId) async {
    final isCurrentlyFavorite = state.favorites.any((p) => p.id == productId);

    try {
      if (isCurrentlyFavorite) {
        await _dataSource.removeFavorite(productId);
        state = state.copyWith(
          favorites: state.favorites.where((p) => p.id != productId).toList(),
        );
        return false; // removed
      } else {
        final product = await _dataSource.addFavorite(productId);
        state = state.copyWith(
          favorites: [...state.favorites, product],
        );
        return true; // added
      }
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث المفضلة: $e');
      return !isCurrentlyFavorite;
    }
  }

  bool isFavorite(int productId) {
    return state.favorites.any((p) => p.id == productId);
  }

  Future<void> clearAll() async {
    try {
      await _dataSource.clearAllFavorites();
      state = state.copyWith(favorites: []);
    } catch (e) {
      state = state.copyWith(error: 'فشل مسح المفضلة: $e');
    }
  }
}

// Provider
final favoritesDataSourceProvider = Provider<FavoritesRemoteDataSource>((ref) {
  return FavoritesRemoteDataSource();
});

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.read(favoritesDataSourceProvider));
});

// Helper provider to check if a product is favorite
final isFavoriteProvider = Provider.family<bool, int>((ref, productId) {
  return ref.watch(favoritesProvider.notifier).isFavorite(productId);
});
