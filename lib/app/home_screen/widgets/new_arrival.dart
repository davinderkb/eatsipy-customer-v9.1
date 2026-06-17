import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/home_controller.dart';
import 'package:eatsipy_customer/models/favourite_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class NewArrival extends StatelessWidget {
  final HomeController controller;

  const NewArrival({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.height(28, context),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: controller.newArrivalRestaurantList.length >= 10 ? 10 : controller.newArrivalRestaurantList.length,
        itemBuilder: (BuildContext context, int index) {
          VendorModel vendorModel = controller.newArrivalRestaurantList[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return InkWell(
            key: ValueKey(vendorModel.id),
            onTap: () {
              Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel})?.then((v) {
                controller.getFavouriteRestaurant();
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: AppThemeData.space12),
              child: SizedBox(
                width: Responsive.width(72, context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppThemeData.radius16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetworkImageWidget(
                              imageUrl: vendorModel.photo.toString(),
                              fit: BoxFit.cover,
                              height: Responsive.height(100, context),
                              width: Responsive.width(100, context),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(0, -0.5),
                                  end: const Alignment(0, 1),
                                  colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.7)],
                                ),
                              ),
                            ),
                            Positioned(
                              right: AppThemeData.space12,
                              top: AppThemeData.space12,
                              child: InkWell(
                                onTap: () async {
                                  if (controller.favouriteList.where((p0) => p0.restaurantId == vendorModel.id).isNotEmpty) {
                                    FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                    controller.favouriteList.removeWhere((item) => item.restaurantId == vendorModel.id);
                                    await FireStoreUtils.removeFavouriteRestaurant(favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                    controller.favouriteList.add(favouriteModel);
                                    await FireStoreUtils.setFavouriteRestaurant(favouriteModel);
                                  }
                                },
                                child: Obx(
                                  () => controller.favouriteList.where((p0) => p0.restaurantId == vendorModel.id).isNotEmpty
                                      ? SvgPicture.asset("assets/icons/ic_like_fill.svg")
                                      : SvgPicture.asset("assets/icons/ic_like.svg"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppThemeData.space8),
                    TranslatedText(
                      vendorModel.title.toString(),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.space4),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/ic_star.svg",
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(AppThemeData.primary300, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontFamily: 'Urbanist', fontWeight: FontWeight.w500, color: isDark ? AppThemeData.grey400 : AppThemeData.grey500),
                          ),
                        ),
                        const SizedBox(width: AppThemeData.space8),
                        Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppThemeData.grey500 : AppThemeData.grey400)),
                        const SizedBox(width: AppThemeData.space8),
                        SvgPicture.asset("assets/icons/ic_map_distance.svg", width: 14, height: 14, colorFilter: ColorFilter.mode(isDark ? AppThemeData.grey400 : AppThemeData.grey500, BlendMode.srcIn)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "${Constant.getDistance(
                              lat1: vendorModel.latitude.toString(),
                              lng1: vendorModel.longitude.toString(),
                              lat2: Constant.selectedLocation.location!.latitude.toString(),
                              lng2: Constant.selectedLocation.location!.longitude.toString(),
                            )} ${Constant.distanceType}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontFamily: 'Urbanist', fontWeight: FontWeight.w500, color: isDark ? AppThemeData.grey400 : AppThemeData.grey500),
                          ),
                        ),
                        if (vendorModel.isSelfDelivery == true && Constant.isSelfDeliveryFeature == true) ...[
                          const SizedBox(width: AppThemeData.space8),
                          Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppThemeData.grey500 : AppThemeData.grey400)),
                          const SizedBox(width: AppThemeData.space8),
                          TranslatedText(
                            "Free",
                            style: TextStyle(fontSize: 12, fontFamily: 'Urbanist', fontWeight: FontWeight.w500, color: isDark ? AppThemeData.grey400 : AppThemeData.grey500),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
