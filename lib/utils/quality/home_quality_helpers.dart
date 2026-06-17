import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/utils/quality/restaurant_card_image_resolver.dart';

typedef VendorOpenPredicate = bool Function(VendorModel vendor);
typedef VendorRatingResolver = double Function(VendorModel vendor);
typedef VendorDistanceResolver = double Function(VendorModel vendor);
typedef VendorNextOpeningResolver = DateTime? Function(VendorModel vendor);
typedef VendorStockImagesResolver = List<String> Function(VendorModel vendor);

class HomeRestaurantSplit {
  final List<VendorModel> open;
  final List<VendorModel> closed;

  const HomeRestaurantSplit({required this.open, required this.closed});
}

class HomeQualityHelpers {
  static List<VendorModel> filterRestaurants({
    required List<VendorModel> source,
    required Set<String> selectedFilters,
    required Iterable<String?> offerVendorIds,
    required bool selfDeliveryEnabled,
    required VendorRatingResolver ratingOf,
    required VendorDistanceResolver distanceOf,
  }) {
    var result = source.toList();
    if (selectedFilters.contains('Rating 4.0+')) {
      result = result.where((vendor) => ratingOf(vendor) >= 4.0).toList();
    }
    if (selectedFilters.contains('Free Delivery')) {
      result = result
          .where(
              (vendor) => vendor.isSelfDelivery == true && selfDeliveryEnabled)
          .toList();
    }
    if (selectedFilters.contains('Offers')) {
      final offerIds = offerVendorIds.toSet();
      result = result.where((vendor) => offerIds.contains(vendor.id)).toList();
    }
    if (selectedFilters.contains('Nearest')) {
      result.sort((a, b) => distanceOf(a).compareTo(distanceOf(b)));
    }
    return result;
  }

  static HomeRestaurantSplit splitByStatus({
    required List<VendorModel> source,
    required VendorOpenPredicate isOpen,
    required VendorNextOpeningResolver nextOpeningOf,
  }) {
    final open = source.where(isOpen).toList();
    final closed = source.where((vendor) => !isOpen(vendor)).toList();
    closed.sort((a, b) {
      final aTime = nextOpeningOf(a);
      final bTime = nextOpeningOf(b);
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return aTime.compareTo(bTime);
    });
    return HomeRestaurantSplit(open: open, closed: closed);
  }

  static Map<String, String> assignFallbackImages({
    required List<VendorModel> vendors,
    required VendorStockImagesResolver stockImagesFor,
    int recentWindow = 3,
  }) {
    final assignments = <String, String>{};
    final recentlyUsed = <String>[];
    for (final vendor in vendors) {
      if (vendor.id == null) continue;
      if (!RestaurantCardImageResolver.needsFallback(vendor)) {
        recentlyUsed.clear();
        continue;
      }
      final pool = stockImagesFor(vendor);
      if (pool.isEmpty) continue;
      var picked = pool.first;
      for (final url in pool) {
        if (!recentlyUsed.contains(url)) {
          picked = url;
          break;
        }
      }
      assignments[vendor.id!] = picked;
      recentlyUsed.add(picked);
      if (recentlyUsed.length > recentWindow) {
        recentlyUsed.removeAt(0);
      }
    }
    return assignments;
  }
}
