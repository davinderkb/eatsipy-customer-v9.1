import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/home_controller.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/widget/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllRestaurant extends StatelessWidget {
  final HomeController controller;
  final List<VendorModel> restaurants;
  final bool isMuted;

  const AllRestaurant({super.key, required this.controller, required this.restaurants, this.isMuted = false});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: restaurants.length,
      itemBuilder: (BuildContext context, int index) {
        if (index >= restaurants.length) return const SizedBox.shrink();
        VendorModel vendorModel = restaurants[index];
        return Padding(
          key: ValueKey(vendorModel.id),
          padding: EdgeInsets.only(bottom: restaurants.length - 1 == index ? 60 : AppThemeData.space16),
          child: RestaurantCard(
            vendorModel: vendorModel,
            isMuted: isMuted,
            favouriteList: controller.favouriteList,
            offerText: _getOfferText(vendorModel),
            onTap: () {
              Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel})?.then((v) {
                controller.getFavouriteRestaurant();
              });
            },
          ),
        );
      },
    );
  }

  String? _getOfferText(VendorModel vendor) {
    final idx = controller.couponRestaurantList.indexWhere((v) => v.id == vendor.id);
    if (idx == -1) return null;
    final coupon = controller.couponList[idx];
    return coupon.discountType == "Percentage" ? "${coupon.discount}% OFF" : "${Constant.currencyModel?.symbol ?? ''}${coupon.discount} OFF";
  }
}
