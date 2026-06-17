import 'package:eatsipy_customer/utils/quality/home_quality_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_models.dart';

void main() {
  group('HomeQualityHelpers', () {
    test('filters rating, free delivery, offers, and nearest deterministically',
        () {
      final a = testVendor(id: 'a', isSelfDelivery: true);
      final b = testVendor(id: 'b', isSelfDelivery: true);
      final c = testVendor(id: 'c', isSelfDelivery: false);

      final result = HomeQualityHelpers.filterRestaurants(
        source: [a, b, c],
        selectedFilters: {'Rating 4.0+', 'Free Delivery', 'Offers', 'Nearest'},
        offerVendorIds: ['a', 'b'],
        selfDeliveryEnabled: true,
        ratingOf: (vendor) => vendor.id == 'c' ? 3.9 : 4.5,
        distanceOf: (vendor) => vendor.id == 'b' ? 1 : 5,
      );

      expect(result.map((vendor) => vendor.id), ['b', 'a']);
    });

    test(
        'splits open and closed restaurants and sorts closed null openings last',
        () {
      final open = testVendor(id: 'open');
      final soon = testVendor(id: 'soon');
      final later = testVendor(id: 'later');
      final unknown = testVendor(id: 'unknown');
      final base = DateTime(2026, 6, 18, 12);

      final split = HomeQualityHelpers.splitByStatus(
        source: [unknown, later, open, soon],
        isOpen: (vendor) => vendor.id == 'open',
        nextOpeningOf: (vendor) {
          if (vendor.id == 'soon') return base.add(const Duration(hours: 1));
          if (vendor.id == 'later') return base.add(const Duration(hours: 3));
          return null;
        },
      );

      expect(split.open.map((vendor) => vendor.id), ['open']);
      expect(split.closed.map((vendor) => vendor.id),
          ['soon', 'later', 'unknown']);
    });

    test(
        'assigns fallback images with a sliding recent window and skips vendors with card images',
        () {
      final vendors = [
        testVendor(id: 'a', categoryTitle: ['Indian']),
        testVendor(id: 'b', categoryTitle: ['Indian']),
        testVendor(id: 'c', categoryTitle: ['Indian']),
        testVendor(
          id: 'cover',
          isCoverImageApproved: true,
          coverImageUrl: 'https://example.com/cover.jpg',
        ),
      ];

      final result = HomeQualityHelpers.assignFallbackImages(
        vendors: vendors,
        stockImagesFor: (_) => ['img-1', 'img-2'],
      );

      expect(result['a'], 'img-1');
      expect(result['b'], 'img-2');
      expect(result['c'], 'img-1');
      expect(result.containsKey('cover'), isFalse);
    });
  });
}
