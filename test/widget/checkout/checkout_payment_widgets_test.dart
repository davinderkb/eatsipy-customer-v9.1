import 'package:eatsipy_customer/app/cart_screen/widgets/checkout_payment_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget _wrap(Widget child) {
  return GetMaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 360, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('payment mode tile shows customer mode without gateway names',
      (tester) async {
    var selected = 'upi';
    await tester.pumpWidget(
      _wrap(
        CheckoutPaymentModeTile(
          isDark: false,
          title: 'UPI',
          subtitle: 'Google Pay, PhonePe, Paytm UPI, BHIM or any UPI app',
          icon: Icons.account_balance_wallet_outlined,
          value: 'upi',
          groupValue: selected,
          onChanged: (value) => selected = value,
        ),
      ),
    );

    expect(find.text('UPI'), findsOneWidget);
    expect(find.textContaining('Razorpay'), findsNothing);
    expect(find.textContaining('Cashfree'), findsNothing);
    expect(find.textContaining('PhonePe Gateway'), findsNothing);

    await tester.tap(find.byType(CheckoutPaymentModeTile));
    expect(selected, 'upi');
  });

  testWidgets('wallet toggle calls onChanged and shows deduction copy',
      (tester) async {
    var walletEnabled = true;
    await tester.pumpWidget(
      _wrap(
        CheckoutWalletToggleTile(
          isDark: false,
          value: walletEnabled,
          onChanged: (value) => walletEnabled = value,
          title: 'Use Eatsipy Wallet',
          subtitle: 'Rs.50 will be applied from Rs.120',
          icon: Icons.account_balance_wallet,
        ),
      ),
    );

    expect(find.text('Use Eatsipy Wallet'), findsOneWidget);
    expect(find.text('Rs.50 will be applied from Rs.120'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    expect(walletEnabled, isFalse);
  });

  testWidgets('bill summary opens through tap target and shows wallet text',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        CheckoutBillSummaryCard(
          isDark: false,
          totalAmount: 'Rs.180',
          walletAppliedText: 'Rs.50 wallet applied',
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('To Pay'), findsOneWidget);
    expect(find.text('Rs.180'), findsOneWidget);
    expect(find.text('Rs.50 wallet applied'), findsOneWidget);
    expect(find.text('View Bill Details'), findsOneWidget);

    await tester.tap(find.byType(CheckoutBillSummaryCard));
    expect(tapped, isTrue);
  });
}
