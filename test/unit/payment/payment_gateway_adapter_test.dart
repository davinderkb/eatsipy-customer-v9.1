import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';
import 'package:eatsipy_customer/services/payment/payment_gateway_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentGatewayAdapterRegistry', () {
    test('returns adapters for supported checkout gateways only', () {
      final registry = PaymentGatewayAdapterRegistry();

      expect(registry.adapterFor(PaymentGatewayType.phonePe),
          isA<PhonePeGatewayAdapter>());
      expect(registry.adapterFor(PaymentGatewayType.cashfree),
          isA<CashfreeGatewayAdapter>());
      expect(registry.adapterFor(PaymentGatewayType.razorpay),
          isA<RazorpayGatewayAdapter>());
      expect(registry.adapterFor(null), isNull);
    });

    test('PhonePe adapter supports UPI only', () {
      final adapter = PhonePeGatewayAdapter();

      expect(adapter.supportsPaymentMode(PaymentMode.upi), isTrue);
      expect(adapter.supportsPaymentMode(PaymentMode.card), isFalse);
      expect(adapter.supportsPaymentMode(PaymentMode.netBanking), isFalse);
    });

    test('Cashfree and Razorpay adapters support online modes', () {
      final cashfree = CashfreeGatewayAdapter();
      final razorpay = RazorpayGatewayAdapter();

      for (final adapter in [cashfree, razorpay]) {
        expect(adapter.supportsPaymentMode(PaymentMode.upi), isTrue);
        expect(adapter.supportsPaymentMode(PaymentMode.card), isTrue);
        expect(adapter.supportsPaymentMode(PaymentMode.netBanking), isTrue);
        expect(adapter.supportsPaymentMode(PaymentMode.cod), isFalse);
        expect(adapter.supportsPaymentMode(PaymentMode.wallet), isFalse);
      }
    });
  });
}
