import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/advertisement_model.dart';

class GoldenAdCard extends StatefulWidget {
  final List<AdvertisementModel> ads;
  final VoidCallback? onTap;
  final void Function(int companyId)? onCompanyTap;

  const GoldenAdCard({
    super.key,
    required this.ads,
    this.onTap,
    this.onCompanyTap,
  });

  @override
  State<GoldenAdCard> createState() => _GoldenAdCardState();
}

class _GoldenAdCardState extends State<GoldenAdCard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.ads.length > 1) {
      _startAutoRotate();
    }
  }

  void _startAutoRotate() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && widget.ads.length > 1) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.ads.length;
        });
        _startAutoRotate();
      }
    });
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
    final ad = widget.ads[_currentIndex];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha:0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ad Image with overlay
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: ad.imageUrlFull,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(child: CircularProgressIndicator()),
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
                    ),
                    // Golden Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'إعلان مميز',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Dots indicator if more than one ad
                    if (widget.ads.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.ads.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _currentIndex ? 18 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: i == _currentIndex
                                    ? const Color(0xFFFFD700)
                                    : Colors.white.withValues(alpha:0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
                // Info section
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company name
                      if (ad.company != null)
                        Row(
                          children: [
                            const Icon(Icons.business, size: 16, color: Color(0xFFFFA500)),
                            const SizedBox(width: 6),
                            Text(
                              ad.company!.name,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: const Color(0xFFFFA500),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      if (ad.title.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          ad.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (ad.description != null && ad.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          ad.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (ad.company != null && widget.onCompanyTap != null) {
                              widget.onCompanyTap!(ad.company!.id);
                            } else if (ad.linkUrl != null && ad.linkUrl!.isNotEmpty) {
                              _launchAdUrl(ad.linkUrl);
                            }
                          },
                          icon: const Icon(Icons.explore_outlined, size: 18),
                          label: const Text('اكتشف المزيد'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
