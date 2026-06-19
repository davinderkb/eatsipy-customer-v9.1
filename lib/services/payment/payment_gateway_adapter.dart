import 'package:eatsipy_customer/controllers/cashfree_service_controller.dart';
import 'package:eatsipy_customer/controllers/phonepay_controller.dart';
import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';
import 'package:eatsipy_customer/models/payment_model/cashfree_model.dart';
import 'package:eatsipy_customer/models/payment_model/phonepe_model.dart';
import 'package:eatsipy_customer/models/payment_model/razorpay_model.dart';
import 'package:eatsipy_customer/models/user_model.dart';
import 'package:eatsipy_customer/payment/createRazorPayOrderModel.dart';
import 'package:eatsipy_customer/payment/rozorpayConroller.dart';
import 'package:eatsipy_customer/payment/weburlservicescreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PaymentGatewayStartStatus {
  success,
  failed,
  cancelled,
  launched,
}

class PaymentGatewayStartResult {
  final PaymentGatewayStartStatus status;
  final String? message;
  final String? transactionId;

  const PaymentGatewayStartResult({
    required this.status,
    this.message,
    this.transactionId,
  });

  bool get isSuccess => status == PaymentGatewayStartStatus.success;
}

class PaymentGatewayStartRequest {
  final BuildContext context;
  final double amount;
  final String description;
  final UserModel user;
  final PhonePe phonePe;
  final Cashfree cashfree;
  final RazorPayModel razorpay;
  final Future<void> Function({
    required double amount,
    required String orderId,
  }) openRazorpayCheckout;

  const PaymentGatewayStartRequest({
    required this.context,
    required this.amount,
    required this.description,
    required this.user,
    required this.phonePe,
    required this.cashfree,
    required this.razorpay,
    required this.openRazorpayCheckout,
  });
}

abstract class PaymentGatewayAdapter {
  PaymentGatewayType get gatewayType;

  Future<void> initialize() async {}

  bool supportsPaymentMode(PaymentMode mode);

  Future<PaymentGatewayStartResult> startPayment(
    PaymentGatewayStartRequest request,
  );
}

class PhonePeGatewayAdapter extends PaymentGatewayAdapter {
  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.phonePe;

  @override
  bool supportsPaymentMode(PaymentMode mode) => mode == PaymentMode.upi;

  @override
  Future<PaymentGatewayStartResult> startPayment(
    PaymentGatewayStartRequest request,
  ) async {
    PhonePePaymentService.phonePe = request.phonePe;
    await PhonePePaymentService.payNow(
      amountInPaise: (request.amount * 100).round(),
    );
    return PaymentGatewayStartResult(
      status: PhonePePaymentService.isSucess
          ? PaymentGatewayStartStatus.success
          : PaymentGatewayStartStatus.failed,
    );
  }
}

class CashfreeGatewayAdapter extends PaymentGatewayAdapter {
  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.cashfree;

  @override
  bool supportsPaymentMode(PaymentMode mode) =>
      mode == PaymentMode.upi ||
      mode == PaymentMode.card ||
      mode == PaymentMode.netBanking;

  @override
  Future<PaymentGatewayStartResult> startPayment(
    PaymentGatewayStartRequest request,
  ) async {
    final paymentUrl = await CashfreeService().createPaymentLink(
      cashfree: request.cashfree,
      userModel: request.user,
      amount: double.parse(request.amount.toStringAsFixed(2)),
      paymentDesc: request.description,
    );
    if (paymentUrl == null || paymentUrl.toString().isEmpty) {
      return const PaymentGatewayStartResult(
        status: PaymentGatewayStartStatus.failed,
        message: 'Error while transaction!',
      );
    }

    final result = await Get.to(WebUrlServiceScreen(initialURl: paymentUrl));
    if (result == true) {
      return const PaymentGatewayStartResult(
        status: PaymentGatewayStartStatus.success,
      );
    }
    return const PaymentGatewayStartResult(
      status: PaymentGatewayStartStatus.cancelled,
      message: 'Payment failed or was cancelled.',
    );
  }
}

class RazorpayGatewayAdapter extends PaymentGatewayAdapter {
  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.razorpay;

  @override
  bool supportsPaymentMode(PaymentMode mode) =>
      mode == PaymentMode.upi ||
      mode == PaymentMode.card ||
      mode == PaymentMode.netBanking;

  @override
  Future<PaymentGatewayStartResult> startPayment(
    PaymentGatewayStartRequest request,
  ) async {
    final CreateRazorPayOrderModel? order =
        await RazorPayController().createOrderRazorPay(
      amount: request.amount,
      razorpayModel: request.razorpay,
    );
    if (order == null || order.id.isEmpty) {
      return const PaymentGatewayStartResult(
        status: PaymentGatewayStartStatus.failed,
        message: 'Something went wrong, please contact admin.',
      );
    }
    await request.openRazorpayCheckout(
      amount: request.amount,
      orderId: order.id,
    );
    return PaymentGatewayStartResult(
      status: PaymentGatewayStartStatus.launched,
      transactionId: order.id,
    );
  }
}

class PaymentGatewayAdapterRegistry {
  final Map<PaymentGatewayType, PaymentGatewayAdapter> _adapters;

  PaymentGatewayAdapterRegistry({
    Map<PaymentGatewayType, PaymentGatewayAdapter>? adapters,
  }) : _adapters = adapters ??
            {
              PaymentGatewayType.phonePe: PhonePeGatewayAdapter(),
              PaymentGatewayType.cashfree: CashfreeGatewayAdapter(),
              PaymentGatewayType.razorpay: RazorpayGatewayAdapter(),
            };

  PaymentGatewayAdapter? adapterFor(PaymentGatewayType? gatewayType) {
    if (gatewayType == null) return null;
    return _adapters[gatewayType];
  }
}
