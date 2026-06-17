import 'package:eatsipy_customer/models/vendor_model.dart';

enum RestaurantCardImageMode {
  showcase,
  singleShowcase,
  coverImage,
  stockImage,
  placeholder,
}

class RestaurantCardImageResolution {
  final RestaurantCardImageMode mode;
  final List<CardShowcaseItem> showcaseItems;
  final String? imageUrl;

  const RestaurantCardImageResolution({
    required this.mode,
    this.showcaseItems = const [],
    this.imageUrl,
  });
}

class RestaurantCardImageResolver {
  static RestaurantCardImageResolution resolve({
    required VendorModel vendor,
    String? fallbackImageUrl,
  }) {
    final showcaseItems = vendor.activeShowcaseItems;
    if (vendor.showCardShowcase == true && showcaseItems.length >= 2) {
      return RestaurantCardImageResolution(
        mode: RestaurantCardImageMode.showcase,
        showcaseItems: showcaseItems,
      );
    }
    if (vendor.showCardShowcase == true && showcaseItems.length == 1) {
      return RestaurantCardImageResolution(
        mode: RestaurantCardImageMode.singleShowcase,
        showcaseItems: showcaseItems,
        imageUrl: showcaseItems.first.imageUrl,
      );
    }
    if (vendor.isCoverImageApproved == true &&
        _isValidHttpUrl(vendor.coverImageUrl)) {
      return RestaurantCardImageResolution(
        mode: RestaurantCardImageMode.coverImage,
        imageUrl: vendor.coverImageUrl!.trim(),
      );
    }
    if (_isValidHttpUrl(fallbackImageUrl)) {
      return RestaurantCardImageResolution(
        mode: RestaurantCardImageMode.stockImage,
        imageUrl: _cleanUrl(fallbackImageUrl!),
      );
    }
    return const RestaurantCardImageResolution(
      mode: RestaurantCardImageMode.placeholder,
    );
  }

  static bool needsFallback(VendorModel vendor) {
    return resolve(vendor: vendor).mode == RestaurantCardImageMode.placeholder;
  }

  static bool _isValidHttpUrl(String? value) {
    return value != null && _cleanUrl(value).startsWith('http');
  }

  static String _cleanUrl(String value) => value.replaceAll('"', '').trim();
}
