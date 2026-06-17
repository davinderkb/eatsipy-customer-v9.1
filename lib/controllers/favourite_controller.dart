import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/models/favourite_item_model.dart';
import 'package:eatsipy_customer/models/favourite_model.dart';
import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class FavouriteController extends GetxController {
  RxBool favouriteRestaurant = true.obs;
  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList<VendorModel> favouriteVendorList = <VendorModel>[].obs;

  RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
  RxList<ProductModel> favouriteFoodList = <ProductModel>[].obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
    getData();
  }

  bool _isVendorSubscriptionValid(VendorModel vendor) {
    if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && vendor.subscriptionPlan != null) {
      if (vendor.subscriptionTotalOrders == "-1") return true;
      if ((vendor.subscriptionExpiryDate != null && vendor.subscriptionExpiryDate!.toDate().isBefore(DateTime.now()) == false) ||
          vendor.subscriptionPlan?.expiryDay == '-1') {
        return vendor.subscriptionTotalOrders != '0';
      }
      return false;
    }
    return true;
  }

  Future<void> getData() async {
    reset();
    if (Constant.userModel == null) {
      isLoading.value = false;
      return;
    }

    final results = await Future.wait([
      FireStoreUtils.getFavouriteRestaurant(),
      FireStoreUtils.getFavouriteItem(),
    ]);
    favouriteList.value = results[0] as List<FavouriteModel>;
    favouriteItemList.value = results[1] as List<FavouriteItemModel>;

    final vendorIds = favouriteList.map((e) => e.restaurantId.toString()).toList();
    final productIds = favouriteItemList.map((e) => e.productId.toString()).toList();

    final batchResults = await Future.wait([
      FireStoreUtils.getVendorsByIds(vendorIds),
      FireStoreUtils.getProductsByIds(productIds),
    ]);
    final vendorMap = batchResults[0] as Map<String, VendorModel>;
    final productMap = batchResults[1] as Map<String, ProductModel>;

    // Build favourite vendors list
    final favouriteVendorData = vendorMap.values.where(_isVendorSubscriptionValid).toList();
    favouriteVendorData.sort((a, b) {
      final aOpen = Constant.statusCheckOpenORClose(vendorModel: a);
      final bOpen = Constant.statusCheckOpenORClose(vendorModel: b);
      if (aOpen == bOpen) return 0;
      return aOpen ? -1 : 1;
    });
    favouriteVendorList.value = removeDuplicateVendor(favouriteVendorData);

    // Build favourite foods list — need vendor subscription check per product
    final productVendorIds = productMap.values.where((p) => p.publish == true).map((p) => p.vendorID.toString()).toSet().toList();
    final productVendorMap = await FireStoreUtils.getVendorsByIds(productVendorIds);

    final favouriteFoodData = <ProductModel>[];
    for (final product in productMap.values) {
      if (product.publish != true) continue;
      final vendor = productVendorMap[product.vendorID.toString()];
      if (vendor == null) continue;
      if (_isVendorSubscriptionValid(vendor)) {
        favouriteFoodData.add(product);
      }
    }
    favouriteFoodList.value = removeDuplicateFoods(favouriteFoodData);
    isLoading.value = false;
  }

  List<ProductModel> removeDuplicateFoods(List<ProductModel> favouriteFoodList) {
    final seenIds = <String>{};
    return favouriteFoodList.where((food) {
      return seenIds.add(food.id!);
    }).toList();
  }

  List<VendorModel> removeDuplicateVendor(List<VendorModel> favouriteFoodVendor) {
    final seenIds = <String>{};
    return favouriteFoodVendor.where((food) {
      return seenIds.add(food.id!);
    }).toList();
  }

  void reset() {
    favouriteRestaurant.value = true;
    favouriteList.value = [];
    favouriteVendorList.value = [];
    favouriteItemList.value = [];
    favouriteFoodList.value = [];
    isLoading.value = true;
  }
}
