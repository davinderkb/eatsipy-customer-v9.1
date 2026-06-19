import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsipy_customer/models/order_model.dart';
import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';
import 'package:eatsipy_customer/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('checkout payment models', () {
    test('OrderModel parses old orders without payment breakdown', () {
      final order = OrderModel.fromJson({
        'payment_method': 'cod',
        'deliveryCharge': '0',
        'tip_amount': '0',
      });

      expect(order.paymentMethod, 'cod');
      expect(order.paymentBreakdown, isNull);
    });

    test('OrderModel round-trips payment breakdown', () {
      final order = OrderModel(
        paymentMethod: 'wallet+upi',
        paymentBreakdown: const PaymentBreakdown(
          totalAmount: 250,
          walletAppliedAmount: 100,
          remainingPayableAmount: 150,
          components: [
            PaymentComponent(
              mode: PaymentMode.wallet,
              amount: 100,
              status: PaymentComponentStatus.success,
            ),
            PaymentComponent(
              mode: PaymentMode.upi,
              gateway: PaymentGatewayType.cashfree,
              amount: 150,
              status: PaymentComponentStatus.success,
              transactionId: 'pay_123',
            ),
          ],
        ),
      );

      final parsed = OrderModel.fromJson(order.toJson());

      expect(parsed.paymentMethod, 'wallet+upi');
      expect(parsed.paymentBreakdown?.totalAmount, 250);
      expect(parsed.paymentBreakdown?.components, hasLength(2));
      expect(parsed.paymentBreakdown?.components.last.gateway,
          PaymentGatewayType.cashfree);
      expect(parsed.paymentBreakdown?.components.last.transactionId, 'pay_123');
    });

    test('UserModel parses missing payment preferences safely', () {
      final user = UserModel.fromJson({'id': 'user_1'});

      expect(user.id, 'user_1');
      expect(user.paymentPreferences, isNull);
    });

    test('UserModel round-trips payment preferences', () {
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(1234);
      final user = UserModel(
        id: 'user_1',
        paymentPreferences: PaymentPreferences(
          lastUsedPaymentMode: PaymentMode.upi,
          lastUsedUpiApp: 'Google Pay',
          lastUsedGateway: PaymentGatewayType.razorpay,
          lastSuccessfulPaymentTimestamp: timestamp,
        ),
      );

      final parsed = UserModel.fromJson(user.toJson());

      expect(parsed.paymentPreferences?.lastUsedPaymentMode, PaymentMode.upi);
      expect(parsed.paymentPreferences?.lastUsedUpiApp, 'Google Pay');
      expect(parsed.paymentPreferences?.lastUsedGateway,
          PaymentGatewayType.razorpay);
      expect(
          parsed.paymentPreferences?.lastSuccessfulPaymentTimestamp, timestamp);
    });

    test('PaymentGatewayConfig defaults to India checkout gateways', () {
      final config = PaymentGatewayConfig.defaultIndia();

      expect(config.activeGateway, PaymentGatewayType.cashfree);
      expect(config.gateways.keys, contains(PaymentGatewayType.phonePe));
      expect(config.gateways.keys, contains(PaymentGatewayType.cashfree));
      expect(config.gateways.keys, contains(PaymentGatewayType.razorpay));
      expect(config.modes[PaymentMode.cod], isTrue);
      expect(config.modes[PaymentMode.wallet], isTrue);
    });

    test('PaymentGatewayConfig.noOnlineGateway keeps wallet and COD only', () {
      final config = PaymentGatewayConfig.noOnlineGateway();

      expect(config.activeGateway, isNull);
      expect(config.gateways, isEmpty);
      expect(config.modes[PaymentMode.wallet], isTrue);
      expect(config.modes[PaymentMode.cod], isTrue);
      expect(config.modes[PaymentMode.upi], isNull);
      expect(config.modes[PaymentMode.card], isNull);
      expect(config.modes[PaymentMode.netBanking], isNull);
    });

    test('PaymentComponent copyWith updates refund metadata', () {
      const component = PaymentComponent(
        mode: PaymentMode.upi,
        gateway: PaymentGatewayType.cashfree,
        amount: 150,
        status: PaymentComponentStatus.success,
      );

      final updated = component.copyWith(
        refundStatus: RefundStatus.pendingManualReview,
        refundDestination: RefundDestination.originalSource,
        refundedAmount: 0,
      );

      expect(updated.mode, PaymentMode.upi);
      expect(updated.gateway, PaymentGatewayType.cashfree);
      expect(updated.amount, 150);
      expect(updated.refundStatus, RefundStatus.pendingManualReview);
      expect(updated.refundDestination, RefundDestination.originalSource);
    });
  });
}
