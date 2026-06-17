import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/home_controller.dart';
import 'package:eatsipy_customer/models/BannerModel.dart';
import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerView extends StatelessWidget {
  final HomeController controller;

  const BannerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: controller.pageController.value,
            scrollDirection: Axis.horizontal,
            itemCount: controller.bannerModel.length,
            padEnds: false,
            pageSnapping: true,
            allowImplicitScrolling: true,
            onPageChanged: (value) {
              controller.currentPage.value = value;
            },
            itemBuilder: (BuildContext context, int index) {
              BannerModel bannerModel = controller.bannerModel[index];
              return InkWell(
                key: ValueKey(index),
                onTap: () async {
                  if (bannerModel.redirect_type == "store") {
                    ShowToastDialog.showLoader("Please wait");
                    VendorModel? vendorModel = await FireStoreUtils.getVendorById(bannerModel.redirect_id.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast("Sorry, The Zone is not available in your area. change the other location first.");
                    }
                  } else if (bannerModel.redirect_type == "product") {
                    ShowToastDialog.showLoader("Please wait");
                    ProductModel? productModel = await FireStoreUtils.getProductById(bannerModel.redirect_id.toString());
                    VendorModel? vendorModel = await FireStoreUtils.getVendorById(productModel!.vendorID.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast("Sorry, The Zone is not available in your area. change the other location first.");
                    }
                  } else if (bannerModel.redirect_type == "external_link") {
                    final uri = Uri.parse(bannerModel.redirect_id.toString());
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ShowToastDialog.showToast("Could not launch");
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: NetworkImageWidget(
                      imageUrl: bannerModel.photo.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              controller.bannerModel.length,
              (index) {
                return Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: 5),
                    alignment: Alignment.centerLeft,
                    height: 9,
                    width: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.currentPage.value == index ? AppThemeData.primary300 : Colors.black12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
