import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/company_model.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/golden_ad_card.dart';
import '../../widgets/silver_ad_carousel.dart';
import '../../widgets/brand_banner.dart';
import '../../widgets/company_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/shimmer_loading.dart';
import '../products/company_products_screen.dart';
import '../products/brand_products_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<CompanyModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query, List<CompanyModel> companies) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _searchResults = companies
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _isSearching = false;
      _searchFocusNode.unfocus();
    });
  }

  void _navigateToCompany(CompanyModel company) {
    _clearSearch();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyProductsScreen(company: company),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // Hero Header with gradient
              _buildHeroHeader(context, authState.user?.name ?? 'مستخدم'),

              // Search Bar
              SliverToBoxAdapter(child: _buildSearchBar()),

              // Search Results
              if (_isSearching)
                SliverToBoxAdapter(
                  child: _buildSearchResults(),
                ),

              // Loading shimmer
              if (homeState.isLoading && homeState.companies.isEmpty)
                const SliverToBoxAdapter(child: HomeShimmer())
              else if (homeState.error != null)
                SliverFillRemaining(
                  child: _buildErrorState(context),
                )
              else if (homeState.companies.isEmpty && 
                       homeState.goldenAds.isEmpty && 
                       homeState.silverAds.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'لا توجد بيانات حالياً',
                      message: 'لا توجد شركات أو إعلانات متاحة في الوقت الحالي\nيرجى المحاولة مرة أخرى لاحقاً',
                      onRetry: () => ref.read(homeProvider.notifier).refresh(),
                      isFullScreen: true,
                    ),
                  ),
                )
              else ...[
                // Golden Ads Section
                if (homeState.hasGoldenAds) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(context, 'الشركات المميزة'),
                  ),
                  SliverToBoxAdapter(
                    child: GoldenAdCard(
                      ads: homeState.goldenAds,
                      onCompanyTap: (companyId) {
                        final company = homeState.companies.where((c) => c.id == companyId).firstOrNull;
                        if (company != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyProductsScreen(company: company),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
                
                // Silver Ads Carousel
                if (homeState.hasSilverAds) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(context, 'العروض الخاصة'),
                  ),
                  SliverToBoxAdapter(
                    child: SilverAdCarousel(ads: homeState.silverAds),
                  ),
                ],
                
                // Brand Banners Section
                if (homeState.brands.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(context, 'تصفح حسب الماركة'),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: homeState.brands.length,
                        itemBuilder: (context, index) {
                          final brand = homeState.brands[index];
                          return BrandBanner(
                            brand: brand,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BrandProductsScreen(brand: brand),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
                
                // Companies Section
                SliverToBoxAdapter(
                  child: _buildSectionHeader(context, 'شركات الأدوية'),
                ),
                
                if (homeState.companies.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      icon: Icons.business_outlined,
                      title: 'لا توجد شركات متاحة',
                      message: 'لا توجد شركات أدوية مسجلة حالياً',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final company = homeState.companies[index];
                          return CompanyCard(
                            company: company,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompanyProductsScreen(
                                    company: company,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: homeState.companies.length,
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeroHeader(BuildContext context, String userName) {
    final cartItemCount = ref.watch(cartItemCountProvider);

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Row(
          children: [
            // Logo + greeting
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/witoutbg.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.local_pharmacy,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pharma Way',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مرحباً، $userName',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha:0.85),
                        ),
                  ),
                ],
              ),
            ),
            // Action icons
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            const SizedBox(width: 4),
            if (cartItemCount > 0)
              badges.Badge(
                badgeContent: Text(
                  '$cartItemCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: AppColors.secondary,
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final homeState = ref.watch(homeProvider);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'ابحث عن شركة أدوية...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textTertiary),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          _performSearch(value, homeState.companies);
        },
        onSubmitted: (value) {
          _performSearch(value, homeState.companies);
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'لا توجد نتائج لـ "${_searchController.text}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.business, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'الشركات (${_searchResults.length})',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final company = _searchResults[index];
                return _buildSearchResultTile(company);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(CompanyModel company) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: company.logoUrlFull,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 40,
            height: 40,
            color: AppColors.surfaceVariant,
            child: const Icon(Icons.business, size: 20, color: AppColors.textTertiary),
          ),
          errorWidget: (context, url, error) => Container(
            width: 40,
            height: 40,
            color: AppColors.primaryLighter,
            child: const Icon(Icons.business, size: 20, color: AppColors.primary),
          ),
        ),
      ),
      title: Text(
        company.name,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: company.productsCount != null && company.productsCount! > 0
          ? Text('${company.productsCount} منتج')
          : null,
      trailing: const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textTertiary),
      onTap: () => _navigateToCompany(company),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(homeProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
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
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'الإشعارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/orders');
              break;
            case 2:
              Navigator.pushNamed(context, '/notifications');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
