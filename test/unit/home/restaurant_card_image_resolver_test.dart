import 'package:eatsipy_customer/utils/quality/restaurant_card_image_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_models.dart';

void main() {
  group('RestaurantCardImageResolver', () {
    test('uses showcase slider for two or more active showcase items', () {
      final result = RestaurantCardImageResolver.resolve(
        vendor: testVendor(
          showCardShowcase: true,
          showcaseItems: [
            testShowcaseItem(displayOrder: 2),
            testShowcaseItem(id: 'product-2', displayOrder: 1),
          ],
          isCoverImageApproved: true,
          coverImageUrl: 'https://example.com/cover.jpg',
        ),
        fallbackImageUrl: 'https://example.com/fallback.jpg',
      );

      expect(result.mode, RestaurantCardImageMode.showcase);
      expect(result.showcaseItems.map((item) => item.displayOrder), [1, 2]);
    });

    test('uses single showcase before cover and fallback', () {
      final result = RestaurantCardImageResolver.resolve(
        vendor: testVendor(
          showCardShowcase: true,
          showcaseItems: [
            testShowcaseItem(imageUrl: 'https://example.com/food.jpg')
          ],
          isCoverImageApproved: true,
          coverImageUrl: 'https://example.com/cover.jpg',
        ),
        fallbackImageUrl: 'https://example.com/fallback.jpg',
      );

      expect(result.mode, RestaurantCardImageMode.singleShowcase);
      expect(result.imageUrl, 'https://example.com/food.jpg');
    });

    test('uses approved cover before stock fallback', () {
      final result = RestaurantCardImageResolver.resolve(
        vendor: testVendor(
          isCoverImageApproved: true,
          coverImageUrl: 'https://example.com/cover.jpg',
        ),
        fallbackImageUrl: 'https://example.com/fallback.jpg',
      );

      expect(result.mode, RestaurantCardImageMode.coverImage);
      expect(result.imageUrl, 'https://example.com/cover.jpg');
    });

    test(
        'uses cleaned stock fallback when no showcase or approved cover exists',
        () {
      final result = RestaurantCardImageResolver.resolve(
        vendor: testVendor(coverImageUrl: 'https://example.com/unapproved.jpg'),
        fallbackImageUrl: '"https://example.com/fallback.jpg"',
      );

      expect(result.mode, RestaurantCardImageMode.stockImage);
      expect(result.imageUrl, 'https://example.com/fallback.jpg');
    });

    test('does not use restaurant gallery photo and falls back to placeholder',
        () {
      final vendor = testVendor()
        ..photo = 'https://example.com/gallery.jpg'
        ..photos = ['https://example.com/gallery-2.jpg'];

      final result = RestaurantCardImageResolver.resolve(vendor: vendor);

      expect(result.mode, RestaurantCardImageMode.placeholder);
    });
  });
}
