import 'package:eatsipy_customer/app/auth_screen/login_screen.dart';
import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/favourite_controller.dart';
import 'package:eatsipy_customer/models/favourite_item_model.dart';
import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/themes/round_button_fill.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: FavouriteController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TranslatedText(
                                  "Your Favourites, All in One Place",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SvgPicture.asset("assets/images/ic_favourite.svg")
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Constant.userModel == null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/login.gif",
                                        height: 120,
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      TranslatedText(
                                        "Please Log In to Continue",
                                        style: TextStyle(color: isDark ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: 'Urbanist', fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TranslatedText(
                                        "You’re not logged in. Please sign in to access your account and explore all features.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: isDark ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      RoundedButtonFill(
                                        title: "Log in",
                                        width: 55,
                                        height: 5.5,
                                        color: AppThemeData.primary300,
                                        textColor: AppThemeData.grey50,
                                        onPress: () async {
                                          Get.offAll(const LoginScreen());
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Container(
                                        decoration: ShapeDecoration(
                                          color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(120),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    controller.favouriteRestaurant.value = true;
                                                  },
                                                  child: Container(
                                                    decoration: controller.favouriteRestaurant.value == false
                                                        ? null
                                                        : ShapeDecoration(
                                                            color: AppThemeData.grey900,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(120),
                                                            ),
                                                          ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                      child: TranslatedText(
                                                        "Favourite Restaurants",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                                                          color: isDark ? AppThemeData.primary300 : AppThemeData.primary300,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    controller.favouriteRestaurant.value = false;
                                                  },
                                                  child: Container(
                                                    decoration: controller.favouriteRestaurant.value == true
                                                        ? null
                                                        : ShapeDecoration(
                                                            color: AppThemeData.grey900,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(120),
                                                            ),
                                                          ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                      child: TranslatedText(
                                                        "Favourite Foods",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                                                          color: controller.favouriteRestaurant.value == true
                                                              ? isDark
                                                                  ? AppThemeData.grey400
                                                                  : AppThemeData.grey500
                                                              : isDark
                                                                  ? AppThemeData.primary300
                                                                  : AppThemeData.primary300,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 18),
                                        child: controller.favouriteRestaurant.value
                                            ? controller.favouriteVendorList.isEmpty
                                                ? Constant.showEmptyView(message: "Favourite Restaurants not found.")
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    scrollDirection: Axis.vertical,
                                                    itemCount: controller.favouriteVendorList.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      VendorModel vendorModel = controller.favouriteVendorList[index];
                                                      return Padding(
                                                        padding: const EdgeInsets.only(bottom: 20),
                                                        child: RestaurantCard(
                                                          vendorModel: vendorModel,
                                                          favouriteList: controller.favouriteList,
                                                          onFavouriteRemoved: () => controller.favouriteVendorList.removeAt(index),
                                                          onTap: () {
                                                            if (vendorModel.zoneId == Constant.selectedZone!.id) {
                                                              ShowToastDialog.closeLoader();
                                                              Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel})?.then((value) async {
                                                                await controller.getData();
                                                              });
                                                            } else {
                                                              ShowToastDialog.closeLoader();
                                                              ShowToastDialog.showToast("Sorry, The Zone is not available in your area. change the other location first.");
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  )
                                            : controller.favouriteFoodList.isEmpty
                                                ? Constant.showEmptyView(message: "Favourite Foods not found.")
                                                : ListView.builder(
                                                    itemCount: controller.favouriteFoodList.length,
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder: (context, index) {
                                                      ProductModel productModel = controller.favouriteFoodList[index];
                                                      return FutureBuilder(
                                                        future: getPrice(productModel),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return Constant.loader();
                                                          } else {
                                                            if (snapshot.hasError) {
                                                              return Center(child: TranslatedText('Error: ${snapshot.error}'));
                                                            } else if (snapshot.data == null) {
                                                              return const SizedBox();
                                                            } else {
                                                              Map<String, dynamic> map = snapshot.data!;
                                                              String price = map['price'];
                                                              String disPrice = map['disPrice'];
                                                              return InkWell(
                                                                onTap: () async {
                                                                  await FireStoreUtils.getVendorById(productModel.vendorID.toString()).then(
                                                                    (value) {
                                                                      if (value != null) {
                                                                        if (value.zoneId == Constant.selectedZone!.id) {
                                                                          ShowToastDialog.closeLoader();
                                                                          Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": value})?.then((value) {
                                                                            controller.getData();
                                                                          });
                                                                        } else {
                                                                          ShowToastDialog.closeLoader();
                                                                          ShowToastDialog.showToast("Sorry, The Zone is not available in your area. change the other location first.");
                                                                        }

                                                                        // Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": value});
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                  child: Container(
                                                                    decoration: ShapeDecoration(
                                                                      color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                                                                                    productModel.nonveg == true
                                                                                        ? SvgPicture.asset("assets/icons/ic_nonveg.svg")
                                                                                        : SvgPicture.asset("assets/icons/ic_veg.svg"),
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
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width: 6,
                                                                          ),
                                                                          ClipRRect(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                                                                            child: Stack(
                                                                              children: [
                                                                                NetworkImageWidget(
                                                                                  imageUrl: productModel.photo.toString(),
                                                                                  fit: BoxFit.cover,
                                                                                  height: Responsive.height(16, context),
                                                                                  width: Responsive.width(34, context),
                                                                                ),
                                                                                Container(
                                                                                  height: Responsive.height(16, context),
                                                                                  width: Responsive.width(34, context),
                                                                                  decoration: BoxDecoration(
                                                                                    gradient: LinearGradient(
                                                                                      begin: const Alignment(-0.00, -1.00),
                                                                                      end: const Alignment(0, 1),
                                                                                      colors: [Colors.black.withValues(alpha: 0), AppThemeData.grey900],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Positioned(
                                                                                  right: 10,
                                                                                  top: 10,
                                                                                  child: InkWell(
                                                                                    onTap: () async {
                                                                                      if (controller.favouriteItemList.where((p0) => p0.productId == productModel.id).isNotEmpty) {
                                                                                        FavouriteItemModel favouriteModel = FavouriteItemModel(
                                                                                            productId: productModel.id, storeId: productModel.vendorID, userId: FireStoreUtils.getCurrentUid());
                                                                                        controller.favouriteItemList.removeWhere((item) => item.productId == productModel.id);
                                                                                        controller.favouriteFoodList.removeAt(index);
                                                                                        await FireStoreUtils.removeFavouriteItem(favouriteModel);
                                                                                      } else {
                                                                                        FavouriteItemModel favouriteModel = FavouriteItemModel(
                                                                                            productId: productModel.id, storeId: productModel.vendorID, userId: FireStoreUtils.getCurrentUid());
                                                                                        controller.favouriteItemList.add(favouriteModel);
                                                                                        await FireStoreUtils.setFavouriteItem(favouriteModel);
                                                                                      }
                                                                                    },
                                                                                    child: Obx(
                                                                                      () => controller.favouriteItemList.where((p0) => p0.productId == productModel.id).isNotEmpty
                                                                                          ? SvgPicture.asset(
                                                                                              "assets/icons/ic_like_fill.svg",
                                                                                            )
                                                                                          : SvgPicture.asset(
                                                                                              "assets/icons/ic_like.svg",
                                                                                            ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      );
                                                    },
                                                  ),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
          );
        });
  }

  Future<Map<String, dynamic>> getPrice(ProductModel productModel) async {
    String price = "0.0";
    String disPrice = "0.0";
    List<String> selectedVariants = [];
    List<String> selectedIndexVariants = [];
    List<String> selectedIndexArray = [];

    print("=======>");
    print(productModel.price);
    print(productModel.disPrice);

    VendorModel? vendorModel = await FireStoreUtils.getVendorById(productModel.vendorID.toString());
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
        price = Constant.productCommissionPrice(vendorModel!, productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantPrice ?? '0');
        disPrice = Constant.productCommissionPrice(vendorModel, '0');
      }
    } else {
      price = Constant.productCommissionPrice(vendorModel!, productModel.price.toString());
      disPrice = Constant.productCommissionPrice(vendorModel, productModel.disPrice.toString());
    }

    return {'price': price, 'disPrice': disPrice};
  }
}
