import 'package:eatsipy_customer/app/wallet_screen/wallet_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/cart_controller.dart';
import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/round_button_fill.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:get/get.dart';

class SelectPaymentScreen extends StatelessWidget {
  const SelectPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
      init: CartController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
          appBar: AppBar(
            backgroundColor:
                isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
            centerTitle: false,
            titleSpacing: 0,
            title: TranslatedText(
              "Payment Option",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
              ),
            ),
          ),
          body: controller.isLoading.value == true
              ? Align(
                  alignment: Alignment.center,
                  child: TranslatedText(
                    "Loading, please wait...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color:
                          isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          "Payment",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDark
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: ShapeDecoration(
                            color: isDark
                                ? AppThemeData.grey900
                                : AppThemeData.grey50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x07000000),
                                blurRadius: 20,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                if (controller.isWalletEnabled &&
                                    controller.walletBalance > 0)
                                  walletToggle(controller, isDark),
                                RadioGroup<String>(
                                  groupValue:
                                      controller.selectedPaymentMethod.value,
                                  onChanged: (value) {
                                    final selectedMode =
                                        PaymentMode.values.firstWhereOrNull(
                                      (mode) => mode.name == value,
                                    );
                                    if (selectedMode != null) {
                                      controller
                                          .selectPaymentMode(selectedMode);
                                    }
                                  },
                                  child: Column(
                                    children: controller.selectablePaymentModes
                                        .where((mode) =>
                                            mode != PaymentMode.wallet ||
                                            controller
                                                .walletSplitResult.isWalletOnly)
                                        .map((mode) =>
                                            modeCard(controller, mode, isDark))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (controller.selectablePaymentModes.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
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
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: RoundedButtonFill(
                title: controller.remainingPayableAmount <= 0 ||
                        controller.isSelectedModeCod
                    ? "Done"
                    : "Done | ${Constant.amountShow(amount: controller.remainingPayableAmount.toString())}",
                height: 5,
                color: AppThemeData.primary300,
                textColor: AppThemeData.grey50,
                fontSizes: 16,
                onPress: () async {
                  Get.back();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Obx walletToggle(CartController controller, bool isDark) {
    return Obx(
      () => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: controller.isWalletApplied.value,
        activeThumbColor: AppThemeData.primary300,
        onChanged: controller.setWalletApplied,
        secondary: Icon(
          controller.paymentModeIcon(PaymentMode.wallet),
          color: AppThemeData.primary300,
        ),
        title: TranslatedText(
          "Use Eatsipy Wallet",
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
        subtitle: Text(
          "${Constant.amountShow(amount: controller.walletAppliedAmount.toString())} will be applied from ${Constant.amountShow(amount: controller.walletBalance.toString())}",
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
          ),
        ),
      ),
    );
  }

  Obx modeCard(CartController controller, PaymentMode mode, bool isDark) {
    return Obx(
      () => InkWell(
        onTap: () => controller.selectPaymentMode(mode),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: ShapeDecoration(
                  color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                  shape: RoundedRectangleBorder(
                    side:
                        const BorderSide(width: 1, color: AppThemeData.grey200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Icon(
                  controller.paymentModeIcon(mode),
                  color: AppThemeData.primary300,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      controller.paymentModeLabel(mode),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color:
                            isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                      ),
                    ),
                    Text(
                      controller.paymentModeSubtitle(mode),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: isDark
                            ? AppThemeData.grey400
                            : AppThemeData.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: mode.name,
                activeColor: AppThemeData.primary300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Obx cardDecoration(
      CartController controller, PaymentGateway value, isDark, String image) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                controller.selectedPaymentMethod.value = value.name;
              },
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: AppThemeData.grey200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.all(value.name == "payFast" ? 0 : 8.0),
                      child: Image.asset(
                        image,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  value.name == "wallet"
                      ? Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText(
                                value.name.toString().capitalizeFirst ?? '',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: isDark
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                ),
                              ),
                              Text(
                                Constant.amountShow(
                                    amount: controller
                                                .userModel.value.walletAmount ==
                                            null
                                        ? '0.0'
                                        : controller
                                            .userModel.value.walletAmount
                                            .toString()),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark
                                      ? AppThemeData.primary300
                                      : AppThemeData.primary300,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: TranslatedText(
                            value.name.toString().capitalizeFirst ?? '',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: isDark
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                            ),
                          ),
                        ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  RadioGroup<String>(
                    groupValue: controller.selectedPaymentMethod.value,
                    onChanged: (selectedValue) {
                      if (selectedValue != null) {
                        controller.selectedPaymentMethod.value = selectedValue;
                      }
                    },
                    child: Radio<String>(
                      value: value.name,
                      activeColor: AppThemeData.primary300,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
