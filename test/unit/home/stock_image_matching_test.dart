import 'package:eatsipy_customer/constant/constant.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_models.dart';

void main() {
  group('Constant.getStockImagesForVendor', () {
    setUp(() {
      Constant.categoryStockImages = {
        'vegetarian': ['https://example.com/veg1.jpg', 'https://example.com/veg2.jpg'],
        'chinese': ['https://example.com/chinese1.jpg'],
        'default': ['https://example.com/default1.jpg'],
      };
    });

    tearDown(() {
      Constant.categoryStockImages = {};
    });

    test('matches vendor category to stock image pool', () {
      final vendor = testVendor(categoryTitle: ['Vegetarian']);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, ['https://example.com/veg1.jpg', 'https://example.com/veg2.jpg']);
    });

    test('matches case-insensitively', () {
      final vendor = testVendor(categoryTitle: ['CHINESE']);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, ['https://example.com/chinese1.jpg']);
    });

    test('matches partial category name containing the key', () {
      final vendor = testVendor(categoryTitle: ['Vegetarian Food']);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, ['https://example.com/veg1.jpg', 'https://example.com/veg2.jpg']);
    });

    test('falls back to default when no category matches', () {
      final vendor = testVendor(categoryTitle: ['Mexican']);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, ['https://example.com/default1.jpg']);
    });

    test('falls back to default when categoryTitle is empty', () {
      final vendor = testVendor(categoryTitle: []);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, ['https://example.com/default1.jpg']);
    });

    test('falls back to default when categoryTitle is null', () {
      final vendor = testVendor(categoryTitle: null);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, ['https://example.com/default1.jpg']);
    });

    test('returns empty list when no match and no default key', () {
      Constant.categoryStockImages = {
        'pizza': ['https://example.com/pizza1.jpg'],
      };
      final vendor = testVendor(categoryTitle: ['Indian']);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, isEmpty);
    });

    test('skips the default key during category matching', () {
      final vendor = testVendor(categoryTitle: ['default cuisine']);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, ['https://example.com/default1.jpg']);
    });

    test('joins multiple categories for matching', () {
      final vendor = testVendor(categoryTitle: ['Indian', 'Chinese Fusion']);
      final images = Constant.getStockImagesForVendor(vendor);
      expect(images, ['https://example.com/chinese1.jpg']);
    });
  });
}
