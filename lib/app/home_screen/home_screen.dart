import 'package:eatsipy_customer/app/address_screens/address_list_screen.dart';
import 'package:eatsipy_customer/app/advertisement_screens/all_advertisement_screen.dart';
import 'package:eatsipy_customer/app/cart_screen/cart_screen.dart';
import 'package:eatsipy_customer/app/home_screen/discount_restaurant_list_screen.dart';
import 'package:eatsipy_customer/app/home_screen/view_all_category_screen.dart';
import 'package:eatsipy_customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:eatsipy_customer/app/scan_qrcode_screen/scan_qr_code_screen.dart';
import 'package:eatsipy_customer/app/search_screen/search_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/home_controller.dart';
import 'package:eatsipy_customer/models/user_model.dart';
import 'package:eatsipy_customer/services/database_helper.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/custom_dialog_box.dart';
import 'package:eatsipy_customer/themes/round_button_fill.dart';
import 'package:eatsipy_customer/utils/preferences.dart';
import 'package:eatsipy_customer/utils/translation_notifier.dart';
import 'package:eatsipy_customer/widget/osm_map/map_picker_page.dart';
import 'package:eatsipy_customer/widget/place_picker/location_picker_screen.dart';
import 'package:eatsipy_customer/widget/place_picker/selected_location_model.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:eatsipy_customer/app/home_screen/widgets/all_restaurant.dart';
import 'package:eatsipy_customer/app/home_screen/widgets/new_arrival.dart';
import 'package:eatsipy_customer/app/home_screen/widgets/advertisement_home_card.dart';
import 'package:eatsipy_customer/app/home_screen/widgets/offer_view.dart';
import 'package:eatsipy_customer/app/home_screen/widgets/banner_view.dart';
import 'package:eatsipy_customer/app/home_screen/widgets/category_view.dart';
import 'package:eatsipy_customer/app/home_screen/widgets/story_view_widget.dart';
import 'package:eatsipy_customer/app/home_screen/widgets/map_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.00, -3),
                colors: [
                  isDark ? AppThemeData.secondary600 : AppThemeData.secondary50,
                  isDark ? AppThemeData.surfaceDark : AppThemeData.surface
                ],
                end: const Alignment(0, 1),
              ),
            ),
            child: controller.isLoading.value
                ? _buildShimmerSkeleton(context, isDark)
                : Constant.isZoneAvailable == false ||
                        controller.allNearestRestaurant.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/location.gif",
                              height: 120,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TranslatedText(
                              "No Restaurants Found in Your Area",
                              style: TextStyle(
                                  color: isDark
                                      ? AppThemeData.grey100
                                      : AppThemeData.grey800,
                                  fontSize: 22,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TranslatedText(
                              "Currently, there are no available restaurants in your zone. Try changing your location to find nearby options.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isDark
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey500,
                                  fontSize: 16,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RoundedButtonFill(
                              title: "Change Zone",
                              width: 55,
                              height: 5.5,
                              color: AppThemeData.primary300,
                              textColor: AppThemeData.grey50,
                              onPress: () async {
                                Get.offAll(const LocationPermissionScreen());
                              },
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top),
                        child: controller.isListView.value == false
                            ? const MapView()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppThemeData.space16),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                            height: AppThemeData.space8),
                                        // ── Location bar ──
                                        InkWell(
                                          onTap: () async {
                                            if (Constant.userModel != null) {
                                              Get.to(const AddressListScreen())!
                                                  .then(
                                                (value) {
                                                  if (value != null) {
                                                    ShippingAddress
                                                        addressModel = value;
                                                    Constant.selectedLocation =
                                                        addressModel;
                                                    controller.getData();
                                                  }
                                                },
                                              );
                                            } else {
                                              Constant.checkPermission(
                                                  onTap: () async {
                                                    ShowToastDialog.showLoader(
                                                        "Please wait");
                                                    ShippingAddress
                                                        addressModel =
                                                        ShippingAddress();
                                                    try {
                                                      await Geolocator
                                                          .requestPermission();
                                                      await Geolocator
                                                          .getCurrentPosition();
                                                      ShowToastDialog
                                                          .closeLoader();
                                                      if (Constant
                                                              .selectedMapType ==
                                                          'osm') {
                                                        final result =
                                                            await Get.to(() =>
                                                                MapPickerPage());
                                                        if (result != null) {
                                                          final firstPlace =
                                                              result;
                                                          final lat = firstPlace
                                                              .coordinates
                                                              .latitude;
                                                          final lng = firstPlace
                                                              .coordinates
                                                              .longitude;
                                                          final address =
                                                              firstPlace
                                                                  .address;

                                                          addressModel
                                                                  .addressAs =
                                                              "Home";
                                                          addressModel
                                                                  .locality =
                                                              address
                                                                  .toString();
                                                          addressModel
                                                                  .location =
                                                              UserLocation(
                                                                  latitude: lat,
                                                                  longitude:
                                                                      lng);
                                                          Constant.selectedLocation =
                                                              addressModel;
                                                          controller.getData();
                                                          Get.back();
                                                        }
                                                      } else {
                                                        Get.to(LocationPickerScreen())!
                                                            .then(
                                                                (value) async {
                                                          if (value != null) {
                                                            SelectedLocationModel
                                                                selectedLocationModel =
                                                                value;

                                                            ShippingAddress
                                                                addressModel =
                                                                ShippingAddress();
                                                            addressModel
                                                                    .addressAs =
                                                                "Home";
                                                            addressModel
                                                                    .locality =
                                                                Constant.formatAddress(
                                                                    selectedLocation:
                                                                        selectedLocationModel);
                                                            addressModel.location = UserLocation(
                                                                latitude:
                                                                    selectedLocationModel
                                                                        .latLng!
                                                                        .latitude,
                                                                longitude:
                                                                    selectedLocationModel
                                                                        .latLng!
                                                                        .longitude);
                                                            Constant.selectedLocation =
                                                                addressModel;
                                                            controller
                                                                .getData();
                                                            Get.back();
                                                          }
                                                        });
                                                      }
                                                    } catch (e) {
                                                      await placemarkFromCoordinates(
                                                              19.228825,
                                                              72.854118)
                                                          .then(
                                                              (valuePlaceMaker) {
                                                        Placemark placeMark =
                                                            valuePlaceMaker[0];
                                                        addressModel.location =
                                                            UserLocation(
                                                                latitude:
                                                                    19.228825,
                                                                longitude:
                                                                    72.854118);
                                                        String currentLocation =
                                                            "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                                                        addressModel.locality =
                                                            currentLocation;
                                                      });

                                                      Constant.selectedLocation =
                                                          addressModel;
                                                      ShowToastDialog
                                                          .closeLoader();
                                                      controller.getData();
                                                    }
                                                  },
                                                  context: context);
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/ic_location_pin.svg",
                                                width: 18,
                                                height: 18,
                                                colorFilter: ColorFilter.mode(
                                                    AppThemeData.primary300,
                                                    BlendMode.srcIn),
                                              ),
                                              const SizedBox(
                                                  width: AppThemeData.space8),
                                              Expanded(
                                                child: ValueListenableBuilder(
                                                  valueListenable:
                                                      TranslationNotifier
                                                          .refresh,
                                                  builder: (_, __, ___) {
                                                    return Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            Constant
                                                                .selectedLocation
                                                                .getFullAddress()
                                                                .tr,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: AppThemeData
                                                                .space4),
                                                        SvgPicture.asset(
                                                            "assets/icons/ic_down.svg"),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                            height: AppThemeData.space12),
                                        // ── Search bar + Cart ──
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  Get.to(const SearchScreen(),
                                                      arguments: {
                                                        "vendorList": controller
                                                            .allNearestRestaurant
                                                      });
                                                },
                                                child: Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? AppThemeData.grey800
                                                        : AppThemeData.grey100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppThemeData
                                                                .radius12),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                          width: AppThemeData
                                                              .space16),
                                                      SvgPicture.asset(
                                                        "assets/icons/ic_search.svg",
                                                        width: 20,
                                                        height: 20,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                          isDark
                                                              ? AppThemeData
                                                                  .grey400
                                                              : AppThemeData
                                                                  .grey500,
                                                          BlendMode.srcIn,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: AppThemeData
                                                              .space12),
                                                      TranslatedText(
                                                        "Search dishes, restaurants...",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: isDark
                                                              ? AppThemeData
                                                                  .grey500
                                                              : AppThemeData
                                                                  .grey400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppThemeData.space12),
                                            Obx(
                                              () => HomeCartButton(
                                                isDark: isDark,
                                                count: cartItem.length,
                                                onTap: () async {
                                                  (await Get.to(
                                                      const CartScreen()));
                                                  controller.getCartData();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height: AppThemeData.space8),
                                      ],
                                    ),
                                  ),
                                  // ── Quick Filters ──
                                  SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppThemeData.space16),
                                      itemCount:
                                          HomeController.filterKeys.length,
                                      itemBuilder: (context, index) {
                                        final filter =
                                            HomeController.filterKeys[index];
                                        final isSelected = controller
                                            .selectedFilters
                                            .contains(filter);
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              right: AppThemeData.space8),
                                          child: FilterChip(
                                            selected: isSelected,
                                            label: TranslatedText(filter,
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: isSelected
                                                      ? AppThemeData.grey50
                                                      : (isDark
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600),
                                                )),
                                            selectedColor:
                                                AppThemeData.primary300,
                                            backgroundColor: isDark
                                                ? AppThemeData.grey800
                                                : AppThemeData.grey50,
                                            side: BorderSide(
                                              color: isSelected
                                                  ? AppThemeData.primary300
                                                  : (isDark
                                                      ? AppThemeData.grey700
                                                      : AppThemeData.grey200),
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppThemeData.radius20)),
                                            showCheckmark: false,
                                            elevation: isSelected ? 2 : 0,
                                            pressElevation: 1,
                                            shadowColor: isSelected
                                                ? AppThemeData.primary300
                                                    .withValues(alpha: 0.3)
                                                : Colors.transparent,
                                            onSelected: (_) =>
                                                controller.toggleFilter(filter),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: AppThemeData.space4),
                                  Expanded(
                                    child: CustomScrollView(
                                      slivers: [
                                        SliverToBoxAdapter(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // ── Categories ──
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    titleView(isDark,
                                                        "Explore the Categories",
                                                        () {
                                                      Get.to(
                                                          const ViewAllCategoryScreen());
                                                    }),
                                                    const SizedBox(height: 10),
                                                    CategoryView(
                                                        controller: controller),
                                                  ],
                                                ),
                                              ),
                                              // ── Top Banner ──
                                              if (controller
                                                  .bannerModel.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    child: BannerView(
                                                        controller: controller),
                                                  ),
                                                ),
                                              // ── Offers ──
                                              if (controller
                                                  .couponRestaurantList
                                                  .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        titleView(isDark,
                                                            "Largest Discounts",
                                                            () {
                                                          Get.to(
                                                              const DiscountRestaurantListScreen(),
                                                              arguments: {
                                                                "vendorList":
                                                                    controller
                                                                        .couponRestaurantList,
                                                                "couponList":
                                                                    controller
                                                                        .couponList,
                                                                "title":
                                                                    "Discounts Restaurants"
                                                              });
                                                        }),
                                                        const SizedBox(
                                                            height: 16),
                                                        OfferView(
                                                            controller:
                                                                controller),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              // ── Featured & Trending ──
                                              if (controller
                                                      .newArrivalRestaurantList
                                                      .length >=
                                                  3)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TranslatedText(
                                                          "Featured & Trending",
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: isDark
                                                                ? AppThemeData
                                                                    .grey50
                                                                : AppThemeData
                                                                    .grey900,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        NewArrival(
                                                            controller:
                                                                controller),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              // ── Stories ──
                                              if (controller
                                                      .storyList.isNotEmpty &&
                                                  Constant.storyEnable != false)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    child: StoryView(
                                                        controller: controller),
                                                  ),
                                                ),
                                              // ── Advertisements ──
                                              if (Constant.isEnableAdsFeature ==
                                                      true &&
                                                  controller.advertisementList
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20),
                                                  child: Container(
                                                    color: AppThemeData
                                                        .primary300
                                                        .withAlpha(40),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 16),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TranslatedText(
                                                                  "Highlights for you",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        16,
                                                                    color: isDark
                                                                        ? AppThemeData
                                                                            .grey50
                                                                        : AppThemeData
                                                                            .grey900,
                                                                  ),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Get.to(AllAdvertisementScreen())
                                                                      ?.then(
                                                                          (value) {
                                                                    controller
                                                                        .getFavouriteRestaurant();
                                                                  });
                                                                },
                                                                child:
                                                                    TranslatedText(
                                                                  "View all",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    color: isDark
                                                                        ? AppThemeData
                                                                            .primary300
                                                                        : AppThemeData
                                                                            .primary300,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          SizedBox(
                                                            height: 220,
                                                            child: ListView
                                                                .builder(
                                                              physics:
                                                                  const BouncingScrollPhysics(),
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              itemCount: controller
                                                                          .advertisementList
                                                                          .length >=
                                                                      10
                                                                  ? 10
                                                                  : controller
                                                                      .advertisementList
                                                                      .length,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(0),
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return AdvertisementHomeCard(
                                                                    key: ValueKey(
                                                                        index),
                                                                    controller:
                                                                        controller,
                                                                    model: controller
                                                                            .advertisementList[
                                                                        index]);
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        // ── Empty state: no restaurants delivering ──
                                        if (controller
                                                .openRestaurantList.isEmpty &&
                                            controller.closedRestaurantList
                                                .isNotEmpty)
                                          SliverToBoxAdapter(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? AppThemeData.grey800
                                                      : const Color(0xFFFFF8E1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppThemeData
                                                              .radius12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.schedule,
                                                        size: 20,
                                                        color: isDark
                                                            ? AppThemeData
                                                                .warning300
                                                            : const Color(
                                                                0xFFF59E0B)),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TranslatedText(
                                                            "No restaurants are accepting orders right now.",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey100
                                                                  : AppThemeData
                                                                      .grey800,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                          Text(
                                                            "${controller.closedRestaurantList.length} restaurants will be opening soon.",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey400
                                                                  : AppThemeData
                                                                      .grey500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        // ── Restaurants Delivering Now ──
                                        if (controller
                                            .openRestaurantList.isNotEmpty)
                                          SliverToBoxAdapter(
                                            child: _sectionHeader(
                                              isDark,
                                              "Restaurants Delivering Now",
                                              controller
                                                  .openRestaurantList.length,
                                            ),
                                          ),
                                        if (controller
                                            .openRestaurantList.isNotEmpty)
                                          SliverPadding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            sliver: AllRestaurant(
                                              controller: controller,
                                              restaurants:
                                                  controller.openRestaurantList,
                                              isLastSection: controller
                                                  .closedRestaurantList.isEmpty,
                                            ),
                                          ),
                                        // ── Currently Unavailable ──
                                        if (controller
                                            .closedRestaurantList.isNotEmpty)
                                          SliverToBoxAdapter(
                                            child: _sectionHeader(
                                              isDark,
                                              controller.openRestaurantList
                                                      .isEmpty
                                                  ? "Opening Soon"
                                                  : "Currently Unavailable",
                                              controller
                                                  .closedRestaurantList.length,
                                              subtitle:
                                                  "Sorted by nearest opening time",
                                            ),
                                          ),
                                        if (controller
                                            .closedRestaurantList.isNotEmpty)
                                          SliverPadding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            sliver: AllRestaurant(
                                              controller: controller,
                                              restaurants: controller
                                                  .closedRestaurantList,
                                              isMuted: true,
                                              isLastSection: true,
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                      ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: !Constant.showHomeQuickActions
              ? null
              : Container(
                  decoration: BoxDecoration(
                      color:
                          isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppThemeData.grey900
                                : AppThemeData.grey50,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    controller.isListView.value = true;
                                  },
                                  child: ClipOval(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: controller.isListView.value
                                                ? AppThemeData.primary300
                                                : null),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            "assets/icons/ic_view_grid_list.svg",
                                            colorFilter: ColorFilter.mode(
                                                controller.isListView.value
                                                    ? AppThemeData.grey50
                                                    : AppThemeData.grey500,
                                                BlendMode.srcIn),
                                          ),
                                        )),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.isListView.value = false;
                                    controller.update();
                                  },
                                  child: ClipOval(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                controller.isListView.value ==
                                                        false
                                                    ? AppThemeData.primary300
                                                    : null),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            "assets/icons/ic_map_draw.svg",
                                            colorFilter: ColorFilter.mode(
                                                controller.isListView.value ==
                                                        false
                                                    ? AppThemeData.grey50
                                                    : AppThemeData.grey500,
                                                BlendMode.srcIn),
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(const ScanQrCodeScreen());
                          },
                          child: ClipOval(
                            child: Container(
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.asset(
                                    "assets/icons/ic_scan_code.svg",
                                    colorFilter: ColorFilter.mode(
                                        isDark
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey500,
                                        BlendMode.srcIn),
                                  ),
                                )),
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        DropdownButton<String>(
                          isDense: false,
                          underline: const SizedBox(),
                          value: controller.selectedOrderTypeValue.value,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: <String>[
                            'Delivery',
                            if (Constant.takeawayEnabled) 'TakeAway'.tr
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: TranslatedText(
                                value,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (cartItem.isEmpty) {
                              await Preferences.setString(
                                  Preferences.foodDeliveryType, value!);
                              controller.selectedOrderTypeValue.value = value;
                              controller.getData();
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: "Alert",
                                      descriptions:
                                          "Do you really want to change the delivery option? Your cart will be empty.",
                                      positiveString: "Ok",
                                      negativeString: "Cancel",
                                      positiveClick: () async {
                                        await Preferences.setString(
                                            Preferences.foodDeliveryType,
                                            value!);
                                        controller.selectedOrderTypeValue
                                            .value = value;
                                        controller.getData();
                                        DatabaseHelper.instance
                                            .deleteAllCartProducts();
                                        controller.cartProvider.clearDatabase();
                                        controller.getCartData();
                                        Get.back();
                                      },
                                      negativeClick: () {
                                        Get.back();
                                      },
                                      img: null,
                                    );
                                  });
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _sectionHeader(bool isDark, String title, int count,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TranslatedText(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "($count)",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TranslatedText(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerSkeleton(BuildContext context, bool isDark) {
    final baseColor = isDark ? AppThemeData.grey800 : AppThemeData.grey200;
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: AppThemeData.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppThemeData.space12),
                Row(
                  children: [
                    _shimmerBox(18, 18, baseColor, isCircle: true),
                    const SizedBox(width: AppThemeData.space8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerBox(60, 10, baseColor, borderRadius: 4),
                          const SizedBox(height: 6),
                          _shimmerBox(180, 14, baseColor, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppThemeData.space16),
                Row(
                  children: [
                    Expanded(
                        child: _shimmerBox(double.infinity, 48, baseColor,
                            borderRadius: AppThemeData.radius12)),
                    const SizedBox(width: AppThemeData.space12),
                    _shimmerBox(48, 48, baseColor,
                        borderRadius: AppThemeData.radius12),
                  ],
                ),
                const SizedBox(height: AppThemeData.space16),
                Row(
                  children: List.generate(
                      4,
                      (i) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: i < 3 ? AppThemeData.space8 : 0),
                              child: _shimmerBox(double.infinity, 36, baseColor,
                                  borderRadius: AppThemeData.radius20),
                            ),
                          )),
                ),
                const SizedBox(height: AppThemeData.space24),
                _shimmerBox(120, 16, baseColor, borderRadius: 4),
                const SizedBox(height: AppThemeData.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      4,
                      (_) => Column(
                            children: [
                              _shimmerBox(60, 60, baseColor, isCircle: true),
                              const SizedBox(height: 6),
                              _shimmerBox(48, 10, baseColor, borderRadius: 4),
                            ],
                          )),
                ),
                const SizedBox(height: AppThemeData.space24),
                _shimmerBox(double.infinity, 140, baseColor,
                    borderRadius: AppThemeData.radius16),
                const SizedBox(height: AppThemeData.space24),
                _shimmerBox(double.infinity, 200, baseColor,
                    borderRadius: AppThemeData.radius16),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.18,
                child: Image.asset("assets/images/simmer_gif.gif",
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, Color color,
      {double borderRadius = 0, bool isCircle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  Row titleView(bool isDark, String name, Function()? onPress) {
    return Row(
      children: [
        Expanded(
          child: TranslatedText(
            name,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            onPress!();
          },
          child: TranslatedText(
            "View all",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Urbanist',
              color: isDark ? AppThemeData.primary300 : AppThemeData.primary300,
            ),
          ),
        )
      ],
    );
  }
}

class HomeCartButton extends StatelessWidget {
  final bool isDark;
  final int count;
  final VoidCallback onTap;

  const HomeCartButton({
    super.key,
    required this.isDark,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                borderRadius: BorderRadius.circular(AppThemeData.radius12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  "assets/icons/ic_shoping_cart.svg",
                  colorFilter: ColorFilter.mode(
                    isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                key: const ValueKey('home-cart-badge'),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppThemeData.cartBadge,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  "$count",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    color: AppThemeData.grey50,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
