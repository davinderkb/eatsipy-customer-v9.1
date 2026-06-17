import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/home_controller.dart';
import 'package:eatsipy_customer/models/advertisement_model.dart';
import 'package:eatsipy_customer/models/favourite_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:eatsipy_customer/widget/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AdvertisementHomeCard extends StatelessWidget {
  final AdvertisementModel model;
  final HomeController controller;

  const AdvertisementHomeCard({super.key, required this.controller, required this.model});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () async {
        ShowToastDialog.showLoader("Please wait");
        VendorModel? vendorModel = await FireStoreUtils.getVendorById(model.vendorId!);
        ShowToastDialog.closeLoader();
        Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
      },
      child: Container(
        margin: EdgeInsets.only(right: 16),
        width: Responsive.width(70, context),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.info600 : AppThemeData.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: isDark ? 6 : 2,
              spreadRadius: 0,
              offset: Offset(0, isDark ? 3 : 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                model.type == 'restaurant_promotion'
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        child: NetworkImageWidget(
                          imageUrl: model.coverImage ?? '',
                          height: 135,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : VideoAdvWidget(
                        url: model.video ?? '',
                        height: 135,
                        width: double.infinity,
                      ),
                if (model.type != 'video_promotion' && model.vendorId != null && (model.showRating == true || model.showReview == true))
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FutureBuilder(
                        future: FireStoreUtils.getVendorById(model.vendorId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox();
                          } else {
                            if (snapshot.hasError) {
                              return const SizedBox();
                            } else if (snapshot.data == null) {
                              return const SizedBox();
                            } else {
                              VendorModel vendorModel = snapshot.data!;
                              return Container(
                                decoration: ShapeDecoration(
                                  color: isDark ? AppThemeData.primary600 : AppThemeData.primary50,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      if (model.showRating == true)
                                        SvgPicture.asset(
                                          "assets/icons/ic_star.svg",
                                          colorFilter: ColorFilter.mode(AppThemeData.primary300, BlendMode.srcIn),
                                        ),
                                      if (model.showRating == true)
                                        const SizedBox(
                                          width: 5,
                                        ),
                                      Text(
                                        "${model.showRating == true ? Constant.calculateReview(reviewCount: vendorModel.reviewsCount!.toStringAsFixed(0), reviewSum: vendorModel.reviewsSum.toString()) : ''} ${model.showReview == true ? '(${vendorModel.reviewsCount!.toStringAsFixed(0)})' : ''}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? AppThemeData.primary300 : AppThemeData.primary300,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                        }),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (model.type == 'restaurant_promotion')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: NetworkImageWidget(
                        imageUrl: model.profileImage ?? '',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          model.title ?? '',
                          style: TextStyle(
                            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        TranslatedText(
                          model.description ?? '',
                          style: TextStyle(fontSize: 12, fontFamily: 'Urbanist', fontWeight: FontWeight.w500, color: isDark ? AppThemeData.grey400 : AppThemeData.grey600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  model.type == 'restaurant_promotion'
                      ? IconButton(
                          icon: Obx(
                            () => controller.favouriteList.where((p0) => p0.restaurantId == model.vendorId).isNotEmpty
                                ? SvgPicture.asset(
                                    "assets/icons/ic_like_fill.svg",
                                  )
                                : SvgPicture.asset(
                                    "assets/icons/ic_like.svg",
                                    colorFilter: ColorFilter.mode(isDark ? AppThemeData.grey400 : AppThemeData.grey600, BlendMode.srcIn),
                                  ),
                          ),
                          onPressed: () async {
                            if (controller.favouriteList.where((p0) => p0.restaurantId == model.vendorId).isNotEmpty) {
                              FavouriteModel favouriteModel = FavouriteModel(restaurantId: model.vendorId, userId: FireStoreUtils.getCurrentUid());
                              controller.favouriteList.removeWhere((item) => item.restaurantId == model.vendorId);
                              await FireStoreUtils.removeFavouriteRestaurant(favouriteModel);
                            } else {
                              FavouriteModel favouriteModel = FavouriteModel(restaurantId: model.vendorId, userId: FireStoreUtils.getCurrentUid());
                              controller.favouriteList.add(favouriteModel);
                              await FireStoreUtils.setFavouriteRestaurant(favouriteModel);
                            }
                            controller.update();
                          },
                        )
                      : Container(
                          decoration: ShapeDecoration(
                            color: isDark ? AppThemeData.primary600 : AppThemeData.primary50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), child: Icon(Icons.arrow_forward, size: 20, color: AppThemeData.primary300)))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
