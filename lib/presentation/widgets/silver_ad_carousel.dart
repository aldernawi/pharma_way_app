import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/advertisement_model.dart';

class SilverAdCarousel extends StatefulWidget {
  final List<AdvertisementModel> ads;

  const SilverAdCarousel({
    super.key,
    required this.ads,
  });

  @override
  State<SilverAdCarousel> createState() => _SilverAdCarouselState();
}

class _SilverAdCarouselState extends State<SilverAdCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && widget.ads.isNotEmpty) {
        final nextPage = (_currentPage + 1) % widget.ads.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchAdUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Carousel
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.ads.length,
              itemBuilder: (context, index) {
                final ad = widget.ads[index];
                return GestureDetector(
                  onTap: () => _launchAdUrl(ad.linkUrl),
                  child: _buildAdItem(ad),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Page Indicator
          if (widget.ads.length > 1)
            SmoothPageIndicator(
              controller: _pageController,
              count: widget.ads.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.secondary,
                dotColor: AppColors.border,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdItem(AdvertisementModel ad) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Ad Image
            CachedNetworkImage(
              imageUrl: ad.imageUrlFull,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.secondaryLighter,
                child: const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: AppColors.secondary,
                ),
              ),
            ),
            // Silver Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'عرض خاص',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
