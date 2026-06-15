import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:customer/app/cart_screen/oder_placing_screens.dart';
import 'package:customer/app/wallet_screen/wallet_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cashfree_service_controller.dart';
import 'package:customer/controllers/instamojo_service_controller.dart';
import 'package:customer/controllers/mtnmomo_controller.dart';
import 'package:customer/controllers/paymongo_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/cashbackModel.dart';
import 'package:customer/models/cashback_redeem_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/free_delivery_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/models/payment_model/cashfree_model.dart';
import 'package:customer/models/payment_model/cod_setting_model.dart';
import 'package:customer/models/payment_model/flutter_wave_model.dart';
import 'package:customer/models/payment_model/foloosi_model.dart';
import 'package:customer/models/payment_model/instamojo_model.dart';
import 'package:customer/models/payment_model/mercado_pago_model.dart';
import 'package:customer/models/payment_model/midtrans_model.dart';
import 'package:customer/models/payment_model/mtnmomo_model.dart';
import 'package:customer/models/payment_model/orange_money.dart';
import 'package:customer/models/payment_model/pay_fast_model.dart';
import 'package:customer/models/payment_model/pay_stack_model.dart';
import 'package:customer/models/payment_model/paymongo_model.dart';
import 'package:customer/models/payment_model/paypal_model.dart';
import 'package:customer/models/payment_model/paytm_model.dart';
import 'package:customer/models/payment_model/phonepe_model.dart';
import 'package:customer/models/payment_model/razorpay_model.dart';
import 'package:customer/models/payment_model/stripe_model.dart';
import 'package:customer/models/payment_model/wallet_setting_model.dart';
import 'package:customer/models/payment_model/xendit.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/wallet_transaction_model.dart';
import 'package:customer/payment/MercadoPagoScreen.dart';
import 'package:customer/payment/PayFastScreen.dart';
import 'package:customer/payment/getPaytmTxtToken.dart';
import 'package:customer/payment/midtrans_screen.dart';
import 'package:customer/payment/mtn_momo_payment_screen.dart';
import 'package:customer/payment/orangePayScreen.dart';
import 'package:customer/payment/paystack/pay_stack_screen.dart';
import 'package:customer/payment/paystack/pay_stack_url_model.dart';
import 'package:customer/payment/paystack/paystack_url_genrater.dart';
import 'package:customer/payment/weburlservicescreen.dart';
import 'package:customer/payment/xenditModel.dart';
import 'package:customer/payment/xenditScreen.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';

import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:foloosi_plugins/foloosi_plugins.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

class CartController extends GetxController {
  RxBool isCashbackApply = false.obs;
  Rx<CashbackModel> bestCashback = CashbackModel().obs;

  final CartProvider cartProvider = CartProvider();
  Rx<TextEditingController> reMarkController = TextEditingController().obs;
  Rx<TextEditingController> couponCodeController = TextEditingController().obs;
  Rx<TextEditingController> tipsController = TextEditingController().obs;

  Rx<ShippingAddress> selectedAddress = ShippingAddress().obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;
  Rx<FreeDeliveryByAdminModel> freeDeliveryByAdminModel = FreeDeliveryByAdminModel().obs;
  RxBool isEnableFreeDeliveryByAdmin = false.obs;
  Rx<DeliveryCharge> deliveryChargeModel = DeliveryCharge().obs;
  Rx<UserModel> userModel = UserModel().obs;
  RxList<CouponModel> couponList = <CouponModel>[].obs;
  RxList<CouponModel> allCouponList = <CouponModel>[].obs;
  RxString selectedFoodType = "Delivery".obs;

  RxString selectedPaymentMethod = ''.obs;
  RxBool isOrderPlaced = false.obs;

  RxString deliveryType = "instant".obs;
  Rx<DateTime> scheduleDateTime = DateTime.now().obs;
  RxDouble totalDistance = 0.0.obs;
  RxDouble deliveryCharges = 0.0.obs;
  RxDouble subTotal = 0.0.obs;
  RxDouble packagingCharge = 0.0.obs;
  RxDouble platformFee = 0.0.obs;
  RxDouble couponAmount = 0.0.obs;

  RxDouble specialDiscountAmount = 0.0.obs;
  RxDouble specialDiscount = 0.0.obs;
  RxString specialType = "".obs;

