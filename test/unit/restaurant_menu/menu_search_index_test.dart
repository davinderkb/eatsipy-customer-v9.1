import 'package:eatsipy_customer/utils/quality/restaurant_menu_quality_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_models.dart';

void main() {
  group('Restaurant menu search helpers', () {
    test(
        'ranks name prefix before name contains, category, and description matches',
        () {
      final products = [
        testProduct(
            id: 'description',
            name: 'Chef Special',
            description: 'Sweet lassi included',
            categoryId: 'cat-1'),
        testProduct(
            id: 'category', name: 'Plain Fries', categoryId: 'cat-lassi'),
        testProduct(
            id: 'contains', name: 'Mango Sweet Lassi', categoryId: 'cat-1'),
        testProduct(id: 'prefix', name: 'Lassi Classic', categoryId: 'cat-1'),
      ];
      final index = RestaurantMenuQualityHelpers.buildSearchIndex(
        products: products,
        categories: [
          testCategory(id: 'cat-1', title: 'Snacks'),
          testCategory(id: 'cat-lassi', title: 'Lassi Drinks'),
        ],
      );

      final result = RestaurantMenuQualityHelpers.searchProducts(
        index: index,
        query: 'lassi',
      );

      expect(result.map((product) => product.id),
          ['prefix', 'contains', 'category', 'description']);
    });

    test('combines diet filters with active search results', () {
      final veg = testProduct(id: 'veg', name: 'Lassi Classic', nonveg: false);
      final nonVeg =
          testProduct(id: 'nonveg', name: 'Chicken Lassi Bowl', nonveg: true);
      final index = RestaurantMenuQualityHelpers.buildSearchIndex(
        products: [veg, nonVeg],
        categories: [testCategory()],
      );
      final searched = RestaurantMenuQualityHelpers.searchProducts(
          index: index, query: 'lassi');

      final result = RestaurantMenuQualityHelpers.applyDietFilters(
        products: searched,
        vegOnly: true,
        nonVegOnly: false,
      );

      expect(result.map((product) => product.id), ['veg']);
    });
  });
}
