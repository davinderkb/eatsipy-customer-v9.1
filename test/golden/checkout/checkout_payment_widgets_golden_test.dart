import 'package:eatsipy_customer/app/cart_screen/widgets/checkout_payment_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget _goldenWrap(Widget child) {
  return GetMaterialApp(
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: RepaintBoundary(
          child: SizedBox(width: 360, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('checkout bill summary golden', (tester) async {
    await tester.pumpWidget(
      _goldenWrap(
        CheckoutBillSummaryCard(
          isDark: false,
          totalAmount: 'Rs.180',
          walletAppliedText: 'Rs.50 wallet applied',
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CheckoutBillSummaryCard),
      matchesGoldenFile('goldens/checkout_bill_summary.png'),
    );
  });

  testWidgets('checkout payment mode golden', (tester) async {
    await tester.pumpWidget(
      _goldenWrap(
        CheckoutPaymentModeTile(
          isDark: false,
          title: 'UPI',
          subtitle: 'Google Pay, PhonePe, Paytm UPI, BHIM or any UPI app',
          icon: Icons.account_balance_wallet_outlined,
          value: 'upi',
          groupValue: 'upi',
          onChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CheckoutPaymentModeTile),
      matchesGoldenFile('goldens/checkout_payment_mode.png'),
    );
  });
}
