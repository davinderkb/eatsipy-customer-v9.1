import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/restaurant_list_controller.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/widget/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:get/get.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: RestaurantListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: TranslatedText(
                controller.title.value,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.vendorSearchList.length,
                      itemBuilder: (context, index) {
                        VendorModel vendorModel = controller.vendorSearchList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RestaurantCard(
                            vendorModel: vendorModel,
                            favouriteList: controller.favouriteList,
                            onTap: () {
                              Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel})?.then((v) {
                                controller.getFavouriteRestaurant();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
          );
        });
  }
}
