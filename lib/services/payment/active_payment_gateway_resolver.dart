import 'package:eatsipy_customer/models/payment/checkout_payment_models.dart';

class ActiveGatewayResolution {
  final PaymentGatewayType? gateway;
  final Set<PaymentMode> availableOnlineModes;
  final bool isOnlineAvailable;
  final String? unavailableReason;

  const ActiveGatewayResolution({
    this.gateway,
    this.availableOnlineModes = const {},
    this.isOnlineAvailable = false,
    this.unavailableReason,
  });
}

class ActivePaymentGatewayResolver {
  static const Set<PaymentMode> onlineModes = {
    PaymentMode.upi,
    PaymentMode.card,
    PaymentMode.netBanking,
  };

  const ActivePaymentGatewayResolver();

  ActiveGatewayResolution resolve(PaymentGatewayConfig config) {
    final activeGateway = config.activeGateway;
    if (activeGateway == null) {
      return const ActiveGatewayResolution(
        unavailableReason: 'active_gateway_missing',
      );
    }

    final gatewayConfig = config.gateways[activeGateway];
    if (gatewayConfig == null) {
      return const ActiveGatewayResolution(
        unavailableReason: 'active_gateway_not_configured',
      );
    }
    if (!gatewayConfig.isEnabled) {
      return ActiveGatewayResolution(
        gateway: activeGateway,
        unavailableReason: 'active_gateway_disabled',
      );
    }
    if (!gatewayConfig.isHealthy) {
      return ActiveGatewayResolution(
        gateway: activeGateway,
        unavailableReason: 'active_gateway_unhealthy',
      );
    }

    final availableModes = gatewayConfig.supportedMethods
        .where(onlineModes.contains)
        .where((mode) => config.modes[mode] == true)
        .toSet();

    if (availableModes.isEmpty) {
      return ActiveGatewayResolution(
        gateway: activeGateway,
        unavailableReason: 'no_supported_online_modes',
      );
    }

    return ActiveGatewayResolution(
      gateway: activeGateway,
      availableOnlineModes: availableModes,
      isOnlineAvailable: true,
    );
  }

  bool canUseMode(PaymentGatewayConfig config, PaymentMode mode) {
    if (!onlineModes.contains(mode)) return false;
    return resolve(config).availableOnlineModes.contains(mode);
  }
}
