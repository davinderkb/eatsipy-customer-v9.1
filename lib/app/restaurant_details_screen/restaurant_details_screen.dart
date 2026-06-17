import 'package:badges/badges.dart' as badges;
import 'package:eatsipy_customer/app/auth_screen/login_screen.dart';
import 'package:eatsipy_customer/app/cart_screen/cart_screen.dart';
import 'package:eatsipy_customer/app/dine_in_screeen/dine_in_details_screen.dart';
import 'package:eatsipy_customer/app/review_list_screen/review_list_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/restaurant_details_controller.dart';
import 'package:eatsipy_customer/models/cart_product_model.dart';
import 'package:eatsipy_customer/models/coupon_model.dart';
import 'package:eatsipy_customer/models/favourite_item_model.dart';
import 'package:eatsipy_customer/models/favourite_model.dart';
import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/vendor_category_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/themes/round_button_fill.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: RestaurantDetailsController(),
        autoRemove: false,
        builder: (controller) {
          return Scaffold(
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : InkWell(
                    onTap: () {
                      Get.to(const CartScreen());
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppThemeData.primary300,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TranslatedText(
                            '${cartItem.length} ${'items'}',
                            style: TextStyle(
                              fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                              color: AppThemeData.grey50,
                              fontSize: 16,
                            ),
                          ),
                          TranslatedText(
                            'View Cart',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              color: AppThemeData.grey50,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            appBar: AppBar(
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.grey50,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              leading: InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.arrow_back, color: isDark ? AppThemeData.grey50 : AppThemeData.grey900),
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    if (controller.favouriteList.where((p0) => p0.restaurantId == controller.vendorModel.value.id).isNotEmpty) {
                      FavouriteModel favouriteModel = FavouriteModel(restaurantId: controller.vendorModel.value.id, userId: FireStoreUtils.getCurrentUid());
                      controller.favouriteList.removeWhere((item) => item.restaurantId == controller.vendorModel.value.id);
                      await FireStoreUtils.removeFavouriteRestaurant(favouriteModel);
                    } else {
                      FavouriteModel favouriteModel = FavouriteModel(restaurantId: controller.vendorModel.value.id, userId: FireStoreUtils.getCurrentUid());
                      controller.favouriteList.add(favouriteModel);
                      await FireStoreUtils.setFavouriteRestaurant(favouriteModel);
                    }
                  },
                  child: Obx(
                    () => controller.favouriteList.where((p0) => p0.restaurantId == controller.vendorModel.value.id).isNotEmpty
                        ? SvgPicture.asset(
                            "assets/icons/ic_like_fill.svg",
                            colorFilter: ColorFilter.mode(isDark ? AppThemeData.grey50 : AppThemeData.grey900, BlendMode.srcIn),
                          )
                        : SvgPicture.asset(
                            "assets/icons/ic_like.svg",
                            colorFilter: ColorFilter.mode(isDark ? AppThemeData.grey400 : AppThemeData.grey600, BlendMode.srcIn),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => badges.Badge(
                    showBadge: cartItem.isEmpty ? false : true,
                    badgeContent: Text(
                      "${cartItem.length}",
                      style: const TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        color: AppThemeData.grey50,
                      ),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      shape: badges.BadgeShape.circle,
                      badgeColor: AppThemeData.secondary300,
                    ),
                    child: InkWell(
                      onTap: () {
                        Get.to(const CartScreen());
                      },
                      child: SvgPicture.asset(
                        "assets/icons/ic_shoping_cart.svg",
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(isDark ? AppThemeData.grey50 : AppThemeData.grey900, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (controller.vendorModel.value.workingHours == null || controller.vendorModel.value.workingHours!.isEmpty) {
                                        ShowToastDialog.showToast("Timing is not added by restaurant");
                                      } else {
                                        timeShowBottomSheet(context, controller);
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: TranslatedText(
                                                controller.vendorModel.value.title.toString(),
                                                textAlign: TextAlign.start,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  overflow: TextOverflow.ellipsis,
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            InkWell(
                                              onTap: () {
                                                Get.to(const ReviewListScreen(), arguments: {"vendorModel": controller.vendorModel.value});
                                              },
                                              child: Container(
                                                decoration: ShapeDecoration(
                                                  color: isDark ? AppThemeData.primary600 : AppThemeData.primary50,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SvgPicture.asset(
                                                        "assets/icons/ic_star.svg",
                                                        colorFilter: ColorFilter.mode(AppThemeData.primary300, BlendMode.srcIn),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        Constant.calculateReview(
                                                            reviewCount: controller.vendorModel.value.reviewsCount!.toStringAsFixed(0),
                                                            reviewSum: controller.vendorModel.value.reviewsSum.toString()),
                                                        style: TextStyle(
                                                          color: AppThemeData.primary300,
                                                          fontFamily: 'Urbanist',
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (controller.vendorModel.value.categoryTitle != null && (controller.vendorModel.value.categoryTitle as List).isNotEmpty)
                                              ? (controller.vendorModel.value.categoryTitle as List).join(', ')
                                              : controller.vendorModel.value.location.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w400,
                                            color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 16,
                                              color: controller.isOpen.value ? AppThemeData.success400 : AppThemeData.danger300,
                                            ),
                                            const SizedBox(width: 4),
                                            TranslatedText(
                                              controller.isOpen.value
                                                  ? (controller.todayTimingDisplay.isNotEmpty ? 'Open  ${controller.todayTimingDisplay}' : 'Open')
                                                  : 'Closed',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w500,
                                                color: controller.isOpen.value ? AppThemeData.success400 : AppThemeData.danger300,
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons.chevron_right,
                                              size: 20,
                                              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  (Constant.isDineInEnable == true &&
                                          controller.vendorModel.value.enabledDiveInFuture == true &&
                                          controller.vendorModel.value.openDineTime != null &&
                                          controller.vendorModel.value.openDineTime?.isNotEmpty == true)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TranslatedText(
                                              "Also applicable on table booking",
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Get.to(const DineInDetailsScreen(), arguments: {"vendorModel": controller.vendorModel.value});
                                              },
                                              child: Container(
                                                height: 80,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(width: 1, color: isDark ? AppThemeData.grey900 : AppThemeData.grey50),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Image.asset(isDark ? "assets/images/ic_table_dark.gif" : "assets/images/ic_table.gif"),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            TranslatedText(
                                                              "Table Booking",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                fontFamily: 'Urbanist',
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                            TranslatedText(
                                                              "Quick Confirmation",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                                                fontFamily: 'Urbanist',
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : const SizedBox(),
                                  controller.couponList.isEmpty
                                      ? const SizedBox()
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TranslatedText(
                                              "Additional Offers",
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            CouponListView(
                                              controller: controller,
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TranslatedText(
                                    "Menu",
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppThemeData.radius24),
                                        color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                                        boxShadow: AppThemeData.shadowSm(isDark),
                                      ),
                                      child: TextFormField(
                                        controller: controller.searchEditingController.value,
                                        onChanged: (value) => controller.searchProduct(value),
                                        style: TextStyle(
                                          color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Search dishes, meals...',
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: isDark ? AppThemeData.grey600 : AppThemeData.grey400,
                                            fontFamily: 'Urbanist',
                                          ),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: SvgPicture.asset("assets/icons/ic_search.svg"),
                                          ),
                                          filled: true,
                                          fillColor: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppThemeData.radius24), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppThemeData.radius24), borderSide: BorderSide.none),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppThemeData.radius24), borderSide: BorderSide(color: AppThemeData.primary300, width: 1)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (controller.isVag.value == true) {
                                            controller.isVag.value = false;
                                          } else {
                                            controller.isVag.value = true;
                                          }
                                          controller.filterRecord();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: controller.isVag.value
                                              ? ShapeDecoration(
                                                  color: isDark ? AppThemeData.primary600 : AppThemeData.lightGreen,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(width: 1, color: AppThemeData.darkGreen),
                                                    borderRadius: BorderRadius.circular(120),
                                                  ),
                                                )
                                              : ShapeDecoration(
                                                  color: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(width: 1, color: isDark ? AppThemeData.grey700 : AppThemeData.grey200),
                                                    borderRadius: BorderRadius.circular(120),
                                                  ),
                                                ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/ic_veg.svg",
                                                height: 20,
                                                width: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              TranslatedText(
                                                'Veg',
                                                style: TextStyle(
                                                  color: controller.isVag.value ? AppThemeData.darkGreen : (isDark ? AppThemeData.grey100 : AppThemeData.grey800),
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w600,
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
                                          if (controller.isNonVag.value == true) {
                                            controller.isNonVag.value = false;
                                          } else {
                                            controller.isNonVag.value = true;
                                          }
                                          controller.filterRecord();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: controller.isNonVag.value
                                              ? ShapeDecoration(
                                                  color: isDark ? const Color(0xFF3D1012) : AppThemeData.danger50,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(width: 1, color: AppThemeData.danger300),
                                                    borderRadius: BorderRadius.circular(120),
                                                  ),
                                                )
                                              : ShapeDecoration(
                                                  color: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(width: 1, color: isDark ? AppThemeData.grey700 : AppThemeData.grey200),
                                                    borderRadius: BorderRadius.circular(120),
                                                  ),
                                                ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/ic_nonveg.svg",
                                                height: 20,
                                                width: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              TranslatedText(
                                                'Non Veg',
                                                style: TextStyle(
                                                  color: controller.isNonVag.value ? AppThemeData.danger300 : (isDark ? AppThemeData.grey100 : AppThemeData.grey800),
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (controller.vendorCategoryList.isNotEmpty)
                              Container(
                                color: isDark ? AppThemeData.surfaceDark : AppThemeData.grey50,
                                height: 40,
                                child: Obx(() => ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: controller.vendorCategoryList.length,
                                  itemBuilder: (context, index) {
                                    final cat = controller.vendorCategoryList[index];
                                    final isActive = controller.activeCategoryIndex.value == index;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: InkWell(
                                        onTap: () => controller.scrollToCategory(index),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? (isDark ? AppThemeData.primary600 : AppThemeData.primary50)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isActive
                                                  ? AppThemeData.primary300
                                                  : (isDark ? AppThemeData.grey700 : AppThemeData.grey200),
                                            ),
                                          ),
                                          child: Text(
                                            cat.title.toString().tr,
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                              fontSize: 13,
                                              color: isActive
                                                  ? AppThemeData.primary300
                                                  : (isDark ? AppThemeData.grey300 : AppThemeData.grey600),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                              ),
                            const SizedBox(height: 8),
                            ProductListView(controller: controller),
                          ],
                        ),
                      ),
          );
        });
  }

  Future timeShowBottomSheet(BuildContext context, RestaurantDetailsController productModel) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.70,
              child: StatefulBuilder(builder: (context1, setState) {
                final isDark = Theme.of(context1).brightness == Brightness.dark;
                return Scaffold(
                  backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              width: 134,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: ShapeDecoration(
                                color: isDark ? AppThemeData.grey50 : AppThemeData.grey800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: productModel.vendorModel.value.workingHours!.length,
                            itemBuilder: (context, dayIndex) {
                              WorkingHours workingHours = productModel.vendorModel.value.workingHours![dayIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      "${workingHours.day}",
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    workingHours.timeslot == null || workingHours.timeslot!.isEmpty
                                        ? const SizedBox()
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: workingHours.timeslot!.length,
                                            itemBuilder: (context, timeIndex) {
                                              Timeslot timeSlotModel = workingHours.timeslot![timeIndex];
                                              return Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        decoration: BoxDecoration(
                                                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                            border: Border.all(color: isDark ? AppThemeData.grey400 : AppThemeData.grey200)),
                                                        child: Center(
                                                          child: TranslatedText(
                                                            timeSlotModel.from.toString(),
                                                            style: TextStyle(
                                                              fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                                                              fontSize: 14,
                                                              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        decoration: BoxDecoration(
                                                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                            border: Border.all(color: isDark ? AppThemeData.grey400 : AppThemeData.grey200)),
                                                        child: Center(
                                                          child: TranslatedText(
                                                            timeSlotModel.to.toString(),
                                                            style: TextStyle(
                                                              fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                                                              fontSize: 14,
                                                              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ));
  }
}

class CouponListView extends StatelessWidget {
  final RestaurantDetailsController controller;

  const CouponListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: Responsive.height(9, context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.couponList.length,
        itemBuilder: (BuildContext context, int index) {
          CouponModel offerModel = controller.couponList[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: isDark ? AppThemeData.grey800 : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: SizedBox(
                  width: Responsive.width(80, context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/offer_gif.gif"), fit: BoxFit.fill)),
                        child: Center(
                            child: TranslatedText(
                          offerModel.discountType == "Fix Price" ? Constant.amountShow(amount: offerModel.discount) : "${offerModel.discount}%",
                          style: TextStyle(color: isDark ? AppThemeData.grey50 : AppThemeData.grey50, fontFamily: 'Urbanist', fontWeight: FontWeight.w600, fontSize: 12),
                        )),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            offerModel.description.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: offerModel.code.toString())).then(
                                (value) {
                                  ShowToastDialog.showToast("Copied");
                                },
                              );
                            },
                            child: Row(
                              children: [
                                TranslatedText(
                                  offerModel.code.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                SvgPicture.asset("assets/icons/ic_copy.svg"),
                                const SizedBox(height: 10, child: VerticalDivider()),
                                const SizedBox(
                                  width: 5,
                                ),
                                TranslatedText(
                                  Constant.timestampToDateTime(offerModel.expiresAt!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductListView extends StatelessWidget {
  final RestaurantDetailsController controller;

  const ProductListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: controller.vendorCategoryList.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          VendorCategoryModel vendorCategoryModel = controller.vendorCategoryList[index];
          return ExpansionTile(
            key: controller.categoryKeys[vendorCategoryModel.id.toString()],
            childrenPadding: EdgeInsets.zero,
            tilePadding: EdgeInsets.zero,
            shape: const Border(),
            initiallyExpanded: true,
            title: Text(
              "${vendorCategoryModel.title.toString().tr} (${controller.productList.where((p0) => p0.categoryID == vendorCategoryModel.id).toList().length})",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
              ),
            ),
            children: [
              Obx(
                () => ListView.builder(
                  itemCount: controller.productList.where((p0) => p0.categoryID == vendorCategoryModel.id).toList().length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    ProductModel productModel = controller.productList.where((p0) => p0.categoryID == vendorCategoryModel.id).toList()[index];

                    String price = "0.0";
                    String disPrice = "0.0";
                    List<String> selectedVariants = [];
                    List<String> selectedIndexVariants = [];
                    List<String> selectedIndexArray = [];
                    if (productModel.itemAttribute != null) {
                      if (productModel.itemAttribute!.attributes!.isNotEmpty) {
                        for (var element in productModel.itemAttribute!.attributes!) {
                          if (element.attributeOptions!.isNotEmpty) {
                            selectedVariants.add(productModel.itemAttribute!.attributes![productModel.itemAttribute!.attributes!.indexOf(element)].attributeOptions![0].toString());
                            selectedIndexVariants.add('${productModel.itemAttribute!.attributes!.indexOf(element)} _${productModel.itemAttribute!.attributes![0].attributeOptions![0].toString()}');
                            selectedIndexArray.add('${productModel.itemAttribute!.attributes!.indexOf(element)}_0');
                          }
                        }
                      }
                      if (productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty) {
                        price = Constant.productCommissionPrice(
                            controller.vendorModel.value, productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantPrice ?? '0');
                        disPrice = "0";
                      }
                    } else {
                      price = Constant.productCommissionPrice(controller.vendorModel.value, productModel.price.toString());
                      disPrice = double.parse(productModel.disPrice.toString()) <= 0 ? "0" : Constant.productCommissionPrice(controller.vendorModel.value, productModel.disPrice.toString());
                    }
                    final hasPhoto = productModel.photo != null && productModel.photo!.trim().isNotEmpty && productModel.photo != 'null' && productModel.photo!.startsWith('http');
                    return Column(
                      children: [
                        Padding(
                      padding: EdgeInsets.symmetric(vertical: AppThemeData.space12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    productModel.nonveg == true ? SvgPicture.asset("assets/icons/ic_nonveg.svg") : SvgPicture.asset("assets/icons/ic_veg.svg"),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    TranslatedText(
                                      productModel.nonveg == true ? "Non Veg." : "Pure veg.",
                                      style: TextStyle(
                                        color: productModel.nonveg == true ? AppThemeData.danger300 : AppThemeData.success400,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TranslatedText(
                                  productModel.name.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                double.parse(disPrice) <= 0
                                    ? Text(
                                        Constant.amountShow(amount: price),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            Constant.amountShow(amount: disPrice),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            Constant.amountShow(amount: price),
                                            style: TextStyle(
                                              fontSize: 14,
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
                                              color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                if ((productModel.reviewsCount ?? 0) > 0)
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/ic_star.svg",
                                        colorFilter: const ColorFilter.mode(AppThemeData.warning300, BlendMode.srcIn),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${Constant.calculateReview(reviewCount: productModel.reviewsCount!.toStringAsFixed(0), reviewSum: productModel.reviewsSum.toString())} (${productModel.reviewsCount!.toStringAsFixed(0)})",
                                        style: TextStyle(
                                          color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                TranslatedText(
                                  "${productModel.description}",
                                  maxLines: 2,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (!hasPhoto && controller.isOpen.value)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 90,
                                        child: selectedVariants.isNotEmpty || (productModel.addOnsTitle != null && productModel.addOnsTitle!.isNotEmpty)
                                            ? InkWell(
                                                onTap: () async {
                                                  if (Constant.userModel?.id == null) {
                                                    ShowToastDialog.showToast("Please login first to add items to your cart.");
                                                    Get.offAll(LoginScreen());
                                                  } else {
                                                    controller.selectedVariants.clear();
                                                    controller.selectedIndexVariants.clear();
                                                    controller.selectedIndexArray.clear();
                                                    controller.selectedAddOns.clear();
                                                    controller.quantity.value = 1;
                                                    if (productModel.itemAttribute != null) {
                                                      if (productModel.itemAttribute!.attributes!.isNotEmpty) {
                                                        for (var element in productModel.itemAttribute!.attributes!) {
                                                          if (element.attributeOptions!.isNotEmpty) {
                                                            controller.selectedVariants
                                                                .add(productModel.itemAttribute!.attributes![productModel.itemAttribute!.attributes!.indexOf(element)].attributeOptions![0].toString());
                                                            controller.selectedIndexVariants.add(
                                                                '${productModel.itemAttribute!.attributes!.indexOf(element)} _${productModel.itemAttribute!.attributes![0].attributeOptions![0].toString()}');
                                                            controller.selectedIndexArray.add('${productModel.itemAttribute!.attributes!.indexOf(element)}_0');
                                                          }
                                                        }
                                                      }
                                                      final bool productIsInList = cartItem.any((product) =>
                                                          product.id ==
                                                          "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                                      if (productIsInList) {
                                                        CartProductModel element = cartItem.firstWhere((product) =>
                                                            product.id ==
                                                            "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                                        controller.quantity.value = element.quantity!;
                                                        if (element.extras != null) {
                                                          for (var element in element.extras!) {
                                                            controller.selectedAddOns.add(element);
                                                          }
                                                        }
                                                      }
                                                    } else {
                                                      if (cartItem.where((product) => product.id == "${productModel.id}").isNotEmpty) {
                                                        CartProductModel element = cartItem.firstWhere((product) => product.id == "${productModel.id}");
                                                        controller.quantity.value = element.quantity!;
                                                        if (element.extras != null) {
                                                          for (var element in element.extras!) {
                                                            controller.selectedAddOns.add(element);
                                                          }
                                                        }
                                                      }
                                                    }
                                                    controller.update();
                                                    controller.calculatePrice(productModel);
                                                    productDetailsBottomSheet(context, productModel);
                                                  }
                                                },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: isDark ? AppThemeData.grey900 : Colors.white,
                                                    borderRadius: BorderRadius.circular(AppThemeData.radius8),
                                                    border: Border.all(color: AppThemeData.primary300, width: 1.5),
                                                    boxShadow: AppThemeData.shadowSm(isDark),
                                                  ),
                                                  child: Center(
                                                    child: Text('ADD', style: TextStyle(color: AppThemeData.primary300, fontFamily: 'Urbanist', fontWeight: FontWeight.w600, fontSize: 14)),
                                                  ),
                                                ),
                                              )
                                            : Obx(
                                                () => cartItem.where((p0) => p0.id == productModel.id).isNotEmpty
                                                    ? Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: isDark ? AppThemeData.grey900 : Colors.white,
                                                          borderRadius: BorderRadius.circular(AppThemeData.radius8),
                                                          border: Border.all(color: AppThemeData.primary300, width: 1.5),
                                                          boxShadow: AppThemeData.shadowSm(isDark),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            InkWell(
                                                                onTap: () {
                                                                  controller.addToCart(
                                                                      productModel: productModel, price: price, discountPrice: disPrice, isIncrement: false,
                                                                      quantity: cartItem.where((p0) => p0.id == productModel.id).first.quantity! - 1);
                                                                },
                                                                child: Icon(Icons.remove, size: 18, color: isDark ? AppThemeData.grey100 : AppThemeData.grey800)),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                                              child: Text(
                                                                cartItem.where((p0) => p0.id == productModel.id).first.quantity.toString(),
                                                                style: TextStyle(fontSize: 14, fontFamily: 'Urbanist', fontWeight: FontWeight.w600, color: isDark ? AppThemeData.grey100 : AppThemeData.grey800),
                                                              ),
                                                            ),
                                                            InkWell(
                                                                onTap: () {
                                                                  if ((cartItem.where((p0) => p0.id == productModel.id).first.quantity ?? 0) < (productModel.quantity ?? 0) ||
                                                                      (productModel.quantity ?? 0) == -1) {
                                                                    controller.addToCart(
                                                                        productModel: productModel, price: price, discountPrice: disPrice, isIncrement: true,
                                                                        quantity: cartItem.where((p0) => p0.id == productModel.id).first.quantity! + 1);
                                                                  } else {
                                                                    ShowToastDialog.showToast("Out of stock");
                                                                  }
                                                                },
                                                                child: Icon(Icons.add, size: 18, color: isDark ? AppThemeData.grey100 : AppThemeData.grey800)),
                                                          ],
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () async {
                                                          if (Constant.userModel?.id == null) {
                                                            ShowToastDialog.showToast("Please login first to add items to your cart.");
                                                            Get.offAll(LoginScreen());
                                                          } else {
                                                            if (1 <= (productModel.quantity ?? 0) || (productModel.quantity ?? 0) == -1) {
                                                              controller.addToCart(productModel: productModel, price: price, discountPrice: disPrice, isIncrement: true, quantity: 1);
                                                            } else {
                                                              ShowToastDialog.showToast("Out of stock");
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: isDark ? AppThemeData.grey900 : Colors.white,
                                                            borderRadius: BorderRadius.circular(AppThemeData.radius8),
                                                            border: Border.all(color: AppThemeData.primary300, width: 1.5),
                                                            boxShadow: AppThemeData.shadowSm(isDark),
                                                          ),
                                                          child: Center(
                                                            child: Text('ADD', style: TextStyle(color: AppThemeData.primary300, fontFamily: 'Urbanist', fontWeight: FontWeight.w600, fontSize: 14)),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (hasPhoto)
                          SizedBox(
                            width: Responsive.width(34, context),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: Responsive.height(16, context) + (controller.isOpen.value ? 18 : 0),
                                  child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: NetworkImageWidget(
                                        imageUrl: productModel.photo.toString(),
                                        fit: BoxFit.cover,
                                        height: Responsive.height(16, context),
                                        width: Responsive.width(34, context),
                                        errorWidget: Container(
                                          height: Responsive.height(16, context),
                                          width: Responsive.width(34, context),
                                          color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                                          child: Icon(Icons.restaurant_menu, size: 32, color: isDark ? AppThemeData.grey600 : AppThemeData.grey300),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: InkWell(
                                        onTap: () async {
                                          if (controller.favouriteItemList.where((p0) => p0.productId == productModel.id).isNotEmpty) {
                                            FavouriteItemModel favouriteModel =
                                                FavouriteItemModel(productId: productModel.id, storeId: controller.vendorModel.value.id, userId: FireStoreUtils.getCurrentUid());
                                            controller.favouriteItemList.removeWhere((item) => item.productId == productModel.id);
                                            await FireStoreUtils.removeFavouriteItem(favouriteModel);
                                          } else {
                                            FavouriteItemModel favouriteModel =
                                                FavouriteItemModel(productId: productModel.id, storeId: controller.vendorModel.value.id, userId: FireStoreUtils.getCurrentUid());
                                            controller.favouriteItemList.add(favouriteModel);
                                            await FireStoreUtils.setFavouriteItem(favouriteModel);
                                          }
                                        },
                                        child: Obx(
                                          () => controller.favouriteItemList.where((p0) => p0.productId == productModel.id).isNotEmpty
                                              ? SvgPicture.asset("assets/icons/ic_like_fill.svg")
                                              : SvgPicture.asset("assets/icons/ic_like.svg"),
                                        ),
                                      ),
                                    ),
                                    if (controller.isOpen.value)
                                      Positioned(
                                        bottom: 2,
                                        left: 12,
                                        right: 12,
                                        child: selectedVariants.isNotEmpty || (productModel.addOnsTitle != null && productModel.addOnsTitle!.isNotEmpty)
                                            ? InkWell(
                                                onTap: () async {
                                                  if (Constant.userModel?.id == null) {
                                                    ShowToastDialog.showToast("Please login first to add items to your cart.");
                                                    Get.offAll(LoginScreen());
                                                  } else {
                                                    controller.selectedVariants.clear();
                                                    controller.selectedIndexVariants.clear();
                                                    controller.selectedIndexArray.clear();
                                                    controller.selectedAddOns.clear();
                                                    controller.quantity.value = 1;
                                                    if (productModel.itemAttribute != null) {
                                                      if (productModel.itemAttribute!.attributes!.isNotEmpty) {
                                                        for (var element in productModel.itemAttribute!.attributes!) {
                                                          if (element.attributeOptions!.isNotEmpty) {
                                                            controller.selectedVariants
                                                                .add(productModel.itemAttribute!.attributes![productModel.itemAttribute!.attributes!.indexOf(element)].attributeOptions![0].toString());
                                                            controller.selectedIndexVariants.add(
                                                                '${productModel.itemAttribute!.attributes!.indexOf(element)} _${productModel.itemAttribute!.attributes![0].attributeOptions![0].toString()}');
                                                            controller.selectedIndexArray.add('${productModel.itemAttribute!.attributes!.indexOf(element)}_0');
                                                          }
                                                        }
                                                      }
                                                      final bool productIsInList = cartItem.any((product) =>
                                                          product.id ==
                                                          "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                                      if (productIsInList) {
                                                        CartProductModel element = cartItem.firstWhere((product) =>
                                                            product.id ==
                                                            "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                                        controller.quantity.value = element.quantity!;
                                                        if (element.extras != null) {
                                                          for (var element in element.extras!) {
                                                            controller.selectedAddOns.add(element);
                                                          }
                                                        }
                                                      }
                                                    } else {
                                                      if (cartItem.where((product) => product.id == "${productModel.id}").isNotEmpty) {
                                                        CartProductModel element = cartItem.firstWhere((product) => product.id == "${productModel.id}");
                                                        controller.quantity.value = element.quantity!;
                                                        if (element.extras != null) {
                                                          for (var element in element.extras!) {
                                                            controller.selectedAddOns.add(element);
                                                          }
                                                        }
                                                      }
                                                    }
                                                    controller.update();
                                                    controller.calculatePrice(productModel);
                                                    productDetailsBottomSheet(context, productModel);
                                                  }
                                                },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: isDark ? AppThemeData.grey900 : Colors.white,
                                                    borderRadius: BorderRadius.circular(AppThemeData.radius8),
                                                    border: Border.all(color: AppThemeData.primary300, width: 1.5),
                                                    boxShadow: AppThemeData.shadowSm(isDark),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'ADD',
                                                      style: TextStyle(
                                                        color: AppThemeData.primary300,
                                                        fontFamily: 'Urbanist',
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Obx(
                                                () => cartItem.where((p0) => p0.id == productModel.id).isNotEmpty
                                                    ? Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: isDark ? AppThemeData.grey900 : Colors.white,
                                                          borderRadius: BorderRadius.circular(AppThemeData.radius8),
                                                          border: Border.all(color: AppThemeData.primary300, width: 1.5),
                                                          boxShadow: AppThemeData.shadowSm(isDark),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            InkWell(
                                                                onTap: () {
                                                                  controller.addToCart(
                                                                      productModel: productModel,
                                                                      price: price,
                                                                      discountPrice: disPrice,
                                                                      isIncrement: false,
                                                                      quantity: cartItem.where((p0) => p0.id == productModel.id).first.quantity! - 1);
                                                                },
                                                                child: Icon(Icons.remove, size: 18, color: isDark ? AppThemeData.grey100 : AppThemeData.grey800)),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                                              child: Text(
                                                                cartItem.where((p0) => p0.id == productModel.id).first.quantity.toString(),
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontFamily: 'Urbanist',
                                                                  fontWeight: FontWeight.w600,
                                                                  color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                                onTap: () {
                                                                  if ((cartItem.where((p0) => p0.id == productModel.id).first.quantity ?? 0) < (productModel.quantity ?? 0) ||
                                                                      (productModel.quantity ?? 0) == -1) {
                                                                    controller.addToCart(
                                                                        productModel: productModel,
                                                                        price: price,
                                                                        discountPrice: disPrice,
                                                                        isIncrement: true,
                                                                        quantity: cartItem.where((p0) => p0.id == productModel.id).first.quantity! + 1);
                                                                  } else {
                                                                    ShowToastDialog.showToast("Out of stock");
                                                                  }
                                                                },
                                                                child: Icon(Icons.add, size: 18, color: isDark ? AppThemeData.grey100 : AppThemeData.grey800)),
                                                          ],
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () async {
                                                          if (Constant.userModel?.id == null) {
                                                            ShowToastDialog.showToast("Please login first to add items to your cart.");
                                                            Get.offAll(LoginScreen());
                                                          } else {
                                                            if (1 <= (productModel.quantity ?? 0) || (productModel.quantity ?? 0) == -1) {
                                                              controller.addToCart(productModel: productModel, price: price, discountPrice: disPrice, isIncrement: true, quantity: 1);
                                                            } else {
                                                              ShowToastDialog.showToast("Out of stock");
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: isDark ? AppThemeData.grey900 : Colors.white,
                                                            borderRadius: BorderRadius.circular(AppThemeData.radius8),
                                                            border: Border.all(color: AppThemeData.primary300, width: 1.5),
                                                            boxShadow: AppThemeData.shadowSm(isDark),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'ADD',
                                                              style: TextStyle(
                                                                color: AppThemeData.primary300,
                                                                fontFamily: 'Urbanist',
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                      ),
                                  ],
                                ),
                                ),
                                if ((selectedVariants.isNotEmpty || (productModel.addOnsTitle != null && productModel.addOnsTitle!.isNotEmpty)) && controller.isOpen.value)
                                  Text(
                                    'customisable',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w400,
                                      color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                        ),
                        Divider(height: 1, thickness: 1, color: isDark ? AppThemeData.grey800 : const Color(0xFFEEEEEE)),
                      ],
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  productDetailsBottomSheet(BuildContext context, ProductModel productModel) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.85,
              child: StatefulBuilder(builder: (context1, setState) {
                return ProductDetailsView(
                  productModel: productModel,
                );
              }),
            ));
  }

  infoDialog(RestaurantDetailsController controller, isDark, ProductModel productModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TranslatedText(
                    "Food Information's",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                      color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                TranslatedText(
                  productModel.description.toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Gram",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TranslatedText(
                      productModel.grams.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Calories",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TranslatedText(
                      productModel.calories.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Proteins",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TranslatedText(
                      productModel.proteins.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Fats",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TranslatedText(
                      productModel.fats.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                productModel.productSpecification != null && productModel.productSpecification!.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TranslatedText(
                              "Specification",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                                color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListView.builder(
                            itemCount: productModel.productSpecification!.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      productModel.productSpecification!.keys.elementAt(index),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TranslatedText(
                                      productModel.productSpecification!.values.elementAt(index),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 20,
                ),
                RoundedButtonFill(
                  title: "Back",
                  color: AppThemeData.primary300,
                  textColor: AppThemeData.grey50,
                  onPress: () async {
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsView extends StatelessWidget {
  final ProductModel productModel;

  const ProductDetailsView({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: RestaurantDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppThemeData.grey600 : AppThemeData.grey300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            productModel.nonveg == true
                                ? SvgPicture.asset("assets/icons/ic_nonveg.svg", height: 16, width: 16)
                                : SvgPicture.asset("assets/icons/ic_veg.svg", height: 16, width: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TranslatedText(
                                productModel.name.toString(),
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                if (controller.favouriteItemList.where((p0) => p0.productId == productModel.id).isNotEmpty) {
                                  FavouriteItemModel favouriteModel =
                                      FavouriteItemModel(productId: productModel.id, storeId: controller.vendorModel.value.id, userId: FireStoreUtils.getCurrentUid());
                                  controller.favouriteItemList.removeWhere((item) => item.productId == productModel.id);
                                  await FireStoreUtils.removeFavouriteItem(favouriteModel);
                                } else {
                                  FavouriteItemModel favouriteModel =
                                      FavouriteItemModel(productId: productModel.id, storeId: controller.vendorModel.value.id, userId: FireStoreUtils.getCurrentUid());
                                  controller.favouriteItemList.add(favouriteModel);
                                  await FireStoreUtils.setFavouriteItem(favouriteModel);
                                }
                              },
                              child: Obx(
                                () => controller.favouriteItemList.where((p0) => p0.productId == productModel.id).isNotEmpty
                                    ? SvgPicture.asset("assets/icons/ic_like_fill.svg")
                                    : SvgPicture.asset("assets/icons/ic_like.svg", colorFilter: const ColorFilter.mode(AppThemeData.grey500, BlendMode.srcIn)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.close, size: 22, color: isDark ? AppThemeData.grey400 : AppThemeData.grey500),
                            ),
                          ],
                        ),
                        if (productModel.description != null && productModel.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: TranslatedText(
                              productModel.description.toString(),
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 13,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w400,
                                color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  productModel.itemAttribute == null || productModel.itemAttribute!.attributes!.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                          itemCount: productModel.itemAttribute!.attributes!.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            String title = "";
                            for (var element in controller.attributesList) {
                              if (productModel.itemAttribute!.attributes![index].attributeId == element.id) {
                                title = element.title.toString();
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (productModel.itemAttribute!.attributes![index].attributeOptions!.isNotEmpty) ...[
                                      TranslatedText(
                                        title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      TranslatedText(
                                        "Required • Select any 1 option",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    ...List.generate(
                                      productModel.itemAttribute!.attributes![index].attributeOptions!.length,
                                      (i) {
                                        final optionName = productModel.itemAttribute!.attributes![index].attributeOptions![i].toString();
                                        final isSelected = controller.selectedVariants.contains(optionName);
                                        return InkWell(
                                          onTap: () async {
                                            if (controller.selectedIndexVariants.where((element) => element.contains('$index _')).isEmpty) {
                                              controller.selectedVariants.insert(index, optionName);
                                              controller.selectedIndexVariants.add('$index _$optionName');
                                              controller.selectedIndexArray.add('${index}_$i');
                                            } else {
                                              controller.selectedIndexArray.remove(
                                                  '${index}_${productModel.itemAttribute!.attributes![index].attributeOptions?.indexOf(controller.selectedIndexVariants.where((element) => element.contains('$index _')).first.replaceAll('$index _', ''))}');
                                              controller.selectedVariants.removeAt(index);
                                              controller.selectedIndexVariants.remove(controller.selectedIndexVariants.where((element) => element.contains('$index _')).first);
                                              controller.selectedVariants.insert(index, optionName);
                                              controller.selectedIndexVariants.add('$index _$optionName');
                                              controller.selectedIndexArray.add('${index}_$i');
                                            }

                                            final bool productIsInList = cartItem.any((product) =>
                                                product.id ==
                                                "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                            if (productIsInList) {
                                              CartProductModel element = cartItem.firstWhere((product) =>
                                                  product.id ==
                                                  "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                              controller.quantity.value = element.quantity!;
                                            } else {
                                              controller.quantity.value = 1;
                                            }

                                            controller.update();
                                            controller.calculatePrice(productModel);
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TranslatedText(
                                                        optionName,
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 14,
                                                          color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: isSelected ? AppThemeData.primary300 : (isDark ? AppThemeData.grey600 : AppThemeData.grey300),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: isSelected
                                                          ? Center(
                                                              child: Container(
                                                                width: 10,
                                                                height: 10,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color: AppThemeData.primary300,
                                                                ),
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (i < productModel.itemAttribute!.attributes![index].attributeOptions!.length - 1)
                                                Divider(height: 1, thickness: 1, color: isDark ? AppThemeData.grey800 : const Color(0xFFEEEEEE)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  if (productModel.addOnsTitle != null && productModel.addOnsTitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            "Addons",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.separated(
                            itemCount: productModel.addOnsTitle!.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            separatorBuilder: (_, __) => Divider(height: 1, thickness: 1, color: isDark ? AppThemeData.grey800 : const Color(0xFFEEEEEE)),
                            itemBuilder: (context, index) {
                              String title = productModel.addOnsTitle![index];
                              String price = productModel.addOnsPrice![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TranslatedText(
                                            title,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 14,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w500,
                                              color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            Constant.amountShow(amount: Constant.productCommissionPrice(controller.vendorModel.value, price)),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w400,
                                              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Obx(
                                      () => SizedBox(
                                        height: 22.0,
                                        width: 22.0,
                                        child: Checkbox(
                                          value: controller.selectedAddOns.contains(title),
                                          activeColor: AppThemeData.primary300,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (value) {
                                            if (value != null) {
                                              if (value == true) {
                                                controller.selectedAddOns.add(title);
                                              } else {
                                                controller.selectedAddOns.remove(title);
                                              }
                                              controller.update();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                border: Border(top: BorderSide(color: isDark ? AppThemeData.grey700 : AppThemeData.grey200, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: Responsive.width(100, context),
                        height: Responsive.height(5.5, context),
                        decoration: ShapeDecoration(
                          color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                if (controller.quantity.value > 1) {
                                  controller.quantity.value -= 1;
                                  controller.update();
                                }
                              },
                              child: const Icon(Icons.remove),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                controller.quantity.value.toString(),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  if (productModel.itemAttribute == null) {
                                    if (controller.quantity.value < (productModel.quantity ?? 0) || (productModel.quantity ?? 0) == -1) {
                                      controller.quantity.value += 1;
                                      controller.update();
                                    } else {
                                      ShowToastDialog.showToast("Out of stock");
                                    }
                                  } else {
                                    int totalQuantity = int.parse(
                                        productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantQuantity.toString());
                                    if (controller.quantity.value < totalQuantity || totalQuantity == -1) {
                                      controller.quantity.value += 1;
                                      controller.update();
                                    } else {
                                      ShowToastDialog.showToast("Out of stock");
                                    }
                                  }
                                },
                                child: const Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: RoundedButtonFill(
                        title: "${'Add item'} ${Constant.amountShow(amount: controller.calculatePrice(productModel))}",
                        height: 5.5,
                        color: AppThemeData.primary300,
                        textColor: AppThemeData.grey50,
                        fontSizes: 16,
                        onPress: () async {
                          if (productModel.itemAttribute == null) {
                            controller.addToCart(
                                productModel: productModel,
                                price: Constant.productCommissionPrice(controller.vendorModel.value, productModel.price.toString()),
                                discountPrice:
                                    double.parse(productModel.disPrice.toString()) <= 0 ? "0" : Constant.productCommissionPrice(controller.vendorModel.value, productModel.disPrice.toString()),
                                isIncrement: true,
                                quantity: controller.quantity.value);
                          } else {
                            String variantPrice = "0";
                            if (productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty) {
                              variantPrice = Constant.productCommissionPrice(controller.vendorModel.value,
                                  productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantPrice ?? '0');
                            }
                            Map<String, String> mapData = {};
                            for (var element in productModel.itemAttribute!.attributes!) {
                              mapData.addEntries([
                                MapEntry(controller.attributesList.where((element1) => element.attributeId == element1.id).first.title.toString(),
                                    controller.selectedVariants[productModel.itemAttribute!.attributes!.indexOf(element)])
                              ]);
                            }

                            VariantInfo variantInfo = VariantInfo(
                                variantPrice: productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantPrice ?? '0',
                                variantSku: controller.selectedVariants.join('-'),
                                variantOptions: mapData,
                                variantImage: productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantImage ?? '',
                                variantId: productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId ?? '0');

                            controller.addToCart(productModel: productModel, price: variantPrice, discountPrice: "0", isIncrement: true, variantInfo: variantInfo, quantity: controller.quantity.value);
                          }

                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
