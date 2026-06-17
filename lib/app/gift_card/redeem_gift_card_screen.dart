import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:eatsipy_customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/dash_board_controller.dart';
import 'package:eatsipy_customer/controllers/redeem_gift_card_controller.dart';
import 'package:eatsipy_customer/models/gift_cards_order_model.dart';
import 'package:eatsipy_customer/models/wallet_transaction_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/round_button_fill.dart';
import 'package:eatsipy_customer/themes/text_field_widget.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class RedeemGiftCardScreen extends StatelessWidget {
  const RedeemGiftCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: RedeemGiftCardController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
            ),
            body: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      "Redeem Gift Card",
                      style: TextStyle(
                        fontSize: 24,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TranslatedText(
                      "Enter your gift card code to enjoy discounts and special offers on your orders.",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFieldWidget(
                      title: 'Gift Code',
                      controller: controller.giftCodeController.value,
                      hintText: 'Enter gift code',
                      textInputType: TextInputType.number,
                      prefix: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset("assets/icons/ic_gift_code.svg"),
                      ),
                    ),
                    TextFieldWidget(
                      title: 'Gift Pin',
                      controller: controller.giftPinController.value,
                      hintText: 'Enter gift pin',
                      textInputType: TextInputType.number,
                      prefix: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset("assets/icons/ic_gift_pin.svg"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RoundedButtonFill(
                  title: "Redeem",
                  height: 5.5,
                  color: AppThemeData.primary300,
                  textColor: AppThemeData.grey50,
                  fontSizes: 16,
                  onPress: () async {
                    if (controller.giftCodeController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please Enter Gift Code");
                    } else if (controller.giftPinController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please Enter Gift Pin");
                    } else {
                      ShowToastDialog.showLoader("Please wait");
                      await FireStoreUtils.checkRedeemCode(controller.giftCodeController.value.text.replaceAll(" ", "")).then((value) async {
                        if (value != null) {
                          GiftCardsOrderModel giftCodeModel = value;
                          if (giftCodeModel.redeem == true) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast("Gift voucher already redeemed");
                          } else if (giftCodeModel.giftPin != controller.giftPinController.value.text) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast("Gift Pin Invalid");
                          } else if (giftCodeModel.expireDate!.toDate().isBefore(DateTime.now())) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast("Gift Voucher expire");
                          } else {
                            giftCodeModel.redeem = true;

                            WalletTransactionModel transactionModel = WalletTransactionModel(
                                id: Constant.getUuid(),
                                amount: double.parse(giftCodeModel.price.toString()),
                                date: Timestamp.now(),
                                paymentMethod: "Wallet",
                                transactionUser: "user",
                                userId: FireStoreUtils.getCurrentUid(),
                                isTopup: true,
                                note: "Gift Voucher",
                                paymentStatus: "success");

                            await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
                              if (value == true) {
                                await FireStoreUtils.updateUserWallet(amount: giftCodeModel.price.toString(), userId: FireStoreUtils.getCurrentUid()).then((value) async {
                                  await FireStoreUtils.sendTopUpMail(paymentMethod: "Gift Voucher", amount: giftCodeModel.price.toString(), tractionId: transactionModel.id.toString());
                                  await FireStoreUtils.placeGiftCardOrder(giftCodeModel).then((value) {
                                    ShowToastDialog.closeLoader();
                                    if (Constant.walletSetting == true) {
                                      Get.offAll(const DashBoardScreen());
                                      DashBoardController controller = Get.put(DashBoardController());
                                      controller.selectedIndex.value = 2;
                                    }
                                    ShowToastDialog.showToast("Voucher redeem successfully");
                                  });
                                });
                              }
                            });
                          }
                        } else {
                          ShowToastDialog.closeLoader();
                          ShowToastDialog.showToast("Invalid Gift Code");
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
