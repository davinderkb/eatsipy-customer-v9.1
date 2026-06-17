import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/search_controller.dart';
import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/themes/text_field_widget.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: SearchScreenController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: TranslatedText(
                "Search Food & Restaurant",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(55),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFieldWidget(
                    hintText: 'Search the dish, restaurant, food, meals',
                    prefix: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SvgPicture.asset(
                        "assets/icons/ic_search.svg",
                        width: 25,
                        height: 25,
                      ),
                    ),
                    controller: controller.searchTextController.value,
                    onchange: (value) {
                      controller.onSearchTextChanged(value);
                    },
                    suffix: IconButton(
                        onPressed: () {
                          controller.voiceSearch();
                        },
                        icon: Icon(Icons.mic)),
                  ),
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : controller.vendorSearchList.isEmpty && controller.productSearchList.isEmpty
                    ? Center(child: Constant.showEmptyView(message: "Not Found"))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              controller.vendorSearchList.isEmpty
                                  ? const SizedBox()
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TranslatedText(
                                          "Restaurants",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          child: Divider(),
                                        ),
                                      ],
                                    ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.vendorSearchList.length,
                                itemBuilder: (context, index) {
                                  VendorModel vendorModel = controller.vendorSearchList[index];
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
                              controller.productSearchList.isEmpty
                                  ? const SizedBox()
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TranslatedText(
                                          "Foods",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          child: Divider(),
                                        ),
                                      ],
                                    ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.productSearchList.length,
                                itemBuilder: (context, index) {
                                  ProductModel productModel = controller.productSearchList[index];
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
                                                      Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": value});
                                                    }
                                                  },
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(bottom: 20),
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
                                                              productModel.nonveg == true ? SvgPicture.asset("assets/icons/ic_nonveg.svg") : SvgPicture.asset("assets/icons/ic_veg.svg"),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              TranslatedText(
                                                                productModel.nonveg == true ? "Non Veg." : "Veg",
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
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      });
                                },
                              )
                            ],
                          ),
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
