import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';
import 'package:eatsipy_customer/services/payment/active_payment_gateway_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = ActivePaymentGatewayResolver();

  PaymentGatewayConfig config({
    required PaymentGatewayType? activeGateway,
    required Map<PaymentGatewayType, GatewayConfig> gateways,
    Map<PaymentMode, bool>? modes,
  }) {
    return PaymentGatewayConfig(
      activeGateway: activeGateway,
      gateways: gateways,
      modes: modes ??
          const {
            PaymentMode.upi: true,
            PaymentMode.card: true,
            PaymentMode.netBanking: true,
            PaymentMode.wallet: true,
            PaymentMode.cod: true,
          },
    );
  }

  group('ActivePaymentGatewayResolver', () {
    test('resolves PhonePe with UPI only when admin selects PhonePe', () {
      final result = resolver.resolve(config(
        activeGateway: PaymentGatewayType.phonePe,
        gateways: {
          PaymentGatewayType.phonePe: const GatewayConfig(
            isEnabled: true,
            supportedMethods: {PaymentMode.upi},
          ),
        },
      ));

      expect(result.isOnlineAvailable, isTrue);
      expect(result.gateway, PaymentGatewayType.phonePe);
      expect(result.availableOnlineModes, {PaymentMode.upi});
      expect(
          resolver.canUseMode(
              config(
                activeGateway: PaymentGatewayType.phonePe,
                gateways: {
                  PaymentGatewayType.phonePe: const GatewayConfig(
                    isEnabled: true,
                    supportedMethods: {PaymentMode.upi},
                  ),
                },
              ),
              PaymentMode.card),
          isFalse);
    });

    test('resolves Cashfree supported modes from config', () {
      final result = resolver.resolve(config(
        activeGateway: PaymentGatewayType.cashfree,
        gateways: {
          PaymentGatewayType.cashfree: const GatewayConfig(
            isEnabled: true,
            supportedMethods: {
              PaymentMode.upi,
              PaymentMode.card,
              PaymentMode.netBanking,
            },
          ),
        },
      ));

      expect(result.gateway, PaymentGatewayType.cashfree);
      expect(result.availableOnlineModes, {
        PaymentMode.upi,
        PaymentMode.card,
        PaymentMode.netBanking,
      });
    });

    test('hides disabled online modes even when gateway supports them', () {
      final result = resolver.resolve(config(
        activeGateway: PaymentGatewayType.razorpay,
        modes: const {
          PaymentMode.upi: true,
          PaymentMode.card: false,
          PaymentMode.netBanking: false,
        },
        gateways: {
          PaymentGatewayType.razorpay: const GatewayConfig(
            isEnabled: true,
            supportedMethods: {
              PaymentMode.upi,
              PaymentMode.card,
              PaymentMode.netBanking,
            },
          ),
        },
      ));

      expect(result.gateway, PaymentGatewayType.razorpay);
      expect(result.availableOnlineModes, {PaymentMode.upi});
    });

    test('online is unavailable when active gateway is missing', () {
      final result = resolver.resolve(config(
        activeGateway: null,
        gateways: const {},
      ));

      expect(result.isOnlineAvailable, isFalse);
      expect(result.unavailableReason, 'active_gateway_missing');
    });

    test('online is unavailable when active gateway is unhealthy', () {
      final result = resolver.resolve(config(
        activeGateway: PaymentGatewayType.cashfree,
        gateways: {
          PaymentGatewayType.cashfree: const GatewayConfig(
            isEnabled: true,
            healthStatus: 'down',
            supportedMethods: {PaymentMode.upi},
          ),
        },
      ));

      expect(result.isOnlineAvailable, isFalse);
      expect(result.gateway, PaymentGatewayType.cashfree);
      expect(result.unavailableReason, 'active_gateway_unhealthy');
    });

    test('wallet and COD are never treated as online gateway modes', () {
      final checkoutConfig = config(
        activeGateway: PaymentGatewayType.cashfree,
        gateways: {
          PaymentGatewayType.cashfree: const GatewayConfig(
            isEnabled: true,
            supportedMethods: {
              PaymentMode.upi,
              PaymentMode.wallet,
              PaymentMode.cod,
            },
          ),
        },
      );

      expect(resolver.canUseMode(checkoutConfig, PaymentMode.wallet), isFalse);
      expect(resolver.canUseMode(checkoutConfig, PaymentMode.cod), isFalse);
    });
  });
}
