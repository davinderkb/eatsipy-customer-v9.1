import 'package:eatsipy_customer/utils/quality/restaurant_menu_quality_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_models.dart';

void main() {
  group('Restaurant menu category metadata', () {
    test('excludes empty categories and keeps counts/offsets', () {
      final metadata = RestaurantMenuQualityHelpers.buildCategoryMetadata(
        categories: [
          testCategory(id: 'rolls', title: 'Rolls'),
          testCategory(id: 'empty', title: 'Empty'),
        ],
        products: [
          testProduct(id: 'a', categoryId: 'rolls'),
          testProduct(id: 'b', categoryId: 'rolls'),
        ],
        scrollOffsets: {'rolls': 120},
      );

      expect(metadata, hasLength(1));
      expect(metadata.first.categoryName, 'Rolls');
      expect(metadata.first.itemCount, 2);
      expect(metadata.first.scrollOffset, 120);
    });

    test('computes app-bar-aware scroll target and clamps bounds', () {
      expect(
        RestaurantMenuQualityHelpers.appBarAwareScrollTarget(
          currentScrollOffset: 300,
          sectionTop: 200,
          appBarBottom: 100,
          minScrollExtent: 0,
          maxScrollExtent: 1000,
        ),
        400,
      );
      expect(
        RestaurantMenuQualityHelpers.appBarAwareScrollTarget(
          currentScrollOffset: 20,
          sectionTop: 10,
          appBarBottom: 100,
          minScrollExtent: 0,
          maxScrollExtent: 1000,
        ),
        0,
      );
    });
  });
}
