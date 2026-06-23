import 'dart:convert';

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
import 'package:eatsipy_customer/controllers/restaurant_details_controller.dart';
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
import 'package:eatsipy_customer/utils/preferences.dart';
import 'package:eatsipy_customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const String _recentRestaurantNotesKey = 'recentRestaurantNotes';

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
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _sectionTitle(
                            title: "Your Order",
                            subtitle: _cartItemSummaryText(),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 6),
                                )
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 14, 14, 12),
                              child: Column(
                                children: [
                                  ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: cartItem.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final cartProductModel = cartItem[index];
                                      return FutureBuilder<ProductModel?>(
                                        future: FireStoreUtils.getProductById(
                                          cartProductModel.id!.split('~').first,
                                        ),
                                        builder: (context, snapshot) {
                                          final productModel = snapshot.data;
                                          final isCustomizable =
                                              _isCustomizable(productModel);
                                          return InkWell(
                                            onTap: isCustomizable
                                                ? () =>
                                                    _showCartCustomizationSheet(
                                                      context: context,
                                                      controller: controller,
                                                      cartProductModel:
                                                          cartProductModel,
                                                      productModel:
                                                          productModel!,
                                                      isDark: isDark,
                                                    )
                                                : null,
                                            child: _cartItemTile(
                                              context: context,
                                              controller: controller,
                                              cartProductModel:
                                                  cartProductModel,
                                              productModel: productModel,
                                              isDark: isDark,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: isDark
                                              ? AppThemeData.grey800
                                              : AppThemeData.grey100,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _restaurantNotePreview(
                                    context,
                                    controller,
                                    isDark,
                                  ),
                                  _orderCardActions(
                                    context,
                                    controller,
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _sectionGap(),
                        if (controller.suggestedAddOnItems.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _suggestedAddOnsSection(controller, isDark),
                          ),
                          _sectionGap(),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _offersSavingsSection(
                            context,
                            controller,
                            isDark,
                          ),
                        ),
                        _sectionGap(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _deliverySection(
                            context,
                            controller,
                            isDark,
                          ),
                        ),
                        _sectionGap(),
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
                                child: _tipSection(context, controller, isDark),
                              ),
                        const SizedBox(height: 96),
                      ],
                    ),
                  ),
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : _checkoutFooter(
                    context,
                    controller,
                    isDark,
                    hasSelectedPayment,
                    isPaymentLoading,
                  ),
          );
        });
  }

  Widget _cartItemTile({
    required BuildContext context,
    required CartController controller,
    required CartProductModel cartProductModel,
    required ProductModel? productModel,
    required bool isDark,
  }) {
    final variantSummary = _variantSummary(cartProductModel);
    final customizationSummary = _customizationSummary(cartProductModel);
    final isCustomizable = _isCustomizable(productModel);
    final showTax = Constant.taxScope == "product" &&
        cartProductModel.taxSetting?.isNotEmpty == true;
    final hasDiscount =
        double.tryParse(cartProductModel.discountPrice.toString()) != null &&
            double.parse(cartProductModel.discountPrice.toString()) > 0;
    final actionColumnWidth =
        MediaQuery.sizeOf(context).width < 360 ? 108.0 : 118.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (productModel?.veg == true ||
                          productModel?.nonveg == true) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 4, right: 7),
                          child: _dietMarker(
                            isVeg: productModel?.veg == true,
                          ),
                        ),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartProductModel.name ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                            if (variantSummary != null) ...[
                              const SizedBox(height: 5),
                              Text(
                                variantSummary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _cartMetaStyle(isDark),
                              ),
                            ],
                            if (customizationSummary != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                customizationSummary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _cartMetaStyle(isDark),
                              ),
                            ],
                            if (isCustomizable) ...[
                              const SizedBox(height: 6),
                              _editCustomizationButton(
                                context: context,
                                controller: controller,
                                cartProductModel: cartProductModel,
                                productModel: productModel!,
                                isDark: isDark,
                              ),
                            ],
                            if (showTax) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Tax: ${Constant.getTaxDisplayText(cartProductModel.taxSetting)}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _cartMetaStyle(isDark).copyWith(
                                  color: AppThemeData.primary300,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: actionColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _quantityStepper(
                  controller: controller,
                  cartProductModel: cartProductModel,
                  productModel: productModel,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _cartItemPriceRow(
                  cartProductModel: cartProductModel,
                  hasDiscount: hasDiscount,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemPriceRow({
    required CartProductModel cartProductModel,
    required bool hasDiscount,
    required bool isDark,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasDiscount) ...[
                Text(
                  Constant.amountShow(amount: cartProductModel.price),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
                    fontSize: 10,
                    decoration: TextDecoration.lineThrough,
                    decorationColor:
                        isDark ? AppThemeData.grey500 : AppThemeData.grey400,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                Constant.amountShow(
                  amount: hasDiscount
                      ? cartProductModel.discountPrice.toString()
                      : cartProductModel.price,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _cartMetaStyle(bool isDark) {
    return TextStyle(
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.w600,
      color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
      fontSize: 12,
      height: 1.2,
    );
  }

  Widget _dietMarker({required bool isVeg}) {
    final color = isVeg ? AppThemeData.darkGreen : AppThemeData.danger300;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  String? _variantSummary(CartProductModel cartProductModel) {
    final options = cartProductModel.variantInfo?.variantOptions;
    if (options == null || options.isEmpty) {
      return null;
    }
    return options.entries
        .map((entry) => "${entry.key}: ${entry.value}")
        .join(" · ");
  }

  String? _customizationSummary(CartProductModel cartProductModel) {
    final extras = cartProductModel.extras;
    if (extras == null || extras.isEmpty) {
      return null;
    }
    if (extras.length == 1) {
      return "1 x ${extras.first}";
    }
    return "${extras.length} customizations selected";
  }

  bool _isCustomizable(ProductModel? productModel) {
    if (productModel == null) {
      return false;
    }
    final hasAddons = productModel.addOnsTitle?.isNotEmpty == true;
    final hasVariants =
        productModel.itemAttribute?.attributes?.isNotEmpty == true ||
            productModel.itemAttribute?.variants?.isNotEmpty == true;
    return hasAddons || hasVariants;
  }

  Widget _editCustomizationButton({
    required BuildContext context,
    required CartController controller,
    required CartProductModel cartProductModel,
    required ProductModel productModel,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _showCartCustomizationSheet(
        context: context,
        controller: controller,
        cartProductModel: cartProductModel,
        productModel: productModel,
        isDark: isDark,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Edit",
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                color: AppThemeData.primary300,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              color: AppThemeData.primary300,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  double _cartAddonsTotal() {
    return cartItem.fold<double>(0, (total, item) {
      final extrasPrice = double.tryParse(item.extrasPrice ?? '0') ?? 0;
      final quantity = item.quantity ?? 0;
      return total + (extrasPrice * quantity);
    });
  }

  Future<void> _showCartCustomizationSheet({
    required BuildContext context,
    required CartController controller,
    required CartProductModel cartProductModel,
    required ProductModel productModel,
    required bool isDark,
  }) {
    final selectedAddOns = <String>{
      ...?cartProductModel.extras?.map((extra) => extra.toString()),
    };
    final addonTitles =
        productModel.addOnsTitle?.map((title) => title.toString()).toList() ??
            <String>[];
    final addonPrices =
        productModel.addOnsPrice?.map((price) => price.toString()).toList() ??
            <String>[];
    final variantSummary = _variantSummary(cartProductModel);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final addonTotal = _selectedAddOnsUnitTotal(
              controller: controller,
              productModel: productModel,
              selectedAddOns: selectedAddOns,
            );
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey900 : AppThemeData.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppThemeData.grey700
                                : AppThemeData.grey200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Edit customization",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isDark
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productModel.name ?? cartProductModel.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark
                              ? AppThemeData.grey400
                              : AppThemeData.grey500,
                        ),
                      ),
                      if (variantSummary != null) ...[
                        const SizedBox(height: 14),
                        _readonlyCustomizationInfo(
                          title: "Selected option",
                          value: variantSummary,
                          isDark: isDark,
                        ),
                      ],
                      if (addonTitles.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          "Add-ons",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: isDark
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: addonTitles.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDark
                                  ? AppThemeData.grey800
                                  : AppThemeData.grey100,
                            ),
                            itemBuilder: (context, index) {
                              final title = addonTitles[index];
                              final rawPrice = index < addonPrices.length
                                  ? addonPrices[index]
                                  : '0';
                              final price = Constant.productCommissionPrice(
                                controller.vendorModel.value,
                                rawPrice,
                              );
                              final isSelected = selectedAddOns.contains(title);
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                value: isSelected,
                                activeColor: AppThemeData.primary300,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                onChanged: (value) {
                                  setSheetState(() {
                                    if (value == true) {
                                      selectedAddOns.add(title);
                                    } else {
                                      selectedAddOns.remove(title);
                                    }
                                  });
                                },
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppThemeData.grey100
                                        : AppThemeData.grey900,
                                  ),
                                ),
                                subtitle: Text(
                                  Constant.amountShow(amount: price),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        _readonlyCustomizationInfo(
                          title: "No optional add-ons",
                          value:
                              "This item only has the required option shown above.",
                          isDark: isDark,
                        ),
                      ],
                      const SizedBox(height: 16),
                      RoundedButtonFill(
                        title: addonTotal > 0
                            ? "Update ${Constant.amountShow(amount: addonTotal.toString())}"
                            : "Update Item",
                        height: 5.4,
                        color: AppThemeData.primary300,
                        textColor: AppThemeData.surface,
                        fontSizes: 15,
                        onPress: () async {
                          cartProductModel.extras = selectedAddOns.toList();
                          cartProductModel.extrasPrice = addonTotal.toString();
                          controller.addToCart(
                            cartProductModel: cartProductModel,
                            isIncrement: true,
                            quantity: cartProductModel.quantity ?? 1,
                          );
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _readonlyCustomizationInfo({
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
            ),
          ),
        ],
      ),
    );
  }

  double _selectedAddOnsUnitTotal({
    required CartController controller,
    required ProductModel productModel,
    required Set<String> selectedAddOns,
  }) {
    double total = 0;
    final titles = productModel.addOnsTitle ?? [];
    final prices = productModel.addOnsPrice ?? [];
    for (var index = 0; index < titles.length; index++) {
      final title = titles[index].toString();
      if (!selectedAddOns.contains(title)) {
        continue;
      }
      final rawPrice = index < prices.length ? prices[index].toString() : '0';
      total += double.tryParse(
            Constant.productCommissionPrice(
              controller.vendorModel.value,
              rawPrice,
            ),
          ) ??
          0;
    }
    return total;
  }

  double _savingsAmount(CartController controller) {
    return controller.couponAmount.value +
        controller.specialDiscountAmount.value;
  }

  Widget _quantityStepper({
    required CartController controller,
    required CartProductModel cartProductModel,
    required ProductModel? productModel,
    required bool isDark,
  }) {
    return Container(
      height: 34,
      decoration: ShapeDecoration(
        color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepperTapTarget(
            icon: Icons.remove_rounded,
            onTap: () {
              controller.addToCart(
                cartProductModel: cartProductModel,
                isIncrement: false,
                quantity: cartProductModel.quantity! - 1,
              );
            },
          ),
          SizedBox(
            width: 24,
            child: Text(
              cartProductModel.quantity.toString(),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
              ),
            ),
          ),
          _stepperTapTarget(
            icon: Icons.add_rounded,
            onTap: () => _incrementCartItem(
              controller: controller,
              cartProductModel: cartProductModel,
              productModel: productModel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperTapTarget({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 28,
        height: 34,
        child: Icon(
          icon,
          size: 17,
          color: AppThemeData.primary300,
        ),
      ),
    );
  }

  void _incrementCartItem({
    required CartController controller,
    required CartProductModel cartProductModel,
    required ProductModel? productModel,
  }) {
    if (productModel == null) {
      return;
    }
    if (productModel.itemAttribute != null) {
      final matchingVariants = productModel.itemAttribute!.variants!
          .where(
            (element) =>
                element.variantSku == cartProductModel.variantInfo!.variantSku,
          )
          .toList();
      if (matchingVariants.isNotEmpty) {
        final variantQuantity = int.parse(
          matchingVariants.first.variantQuantity.toString(),
        );
        if (variantQuantity > (cartProductModel.quantity ?? 0) ||
            variantQuantity == -1) {
          controller.addToCart(
            cartProductModel: cartProductModel,
            isIncrement: true,
            quantity: cartProductModel.quantity! + 1,
          );
        } else {
          ShowToastDialog.showToast("Out of stock");
        }
        return;
      }
    }
    if ((productModel.quantity ?? 0) > (cartProductModel.quantity ?? 0) ||
        productModel.quantity == -1) {
      controller.addToCart(
        cartProductModel: cartProductModel,
        isIncrement: true,
        quantity: cartProductModel.quantity! + 1,
      );
    } else {
      ShowToastDialog.showToast("Out of stock");
    }
  }

  SizedBox _sectionGap() => const SizedBox(height: 16);

  String _cartItemSummaryText() {
    final totalQuantity = cartItem.fold<int>(
      0,
      (total, item) => total + (item.quantity ?? 0),
    );
    final itemLabel = cartItem.length == 1 ? "item" : "items";
    final quantityLabel = totalQuantity == 1 ? "quantity" : "quantities";
    return "${cartItem.length} $itemLabel - $totalQuantity $quantityLabel";
  }

  Widget _sectionTitle({
    required String title,
    required bool isDark,
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                title,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 16,
                ),
              ),
              if (subtitle?.isNotEmpty == true) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _premiumCard({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    VoidCallback? onTap,
  }) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      decoration: ShapeDecoration(
        color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 22,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
    if (onTap == null) {
      return card;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
    );
  }

  Widget _orderCardActions(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    return _orderActionButton(
      icon: Icons.add_rounded,
      label: "Add More Items",
      isDark: isDark,
      onTap: () => _openRestaurantMenu(controller),
    );
  }

  Widget _orderActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppThemeData.primary300,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRestaurantMenu(CartController controller) {
    final vendor = controller.vendorModel.value;
    if ((vendor.id ?? '').isEmpty) {
      return;
    }
    Get.to(
      const RestaurantDetailsScreen(),
      arguments: {"vendorModel": vendor},
    );
  }

  Widget _restaurantNotePreview(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.reMarkController.value,
      builder: (context, value, _) {
        final note = value.text.trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showRestaurantNoteSheet(
              context,
              controller,
              isDark,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey800 : AppThemeData.grey50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add note for restaurant",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          note.isEmpty ? "Any kitchen request?" : note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            color: note.isEmpty
                                ? isDark
                                    ? AppThemeData.grey500
                                    : AppThemeData.grey400
                                : isDark
                                    ? AppThemeData.grey300
                                    : AppThemeData.grey700,
                            fontSize: 12,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRestaurantNoteSheet(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    final savedNote = controller.reMarkController.value.text.trim();
    final noteController = TextEditingController(text: savedNote);
    final recentNotes = _recentRestaurantNotes();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey900 : AppThemeData.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Add note for restaurant",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color:
                            isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Share preparation preferences with the kitchen.",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark
                            ? AppThemeData.grey400
                            : AppThemeData.grey500,
                      ),
                    ),
                    TextFieldWidget(
                      title: null,
                      controller: noteController,
                      hintText: 'Any kitchen request?',
                      maxLine: 4,
                    ),
                    if (recentNotes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        "Recent notes",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: isDark
                              ? AppThemeData.grey400
                              : AppThemeData.grey500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recentNotes
                            .map(
                              (note) => _recentNoteChip(
                                label: note,
                                noteController: noteController,
                                isDark: isDark,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (controller.reMarkController.value.text
                            .trim()
                            .isNotEmpty) ...[
                          TextButton(
                            onPressed: () {
                              controller.reMarkController.value.clear();
                              Navigator.pop(sheetContext);
                            },
                            child: const Text("Remove"),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: RoundedButtonFill(
                            title: "Save Note",
                            height: 5.4,
                            color: AppThemeData.primary300,
                            textColor: AppThemeData.surface,
                            fontSizes: 15,
                            onPress: () {
                              final note = noteController.text.trim();
                              controller.reMarkController.value.text = note;
                              _rememberRestaurantNote(note);
                              Navigator.pop(sheetContext);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<String> _recentRestaurantNotes() {
    final rawNotes = Preferences.getString(_recentRestaurantNotesKey);
    if (rawNotes.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(rawNotes);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .map((note) => note.toString().trim())
          .where((note) => note.isNotEmpty)
          .take(3)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _rememberRestaurantNote(String note) async {
    if (note.isEmpty) {
      return;
    }
    final notes = [
      note,
      ..._recentRestaurantNotes().where((existing) => existing != note),
    ].take(3).toList();
    await Preferences.setString(_recentRestaurantNotesKey, jsonEncode(notes));
  }

  Widget _recentNoteChip({
    required String label,
    required TextEditingController noteController,
    required bool isDark,
  }) {
    return ActionChip(
      avatar: Icon(
        Icons.history_rounded,
        size: 16,
        color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
      ),
      label: Text(label),
      onPressed: () {
        noteController.text = label;
        noteController.selection = TextSelection.fromPosition(
          TextPosition(offset: noteController.text.length),
        );
      },
      backgroundColor: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
      side: BorderSide(
        color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
      ),
      labelStyle: TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w700,
        color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
      ),
    );
  }

  Widget _offersSavingsSection(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    final savings =
        controller.couponAmount.value + controller.specialDiscountAmount.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title: "Offers",
          subtitle: savings > 0 ? "You saved on this order" : "Apply coupon",
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _premiumCard(
          isDark: isDark,
          onTap: () => Get.to(const CouponListScreen()),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppThemeData.success400.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: AppThemeData.success400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      savings > 0
                          ? "You saved ${Constant.amountShow(amount: savings.toString())}"
                          : "Apply Coupon",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        color: savings > 0
                            ? AppThemeData.success400
                            : isDark
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      savings > 0
                          ? "Coupon and restaurant savings applied"
                          : "View available offers and discounts",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppThemeData.grey400
                            : AppThemeData.grey500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deliverySection(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title: "Delivery",
          subtitle: controller.selectedFoodType.value == 'TakeAway'
              ? "Pickup details"
              : "ETA, type and address",
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _premiumCard(
          isDark: isDark,
          child: Column(
            children: [
              _etaCard(controller, isDark),
              if (Constant.isScheduledOrderEnabled) ...[
                sectionDivider(isDark),
                _deliveryTypeSegment(context, controller, isDark),
              ],
              if (controller.selectedFoodType.value != 'TakeAway') ...[
                sectionDivider(isDark),
                _deliveryAddressCard(controller, isDark),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _etaCard(CartController controller, bool isDark) {
    final isScheduledDelivery = Constant.isScheduledOrderEnabled &&
        controller.deliveryType.value == "schedule";
    final eta = isScheduledDelivery
        ? Constant.timestampToDateTime(
            Timestamp.fromDate(controller.scheduleDateTime.value),
          )
        : "15-20 mins";
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppThemeData.success400.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: AppThemeData.success400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isScheduledDelivery ? "Scheduled for $eta" : "Delivery in $eta",
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isScheduledDelivery
                    ? "Your preferred delivery slot"
                    : "Fastest available option",
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deliveryTypeSegment(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segmentOption(
              title: "Instant Delivery",
              isSelected: controller.deliveryType.value == "instant",
              isDark: isDark,
              onTap: () => controller.deliveryType.value = "instant",
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _segmentOption(
              title: "Schedule",
              isSelected: controller.deliveryType.value == "schedule",
              isDark: isDark,
              onTap: () => _openSchedulePicker(context, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentOption({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeData.primary300
              : isDark
                  ? AppThemeData.grey800
                  : AppThemeData.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w800,
            color: isSelected
                ? AppThemeData.surface
                : isDark
                    ? AppThemeData.grey200
                    : AppThemeData.grey700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _openSchedulePicker(
    BuildContext context,
    CartController controller,
  ) {
    if (!Constant.isScheduledOrderEnabled) {
      controller.deliveryType.value = "instant";
      return;
    }
    controller.deliveryType.value = "schedule";
    BottomPicker.dateTime(
      initialDateTime: controller.scheduleDateTime.value,
      onSubmit: (index) {
        controller.scheduleDateTime.value = index;
      },
      minDateTime: DateTime.now(),
      displaySubmitButton: true,
      headerBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TranslatedText(
          'Schedule Time',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppThemeData.grey50
                : AppThemeData.grey900,
            fontSize: 18,
          ),
        ),
      ),
      buttonSingleColor: AppThemeData.primary300,
    ).show(context);
  }

  Widget _deliveryAddressCard(CartController controller, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Get.to(const AddressListScreen())!.then(
          (value) {
            if (value != null) {
              ShippingAddress addressModel = value;
              controller.selectedAddress.value = addressModel;
              controller.calculatePrice();
            }
          },
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppThemeData.primary300.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: AppThemeData.primary300,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivering To",
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                TranslatedText(
                  controller.selectedAddress.value.addressAs.toString(),
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                TranslatedText(
                  controller.selectedAddress.value.getFullAddress(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Change",
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              color: AppThemeData.primary300,
              fontSize: 13,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppThemeData.primary300,
          ),
        ],
      ),
    );
  }

  Widget _tipSection(
    BuildContext context,
    CartController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionGap(),
        _sectionTitle(
          title: "Tip Your Delivery Partner",
          subtitle: null,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _premiumCard(
          isDark: isDark,
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tipChip(controller, isDark, 5),
                _tipChip(controller, isDark, 10),
                _tipChip(controller, isDark, 20),
                _tipChip(controller, isDark, 30),
                _tipChip(controller, isDark, null, context: context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tipChip(
    CartController controller,
    bool isDark,
    int? amount, {
    BuildContext? context,
  }) {
    final isOther = amount == null;
    final isSelected = !isOther && controller.deliveryTips.value == amount;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isSelected,
        showCheckmark: false,
        label: Text(
          isOther ? "Other" : Constant.amountShow(amount: amount.toString()),
        ),
        selectedColor: AppThemeData.primary300,
        backgroundColor: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
        labelStyle: TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
          color: isSelected
              ? AppThemeData.surface
              : isDark
                  ? AppThemeData.grey100
                  : AppThemeData.grey800,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: isSelected
                ? AppThemeData.primary300
                : isDark
                    ? AppThemeData.grey700
                    : AppThemeData.grey200,
          ),
        ),
        onSelected: (_) {
          if (isOther && context != null) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return tipsDialog(controller, isDark);
              },
            );
            return;
          }
          controller.deliveryTips.value = amount?.toDouble() ?? 0;
          controller.calculatePrice();
        },
      ),
    );
  }

  Widget _checkoutFooter(
    BuildContext context,
    CartController controller,
    bool isDark,
    bool hasSelectedPayment,
    bool isPaymentLoading,
  ) {
    final canCheckout = hasSelectedPayment && !isPaymentLoading;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 22,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isCashbackApply.value == true &&
                  hasSelectedPayment)
                _footerInfoStrip(
                  isDark: isDark,
                  icon: Icons.savings_rounded,
                  text:
                      "${controller.bestCashback.value.title ?? 'Cashback'} • ${Constant.amountShow(amount: controller.bestCashback.value.cashbackValue?.toStringAsFixed(2))} after order",
                  color: AppThemeData.success400,
                ),
              if ((controller.isEnableFreeDeliveryByAdmin.value == false &&
                      controller.freeDeliveryByAdminModel.value
                              .isEnableFreeDelivery ==
                          true &&
                      controller.selectedFoodType.value != 'TakeAway') &&
                  hasSelectedPayment)
                _footerInfoStrip(
                  isDark: isDark,
                  icon: Icons.local_shipping_rounded,
                  text:
                      "Buy ${Constant.amountShow(amount: "${double.parse("${controller.freeDeliveryByAdminModel.value.freeDeliveryOver ?? 0.0}") - controller.subTotal.value}")} more for free delivery",
                  color: AppThemeData.primary300,
                ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: isPaymentLoading
                          ? null
                          : () => _showPaymentBottomSheet(
                                context,
                                controller,
                                isDark,
                              ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Total Payable",
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppThemeData.grey400
                                    : AppThemeData.grey500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Constant.amountShow(
                                amount: controller.totalAmount.value.toString(),
                              ),
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    hasSelectedPayment
                                        ? controller.checkoutPaymentLabel
                                        : "Select payment",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppThemeData.grey300
                                          : AppThemeData.grey700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Change",
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                    color: AppThemeData.primary300,
                                    fontSize: 12,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppThemeData.primary300,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 152,
                    child: RoundedButtonFill(
                      textColor: canCheckout
                          ? AppThemeData.surface
                          : isDark
                              ? AppThemeData.grey800
                              : AppThemeData.grey100,
                      isEnabled: canCheckout,
                      title: controller.remainingPayableAmount <= 0 ||
                              controller.isSelectedModeCod
                          ? "Place Order →"
                          : "Pay ${Constant.amountShow(amount: controller.remainingPayableAmount.toString())} →",
                      height: 5.8,
                      color: canCheckout
                          ? AppThemeData.primary300
                          : isDark
                              ? AppThemeData.grey800
                              : AppThemeData.grey100,
                      fontSizes: 15,
                      onPress: () => _handlePlaceOrderPressed(
                        context,
                        controller,
                      ),
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

  Widget _footerInfoStrip({
    required bool isDark,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlaceOrderPressed(
    BuildContext context,
    CartController controller,
  ) async {
    if (!Constant.isScheduledOrderEnabled &&
        controller.deliveryType.value == "schedule") {
      controller.deliveryType.value = "instant";
    }
    if (controller.deliveryType.value == "schedule") {
      final isOpen = controller.isSelectedDateRestaurantOpen(
        selectedDateTime: controller.scheduleDateTime.value,
      );
      if (isOpen == false) {
        ShowToastDialog.showToast(
          "The restaurant will be closed at the selected scheduled time. Please choose a different date and time.",
        );
        return;
      }
    }
    if ((controller.couponAmount.value >= 1) &&
        (controller.couponAmount.value > controller.totalAmount.value)) {
      ShowToastDialog.showToast(
        "The total price must be greater than or equal to the coupon discount value for the code to apply. Please review your cart total.",
      );
      return;
    }
    if ((controller.specialDiscountAmount.value >= 1) &&
        (controller.specialDiscountAmount.value >
            controller.totalAmount.value)) {
      ShowToastDialog.showToast(
        "The total price must be greater than or equal to the special discount value for the code to apply. Please review your cart total.",
      );
      return;
    }
    if (Constant.statusCheckOpenORClose(
            vendorModel: controller.vendorModel.value) !=
        true) {
      ShowToastDialog.showToast(
        "The restaurant is closed at the moment. Please try placing your order later.",
      );
      return;
    }
    if (controller.isOrderPlaced.value == false) {
      ShowToastDialog.showLoader("Please wait");
      final isZoneAvailable = await FireStoreUtils.getNearbyVendor(
        latitude: controller.selectedAddress.value.location!.latitude!,
        longitude: controller.selectedAddress.value.location!.longitude!,
        vendor: controller.vendorModel.value,
      );

      if (isZoneAvailable == false) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          "The selected product is not available at your delivery address.",
        );
        return;
      }
      controller.isOrderPlaced.value = true;
      await controller.getCashback();
      if (!context.mounted) {
        controller.isOrderPlaced.value = false;
        ShowToastDialog.closeLoader();
        return;
      }
      await controller.startSelectedPayment(context);
    }
  }

  Widget _suggestedAddOnsSection(CartController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          "Complete Your Meal",
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth * 0.42).clamp(150.0, 172.0);
            final imageHeight = cardWidth * 0.58;
            final listHeight = imageHeight + 72;
            return SizedBox(
              height: listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.suggestedAddOnItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final product = controller.suggestedAddOnItems[index];
                  final price =
                      double.tryParse(product.disPrice ?? '0') != null &&
                              double.parse(product.disPrice ?? '0') > 0
                          ? product.disPrice
                          : product.price;
                  return GestureDetector(
                    onTap: () => _showProductDetailsSheet(context, product),
                    child: SizedBox(
                    width: cardWidth,
                    child: Container(
                      decoration: ShapeDecoration(
                        color:
                            isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 16,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: NetworkImageWidget(
                                imageUrl: product.photo ?? '',
                                height: imageHeight,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        Constant.amountShow(
                                          amount:
                                              Constant.productCommissionPrice(
                                            controller.vendorModel.value,
                                            price ?? '0',
                                          ).toString(),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppThemeData.grey400
                                              : AppThemeData.grey500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: IconButton.outlined(
                                    onPressed: () =>
                                        controller.addSuggestedAddOn(product),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    iconSize: 16,
                                    style: IconButton.styleFrom(
                                      side: BorderSide(
                                        color: AppThemeData.primary300,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: AppThemeData.primary300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showProductDetailsSheet(
      BuildContext context, ProductModel productModel) {
    final cartController = Get.find<CartController>();
    final wasRegistered = Get.isRegistered<RestaurantDetailsController>();
    final detailController = wasRegistered
        ? Get.find<RestaurantDetailsController>()
        : Get.put(RestaurantDetailsController());
    detailController.vendorModel.value = cartController.vendorModel.value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ProductDetailsView(productModel: productModel),
      ),
    ).then((_) {
      if (!wasRegistered) {
        Get.delete<RestaurantDetailsController>(force: true);
      }
      final inCart = cartItem
          .any((item) => item.id?.split('~').first == productModel.id);
      if (inCart) {
        cartController.suggestedAddOnItems
            .removeWhere((item) => item.id == productModel.id);
      }
    });
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
          "Order Total",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
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
          walletAppliedText: _savingsAmount(controller) > 0
              ? "You saved ${Constant.amountShow(amount: _savingsAmount(controller).toString())}"
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
                          "Order Total",
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
                  if (_cartAddonsTotal() > 0) ...[
                    const SizedBox(height: 10),
                    amountRow(
                      title: "Addons",
                      amount: Constant.amountShow(
                        amount: _cartAddonsTotal().toString(),
                      ),
                      isDark: isDark,
                    ),
                  ],
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
                                fontWeight: FontWeight.w600,
                                color: AppThemeData.success400,
                                fontSize: 14,
                              ),
                            )
                          : Text(
                              Constant.amountShow(
                                amount:
                                    controller.deliveryCharges.value.toString(),
                              ),
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontSize: 14,
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
                  Row(
                    children: [
                      Expanded(
                        child: TranslatedText(
                          "Total Payable",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        Constant.amountShow(
                          amount: controller.totalAmount.value.toString(),
                        ),
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w800,
                          color: AppThemeData.primary300,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  if (_savingsAmount(controller) > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      "You saved ${Constant.amountShow(amount: _savingsAmount(controller).toString())}",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        color: AppThemeData.success400,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                fontWeight: FontWeight.w500,
                color: textColour ??
                    (isDark ? AppThemeData.grey300 : AppThemeData.grey600),
                fontSize: 14,
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
                fontWeight: FontWeight.w600,
                color: amountColor ??
                    (isDark ? AppThemeData.grey50 : AppThemeData.grey900),
                fontSize: 14,
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
