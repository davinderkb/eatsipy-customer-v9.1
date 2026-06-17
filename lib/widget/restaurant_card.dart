import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/models/favourite_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/widget/restaurant_image_view.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class RestaurantCard extends StatelessWidget {
  final VendorModel vendorModel;
  final bool isMuted;
  final VoidCallback? onTap;
  final RxList<FavouriteModel>? favouriteList;
  final VoidCallback? onFavouriteRemoved;
  final String? offerText;

  const RestaurantCard({
    super.key,
    required this.vendorModel,
    this.isMuted = false,
    this.onTap,
    this.favouriteList,
    this.onFavouriteRemoved,
    this.offerText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOpen = Constant.statusCheckOpenORClose(vendorModel: vendorModel);
    final showGreyscale = isMuted || !isOpen;
    final showClosedPill = !isOpen && !isMuted;
    final showBadges = !isMuted && isOpen;

    return InkWell(
      onTap: onTap ?? () {
        Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
      },
      child: Opacity(
        opacity: isMuted ? 0.85 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
            borderRadius: BorderRadius.circular(AppThemeData.radius16),
            boxShadow: AppThemeData.shadowSm(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppThemeData.radius16)),
                child: SizedBox(
                  height: AppThemeData.restaurantImageHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColorFiltered(
                        colorFilter: showGreyscale
                            ? (isMuted ? AppThemeData.desatMuted : AppThemeData.desatLight)
                            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                        child: RestaurantImageView(vendorModel: vendorModel, height: AppThemeData.restaurantImageHeight),
                      ),
                      if (showClosedPill)
                        Positioned(
                          top: AppThemeData.space12,
                          left: AppThemeData.space12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppThemeData.grey900.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(AppThemeData.radius8),
                            ),
                            child: const TranslatedText(
                              "Closed",
                              style: TextStyle(color: AppThemeData.grey50, fontSize: 11, fontFamily: 'Urbanist', fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      if (favouriteList != null)
                        Positioned(
                          right: AppThemeData.space12,
                          top: AppThemeData.space12,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              onTap: () async {
                                if (favouriteList!.where((p0) => p0.restaurantId == vendorModel.id).isNotEmpty) {
                                  FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                  favouriteList!.removeWhere((item) => item.restaurantId == vendorModel.id);
                                  await FireStoreUtils.removeFavouriteRestaurant(favouriteModel);
                                  onFavouriteRemoved?.call();
                                } else {
                                  FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                  favouriteList!.add(favouriteModel);
                                  await FireStoreUtils.setFavouriteRestaurant(favouriteModel);
                                }
                              },
                              child: Obx(
                                () => Center(
                                  child: favouriteList!.where((p0) => p0.restaurantId == vendorModel.id).isNotEmpty
                                      ? SvgPicture.asset("assets/icons/ic_like_fill.svg", width: 20, height: 20)
                                      : SvgPicture.asset("assets/icons/ic_like.svg", width: 20, height: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (showBadges && offerText != null && offerText!.isNotEmpty)
                        Positioned(
                          top: showClosedPill ? 44 : AppThemeData.space12,
                          left: AppThemeData.space12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppThemeData.primary300,
                              borderRadius: BorderRadius.circular(AppThemeData.radius8),
                            ),
                            child: Text(
                              offerText!,
                              style: const TextStyle(color: AppThemeData.grey50, fontSize: 12, fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      if (showBadges && vendorModel.isSelfDelivery == true && Constant.isSelfDeliveryFeature == true)
                        Positioned(
                          left: AppThemeData.space12,
                          bottom: AppThemeData.space12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppThemeData.lightGreen,
                              borderRadius: BorderRadius.circular(AppThemeData.radius8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset("assets/icons/ic_free_delivery.svg", width: 14, height: 14),
                                const SizedBox(width: 4),
                                const Text(
                                  "Free Delivery",
                                  style: TextStyle(fontSize: 12, color: AppThemeData.darkGreen, fontFamily: 'Urbanist', fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppThemeData.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      vendorModel.title.toString(),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                      ),
                    ),
                    if (vendorModel.categoryTitle != null && vendorModel.categoryTitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppThemeData.space4),
                        child: Text(
                          vendorModel.categoryTitle!.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Urbanist', fontWeight: FontWeight.w400,
                            color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppThemeData.space8),
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
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                              color: isDark ? AppThemeData.grey200 : AppThemeData.grey700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppThemeData.space12),
                        Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppThemeData.grey500 : AppThemeData.grey400)),
                        const SizedBox(width: AppThemeData.space12),
                        SvgPicture.asset(
                          "assets/icons/ic_map_distance.svg",
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(isDark ? AppThemeData.grey400 : AppThemeData.grey500, BlendMode.srcIn),
                        ),
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
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isOpen)
                      Padding(
                        padding: const EdgeInsets.only(top: AppThemeData.space8),
                        child: TranslatedText(
                          Constant.getNextOpeningTime(vendorModel, DateTime.now()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppThemeData.danger300, fontSize: 12, fontFamily: 'Urbanist', fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
