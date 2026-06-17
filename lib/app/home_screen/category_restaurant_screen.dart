import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/category_restaurant_controller.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/widget/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryRestaurantScreen extends StatelessWidget {
  const CategoryRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: CategoryRestaurantController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : controller.allNearestRestaurant.isEmpty
                    ? Constant.showEmptyView(message: "No Restaurant found")
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.allNearestRestaurant.length,
                          itemBuilder: (context, index) {
                            VendorModel vendorModel = controller.allNearestRestaurant[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: RestaurantCard(
                                vendorModel: vendorModel,
                                onTap: () {
                                  Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
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
