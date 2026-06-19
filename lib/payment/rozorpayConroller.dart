import 'dart:convert';

import 'package:eatsipy_customer/models/payment_model/razorpay_model.dart';
import 'package:eatsipy_customer/payment/createRazorPayOrderModel.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constant/constant.dart';

class RazorPayController {
  Future<CreateRazorPayOrderModel?> createOrderRazorPay(
      {required double amount, required RazorPayModel? razorpayModel}) async {
    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    RazorPayModel razorPayData = razorpayModel!;
    const url = "${Constant.globalUrl}payments/razorpay/createorder";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          "amount": (amount * 100).round().toString(),
          "receipt_id": orderId,
          "currency": "INR",
          "razorpaykey": razorPayData.razorpayKey,
          "razorPaySecret": razorPayData.razorpaySecret,
          "isSandBoxEnabled": razorPayData.isSandboxEnabled.toString(),
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
            'Razorpay create order failed: ${response.statusCode} ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        debugPrint(
            'Razorpay create order returned invalid response: ${response.body}');
        return null;
      }
      return CreateRazorPayOrderModel.fromJson(data);
    } catch (error) {
      debugPrint('Razorpay create order error: $error');
      return null;
    }
  }
}
