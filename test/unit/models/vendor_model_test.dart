import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_models.dart';

void main() {
  group('VendorModel.fromJson — categoryTitle parsing', () {
    test('wraps a non-empty String into a single-element list', () {
      final vendor = VendorModel.fromJson(_baseJson({
        'categoryTitle': 'Vegetarian',
      }));
      expect(vendor.categoryTitle, ['Vegetarian']);
    });

    test('keeps an empty String as an empty list', () {
      final vendor = VendorModel.fromJson(_baseJson({
        'categoryTitle': '',
      }));
      expect(vendor.categoryTitle, isEmpty);
    });

    test('passes a List through unchanged', () {
      final vendor = VendorModel.fromJson(_baseJson({
        'categoryTitle': ['Indian', 'Chinese'],
      }));
      expect(vendor.categoryTitle, ['Indian', 'Chinese']);
    });

    test('defaults null to an empty list', () {
      final vendor = VendorModel.fromJson(_baseJson({
        'categoryTitle': null,
      }));
      expect(vendor.categoryTitle, isEmpty);
    });

    test('defaults missing key to an empty list', () {
      final json = _baseJson({});
      json.remove('categoryTitle');
      final vendor = VendorModel.fromJson(json);
      expect(vendor.categoryTitle, isEmpty);
    });
  });

  group('VendorModel.fromJson — CardShowcaseItem parsing', () {
    test('parses showcase items with correct types', () {
      final vendor = VendorModel.fromJson(_baseJson({
        'show_card_showcase': true,
        'card_showcase_items': [
          {
            'product_id': 'p1',
            'name': 'Paneer Tikka',
            'price': 250,
            'image_url': 'https://example.com/paneer.jpg',
            'display_order': 1,
            'is_active': true,
          },
          {
            'product_id': 'p2',
            'name': 'Dal Makhani',
            'price': '180',
            'image_url': 'https://example.com/dal.jpg',
            'display_order': 2,
            'is_active': false,
          },
        ],
      }));

      expect(vendor.showCardShowcase, isTrue);
      expect(vendor.cardShowcaseItems, hasLength(2));
      expect(vendor.cardShowcaseItems![0].name, 'Paneer Tikka');
      expect(vendor.cardShowcaseItems![0].price, '250');
      expect(vendor.cardShowcaseItems![1].isActive, isFalse);
    });

    test('handles null card_showcase_items gracefully', () {
      final vendor = VendorModel.fromJson(_baseJson({}));
      expect(vendor.cardShowcaseItems, isNull);
      expect(vendor.showCardShowcase, isFalse);
    });

    test('handles numeric price via toString', () {
      final item = CardShowcaseItem.fromJson({
        'price': 99.5,
      });
      expect(item.price, '99.5');
    });
  });

  group('VendorModel.fromJson — cover image fields', () {
    test('parses approved cover image', () {
      final vendor = VendorModel.fromJson(_baseJson({
        'is_cover_image_approved': true,
        'cover_image_url': 'https://example.com/cover.jpg',
      }));
      expect(vendor.isCoverImageApproved, isTrue);
      expect(vendor.coverImageUrl, 'https://example.com/cover.jpg');
    });

    test('defaults is_cover_image_approved to false when missing', () {
      final vendor = VendorModel.fromJson(_baseJson({}));
      expect(vendor.isCoverImageApproved, isFalse);
    });
  });

  group('VendorModel.activeShowcaseItems', () {
    test('filters inactive items and sorts by displayOrder', () {
      final vendor = testVendor(
        showcaseItems: [
          testShowcaseItem(id: 'p3', displayOrder: 3, isActive: true),
          testShowcaseItem(id: 'p1', displayOrder: 1, isActive: true),
          testShowcaseItem(id: 'p2', displayOrder: 2, isActive: false),
        ],
      );

      final active = vendor.activeShowcaseItems;
      expect(active, hasLength(2));
      expect(active[0].productId, 'p1');
      expect(active[1].productId, 'p3');
    });

    test('returns empty list when cardShowcaseItems is null', () {
      final vendor = testVendor();
      expect(vendor.activeShowcaseItems, isEmpty);
    });

    test('returns empty list when all items are inactive', () {
      final vendor = testVendor(
        showcaseItems: [
          testShowcaseItem(isActive: false),
        ],
      );
      expect(vendor.activeShowcaseItems, isEmpty);
    });
  });

  group('VendorModel toJson round-trip', () {
    test('showcase fields survive fromJson → toJson → fromJson', () {
      final original = VendorModel.fromJson(_baseJson({
        'is_cover_image_approved': true,
        'cover_image_url': 'https://example.com/cover.jpg',
        'show_card_showcase': true,
        'card_showcase_items': [
          {
            'product_id': 'p1',
            'name': 'Butter Chicken',
            'price': '350',
            'image_url': 'https://example.com/bc.jpg',
            'display_order': 1,
            'is_active': true,
          },
        ],
        'categoryTitle': 'Indian',
      }));

      final roundTripped = VendorModel.fromJson(original.toJson());

      expect(roundTripped.isCoverImageApproved, isTrue);
      expect(roundTripped.coverImageUrl, 'https://example.com/cover.jpg');
      expect(roundTripped.showCardShowcase, isTrue);
      expect(roundTripped.cardShowcaseItems, hasLength(1));
      expect(roundTripped.cardShowcaseItems![0].name, 'Butter Chicken');
      expect(roundTripped.categoryTitle, ['Indian']);
    });
  });
}

Map<String, dynamic> _baseJson(Map<String, dynamic> overrides) {
  return {
    'id': 'test-vendor',
    'title': 'Test Restaurant',
    'latitude': '28.6139',
    'longitude': '77.2090',
    'reviewsCount': 10,
    'reviewsSum': 45,
    ...overrides,
  };
}
