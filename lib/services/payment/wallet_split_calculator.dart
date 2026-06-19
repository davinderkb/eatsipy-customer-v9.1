import 'dart:math' as math;

import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';

class WalletSplitResult {
  final double billTotal;
  final double walletBalance;
  final bool isWalletApplied;
  final double walletAppliedAmount;
  final double remainingPayableAmount;
  final PaymentMode? remainingPaymentMode;

  const WalletSplitResult({
    required this.billTotal,
    required this.walletBalance,
    required this.isWalletApplied,
    required this.walletAppliedAmount,
    required this.remainingPayableAmount,
    this.remainingPaymentMode,
  });

  bool get isWalletOnly =>
      isWalletApplied && walletAppliedAmount > 0 && remainingPayableAmount == 0;

  bool get needsRemainingPayment => remainingPayableAmount > 0;

  PaymentBreakdown toBreakdown({
    PaymentGatewayType? onlineGateway,
    PaymentComponentStatus status = PaymentComponentStatus.pending,
  }) {
    final components = <PaymentComponent>[];
    if (walletAppliedAmount > 0) {
      components.add(PaymentComponent(
        mode: PaymentMode.wallet,
        amount: walletAppliedAmount,
        status: status,
      ));
    }
    if (remainingPayableAmount > 0 && remainingPaymentMode != null) {
      components.add(PaymentComponent(
        mode: remainingPaymentMode!,
        gateway: _isOnlineMode(remainingPaymentMode!) ? onlineGateway : null,
        amount: remainingPayableAmount,
        status: status,
      ));
    }
    return PaymentBreakdown(
      components: components,
      totalAmount: billTotal,
      walletAppliedAmount: walletAppliedAmount,
      remainingPayableAmount: remainingPayableAmount,
    );
  }
}

class WalletSplitCalculator {
  const WalletSplitCalculator();

  WalletSplitResult calculate({
    required double billTotal,
    required double walletBalance,
    required bool walletEnabled,
    required bool walletApplied,
    PaymentMode? selectedRemainingPaymentMode,
  }) {
    final total = math.max(0, billTotal);
    final balance = math.max(0, walletBalance);
    final shouldApplyWallet = walletEnabled && walletApplied && balance > 0;
    final walletAmount =
        shouldApplyWallet ? math.min(balance, total).toDouble() : 0.0;
    final remaining = math.max(0, total - walletAmount).toDouble();

    return WalletSplitResult(
      billTotal: total.toDouble(),
      walletBalance: balance.toDouble(),
      isWalletApplied: shouldApplyWallet,
      walletAppliedAmount: walletAmount,
      remainingPayableAmount: remaining,
      remainingPaymentMode: remaining > 0 ? selectedRemainingPaymentMode : null,
    );
  }
}

bool _isOnlineMode(PaymentMode mode) {
  return mode == PaymentMode.upi ||
      mode == PaymentMode.card ||
      mode == PaymentMode.netBanking;
}
