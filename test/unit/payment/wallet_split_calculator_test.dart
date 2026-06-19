import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';
import 'package:eatsipy_customer/services/payment/wallet_split_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = WalletSplitCalculator();

  group('WalletSplitCalculator', () {
    test('does not apply wallet when balance is zero', () {
      final result = calculator.calculate(
        billTotal: 250,
        walletBalance: 0,
        walletEnabled: true,
        walletApplied: true,
        selectedRemainingPaymentMode: PaymentMode.upi,
      );

      expect(result.walletAppliedAmount, 0);
      expect(result.remainingPayableAmount, 250);
      expect(result.remainingPaymentMode, PaymentMode.upi);
    });

    test('applies partial wallet and leaves COD remainder', () {
      final result = calculator.calculate(
        billTotal: 250,
        walletBalance: 100,
        walletEnabled: true,
        walletApplied: true,
        selectedRemainingPaymentMode: PaymentMode.cod,
      );

      expect(result.walletAppliedAmount, 100);
      expect(result.remainingPayableAmount, 150);
      expect(result.remainingPaymentMode, PaymentMode.cod);
      expect(result.isWalletOnly, isFalse);
    });

    test('applies exact wallet amount as wallet-only', () {
      final result = calculator.calculate(
        billTotal: 250,
        walletBalance: 250,
        walletEnabled: true,
        walletApplied: true,
        selectedRemainingPaymentMode: PaymentMode.upi,
      );

      expect(result.walletAppliedAmount, 250);
      expect(result.remainingPayableAmount, 0);
      expect(result.remainingPaymentMode, isNull);
      expect(result.isWalletOnly, isTrue);
    });

    test('caps wallet amount at bill total when balance is higher', () {
      final result = calculator.calculate(
        billTotal: 250,
        walletBalance: 500,
        walletEnabled: true,
        walletApplied: true,
        selectedRemainingPaymentMode: PaymentMode.upi,
      );

      expect(result.walletAppliedAmount, 250);
      expect(result.remainingPayableAmount, 0);
    });

    test('does not apply wallet when user turns wallet off', () {
      final result = calculator.calculate(
        billTotal: 250,
        walletBalance: 100,
        walletEnabled: true,
        walletApplied: false,
        selectedRemainingPaymentMode: PaymentMode.upi,
      );

      expect(result.isWalletApplied, isFalse);
      expect(result.walletAppliedAmount, 0);
      expect(result.remainingPayableAmount, 250);
    });

    test('creates payment breakdown for wallet plus online', () {
      final result = calculator.calculate(
        billTotal: 250,
        walletBalance: 100,
        walletEnabled: true,
        walletApplied: true,
        selectedRemainingPaymentMode: PaymentMode.upi,
      );

      final breakdown = result.toBreakdown(
        onlineGateway: PaymentGatewayType.cashfree,
        status: PaymentComponentStatus.success,
      );

      expect(breakdown.components, hasLength(2));
      expect(breakdown.components.first.mode, PaymentMode.wallet);
      expect(breakdown.components.first.amount, 100);
      expect(breakdown.components.last.mode, PaymentMode.upi);
      expect(breakdown.components.last.gateway, PaymentGatewayType.cashfree);
      expect(breakdown.components.last.amount, 150);
    });
  });
}
