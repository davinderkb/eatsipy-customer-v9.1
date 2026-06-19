import 'package:bottom_picker/bottom_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:eatsipy_customer/app/address_screens/address_list_screen.dart';
import 'package:eatsipy_customer/app/cart_screen/coupon_list_screen.dart';
import 'package:eatsipy_customer/app/cart_screen/widgets/checkout_payment_widgets.dart';
import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/app/wallet_screen/wallet_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/cart_controller.dart';
import 'package:eatsipy_customer/models/cart_product_model.dart';
import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';
import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/user_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/themes/round_button_fill.dart';
import 'package:eatsipy_customer/themes/text_field_widget.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: CartController(),
        builder: (controller) {
          final isPaymentLoading = controller.isLoading.value;
          final hasSelectedPayment =
              controller.selectedPaymentMethod.value.isNotEmpty;
          return Scaffold(
            backgroundColor:
                isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor:
                  isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
            ),
            body: cartItem.isEmpty
                ? Constant.showEmptyView(message: "Item Not available")
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controller.selectedFoodType.value == 'TakeAway'
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(const AddressListScreen())!.then(
                                      (value) {
                                        if (value != null) {
                                          ShippingAddress addressModel = value;
                                          controller.selectedAddress.value =
                                              addressModel;
                                          controller.calculatePrice();
                                        }
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: ShapeDecoration(
                                          color: isDark
                                              ? AppThemeData.grey900
                                              : AppThemeData.grey50,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/icons/ic_send_one.svg",
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                            AppThemeData
                                                                .primary300,
                                                            BlendMode.srcIn),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: TranslatedText(
                                                      controller.selectedAddress
                                                          .value.addressAs
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDark
                                                            ? AppThemeData
                                                                .primary300
                                                            : AppThemeData
                                                                .primary300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  SvgPicture.asset(
                                                      "assets/icons/ic_down.svg"),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              TranslatedText(
                                                controller.selectedAddress.value
                                                    .getFullAddress(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? AppThemeData.grey400
                                                      : AppThemeData.grey500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: cartItem.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  CartProductModel cartProductModel =
                                      cartItem[index];
                                  ProductModel? productModel;
                                  FireStoreUtils.getProductById(
                                          cartProductModel.id!.split('~').first)
                                      .then((value) {
                                    productModel = value;
                                  });
                                  return InkWell(
                                    onTap: () async {
                                      await FireStoreUtils.getVendorById(
                                              productModel!.vendorID.toString())
                                          .then(
                                        (value) {
                                          if (value != null) {
                                            Get.to(
                                                const RestaurantDetailsScreen(),
                                                arguments: {
                                                  "vendorModel": value
                                                });
                                          }
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(16)),
                                                child: NetworkImageWidget(
                                                  imageUrl: cartProductModel
                                                      .photo
                                                      .toString(),
                                                  height: Responsive.height(
                                                      10, context),
                                                  width: Responsive.width(
                                                      20, context),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TranslatedText(
                                                      "${cartProductModel.name}",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        color: isDark
                                                            ? AppThemeData
                                                                .grey50
                                                            : AppThemeData
                                                                .grey900,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    double.parse(cartProductModel
                                                                .discountPrice
                                                                .toString()) <=
                                                            0
                                                        ? Text(
                                                            Constant.amountShow(
                                                                amount:
                                                                    cartProductModel
                                                                        .price),
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          )
                                                        : SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  Constant.amountShow(
                                                                      amount: cartProductModel
                                                                          .discountPrice
                                                                          .toString()),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: isDark
                                                                        ? AppThemeData
                                                                            .grey50
                                                                        : AppThemeData
                                                                            .grey900,
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  Constant.amountShow(
                                                                      amount: cartProductModel
                                                                          .price),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    decorationColor: isDark
                                                                        ? AppThemeData
                                                                            .grey500
                                                                        : AppThemeData
                                                                            .grey400,
                                                                    color: isDark
                                                                        ? AppThemeData
                                                                            .grey500
                                                                        : AppThemeData
                                                                            .grey400,
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                    if (Constant.taxScope ==
                                                        "product")
                                                      cartProductModel
                                                                  .taxSetting
                                                                  ?.isEmpty ==
                                                              true
                                                          ? SizedBox()
                                                          : TranslatedText(
                                                              "${'Tax:'} ${Constant.getTaxDisplayText(cartProductModel.taxSetting)}",
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: isDark
                                                                    ? AppThemeData
                                                                        .secondary300
                                                                    : AppThemeData
                                                                        .secondary300,
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: Responsive.width(
                                                    26, context),
                                                decoration: ShapeDecoration(
                                                  color: isDark
                                                      ? AppThemeData.grey900
                                                      : AppThemeData.grey50,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        width: 1,
                                                        color: AppThemeData
                                                            .grey300),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            200),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4,
                                                      horizontal: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                          onTap: () {
                                                            controller.addToCart(
                                                                cartProductModel:
                                                                    cartProductModel,
                                                                isIncrement:
                                                                    false,
                                                                quantity:
                                                                    cartProductModel
                                                                            .quantity! -
                                                                        1);
                                                          },
                                                          child: const Icon(
                                                              Icons.remove)),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: Text(
                                                          cartProductModel
                                                              .quantity
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: isDark
                                                                ? AppThemeData
                                                                    .grey100
                                                                : AppThemeData
                                                                    .grey800,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            if (productModel
                                                                    ?.itemAttribute !=
                                                                null) {
                                                              if (productModel!
                                                                  .itemAttribute!
                                                                  .variants!
                                                                  .where((element) =>
                                                                      element
                                                                          .variantSku ==
                                                                      cartProductModel
                                                                          .variantInfo!
                                                                          .variantSku)
                                                                  .isNotEmpty) {
                                                                if (int.parse(productModel!
                                                                            .itemAttribute!
                                                                            .variants!
                                                                            .where((element) =>
                                                                                element.variantSku ==
                                                                                cartProductModel
                                                                                    .variantInfo!.variantSku)
                                                                            .first
                                                                            .variantQuantity
                                                                            .toString()) >
                                                                        (cartProductModel.quantity ??
                                                                            0) ||
                                                                    int.parse(productModel!
                                                                            .itemAttribute!
                                                                            .variants!
                                                                            .where((element) =>
                                                                                element.variantSku ==
                                                                                cartProductModel.variantInfo!.variantSku)
                                                                            .first
                                                                            .variantQuantity
                                                                            .toString()) ==
                                                                        -1) {
                                                                  controller.addToCart(
                                                                      cartProductModel:
                                                                          cartProductModel,
                                                                      isIncrement:
                                                                          true,
                                                                      quantity:
                                                                          cartProductModel.quantity! +
                                                                              1);
                                                                } else {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Out of stock");
                                                                }
                                                              } else {
                                                                if ((productModel?.quantity ??
                                                                            0) >
                                                                        (cartProductModel.quantity ??
                                                                            0) ||
                                                                    productModel!
                                                                            .quantity ==
                                                                        -1) {
                                                                  controller.addToCart(
                                                                      cartProductModel:
                                                                          cartProductModel,
                                                                      isIncrement:
                                                                          true,
                                                                      quantity:
                                                                          cartProductModel.quantity! +
                                                                              1);
                                                                } else {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Out of stock");
                                                                }
                                                              }
                                                            } else {
                                                              if ((productModel
                                                                              ?.quantity ??
                                                                          0) >
                                                                      (cartProductModel
                                                                              .quantity ??
                                                                          0) ||
                                                                  productModel!
                                                                          .quantity ==
                                                                      -1) {
                                                                controller.addToCart(
                                                                    cartProductModel:
                                                                        cartProductModel,
                                                                    isIncrement:
                                                                        true,
                                                                    quantity:
                                                                        cartProductModel.quantity! +
                                                                            1);
                                                              } else {
                                                                ShowToastDialog
                                                                    .showToast(
                                                                        "Out of stock");
                                                              }
                                                            }
                                                          },
                                                          child: const Icon(
                                                              Icons.add)),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          cartProductModel.variantInfo ==
                                                      null ||
                                                  cartProductModel.variantInfo!
                                                          .variantOptions ==
                                                      null ||
                                                  cartProductModel.variantInfo!
                                                      .variantOptions!.isEmpty
                                              ? Container()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TranslatedText(
                                                        "Variants",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: isDark
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Wrap(
                                                        spacing: 6.0,
                                                        runSpacing: 6.0,
                                                        children: List.generate(
                                                          cartProductModel
                                                              .variantInfo!
                                                              .variantOptions!
                                                              .length,
                                                          (i) {
                                                            return Container(
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: isDark
                                                                    ? AppThemeData
                                                                        .grey800
                                                                    : AppThemeData
                                                                        .grey100,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        5),
                                                                child:
                                                                    TranslatedText(
                                                                  "${cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)} : ${cartProductModel.variantInfo!.variantOptions![cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: isDark
                                                                        ? AppThemeData
                                                                            .grey500
                                                                        : AppThemeData
                                                                            .grey400,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          cartProductModel.extras == null ||
                                                  cartProductModel
                                                      .extras!.isEmpty ||
                                                  cartProductModel
                                                          .extrasPrice ==
                                                      '0'
                                              ? const SizedBox()
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TranslatedText(
                                                            "Addons",
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey300
                                                                  : AppThemeData
                                                                      .grey600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          Constant.amountShow(
                                                              amount: (double.parse(cartProductModel
                                                                          .extrasPrice
                                                                          .toString()) *
                                                                      double.parse(cartProductModel
                                                                          .quantity
                                                                          .toString()))
                                                                  .toString()),
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isDark
                                                                ? AppThemeData
                                                                    .primary300
                                                                : AppThemeData
                                                                    .primary300,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Wrap(
                                                      spacing: 6.0,
                                                      runSpacing: 6.0,
                                                      children: List.generate(
                                                        cartProductModel
                                                            .extras!.length,
                                                        (i) {
                                                          return Container(
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          5),
                                                              child:
                                                                  TranslatedText(
                                                                cartProductModel
                                                                    .extras![i]
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: isDark
                                                                      ? AppThemeData
                                                                          .grey500
                                                                      : AppThemeData
                                                                          .grey400,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: MySeparator(
                                        color: isDark
                                            ? AppThemeData.grey700
                                            : AppThemeData.grey200),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (controller.suggestedAddOnItems.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _suggestedAddOnsSection(controller, isDark),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText(
                                "${'Delivery Type'} ${'(${controller.selectedFoodType.value})'}",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              controller.selectedFoodType.value == 'TakeAway'
                                  ? const SizedBox()
                                  : Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: isDark
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TranslatedText(
                                                    "Instant Delivery",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? AppThemeData
                                                              .primary300
                                                          : AppThemeData
                                                              .primary300,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  TranslatedText(
                                                    "Standard",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: isDark
                                                          ? AppThemeData.grey400
                                                          : AppThemeData
                                                              .grey500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Radio(
                                              value:
                                                  controller.deliveryType.value,
                                              groupValue: "instant",
                                              activeColor:
                                                  AppThemeData.primary300,
                                              onChanged: (value) {
                                                controller.deliveryType.value =
                                                    "instant";
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: Responsive.width(100, context),
                                decoration: ShapeDecoration(
                                  color: isDark
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    controller.deliveryType.value = "schedule";
                                    BottomPicker.dateTime(
                                      onSubmit: (index) {
                                        controller.scheduleDateTime.value =
                                            index;
                                      },
                                      minDateTime: DateTime.now(),
                                      displaySubmitButton: true,
                                      pickerTitle:
                                          TranslatedText('Schedule Time'),
                                      buttonSingleColor:
                                          AppThemeData.primary300,
                                    ).show(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TranslatedText(
                                                "Schedule Time",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? AppThemeData.primary300
                                                      : AppThemeData.primary300,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              TranslatedText(
                                                "${'Your preferred time'} ${controller.deliveryType.value == "schedule" ? Constant.timestampToDateTime(Timestamp.fromDate(controller.scheduleDateTime.value)) : ""}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? AppThemeData.grey400
                                                      : AppThemeData.grey500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Radio(
                                          value: controller.deliveryType.value,
                                          groupValue: "schedule",
                                          activeColor: AppThemeData.primary300,
                                          onChanged: (value) {
                                            controller.deliveryType.value =
                                                "schedule";
                                            BottomPicker.dateTime(
                                              initialDateTime: controller
                                                  .scheduleDateTime.value,
                                              onSubmit: (index) {
                                                controller.scheduleDateTime
                                                    .value = index;
                                              },
                                              minDateTime: controller
                                                  .scheduleDateTime.value,
                                              displaySubmitButton: true,
                                              pickerTitle: TranslatedText(
                                                  'Schedule Time'),
                                              buttonSingleColor:
                                                  AppThemeData.primary300,
                                            ).show(context);
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText(
                                "Offers & Benefits",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(const CouponListScreen());
                                },
                                child: Container(
                                  width: Responsive.width(100, context),
                                  decoration: ShapeDecoration(
                                    color: isDark
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 52,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TranslatedText(
                                            "Apply Coupons",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Icon(Icons.keyboard_arrow_right)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _billSummaryCard(context, controller, isDark),
                        ),
                        ((controller.selectedFoodType.value == 'TakeAway' ||
                                    (controller.vendorModel.value
                                                .isSelfDelivery ==
                                            true &&
                                        Constant.isSelfDeliveryFeature ==
                                            true)) ||
                                controller.isEnableFreeDeliveryByAdmin.value ==
                                    true)
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TranslatedText(
                                      "Thanks with a tip!",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: isDark
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x14000000),
                                            blurRadius: 52,
                                            offset: Offset(0, 0),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 14),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: TranslatedText(
                                                    "Around the clock, our delivery partners bring you your favorite meals. Show your appreciation with a tip.",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SvgPicture.asset(
                                                    "assets/images/ic_tips.svg")
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 20;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      20
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : isDark
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "20"),
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 30;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      30
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : isDark
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "30"),
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 40;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      40
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : isDark
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "40"),
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return tipsDialog(
                                                              controller,
                                                              isDark);
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: TranslatedText(
                                                            'Other',
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              TextFieldWidget(
                                title: 'Remarks',
                                controller: controller.reMarkController.value,
                                hintText: 'Write remarks for the restaurant',
                                maxLine: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : Container(
                    decoration: BoxDecoration(
                        color: isDark
                            ? AppThemeData.grey900
                            : AppThemeData.grey50),
                    height: !hasSelectedPayment
                        ? 100
                        : controller.isCashbackApply.value == true
                            ? controller.isEnableFreeDeliveryByAdmin.value ==
                                        false &&
                                    controller.freeDeliveryByAdminModel.value
                                            .isEnableFreeDelivery ==
                                        true &&
                                    controller.selectedFoodType.value !=
                                        'TakeAway'
                                ? 200
                                : 170
                            : controller.freeDeliveryByAdminModel.value
                                            .isEnableFreeDelivery ==
                                        true &&
                                    controller.isEnableFreeDeliveryByAdmin
                                            .value ==
                                        false &&
                                    controller.selectedFoodType.value !=
                                        'TakeAway'
                                ? 170
                                : 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.isCashbackApply.value == true &&
                            hasSelectedPayment)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TranslatedText(
                                    "Cashback Offer",
                                    style: TextStyle(
                                      color: isDark
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey900,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                TranslatedText(
                                  "${"Cashback Name :"} ${controller.bestCashback.value.title ?? ''}",
                                  style: TextStyle(
                                    color: AppThemeData.darkGreen,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                TranslatedText(
                                  "${"You will get"} ${Constant.amountShow(amount: controller.bestCashback.value.cashbackValue?.toStringAsFixed(2))} ${"cashback after completing the order."}",
                                  style: TextStyle(
                                    color: AppThemeData.darkGreen,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if ((controller.isEnableFreeDeliveryByAdmin.value ==
                                    false &&
                                controller.freeDeliveryByAdminModel.value
                                        .isEnableFreeDelivery ==
                                    true &&
                                controller.selectedFoodType.value !=
                                    'TakeAway') &&
                            hasSelectedPayment)
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: (controller.freeDeliveryByAdminModel.value
                                                .isEnableFreeDelivery ==
                                            true &&
                                        controller.isEnableFreeDeliveryByAdmin
                                                .value ==
                                            false)
                                    ? 10
                                    : 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 25,
                                      height: 25,
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/offer_gif.gif"),
                                              fit: BoxFit.fill)),
                                      child: Center(
                                          child: TranslatedText(
                                        "%",
                                        style: TextStyle(
                                            color: isDark
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey50,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                      )),
                                    ),
                                    TranslatedText(
                                      "${'Buy'} ${Constant.amountShow(amount: "${double.parse("${controller.freeDeliveryByAdminModel.value.freeDeliveryOver ?? 0.0}") - controller.subTotal.value}")} ${"more for free delivery"}",
                                      style: TextStyle(
                                        color: AppThemeData.primary300,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: controller.isCashbackApply.value == false
                                  ? 16
                                  : 12,
                              bottom: 20),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: isPaymentLoading
                                      ? null
                                      : () {
                                          _showPaymentBottomSheet(
                                            context,
                                            controller,
                                            isDark,
                                          );
                                        },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _paymentDecoration(
                                          controller, isDark, isPaymentLoading),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TranslatedText(
                                              "Pay Via",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppThemeData.grey400
                                                    : AppThemeData.grey500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            isPaymentLoading
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Container(
                                                        width: 60,
                                                        height: 12,
                                                        color: isDark
                                                            ? AppThemeData
                                                                .grey800
                                                            : AppThemeData
                                                                .grey100),
                                                  )
                                                : !hasSelectedPayment
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 2),
                                                        child: TranslatedText(
                                                          "Select payment",
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isDark
                                                                ? AppThemeData
                                                                    .grey50
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      )
                                                    : Row(
                                                        children: [
                                                          TranslatedText(
                                                            controller
                                                                .checkoutPaymentLabel,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isDark
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          SizedBox(width: 5),
                                                          TranslatedText(
                                                            "(Change)",
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppThemeData
                                                                  .primary300,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: RoundedButtonFill(
                                  textColor:
                                      hasSelectedPayment && !isPaymentLoading
                                          ? AppThemeData.surface
                                          : isDark
                                              ? AppThemeData.grey800
                                              : AppThemeData.grey100,
                                  isEnabled:
                                      hasSelectedPayment && !isPaymentLoading,
                                  title: controller.remainingPayableAmount <=
                                              0 ||
                                          controller.isSelectedModeCod
                                      ? "Place Order"
                                      : "Pay ${Constant.amountShow(amount: controller.remainingPayableAmount.toString())}",
                                  height: 5,
                                  color: hasSelectedPayment && !isPaymentLoading
                                      ? AppThemeData.primary300
                                      : isDark
                                          ? AppThemeData.grey800
                                          : AppThemeData.grey100,
                                  fontSizes: 16,
                                  onPress: () async {
                                    if (controller.deliveryType.value ==
                                        "schedule") {
                                      bool isOpen = controller
                                          .isSelectedDateRestaurantOpen(
                                              selectedDateTime: controller
                                                  .scheduleDateTime.value);
                                      if (isOpen == false) {
                                        ShowToastDialog.showToast(
                                            "The restaurant will be closed at the selected scheduled time. Please choose a different date and time.");
                                        return;
                                      }
                                    }
                                    if ((controller.couponAmount.value >= 1) &&
                                        (controller.couponAmount.value >
                                            controller.totalAmount.value)) {
                                      ShowToastDialog.showToast(
                                          "The total price must be greater than or equal to the coupon discount value for the code to apply. Please review your cart total.");
                                      return;
                                    }
                                    if ((controller
                                                .specialDiscountAmount.value >=
                                            1) &&
                                        (controller
                                                .specialDiscountAmount.value >
                                            controller.totalAmount.value)) {
                                      ShowToastDialog.showToast(
                                          "The total price must be greater than or equal to the special discount value for the code to apply. Please review your cart total.");
                                      return;
                                    }
                                    if (Constant.statusCheckOpenORClose(
                                            vendorModel:
                                                controller.vendorModel.value) !=
                                        true) {
                                      ShowToastDialog.showToast(
                                          "The restaurant is closed at the moment. Please try placing your order later.");
                                      return;
                                    }
                                    if (controller.isOrderPlaced.value ==
                                        false) {
                                      ShowToastDialog.showLoader("Please wait");
                                      bool? isZoneAvailable =
                                          await FireStoreUtils.getNearbyVendor(
                                              latitude: controller
                                                  .selectedAddress
                                                  .value
                                                  .location!
                                                  .latitude!,
                                              longitude: controller
                                                  .selectedAddress
                                                  .value
                                                  .location!
                                                  .longitude!,
                                              vendor:
                                                  controller.vendorModel.value);

                                      if (isZoneAvailable == false) {
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast(
                                            "The selected product is not available at your delivery address.");
                                        return;
                                      }
                                      controller.isOrderPlaced.value = true;
                                      await controller.getCashback();
                                      if (!context.mounted) {
                                        controller.isOrderPlaced.value = false;
                                        ShowToastDialog.closeLoader();
                                        return;
                                      }
                                      await controller
                                          .startSelectedPayment(context);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }

  Widget _suggestedAddOnsSection(CartController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          "Frequently ordered together",
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.suggestedAddOnItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = controller.suggestedAddOnItems[index];
              final price = double.tryParse(product.disPrice ?? '0') != null &&
                      double.parse(product.disPrice ?? '0') > 0
                  ? product.disPrice
                  : product.price;
              return Container(
                width: 150,
                decoration: ShapeDecoration(
                  color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 16,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NetworkImageWidget(
                          imageUrl: product.photo ?? '',
                          height: 72,
                          width: 134,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Constant.amountShow(
                          amount: Constant.productCommissionPrice(
                            controller.vendorModel.value,
                            price ?? '0',
                          ).toString(),
                        ),
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () =>
                              controller.addSuggestedAddOn(product),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppThemeData.primary300,
                            side: BorderSide(
                              color: AppThemeData.primary300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "ADD",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _billSummaryCard(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          "Bill Summary",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        CheckoutBillSummaryCard(
          isDark: isDark,
          totalAmount: Constant.amountShow(
            amount: controller.totalAmount.value.toString(),
          ),
          walletAppliedText: controller.walletAppliedAmount > 0
              ? "${Constant.amountShow(amount: controller.walletAppliedAmount.toString())} wallet applied"
              : null,
          onTap: () => _showBillDetailsBottomSheet(context, controller, isDark),
        ),
      ],
    );
  }

  Future<void> _showBillDetailsBottomSheet(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.62,
          minChildSize: 0.42,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppThemeData.grey600
                            : AppThemeData.grey200,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TranslatedText(
                          "Bill Details",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDark
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: Get.back,
                        icon: Icon(
                          Icons.close,
                          color: isDark
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  amountRow(
                    title: "Item Total",
                    amount: Constant.amountShow(
                      amount: controller.subTotal.value.toString(),
                    ),
                    isDark: isDark,
                  ),
                  sectionDivider(isDark),
                  amountRow(
                    title: "Coupon Discount",
                    amount:
                        "-${Constant.amountShow(amount: controller.couponAmount.value.toString())}",
                    isDark: isDark,
                    amountColor: AppThemeData.danger300,
                  ),
                  if (controller.vendorModel.value.specialDiscountEnable ==
                          true &&
                      Constant.specialDiscountOffer == true) ...[
                    const SizedBox(height: 10),
                    amountRow(
                      title: "Special Discount",
                      amount:
                          "-${Constant.amountShow(amount: controller.specialDiscountAmount.value.toString())}",
                      isDark: isDark,
                      amountColor: AppThemeData.danger300,
                    ),
                  ],
                  sectionDivider(isDark),
                  amountRow(
                    title: "Packaging Fee",
                    amount: Constant.amountShow(
                      amount: controller.packagingCharge.value.toString(),
                    ),
                    isDark: isDark,
                  ),
                  if (controller.selectedFoodType.value != 'TakeAway') ...[
                    const SizedBox(height: 10),
                    amountRow(
                      title: "Delivery Fee",
                      isDark: isDark,
                      trailing: ((controller.vendorModel.value.isSelfDelivery ==
                                      true &&
                                  Constant.isSelfDeliveryFeature == true) ||
                              controller.isEnableFreeDeliveryByAdmin.value ==
                                  true)
                          ? TranslatedText(
                              'Free Delivery',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                color: AppThemeData.success400,
                                fontSize: 16,
                              ),
                            )
                          : Text(
                              Constant.amountShow(
                                amount:
                                    controller.deliveryCharges.value.toString(),
                              ),
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                color: isDark
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontSize: 16,
                              ),
                            ),
                      amount: '',
                    ),
                  ],
                  const SizedBox(height: 10),
                  amountRow(
                    title: "Platform Fee",
                    amount: Constant.amountShow(
                      amount: controller.platformFee.value.toString(),
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => showBillBifurcationDialog(
                      context,
                      isDark,
                      controller,
                    ),
                    child: amountRow(
                      title: "Taxes",
                      amount: Constant.amountShow(
                        amount: controller.totalTaxAmount.value.toString(),
                      ),
                      isDark: isDark,
                      textColour: AppThemeData.primary300,
                      underline: true,
                    ),
                  ),
                  if (controller.deliveryTips.value > 0) ...[
                    const SizedBox(height: 10),
                    amountRow(
                      title: "Tip",
                      amount: Constant.amountShow(
                        amount: controller.deliveryTips.value.toString(),
                      ),
                      isDark: isDark,
                    ),
                  ],
                  if (controller.walletAppliedAmount > 0) ...[
                    sectionDivider(isDark),
                    amountRow(
                      title: "Wallet Deduction",
                      amount:
                          "-${Constant.amountShow(amount: controller.walletAppliedAmount.toString())}",
                      amountColor: AppThemeData.success400,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    amountRow(
                      title: "Payable Now",
                      amount: Constant.amountShow(
                        amount: controller.remainingPayableAmount.toString(),
                      ),
                      amountColor: AppThemeData.primary300,
                      isDark: isDark,
                    ),
                  ],
                  sectionDivider(isDark),
                  amountRow(
                    title: "Total Payable",
                    amount: Constant.amountShow(
                      amount: controller.totalAmount.value.toString(),
                    ),
                    amountColor: AppThemeData.primary300,
                    isDark: isDark,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showBillBifurcationDialog(
      BuildContext context, bool isDark, CartController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 10), // 🔥 KEY FIX
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: Responsive.width(100, context), // ✅ 90% width
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  TranslatedText(
                    "Tax Details",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color:
                          isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  sectionDivider(isDark),
                  const SizedBox(height: 5),
                  Constant.taxScope == 'product'
                      ? amountRow(
                          title: "Tax on item total",
                          amount: Constant.amountShow(
                            amount:
                                controller.productTaxAmount.value.toString(),
                          ),
                          isDark: isDark,
                        )
                      : amountRow(
                          title: "Tax on Order Total",
                          amount: Constant.amountShow(
                            amount: controller.orderTaxAmount.value.toString(),
                          ),
                          isDark: isDark,
                        ),
                  if (controller.selectedFoodType.value != 'TakeAway' &&
                      controller.vendorModel.value.isSelfDelivery != true)
                    sectionDivider(isDark),
                  if (controller.selectedFoodType.value != 'TakeAway' &&
                      controller.vendorModel.value.isSelfDelivery != true)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Constant.driverDeliveryTaxList!.length,
                      itemBuilder: (context, index) {
                        return amountRow(
                          title:
                              "${Constant.driverDeliveryTaxList?[index].title} ${'Tax on Delivery Fee'}",
                          amount: Constant.amountShow(
                              amount: Constant.calculateTax(
                            taxModel: Constant.driverDeliveryTaxList![index],
                            amount:
                                (controller.deliveryCharges.value).toString(),
                          ).toString()),
                          isDark: isDark,
                        );
                      },
                    ),
                  sectionDivider(isDark),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: Constant.packagingTaxList!.length,
                    itemBuilder: (context, index) {
                      return amountRow(
                        title:
                            "${Constant.packagingTaxList![index].title} ${'Tax on Packaging Fee'}",
                        amount: controller.packagingCharge.value == 0.0
                            ? Constant.amountShow(amount: '0')
                            : Constant.amountShow(
                                amount: Constant.calculateTax(
                                taxModel: Constant.packagingTaxList![index],
                                amount:
                                    controller.packagingCharge.value.toString(),
                              ).toString()),
                        isDark: isDark,
                      );
                    },
                  ),
                  if (Constant.packagingTaxList!.isNotEmpty)
                    sectionDivider(isDark),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: Constant.platformTaxList!.length,
                    itemBuilder: (context, index) {
                      return amountRow(
                        title:
                            "${Constant.platformTaxList![index].title} ${'Tax on Platform Fee'}",
                        amount: controller.platformFee.value == 0.0
                            ? Constant.amountShow(amount: '0')
                            : Constant.amountShow(
                                amount: Constant.calculateTax(
                                taxModel: Constant.platformTaxList![index],
                                amount: controller.platformFee.value.toString(),
                              ).toString()),
                        isDark: isDark,
                      );
                    },
                  ),
                  if (Constant.platformTaxList!.isNotEmpty)
                    sectionDivider(isDark),
                  amountRow(
                    title: "Total Tax Amount",
                    amount: Constant.amountShow(
                        amount: controller.totalTaxAmount.value.toString()),
                    amountColor: AppThemeData.primary300,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: TranslatedText("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget amountRow({
    required String title,
    required String amount,
    required bool isDark,
    Color? textColour,
    Color? amountColor,
    bool? underline,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TranslatedText(
            title,
            style: TextStyle(
                fontFamily: 'Urbanist',
                color: textColour ??
                    (isDark ? AppThemeData.grey300 : AppThemeData.grey600),
                fontSize: 16,
                decoration: underline == true
                    ? TextDecoration.underline
                    : TextDecoration.none),
          ),
        ),
        trailing ??
            Text(
              amount,
              style: TextStyle(
                fontFamily: 'Urbanist',
                color: amountColor ??
                    (isDark ? AppThemeData.grey50 : AppThemeData.grey900),
                fontSize: 16,
              ),
            ),
      ],
    );
  }

  Widget sectionDivider(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 10),
        MySeparator(
            color: isDark ? AppThemeData.grey700 : AppThemeData.grey200),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _paymentDecoration(
      CartController controller, bool isDark, bool isPaymentLoading) {
    if (isPaymentLoading) {
      return cardDecoration(controller, PaymentGateway.wallet, isDark, "");
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppThemeData.grey200),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Icon(
          controller.paymentModeIcon(controller.selectedMode),
          color: AppThemeData.primary300,
          size: 22,
        ),
      ),
    );
  }

  Padding cardDecoration(
      CartController controller, PaymentGateway value, isDark, String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppThemeData.grey200),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(value.name == "payFast" ? 0 : 8.0),
          child: image == ''
              ? Container(
                  color: isDark ? AppThemeData.grey800 : AppThemeData.grey100)
              : Image.asset(
                  image,
                ),
        ),
      ),
    );
  }

  Future<void> _showPaymentBottomSheet(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.58,
          minChildSize: 0.38,
          maxChildSize: 0.88,
          builder: (context, scrollController) {
            return Obx(
              () => Container(
                decoration: BoxDecoration(
                  color:
                      isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppThemeData.grey600
                              : AppThemeData.grey200,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TranslatedText(
                            "Choose payment method",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: isDark
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: Get.back,
                          icon: Icon(
                            Icons.close,
                            color: isDark
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (controller.isWalletEnabled &&
                        controller.walletBalance > 0)
                      _paymentWalletTile(controller, isDark),
                    if (controller.selectablePaymentModes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TranslatedText(
                          "No payment methods are available right now.",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppThemeData.grey300
                                : AppThemeData.grey600,
                          ),
                        ),
                      ),
                    ...controller.selectablePaymentModes
                        .where((mode) =>
                            mode != PaymentMode.wallet ||
                            controller.walletSplitResult.isWalletOnly)
                        .map((mode) =>
                            _paymentModeTile(controller, mode, isDark)),
                    const SizedBox(height: 12),
                    RoundedButtonFill(
                      title: controller.remainingPayableAmount <= 0 ||
                              controller.isSelectedModeCod
                          ? "Done"
                          : "Done | ${Constant.amountShow(amount: controller.remainingPayableAmount.toString())}",
                      height: 5,
                      color: AppThemeData.primary300,
                      textColor: AppThemeData.grey50,
                      fontSizes: 16,
                      onPress: () => Get.back(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => controller.getCashback());
  }

  Widget _paymentWalletTile(CartController controller, bool isDark) {
    return CheckoutWalletToggleTile(
      isDark: isDark,
      value: controller.isWalletApplied.value,
      onChanged: controller.setWalletApplied,
      icon: controller.paymentModeIcon(PaymentMode.wallet),
      title: "Use Eatsipy Wallet",
      subtitle:
          "${Constant.amountShow(amount: controller.walletAppliedAmount.toString())} will be applied from ${Constant.amountShow(amount: controller.walletBalance.toString())}",
    );
  }

  Widget _paymentModeTile(
    CartController controller,
    PaymentMode mode,
    bool isDark,
  ) {
    return CheckoutPaymentModeTile(
      isDark: isDark,
      title: controller.paymentModeLabel(mode),
      subtitle: controller.paymentModeSubtitle(mode),
      icon: controller.paymentModeIcon(mode),
      value: mode.name,
      groupValue: controller.selectedPaymentMethod.value,
      onChanged: (_) => controller.selectPaymentMode(mode),
    );
  }

  Dialog tipsDialog(CartController controller, isDark) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldWidget(
                title: 'Tips Amount',
                controller: controller.tipsController.value,
                textInputType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                ],
                prefix: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    "${Constant.currencyModel!.symbol}",
                    style: TextStyle(
                        color:
                            isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                ),
                hintText: 'Enter Tips Amount',
              ),
              Row(
                children: [
                  Expanded(
                    child: RoundedButtonFill(
                      title: "Cancel",
                      color:
                          isDark ? AppThemeData.grey700 : AppThemeData.grey200,
                      textColor:
                          isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                      onPress: () async {
                        Get.back();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: RoundedButtonFill(
                      title: "Add",
                      color: AppThemeData.primary300,
                      textColor: AppThemeData.grey50,
                      onPress: () async {
                        if (controller.tipsController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter tips Amount");
                        } else {
                          controller.deliveryTips.value = double.parse(
                              controller.tipsController.value.text);
                          controller.calculatePrice();
                          Get.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