  RxDouble deliveryTips = 0.0.obs;

  RxDouble productTaxAmount = 0.0.obs;
  RxDouble orderTaxAmount = 0.0.obs;
  RxDouble driverDeliveryTaxAmount = 0.0.obs;
  RxDouble packagingTaxAmount = 0.0.obs;
  RxDouble platformTaxAmount = 0.0.obs;
  RxDouble totalTaxAmount = 0.0.obs;

  RxDouble totalAmount = 0.0.obs;
  Rx<CouponModel> selectedCouponModel = CouponModel().obs;

  @override
  void onInit() {
    selectedAddress.value = Constant.selectedLocation;
    getPaymentSettings();
    getCartData();
    super.onInit();
  }

  Future<void> getCartData() async {
    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);

        if (cartItem.isNotEmpty) {
          await FireStoreUtils.getVendorById(cartItem.first.vendorID.toString()).then(
            (value) {
              if (value != null) {
                vendorModel.value = value;
              }
            },
          );
        }
        calculatePrice();
      },
    );
    selectedFoodType.value = Preferences.getString(Preferences.foodDeliveryType, defaultValue: "Delivery");

    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );

    await FireStoreUtils.getFreeDeliveryByAdminData().then(
      (value) {
        if (value != null) {
          freeDeliveryByAdminModel.value = value;
        }
      },
    );

    await FireStoreUtils.getDeliveryCharge().then(
      (value) {
        if (value != null) {
          deliveryChargeModel.value = value;
          calculatePrice();
        }
      },
    );

    await FireStoreUtils.getAllVendorPublicCoupons(vendorModel.value.id.toString()).then(
      (value) {
        couponList.value = value;
      },
    );

    await FireStoreUtils.getAllVendorCoupons(vendorModel.value.id.toString()).then(
      (value) {
        allCouponList.value = value;
      },
    );
  }

  Future<void> calculatePrice() async {
    deliveryCharges.value = 0.0;
    subTotal.value = 0.0;
    couponAmount.value = 0.0;
    specialDiscountAmount.value = 0.0;

    productTaxAmount.value = 0.0;
    orderTaxAmount.value = 0.0;
    driverDeliveryTaxAmount.value = 0.0;
    packagingTaxAmount.value = 0.0;
    platformTaxAmount.value = 0.0;
    totalTaxAmount.value = 0.0;

    totalAmount.value = 0.0;
    packagingCharge.value = 0.0;
    platformFee.value = 0.0;

    if (cartItem.isNotEmpty) {
      if (selectedFoodType.value == "Delivery") {
        totalDistance.value = double.parse(Constant.getDistance(
          lat1: selectedAddress.value.location!.latitude.toString(),
          lng1: selectedAddress.value.location!.longitude.toString(),
          lat2: vendorModel.value.latitude.toString(),
          lng2: vendorModel.value.longitude.toString(),
        ));

        if (vendorModel.value.isSelfDelivery == true && Constant.isSelfDeliveryFeature == true) {
          deliveryCharges.value = 0.0;
        } else if (deliveryChargeModel.value.vendorCanModify == false) {
          deliveryCharges.value = totalDistance.value > deliveryChargeModel.value.minimumDeliveryChargesWithinKm!
              ? totalDistance.value * deliveryChargeModel.value.deliveryChargesPerKm!
              : deliveryChargeModel.value.minimumDeliveryCharges!.toDouble();
        } else {
          final charge = vendorModel.value.deliveryCharge ?? deliveryChargeModel.value;
          deliveryCharges.value = totalDistance.value > charge.minimumDeliveryChargesWithinKm! ? totalDistance.value * charge.deliveryChargesPerKm! : charge.minimumDeliveryCharges!.toDouble();
        }
      }
    }

    packagingCharge.value = Constant.packagingChargeEnable == true && vendorModel.value.packagingCharge != null ? double.parse(vendorModel.value.packagingCharge.toString()) : 0.0;

    platformFee.value = Constant.calculatePlatFormMeModel(platFromFeeModel: Constant.platformFeeModel);

    for (var element in cartItem) {
      final price = double.parse((element.discountPrice != null && double.parse(element.discountPrice.toString()) > 0) ? element.discountPrice.toString() : element.price.toString());
      final qty = double.parse(element.quantity.toString());
      final extras = double.parse(element.extrasPrice.toString());
      subTotal.value += (price * qty) + (extras * qty);
    }

    if (selectedCouponModel.value.id != null) {
      couponAmount.value = Constant.calculateDiscount(
        amount: subTotal.value.toString(),
        offerModel: selectedCouponModel.value,
      );
    }

    if (vendorModel.value.specialDiscountEnable == true && Constant.specialDiscountOffer == true) {
      final now = DateTime.now();
      final day = DateFormat('EEEE', 'en_US').format(now);
      final date = DateFormat('dd-MM-yyyy').format(now);

      for (var element in vendorModel.value.specialDiscount!) {
        if (day == element.day.toString()) {
          for (var slot in element.timeslot ?? []) {
            if (slot.discountType == "delivery") {
              final start = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${slot.from}");
              final end = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${slot.to}");

              if (isCurrentDateInRange(start, end)) {
                specialDiscount.value = double.parse(slot.discount.toString());
                specialType.value = slot.type.toString();
                specialDiscountAmount.value = slot.type == "percentage" ? (subTotal.value * specialDiscount.value / 100) : specialDiscount.value;
              }
            }
          }
        }
      }
    }

    final totalDiscount = couponAmount.value + specialDiscountAmount.value;
    double discountRatio = 0.0;
    if (subTotal.value > 0 && totalDiscount > 0) {
      discountRatio = totalDiscount / subTotal.value;
    }

    if (Constant.taxScope == "product") {
      for (var element in cartItem) {
        final price = double.parse((element.discountPrice != null && double.parse(element.discountPrice.toString()) > 0) ? element.discountPrice.toString() : element.price.toString());
        final qty = double.parse(element.quantity.toString());
        final extras = double.parse(element.extrasPrice.toString());
        final itemAmount = (price * qty) + (extras * qty);
        final discountedItemAmount = itemAmount - (itemAmount * discountRatio);

        for (var taxElement in element.taxSetting!) {
          if (taxElement.type == "fix") {
            productTaxAmount.value += Constant.calculateTax(
                  amount: discountedItemAmount.toString(),
                  taxModel: taxElement,
                ) *
                qty;
          } else {
            productTaxAmount.value += Constant.calculateTax(
              amount: discountedItemAmount.toString(),
              taxModel: taxElement,
            );
          }
        }
      }
    }

    if (Constant.taxScope == "order") {
      for (var taxElement in Constant.orderProductTaxList ?? []) {
        orderTaxAmount.value += Constant.calculateTax(
          amount: (subTotal.value - totalDiscount).toString(),
          taxModel: taxElement,
        );
      }
    }

    if (selectedFoodType.value != 'TakeAway' && vendorModel.value.isSelfDelivery != true) {
      for (var taxElement in Constant.driverDeliveryTaxList ?? []) {
        driverDeliveryTaxAmount.value += Constant.calculateTax(
          amount: deliveryCharges.value.toString(),
          taxModel: taxElement,
        );
      }
    }

    if (Constant.packagingChargeEnable == true && packagingCharge.value > 0) {
      for (var taxElement in Constant.packagingTaxList ?? []) {
        packagingTaxAmount.value += Constant.calculateTax(
          amount: packagingCharge.value.toString(),
          taxModel: taxElement,
        );
      }
    }

    if (Constant.platformFeeModel?.enable == true && platformFee.value > 0) {
      for (var taxElement in Constant.platformTaxList ?? []) {
        platformTaxAmount.value += Constant.calculateTax(
          amount: platformFee.value.toString(),
          taxModel: taxElement,
        );
      }
    }

    totalTaxAmount.value = productTaxAmount.value + orderTaxAmount.value + driverDeliveryTaxAmount.value + packagingTaxAmount.value + platformTaxAmount.value;
    totalAmount.value =
        (subTotal.value - totalDiscount) + totalTaxAmount.value + (isEnableFreeDeliveryByAdmin.value ? 0 : deliveryCharges.value) + deliveryTips.value + packagingCharge.value + platformFee.value;

    getCashback();
  }

  Future<void> getCashback() async {
    if (Constant.isCashbackActive == true) {
      final paymentMethod = selectedPaymentMethod.value;
      final orderTotal = subTotal.value;
      final now = DateTime.now();

      List<CashbackModel> eligibleCashbacks = [];
      double maxCashbackValue = 0.0;

      final cashbackModelList = await FireStoreUtils.getAllCashbak();

      for (final cashback in cashbackModelList) {
        final startDate = cashback.startDate;
        final endDate = cashback.endDate;

        if (startDate == null || endDate == null) continue;

        final withinDateRange = startDate.toDate().isBefore(now) && endDate.toDate().isAfter(now);
        final meetsMinAmount = orderTotal >= (cashback.minimumPurchaseAmount ?? 0);
        final allPayment = cashback.allPayment ?? false;
        final paymentMatch = allPayment || (cashback.paymentMethods ?? []).contains(paymentMethod);
        final allCustomer = cashback.allCustomer ?? false;
        final customerMatch = allCustomer || (cashback.customerIds ?? []).contains(FireStoreUtils.getCurrentUid());

        final redeemData = await FireStoreUtils.getRedeemedCashbacks(cashback.id ?? '');
        final underLimit = redeemData.length < (cashback.redeemLimit ?? 0);

        if (withinDateRange && meetsMinAmount && paymentMatch && customerMatch && underLimit) {
          eligibleCashbacks.add(cashback);
        }
      }
      bestCashback.value = CashbackModel();
      for (final cashback in eligibleCashbacks) {
        double cashbackValue = 0.0;

        if (cashback.cashbackType == 'Percent') {
          final percentage = cashback.cashbackAmount ?? 0.0;
          cashbackValue = (percentage / 100.0) * orderTotal;
        } else if (cashback.cashbackType == 'Fixed') {
          cashbackValue = cashback.cashbackAmount ?? 0.0;
        }

        final maxDiscount = cashback.maximumDiscount ?? cashbackValue;
        if (cashbackValue > maxDiscount) cashbackValue = maxDiscount;

        if (cashbackValue > maxCashbackValue) {
          maxCashbackValue = cashbackValue;
          bestCashback.value = cashback;
        }
      }

      if (bestCashback.value.id != null) {
        final cashbackValue = maxCashbackValue;
        isCashbackApply.value = true;
        bestCashback.value.cashbackValue = cashbackValue;
      } else {
        bestCashback.value = CashbackModel();
        isCashbackApply.value = false;
      }
    } else {
      bestCashback.value = CashbackModel();
      isCashbackApply.value = false;
    }
  }

  void addToCart({required CartProductModel cartProductModel, required bool isIncrement, required int quantity}) {
    if (isIncrement) {
      cartProvider.addToCart(Get.context!, cartProductModel, quantity);
    } else {
      cartProvider.removeFromCart(cartProductModel, quantity);
    }
    update();
  }

  List<CartProductModel> tempProduc = [];

  Future<void> placeOrder() async {
    ShowToastDialog.showLoader("Please wait");
    if (selectedPaymentMethod.value == PaymentGateway.wallet.name) {
      if (double.parse(userModel.value.walletAmount.toString()) >= totalAmount.value) {
        setOrder();
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("You don't have sufficient wallet balance to place order");
      }
    } else {
      setOrder();
    }
  }

  Future<void> setOrder() async {
    ShowToastDialog.closeLoader();
    ShowToastDialog.showLoader("Please wait");
    if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && vendorModel.value.subscriptionPlan != null) {
      await FireStoreUtils.getVendorById(vendorModel.value.id!).then((vender) async {
        if (vender?.subscriptionTotalOrders == '0' || vender?.subscriptionTotalOrders == null) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("This vendor has reached their maximum order capacity. Please select a different vendor or try again later.");
          return;
        }
      });
    }

    for (CartProductModel cartProduct in cartItem) {
      CartProductModel tempCart = cartProduct;
      if (cartProduct.extrasPrice == '0') {
        tempCart.extras = [];
      }
      tempProduc.add(tempCart);
    }

    Map<String, dynamic> specialDiscountMap = {'special_discount': specialDiscountAmount.value, 'special_discount_label': specialDiscount.value, 'specialType': specialType.value};

    OrderModel orderModel = OrderModel();
    orderModel.id = Constant.getUuid();
    orderModel.address = selectedAddress.value;
    orderModel.authorID = FireStoreUtils.getCurrentUid();
    orderModel.author = userModel.value;
    orderModel.vendorID = vendorModel.value.id;
    orderModel.vendor = vendorModel.value;
    orderModel.adminCommission = vendorModel.value.adminCommission != null ? vendorModel.value.adminCommission!.amount : Constant.adminCommission!.amount;
    orderModel.adminCommissionType = vendorModel.value.adminCommission != null ? vendorModel.value.adminCommission!.commissionType : Constant.adminCommission!.commissionType;
    orderModel.status = Constant.orderPlaced;
    orderModel.discount = couponAmount.value;
    orderModel.couponId = selectedCouponModel.value.id;
    orderModel.paymentMethod = selectedPaymentMethod.value;
    orderModel.products = cartItem;
    orderModel.specialDiscount = specialDiscountMap;
    orderModel.couponCode = selectedCouponModel.value.code;
    orderModel.deliveryCharge = deliveryCharges.value.toString();
    orderModel.tipAmount = deliveryTips.value.toString();
    orderModel.notes = reMarkController.value.text;
    orderModel.takeAway = selectedFoodType.value == "Delivery" ? false : true;
    orderModel.createdAt = Timestamp.now();
    orderModel.scheduleTime = deliveryType.value == "schedule" ? Timestamp.fromDate(scheduleDateTime.value) : null;
    orderModel.cashback = bestCashback.value.id == null ? null : bestCashback.value;
    orderModel.isFreeDelivery = isEnableFreeDeliveryByAdmin.value;
    orderModel.taxSetting = Constant.taxScope == "order" ? Constant.orderProductTaxList : [];
    orderModel.driverDeliveryTax = Constant.driverDeliveryTaxList;
    orderModel.packagingTax = Constant.packagingTaxList;
    orderModel.platformTax = Constant.platformTaxList;
    orderModel.taxScope = Constant.taxScope;
    orderModel.platformFee = platformFee.value.toString();
    orderModel.isPosOrder = false;
    orderModel.vendor?.packagingCharge = packagingCharge.value.toString();

    if (selectedPaymentMethod.value == PaymentGateway.wallet.name) {
      WalletTransactionModel transactionModel = WalletTransactionModel(
          id: Constant.getUuid(),
          amount: double.parse(totalAmount.value.toString()),
          date: Timestamp.now(),
          paymentMethod: PaymentGateway.wallet.name,
          transactionUser: "user",
          userId: FireStoreUtils.getCurrentUid(),
          isTopup: false,
          orderId: orderModel.id,
          note: "Order Amount debited",
          paymentStatus: "success");

      await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
        if (value == true) {
          await FireStoreUtils.updateUserWallet(amount: "-${totalAmount.value.toString()}", userId: FireStoreUtils.getCurrentUid()).then((value) {});
        }
      });
    }
    for (int i = 0; i < tempProduc.length; i++) {
      await FireStoreUtils.getProductById(tempProduc[i].id!.split('~').first).then((value) async {
        ProductModel? productModel = value;
        if (tempProduc[i].variantInfo != null) {
          if (productModel!.itemAttribute != null) {
            for (int j = 0; j < productModel.itemAttribute!.variants!.length; j++) {
              if (productModel.itemAttribute!.variants![j].variantId == tempProduc[i].id!.split('~').last) {
                if (productModel.itemAttribute!.variants![j].variantQuantity != "-1") {
                  productModel.itemAttribute!.variants![j].variantQuantity = (int.parse(productModel.itemAttribute!.variants![j].variantQuantity.toString()) - tempProduc[i].quantity!).toString();
                }
              }
            }
          } else {
            if (productModel.quantity != -1) {
              productModel.quantity = (productModel.quantity! - tempProduc[i].quantity!);
            }
          }
        } else {
          if (productModel!.quantity != -1) {
            productModel.quantity = (productModel.quantity! - tempProduc[i].quantity!);
          }
        }

        await FireStoreUtils.setProduct(productModel);
      });
    }
    if (Constant.isCashbackActive == true && bestCashback.value.id != null) {
      CashbackRedeemModel cashbackRedeemModel = CashbackRedeemModel(
        id: Constant.getUuid(),
        cashbackId: bestCashback.value.id,
        userId: FireStoreUtils.getCurrentUid(),
        orderId: orderModel.id,
        createdAt: Timestamp.now(),
      );
      await FireStoreUtils.setCashbackRedeemModel(cashbackRedeemModel);
    }
    Constant.sendOrderEmail(orderModel: orderModel);
    await FireStoreUtils.getUserProfile(orderModel.vendor!.author.toString()).then(
      (value) async {
        if (value != null) {
          if (orderModel.scheduleTime != null) {
            SendNotification.sendFcmMessage(Constant.scheduleOrder, value.fcmToken ?? '', {});
          } else {
            SendNotification.sendFcmMessage(Constant.newOrderPlaced, value.fcmToken ?? '', {});
          }
        }
      },
    );
    await FireStoreUtils.setOrder(orderModel).then(
      (value) async {
        ShowToastDialog.closeLoader();
        Get.off(const OrderPlacingScreen(), arguments: {"orderModel": orderModel});
      },
    );
  }

  Rx<WalletSettingModel> walletSettingModel = WalletSettingModel().obs;
  Rx<CodSettingModel> cashOnDeliverySettingModel = CodSettingModel().obs;
  Rx<PayFastModel> payFastModel = PayFastModel().obs;
  Rx<MercadoPagoModel> mercadoPagoModel = MercadoPagoModel().obs;
  Rx<PayPalModel> payPalModel = PayPalModel().obs;
  Rx<StripeModel> stripeModel = StripeModel().obs;
  Rx<FlutterWaveModel> flutterWaveModel = FlutterWaveModel().obs;
  Rx<PayStackModel> payStackModel = PayStackModel().obs;
  Rx<PaytmModel> paytmModel = PaytmModel().obs;
  Rx<RazorPayModel> razorPayModel = RazorPayModel().obs;

  Rx<MidTrans> midTransModel = MidTrans().obs;
  Rx<OrangeMoney> orangeMoneyModel = OrangeMoney().obs;
  Rx<Xendit> xenditModel = Xendit().obs;
  Rx<MtnMomo> mtnMomoModel = MtnMomo().obs;
  Rx<PhonePe> phonePeModel = PhonePe().obs;
  Rx<Instamojo> instamojoModel = Instamojo().obs;
  Rx<Foloosi> foloosiModel = Foloosi().obs;
  Rx<PayMongo> payMongoModel = PayMongo().obs;
  Rx<Cashfree> cashfreeModel = Cashfree().obs;
  RxBool isLoading = true.obs;

  Future<void> getPaymentSettings() async {
    await FireStoreUtils.getPaymentSettingsData().then(
      (value) async {
        isLoading.value = false;
        stripeModel.value = StripeModel.fromJson(jsonDecode(Preferences.getString(Preferences.stripeSettings)));
        payPalModel.value = PayPalModel.fromJson(jsonDecode(Preferences.getString(Preferences.paypalSettings)));
        payStackModel.value = PayStackModel.fromJson(jsonDecode(Preferences.getString(Preferences.payStack)));
        mercadoPagoModel.value = MercadoPagoModel.fromJson(jsonDecode(Preferences.getString(Preferences.mercadoPago)));
        flutterWaveModel.value = FlutterWaveModel.fromJson(jsonDecode(Preferences.getString(Preferences.flutterWave)));
        paytmModel.value = PaytmModel.fromJson(jsonDecode(Preferences.getString(Preferences.paytmSettings)));
        payFastModel.value = PayFastModel.fromJson(jsonDecode(Preferences.getString(Preferences.payFastSettings)));
        razorPayModel.value = RazorPayModel.fromJson(jsonDecode(Preferences.getString(Preferences.razorpaySettings)));
        midTransModel.value = MidTrans.fromJson(jsonDecode(Preferences.getString(Preferences.midTransSettings)));
        orangeMoneyModel.value = OrangeMoney.fromJson(jsonDecode(Preferences.getString(Preferences.orangeMoneySettings)));
        xenditModel.value = Xendit.fromJson(jsonDecode(Preferences.getString(Preferences.xenditSettings)));
        mtnMomoModel.value = MtnMomo.fromJson(jsonDecode(Preferences.getString(Preferences.mtnMomoSettings)));
        phonePeModel.value = PhonePe.fromJson(jsonDecode(Preferences.getString(Preferences.phonePaySettings)));
        instamojoModel.value = Instamojo.fromJson(jsonDecode(Preferences.getString(Preferences.instamojoSettings)));
        foloosiModel.value = Foloosi.fromJson(jsonDecode(Preferences.getString(Preferences.foloosiSettings)));
        payMongoModel.value = PayMongo.fromJson(jsonDecode(Preferences.getString(Preferences.payMongoSettings)));
        cashfreeModel.value = Cashfree.fromJson(jsonDecode(Preferences.getString(Preferences.cashFreeSettings)));
        walletSettingModel.value = WalletSettingModel.fromJson(jsonDecode(Preferences.getString(Preferences.walletSettings)));
        cashOnDeliverySettingModel.value = CodSettingModel.fromJson(jsonDecode(Preferences.getString(Preferences.codSettings)));

        if (walletSettingModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.wallet.name;
        } else if (cashOnDeliverySettingModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.cod.name;
        } else if (stripeModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.stripe.name;
        } else if (payPalModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.paypal.name;
        } else if (payStackModel.value.isEnable == true) {
          selectedPaymentMethod.value = PaymentGateway.payStack.name;
        } else if (mercadoPagoModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.mercadoPago.name;
        } else if (flutterWaveModel.value.isEnable == true) {
          selectedPaymentMethod.value = PaymentGateway.flutterWave.name;
        } else if (paytmModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.paytm.name;
        } else if (payFastModel.value.isEnable == true) {
          selectedPaymentMethod.value = PaymentGateway.payFast.name;
        } else if (razorPayModel.value.isEnabled == true) {
          selectedPaymentMethod.value = PaymentGateway.razorpay.name;
        } else if (midTransModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.midTrans.name;
        } else if (orangeMoneyModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.orangeMoney.name;
        } else if (xenditModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.xendit.name;
        } else if (mtnMomoModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.mtnMomo.name;
        } else if (phonePeModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.phonePe.name;
        } else if (instamojoModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.instamojo.name;
        } else if (foloosiModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.foloosi.name;
        } else if (payMongoModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.payMongo.name;
        } else if (cashfreeModel.value.enable == true) {
          selectedPaymentMethod.value = PaymentGateway.cashfree.name;
        }

        Stripe.publishableKey = stripeModel.value.clientpublishableKey.toString();
        Stripe.merchantIdentifier = 'Eatsipy Customer';
        Stripe.instance.applySettings();
        setRef();

        razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
        razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWaller);
        razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      },
    );
  }

  Future<void> stripeMakePayment({required String amount}) async {
    log(double.parse(amount).toStringAsFixed(0));
    try {
      ShowToastDialog.showLoader("Please wait");
      await Stripe.instance.resetPaymentSheetCustomer();
      Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
      log("stripe Responce====>$paymentIntentData");
      if (paymentIntentData!.containsKey("error")) {
        Get.back();
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Something went wrong, please contact admin.");
      } else {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentData['client_secret'],
                allowsDelayedPaymentMethods: false,
                googlePay: const PaymentSheetGooglePay(
                  merchantCountryCode: 'US',
                  testEnv: true,
                  currencyCode: "USD",
                ),
                customFlow: true,
                style: ThemeMode.system,
                appearance: PaymentSheetAppearance(
                  colors: PaymentSheetAppearanceColors(
                    primary: AppThemeData.primary300,
                  ),
                ),
                merchantDisplayName: 'Eatsipy'));
        ShowToastDialog.closeLoader();
        await displayStripePaymentSheet(amount: amount);
      }
    } catch (e, s) {
      log("$e \n$s");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("exception:$e \n$s");
    }
  }

  Future<void> displayStripePaymentSheet({required String amount}) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ShowToastDialog.showToast("Payment successfully");
      placeOrder();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        ShowToastDialog.showToast("Payment cancelled");
      } else {
        ShowToastDialog.showToast(e.error.localizedMessage ?? "Payment failed");
      }
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  Future<dynamic> createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.fullName(),
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      var stripeSecret = stripeModel.value.stripeSecret;
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {'Authorization': 'Bearer $stripeSecret', 'Content-Type': 'application/x-www-form-urlencoded'});

      return jsonDecode(response.body);
    } catch (e) {
      ShowToastDialog.closeLoader();
      log(e.toString());
    }
  }

  Future<Null> mercadoPagoMakePayment({required BuildContext context, required String amount}) async {
    ShowToastDialog.showLoader("Please wait");
    final headers = {
      'Authorization': 'Bearer ${mercadoPagoModel.value.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "items": [
        {
          "title": "Test",
          "description": "Test Payment",
          "quantity": 1,
          "currency_id": "BRL",
          "unit_price": double.parse(amount),
        }
      ],
      "payer": {"email": userModel.value.email},
      "back_urls": {
        "failure": "${Constant.globalUrl}payment/failure",
        "pending": "${Constant.globalUrl}payment/pending",
        "success": "${Constant.globalUrl}payment/success",
      },
      "auto_return": "approved"
    });

    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['init_point']))!.then((value) {
        ShowToastDialog.closeLoader();
        if (value == true) {
          ShowToastDialog.showToast("Payment Successful!!");
          placeOrder();
        } else {
          ShowToastDialog.showToast("Payment UnSuccessful!!");
        }
      });
    } else {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "Unable to initialize payment, credentials are invalid or not authorized. Please check credentials, environment (sandbox/live), and account region.");
      print("Payment Error");
    }
  }

  Future<void> makeFoloosiPayment({required String amount, required String paymentDesc}) async {
    if (foloosiModel.value.merchantKey == '' || foloosiModel.value.merchantKey?.isEmpty == true) {
      ShowToastDialog.showToast("Foloosi merchant key is missing or invalid.");
      return;
    }
    try {
      await FoloosiPlugins.init(json.encode({
        "merchantKey": foloosiModel.value.merchantKey,
        "customColor": "#1E8449",
      }));

      FoloosiPlugins.setLogVisible(true);

      final paymentData = {
        "orderId": "ORD${Constant.getUuid()}",
        "orderDescription": paymentDesc,
        "orderAmount": double.parse(amount),
        "country": "ARE",
        "currencyCode": "AED",
        "customer": {
          "name": userModel.value.fullName(),
          "email": userModel.value.email,
          "mobile": userModel.value.phoneNumber,
        },
      };

      final result = await FoloosiPlugins.makePayment(json.encode(paymentData));

      if (result != null) {
        ShowToastDialog.showToast("Payment Successful!!");
        placeOrder();
      }
    } catch (e) {
      ShowToastDialog.showToast("Payment UnSuccessful!!");
    }
  }

  Future<void> makePayMongoPayment({required String amount, required String paymentDesc}) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      if (payMongoModel.value.secretKey == '') {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("PayMongo secret key is missing or invaild.");
        return;
      }
      PayMongoService service = PayMongoService();
      service.secretKey = payMongoModel.value.secretKey ?? '';

      final intentRes = await service.createPaymentIntent(amount: amount);
      String intentId = intentRes["data"]["id"];
      String clientKey = intentRes["data"]["attributes"]["client_key"];

      final methodRes = await service.createPaymentMethodGCash(userModel: userModel.value);
      String paymentMethodId = methodRes["data"]["id"];

      final attachRes = await service.attachPaymentMethod(
        intentId: intentId,
        paymentMethodId: paymentMethodId,
        clientKey: clientKey,
      );

      String redirectUrl = attachRes["data"]["attributes"]["next_action"]["redirect"]["url"];
      Get.to(WebUrlServiceScreen(initialURl: redirectUrl))!.then((value) {
        ShowToastDialog.closeLoader();
        if (value) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Payment Successful!!");
          placeOrder();
        } else {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Payment UnSuccessful!!");
        }
      });
    } catch (e) {
      ShowToastDialog.closeLoader();
      print("Payment Error: $e");
    }
  }

  // Utility methods
  void setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      // _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      // _ref = "IOSRef$year$refNumber";
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {}
  void handleExternalWaller(ExternalWalletResponse response) {}
  void handlePaymentError(PaymentFailureResponse response) {}
}
