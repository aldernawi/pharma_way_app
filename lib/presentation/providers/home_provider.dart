import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/models/company_model.dart';
import '../../data/models/advertisement_model.dart';
import '../../data/models/brand_model.dart';

// Providers
final homeDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSource(ref.watch(dioClientProvider));
});

final homeRepositoryProvider = Provider<HomeRepositoryImpl>((ref) {
  return HomeRepositoryImpl(ref.watch(homeDataSourceProvider));
});

// Home State
class HomeState {
  final List<CompanyModel> companies;
  final List<AdvertisementModel> goldenAds;
  final List<AdvertisementModel> silverAds;
  final List<BrandModel> brands;
  final bool isLoading;
  final String? error;

  HomeState({
    this.companies = const [],
    this.goldenAds = const [],
    this.silverAds = const [],
    this.brands = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<CompanyModel>? companies,
    List<AdvertisementModel>? goldenAds,
    List<AdvertisementModel>? silverAds,
    List<BrandModel>? brands,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      companies: companies ?? this.companies,
      goldenAds: goldenAds ?? this.goldenAds,
      silverAds: silverAds ?? this.silverAds,
      brands: brands ?? this.brands,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasSilverAds => silverAds.isNotEmpty;
  bool get hasGoldenAds => goldenAds.isNotEmpty;
}

// Home Notifier
class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepositoryImpl _repository;

  HomeNotifier(this._repository) : super(HomeState()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Independent loading: if one fails, it returns empty list and doesn't crash the others
    // We use Future.wait to run them in parallel for performance
    
    final companiesFuture = _repository.getCompanies(perPage: 20)
        .catchError((e) {
          debugPrint('HomeNotifier: Error loading companies: $e');
          return <CompanyModel>[];
        });

    final goldenAdsFuture = _repository.getGoldenAds()
        .catchError((e) {
          debugPrint('HomeNotifier: Error loading golden ads: $e');
          return <AdvertisementModel>[];
        });

    final silverAdsFuture = _repository.getSilverAds()
        .catchError((e) {
          debugPrint('HomeNotifier: Error loading silver ads: $e');
          return <AdvertisementModel>[];
        });

    final brandsFuture = _repository.getBrands()
        .catchError((e) {
          debugPrint('HomeNotifier: Error loading brands: $e');
          return <BrandModel>[];
        });

    try {
      final results = await Future.wait([
        companiesFuture,
        goldenAdsFuture,
        silverAdsFuture,
        brandsFuture,
      ]);

      state = state.copyWith(
        companies: results[0] as List<CompanyModel>,
        goldenAds: results[1] as List<AdvertisementModel>,
        silverAds: results[2] as List<AdvertisementModel>,
        brands: results[3] as List<BrandModel>,
        isLoading: false,
      );
    } catch (e) {
      // This catch block should ideally not be reached because all futures handle their errors,
      // but as a fallback for unexpected critical errors:
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Home Provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.watch(homeRepositoryProvider));
});
