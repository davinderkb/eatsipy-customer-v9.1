import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/vendor_category_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';

VendorModel testVendor({
  String id = 'vendor-1',
  String title = 'Test Vendor',
  bool? showCardShowcase,
  List<CardShowcaseItem>? showcaseItems,
  bool? isCoverImageApproved,
  String? coverImageUrl,
  bool? isSelfDelivery,
  List<dynamic>? categoryTitle,
  num reviewsCount = 0,
  num reviewsSum = 0,
}) {
  return VendorModel(
    id: id,
    title: title,
    showCardShowcase: showCardShowcase,
    cardShowcaseItems: showcaseItems,
    isCoverImageApproved: isCoverImageApproved,
    coverImageUrl: coverImageUrl,
    isSelfDelivery: isSelfDelivery,
    categoryTitle: categoryTitle,
    reviewsCount: reviewsCount,
    reviewsSum: reviewsSum,
  );
}

CardShowcaseItem testShowcaseItem({
  String id = 'product-1',
  String name = 'Paneer Roll',
  String price = '120',
  String imageUrl = 'https://example.com/paneer.jpg',
  int displayOrder = 0,
  bool isActive = true,
}) {
  return CardShowcaseItem(
    productId: id,
    name: name,
    price: price,
    imageUrl: imageUrl,
    displayOrder: displayOrder,
    isActive: isActive,
  );
}

ProductModel testProduct({
  String id = 'product-1',
  String name = 'Paneer Roll',
  String categoryId = 'cat-1',
  String description = 'Fresh paneer with spices',
  bool nonveg = false,
  String? photo,
  String price = '100',
  String disPrice = '0',
}) {
  return ProductModel(
    id: id,
    name: name,
    categoryID: categoryId,
    description: description,
    nonveg: nonveg,
    photo: photo,
    price: price,
    disPrice: disPrice,
    quantity: -1,
    addOnsTitle: [],
    addOnsPrice: [],
  );
}

VendorCategoryModel testCategory({
  String id = 'cat-1',
  String title = 'Rolls',
}) {
  return VendorCategoryModel(id: id, title: title);
}
