import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/home_controller.dart';
import 'package:eatsipy_customer/models/coupon_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/widget/restaurant_image_view.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OfferView extends StatelessWidget {
  final HomeController controller;

  const OfferView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final itemCount = controller.couponRestaurantList.length >= 15
        ? 15
        : controller.couponRestaurantList.length;
    return SizedBox(
      height: Responsive.height(22, context),
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          VendorModel vendorModel = controller.couponRestaurantList[index];
          CouponModel offerModel = controller.couponList[index];
          bool isOpen =
              Constant.statusCheckOpenORClose(vendorModel: vendorModel);
          bool endsSoon = offerModel.expiresAt != null &&
              offerModel.expiresAt!
                      .toDate()
                      .difference(DateTime.now())
                      .inHours <
                  24;
          return InkWell(
            key: ValueKey(vendorModel.id),
            onTap: () {
              Get.to(const RestaurantDetailsScreen(),
                  arguments: {"vendorModel": vendorModel});
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppThemeData.space4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppThemeData.radius16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: isOpen
                          ? const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply)
                          : AppThemeData.desatLight,
                      child: RestaurantImageView(
                        vendorModel: vendorModel,
                        height: Responsive.height(100, context),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(0, -0.5),
                          end: const Alignment(0, 1),
                          colors: [
                            Colors.black.withValues(alpha: 0),
                            Colors.black.withValues(alpha: 0.8)
                          ],
                        ),
                      ),
                    ),
                    if (!isOpen)
                      Positioned(
                        top: AppThemeData.space12,
                        left: AppThemeData.space12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppThemeData.grey900.withValues(alpha: 0.75),
                            borderRadius:
                                BorderRadius.circular(AppThemeData.radius8),
                          ),
                          child: const TranslatedText(
                            "Closed",
                            style: TextStyle(
                                color: AppThemeData.grey50,
                                fontSize: 11,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: AppThemeData.space12,
                      left: AppThemeData.space16,
                      right: AppThemeData.space16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            "Upto",
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w900,
                              color: AppThemeData.grey50,
                            ),
                          ),
                          Text(
                            "${offerModel.discountType == "Fix Price" ? "${Constant.currencyModel!.symbol}" : ""}${offerModel.discount}${offerModel.discountType == "Percentage" ? "% off".tr : "off".tr}",
                            maxLines: 1,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                              color: AppThemeData.grey50,
                            ),
                          ),
                          const SizedBox(height: AppThemeData.space4),
                          TranslatedText(
                            vendorModel.title.toString(),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w500,
                              color: AppThemeData.grey200,
                            ),
                          ),
                          const SizedBox(height: AppThemeData.space4),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/ic_star.svg",
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                    AppThemeData.primary300, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                    color: AppThemeData.grey300,
                                  ),
                                ),
                              ),
                              if (vendorModel.isSelfDelivery == true &&
                                  Constant.isSelfDeliveryFeature == true) ...[
                                const SizedBox(width: AppThemeData.space8),
                                Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppThemeData.grey400)),
                                const SizedBox(width: AppThemeData.space8),
                                SvgPicture.asset(
                                    "assets/icons/ic_free_delivery.svg",
                                    width: 14,
                                    height: 14),
                                const SizedBox(width: 4),
                                const TranslatedText(
                                  "Free Delivery",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w500,
                                      color: AppThemeData.grey300),
                                ),
                              ],
                            ],
                          ),
                          if (endsSoon)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: AppThemeData.space4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppThemeData.danger300
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(
                                      AppThemeData.radius8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_timer.svg",
                                      width: 12,
                                      height: 12,
                                      colorFilter: const ColorFilter.mode(
                                          AppThemeData.grey50, BlendMode.srcIn),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "Ends soon",
                                      style: TextStyle(
                                          color: AppThemeData.grey50,
                                          fontSize: 11,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
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
        },
      ),
    );
  }
}
