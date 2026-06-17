import 'dart:async';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/dash_board_controller.dart';
import 'package:eatsipy_customer/models/BannerModel.dart';
import 'package:eatsipy_customer/models/advertisement_model.dart';
import 'package:eatsipy_customer/models/coupon_model.dart';
import 'package:eatsipy_customer/models/favourite_model.dart';
import 'package:eatsipy_customer/models/story_model.dart';
import 'package:eatsipy_customer/models/tax_model.dart';
import 'package:eatsipy_customer/models/vendor_category_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/services/cart_provider.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/preferences.dart';
import 'package:eatsipy_customer/utils/quality/home_quality_helpers.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  final DashBoardController dashBoardController =
      Get.find<DashBoardController>();
  final CartProvider cartProvider = CartProvider();

  RxBool isLoading = true.obs;
  RxBool isListView = true.obs;
  RxString selectedOrderTypeValue = "Delivery".tr.obs;

  final Rx<PageController> pageController =
      PageController(viewportFraction: 0.877).obs;
  final Rx<PageController> pageBottomController =
      PageController(viewportFraction: 0.877).obs;
  final RxInt currentPage = 0.obs;
  final RxInt currentBottomPage = 0.obs;

  late TabController tabController;

  // 🔹 Caching & reactive data
  final RxList<VendorCategoryModel> vendorCategoryModel =
      <VendorCategoryModel>[].obs;
  final RxList<VendorModel> allNearestRestaurant = <VendorModel>[].obs;
  final RxList<VendorModel> newArrivalRestaurantList = <VendorModel>[].obs;
  final RxList<VendorModel> couponRestaurantList = <VendorModel>[].obs;
  final RxList<AdvertisementModel> advertisementList =
      <AdvertisementModel>[].obs;
  final RxList<CouponModel> couponList = <CouponModel>[].obs;
  final RxList<StoryModel> storyList = <StoryModel>[].obs;
  final RxList<BannerModel> bannerModel = <BannerModel>[].obs;
  final RxList<BannerModel> bannerBottomModel = <BannerModel>[].obs;
  final RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;

  final Map<String, String> fallbackImageAssignments = {};

  StreamSubscription? _cartSubscription;
  StreamSubscription? _restaurantSubscription;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    isLoading.value = true;
    selectedOrderTypeValue.value = Preferences.getString(
        Preferences.foodDeliveryType,
        defaultValue: "Delivery");
    if (!Constant.takeawayEnabled &&
        selectedOrderTypeValue.value == 'TakeAway') {
      selectedOrderTypeValue.value = 'Delivery';
      Preferences.setString(Preferences.foodDeliveryType, 'Delivery');
    }
    await Future.wait([
      getTaxList(),
      getVendorCategory(),
      getZone(),
      getCartData(),
    ]);
    await Constant.loadCategoryStockImages();
    _listenForRestaurants(); // 🔹 Stream listens in background
  }

  Future<void> getTaxList() async {
    await FireStoreUtils.getTaxList().then(
      (value) {
        if (value != null) {
          Constant.taxProductList = value
              .where((TaxModel taxModel) => taxModel.scope == "product")
              .toList();
          Constant.orderProductTaxList = value
              .where((TaxModel taxModel) => taxModel.scope == "order")
              .toList();
          Constant.driverDeliveryTaxList = value
              .where((TaxModel taxModel) => taxModel.scope == "delivery")
              .toList();

          if (Constant.packagingChargeEnable == true) {
            Constant.packagingTaxList = value
                .where((TaxModel taxModel) => taxModel.scope == "packaging")
                .toList();
          }
          if (Constant.platformFeeModel?.enable == true) {
            Constant.platformTaxList = value
                .where((TaxModel taxModel) => taxModel.scope == "platform")
                .toList();
          }
        }
      },
    );
  }

  // ✅ Optimized cart listening
  Future<void> getCartData() async {
    _cartSubscription?.cancel();
    _cartSubscription = cartProvider.cartStream.listen((event) {
      cartItem
        ..clear()
        ..addAll(event);
      update(['cart']); // partial update only for cart widgets
    });
  }

  // ✅ Stream-based restaurant updates
  void _listenForRestaurants() {
    _restaurantSubscription?.cancel();
    _restaurantSubscription =
        FireStoreUtils.getAllNearestRestaurant().listen((restaurants) async {
      if (restaurants.isEmpty) {
        isLoading.value = false;
        return;
      }

      // Sort by open status and rating
      restaurants.sort((a, b) {
        final aOpen = Constant.statusCheckOpenORClose(vendorModel: a);
        final bOpen = Constant.statusCheckOpenORClose(vendorModel: b);
        if (aOpen == bOpen) {
          final ratingA = Constant.calculateReview(
              reviewCount: a.reviewsCount.toString(),
              reviewSum: a.reviewsSum.toString());
          final ratingB = Constant.calculateReview(
              reviewCount: b.reviewsCount.toString(),
              reviewSum: b.reviewsSum.toString());
          return ratingB.compareTo(ratingA);
        }
        return aOpen ? -1 : 1;
      });

      // Assign fallback images BEFORE triggering reactive rebuild
      assignFallbackImages(restaurants);
      allNearestRestaurant.assignAll(restaurants);
      newArrivalRestaurantList.assignAll(
        restaurants
            .where((v) => Constant.statusCheckOpenORClose(vendorModel: v)),
      );
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      newArrivalRestaurantList.sort((a, b) {
        final ratingA = double.tryParse(Constant.calculateReview(
                reviewCount: a.reviewsCount.toString(),
                reviewSum: a.reviewsSum.toString())) ??
            0;
        final ratingB = double.tryParse(Constant.calculateReview(
                reviewCount: b.reviewsCount.toString(),
                reviewSum: b.reviewsSum.toString())) ??
            0;
        final ageA =
            (nowMs - (a.createdAt?.millisecondsSinceEpoch ?? 0)) / 86400000;
        final ageB =
            (nowMs - (b.createdAt?.millisecondsSinceEpoch ?? 0)) / 86400000;
        final scoreA = (ratingA * 0.7) + (1.0 / (1.0 + ageA / 30) * 5.0 * 0.3);
        final scoreB = (ratingB * 0.7) + (1.0 / (1.0 + ageB / 30) * 5.0 * 0.3);
        return scoreB.compareTo(scoreA);
      });
      Constant.restaurantList = allNearestRestaurant;
      _applyFilters();

      await _loadAdditionalData(restaurants);
      isLoading.value = false;
    });
  }

  // ✅ Parallel fetching of coupons, stories, ads
  Future<void> _loadAdditionalData(List<VendorModel> restaurants) async {
    await Future.wait([
      _fetchCoupons(restaurants),
      _fetchStories(restaurants),
      if (Constant.isEnableAdsFeature) _fetchAds(restaurants),
    ]);
  }

  Future<void> _fetchCoupons(List<VendorModel> restaurants) async {
    final values = await FireStoreUtils.getHomeCoupon();
    final now = DateTime.now();

    couponList.clear();
    couponRestaurantList.clear();
    for (final c in values) {
      if (c.expiresAt!.toDate().isAfter(now)) {
        final match =
            restaurants.firstWhereOrNull((r) => r.id == c.resturantId);
        if (match != null) {
          couponList.add(c);
          couponRestaurantList.add(match);
        }
      }
    }
  }

  Future<void> _fetchStories(List<VendorModel> restaurants) async {
    final values = await FireStoreUtils.getStory();
    final vendorIds = restaurants.map((r) => r.id).toSet();

    storyList.assignAll(
        values.where((s) => vendorIds.contains(s.vendorID)).toList());
  }

  Future<void> _fetchAds(List<VendorModel> restaurants) async {
    final values = await FireStoreUtils.getAllAdvertisement();
    final vendorIds = restaurants.map((r) => r.id).toSet();

    advertisementList.assignAll(
        values.where((a) => vendorIds.contains(a.vendorId)).toList());
  }

  // ✅ Cached and parallel category + banner + favourite fetch
  Future<void> getVendorCategory() async {
    final results = await Future.wait([
      FireStoreUtils.getHomeVendorCategory(),
      FireStoreUtils.getHomeTopBanner(),
      FireStoreUtils.getHomeBottomBanner(),
    ]);

    vendorCategoryModel.assignAll(results[0] as List<VendorCategoryModel>);
    bannerModel.assignAll(results[1] as List<BannerModel>);
    bannerBottomModel.assignAll(results[2] as List<BannerModel>);

    await getFavouriteRestaurant();
  }

  Future<void> getFavouriteRestaurant() async {
    if (Constant.userModel != null) {
      final favs = await FireStoreUtils.getFavouriteRestaurant();
      favouriteList.assignAll(favs);
    }
  }

  // ✅ Optimized zone check
  Future<void> getZone() async {
    final zones = await FireStoreUtils.getZone();
    if (zones == null || zones.isEmpty) return;

    final current = LatLng(
      Constant.selectedLocation.location?.latitude ?? 0.0,
      Constant.selectedLocation.location?.longitude ?? 0.0,
    );

    for (final zone in zones) {
      final inside = Constant.isPointInPolygon(current, zone.area!);
      Constant.selectedZone = zone;
      Constant.isZoneAvailable = inside;
      if (inside) break;
    }
  }

  // ── Quick Filter State ──
  final RxSet<String> selectedFilters = <String>{}.obs;
  final RxList<VendorModel> filteredAllList = <VendorModel>[].obs;
  final RxList<VendorModel> openRestaurantList = <VendorModel>[].obs;
  final RxList<VendorModel> closedRestaurantList = <VendorModel>[].obs;

  static const List<String> filterKeys = [
    'Nearest',
    'Rating 4.0+',
    'Free Delivery',
    'Offers'
  ];

  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    _applyFilters();
  }

  void _applyFilters() {
    if (selectedFilters.isEmpty) {
      filteredAllList.assignAll(allNearestRestaurant);
    } else {
      filteredAllList.assignAll(_filterList(allNearestRestaurant));
    }
    _splitByStatus();
  }

  void _splitByStatus() {
    final now = DateTime.now();
    final split = HomeQualityHelpers.splitByStatus(
      source: filteredAllList,
      isOpen: (vendor) => Constant.statusCheckOpenORClose(vendorModel: vendor),
      nextOpeningOf: (vendor) => Constant.getNextOpeningDateTime(vendor, now),
    );
    openRestaurantList.assignAll(split.open);
    closedRestaurantList.assignAll(split.closed);
  }

  List<VendorModel> _filterList(List<VendorModel> source) {
    return HomeQualityHelpers.filterRestaurants(
      source: source,
      selectedFilters: selectedFilters,
      offerVendorIds: couponRestaurantList.map((vendor) => vendor.id),
      selfDeliveryEnabled: Constant.isSelfDeliveryFeature,
      ratingOf: (vendor) =>
          double.tryParse(Constant.calculateReview(
              reviewCount: vendor.reviewsCount.toString(),
              reviewSum: vendor.reviewsSum.toString())) ??
          0,
      distanceOf: (vendor) =>
          double.tryParse(Constant.getDistance(
              lat1: vendor.latitude.toString(),
              lng1: vendor.longitude.toString(),
              lat2: Constant.selectedLocation.location!.latitude.toString(),
              lng2:
                  Constant.selectedLocation.location!.longitude.toString())) ??
          0,
    );
  }

  void assignFallbackImages(List<VendorModel> vendors) {
    fallbackImageAssignments.clear();
    fallbackImageAssignments.addAll(HomeQualityHelpers.assignFallbackImages(
      vendors: vendors,
      stockImagesFor: Constant.getStockImagesForVendor,
    ));
    debugPrint(
        '📸 Fallback assignments: ${fallbackImageAssignments.length} / ${vendors.length} vendors');
  }

  @override
  void onClose() {
    _cartSubscription?.cancel();
    _restaurantSubscription?.cancel();
    super.onClose();
  }
}
