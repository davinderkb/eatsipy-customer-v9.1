import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/vendor_category_model.dart';

class MenuCategoryMetaData {
  final String categoryId;
  final String categoryName;
  final int itemCount;
  final double? scrollOffset;

  const MenuCategoryMetaData({
    required this.categoryId,
    required this.categoryName,
    required this.itemCount,
    this.scrollOffset,
  });
}

class MenuSearchIndexEntry {
  final ProductModel product;
  final String normalizedName;
  final String normalizedDescription;
  final String normalizedCategory;
  final String normalizedDietTag;

  const MenuSearchIndexEntry({
    required this.product,
    required this.normalizedName,
    required this.normalizedDescription,
    required this.normalizedCategory,
    required this.normalizedDietTag,
  });
}

class RestaurantMenuQualityHelpers {
  static List<MenuSearchIndexEntry> buildSearchIndex({
    required List<ProductModel> products,
    required List<VendorCategoryModel> categories,
  }) {
    final categoryNames = {
      for (final category in categories)
        category.id.toString(): category.title.toString(),
    };
    return products.map((product) {
      final categoryName = categoryNames[product.categoryID] ?? '';
      return MenuSearchIndexEntry(
        product: product,
        normalizedName: normalizeSearchText(product.name ?? ''),
        normalizedDescription: normalizeSearchText(product.description ?? ''),
        normalizedCategory: normalizeSearchText(categoryName),
        normalizedDietTag: product.nonveg == true ? 'non veg nonveg' : 'veg',
      );
    }).toList();
  }

  static List<ProductModel> searchProducts({
    required List<MenuSearchIndexEntry> index,
    required String query,
  }) {
    final normalizedQuery = normalizeSearchText(query);
    if (normalizedQuery.isEmpty) {
      return index.map((entry) => entry.product).toList();
    }
    final scored = <({ProductModel product, int score})>[];
    for (final entry in index) {
      var score = 0;
      if (entry.normalizedName.startsWith(normalizedQuery)) {
        score = 400;
      } else if (entry.normalizedName.contains(normalizedQuery)) {
        score = 300;
      } else if (entry.normalizedCategory.contains(normalizedQuery)) {
        score = 200;
      } else if (entry.normalizedDescription.contains(normalizedQuery) ||
          entry.normalizedDietTag.contains(normalizedQuery)) {
        score = 100;
      }
      if (score > 0) {
        scored.add((product: entry.product, score: score));
      }
    }
    scored.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return (a.product.name ?? '').compareTo(b.product.name ?? '');
    });
    return scored.map((entry) => entry.product).toList();
  }

  static List<ProductModel> applyDietFilters({
    required Iterable<ProductModel> products,
    required bool vegOnly,
    required bool nonVegOnly,
  }) {
    if (vegOnly && !nonVegOnly) {
      return products.where((product) => product.nonveg == false).toList();
    }
    if (!vegOnly && nonVegOnly) {
      return products.where((product) => product.nonveg == true).toList();
    }
    return products.toList();
  }

  static List<MenuCategoryMetaData> buildCategoryMetadata({
    required List<VendorCategoryModel> categories,
    required List<ProductModel> products,
    Map<String, double> scrollOffsets = const {},
  }) {
    final metadata = <MenuCategoryMetaData>[];
    for (final category in categories) {
      final categoryId = category.id.toString();
      final itemCount =
          products.where((product) => product.categoryID == categoryId).length;
      if (itemCount == 0) continue;
      metadata.add(
        MenuCategoryMetaData(
          categoryId: categoryId,
          categoryName: category.title.toString(),
          itemCount: itemCount,
          scrollOffset: scrollOffsets[categoryId],
        ),
      );
    }
    return metadata;
  }

  static double appBarAwareScrollTarget({
    required double currentScrollOffset,
    required double sectionTop,
    required double appBarBottom,
    required double minScrollExtent,
    required double maxScrollExtent,
  }) {
    return (currentScrollOffset + sectionTop - appBarBottom).clamp(
      minScrollExtent,
      maxScrollExtent,
    );
  }

  static String normalizeSearchText(String value) {
    return value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
