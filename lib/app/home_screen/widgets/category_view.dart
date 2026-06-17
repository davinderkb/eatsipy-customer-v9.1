import 'package:eatsipy_customer/app/home_screen/category_restaurant_screen.dart';
import 'package:eatsipy_customer/controllers/home_controller.dart';
import 'package:eatsipy_customer/models/vendor_category_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryView extends StatelessWidget {
  final HomeController controller;

  const CategoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: controller.vendorCategoryModel.length,
        itemBuilder: (context, index) {
          VendorCategoryModel vendorCategoryModel = controller.vendorCategoryModel[index];
          return InkWell(
            key: ValueKey(vendorCategoryModel.id),
            onTap: () {
              Get.to(const CategoryRestaurantScreen(), arguments: {"vendorCategoryModel": vendorCategoryModel, "dineIn": false});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppThemeData.space8),
              child: SizedBox(
                width: 76,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                          border: Border.all(
                            color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: NetworkImageWidget(
                            imageUrl: vendorCategoryModel.photo.toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppThemeData.space8),
                    TranslatedText(
                      '${vendorCategoryModel.title}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
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
