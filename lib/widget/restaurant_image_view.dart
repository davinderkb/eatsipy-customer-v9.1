import 'dart:async';

import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/utils/quality/restaurant_card_image_resolver.dart';
import 'package:flutter/material.dart';

class RestaurantImageView extends StatefulWidget {
  final VendorModel vendorModel;
  final double? height;
  final String? fallbackImageUrl;

  const RestaurantImageView({
    super.key,
    required this.vendorModel,
    this.height,
    this.fallbackImageUrl,
  });

  @override
  State<RestaurantImageView> createState() => _RestaurantImageViewState();
}

class _RestaurantImageViewState extends State<RestaurantImageView> {
  int _currentPage = 0;
  late PageController _pageController;
  Timer? _autoSlideTimer;
  Timer? _resumeTimer;
  late RestaurantCardImageResolution _resolution;

  @override
  void initState() {
    super.initState();
    _resolveMode();
    _pageController = PageController();
    if (_resolution.mode == RestaurantCardImageMode.showcase) {
      _startAutoSlide();
    }
  }

  void _resolveMode() {
    final vendor = widget.vendorModel;
    _resolution = RestaurantCardImageResolver.resolve(
      vendor: vendor,
      fallbackImageUrl: widget.fallbackImageUrl,
    );
    debugPrint(
        '📸 ImageView ${vendor.title}: mode=${_resolution.mode}, fallbackUrl=${widget.fallbackImageUrl}');
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % _resolution.showcaseItems.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  void _scheduleResume() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) _startAutoSlide();
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _resumeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? Responsive.height(20, context);
    final w = Responsive.width(100, context);

    switch (_resolution.mode) {
      case RestaurantCardImageMode.showcase:
        return _buildShowcase(h, w);
      case RestaurantCardImageMode.singleShowcase:
      case RestaurantCardImageMode.coverImage:
      case RestaurantCardImageMode.stockImage:
        return _buildSingleImage(h, w, _resolution.imageUrl ?? '');
      case RestaurantCardImageMode.placeholder:
        return _buildPlaceholder(h, w);
    }
  }

  Widget _buildShowcase(double h, double w) {
    return SizedBox(
      height: h,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            _stopAutoSlide();
          } else if (notification is ScrollEndNotification) {
            _scheduleResume();
          }
          return false;
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _resolution.showcaseItems.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final item = _resolution.showcaseItems[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkImageWidget(
                      imageUrl: item.imageUrl ?? '',
                      fit: BoxFit.cover,
                      height: h,
                      width: w,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 24, 12, 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [Color(0xA6000000), Colors.transparent],
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Constant.amountShow(amount: item.price),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _resolution.showcaseItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 8 : 6,
                    height: _currentPage == index ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImage(double h, double w, String imageUrl) {
    return SizedBox(
      height: h,
      child: NetworkImageWidget(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        height: h,
        width: w,
      ),
    );
  }

  Widget _buildPlaceholder(double h, double w) {
    return SizedBox(
      height: h,
      width: w,
      child: Container(
        color: AppThemeData.grey200,
        child: Center(
          child: Icon(
            Icons.restaurant_menu,
            size: 48,
            color: AppThemeData.grey400,
          ),
        ),
      ),
    );
  }
}
