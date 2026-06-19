import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMode {
  upi,
  wallet,
  card,
  netBanking,
  cod;

  static PaymentMode? fromJson(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    for (final mode in PaymentMode.values) {
      if (mode.name == text) return mode;
    }
    return null;
  }
}

enum PaymentGatewayType {
  phonePe,
  cashfree,
  razorpay;

  static PaymentGatewayType? fromJson(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    for (final gateway in PaymentGatewayType.values) {
      if (gateway.name == text) return gateway;
    }
    return null;
  }
}

enum PaymentComponentStatus {
  pending,
  success,
  failed,
  cancelled;

  static PaymentComponentStatus fromJson(dynamic value) {
    final text = value?.toString();
    for (final status in PaymentComponentStatus.values) {
      if (status.name == text) return status;
    }
    return PaymentComponentStatus.pending;
  }
}

enum RefundDestination {
  wallet,
  originalSource;

  static RefundDestination? fromJson(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    for (final destination in RefundDestination.values) {
      if (destination.name == text) return destination;
    }
    return null;
  }
}

enum RefundStatus {
  none,
  pending,
  success,
  failed,
  pendingManualReview;

  static RefundStatus fromJson(dynamic value) {
    final text = value?.toString();
    for (final status in RefundStatus.values) {
      if (status.name == text) return status;
    }
    return RefundStatus.none;
  }
}

class PaymentGatewayConfig {
  final PaymentGatewayType? activeGateway;
  final Map<PaymentGatewayType, GatewayConfig> gateways;
  final Map<PaymentMode, bool> modes;

  const PaymentGatewayConfig({
    this.activeGateway,
    this.gateways = const {},
    this.modes = const {},
  });

  factory PaymentGatewayConfig.fromJson(Map<String, dynamic>? json) {
    final gatewayMap = <PaymentGatewayType, GatewayConfig>{};
    final rawGateways = json?['gateways'];
    if (rawGateways is Map) {
      rawGateways.forEach((key, value) {
        final gateway = PaymentGatewayType.fromJson(key);
        if (gateway != null && value is Map) {
          gatewayMap[gateway] = GatewayConfig.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    final modeMap = <PaymentMode, bool>{};
    final rawModes = json?['modes'];
    if (rawModes is Map) {
      rawModes.forEach((key, value) {
        final mode = PaymentMode.fromJson(key);
        if (mode != null) {
          modeMap[mode] = value == true;
        }
      });
    }

    return PaymentGatewayConfig(
      activeGateway: PaymentGatewayType.fromJson(json?['activeGateway']),
      gateways: gatewayMap,
      modes: modeMap,
    );
  }

  factory PaymentGatewayConfig.defaultIndia() {
    return PaymentGatewayConfig(
      activeGateway: PaymentGatewayType.cashfree,
      gateways: {
        PaymentGatewayType.phonePe: const GatewayConfig(
          isEnabled: true,
          supportedMethods: {PaymentMode.upi},
        ),
        PaymentGatewayType.cashfree: const GatewayConfig(
          isEnabled: true,
          supportedMethods: {
            PaymentMode.upi,
            PaymentMode.card,
            PaymentMode.netBanking,
          },
        ),
        PaymentGatewayType.razorpay: const GatewayConfig(
          isEnabled: true,
          supportedMethods: {
            PaymentMode.upi,
            PaymentMode.card,
            PaymentMode.netBanking,
          },
        ),
      },
      modes: const {
        PaymentMode.upi: true,
        PaymentMode.wallet: true,
        PaymentMode.card: true,
        PaymentMode.netBanking: true,
        PaymentMode.cod: true,
      },
    );
  }

  factory PaymentGatewayConfig.noOnlineGateway() {
    return const PaymentGatewayConfig(
      modes: {
        PaymentMode.wallet: true,
        PaymentMode.cod: true,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeGateway': activeGateway?.name,
      'gateways':
          gateways.map((key, value) => MapEntry(key.name, value.toJson())),
      'modes': modes.map((key, value) => MapEntry(key.name, value)),
    };
  }
}

class GatewayConfig {
  final bool isEnabled;
  final String healthStatus;
  final Set<PaymentMode> supportedMethods;

  const GatewayConfig({
    this.isEnabled = false,
    this.healthStatus = 'healthy',
    this.supportedMethods = const {},
  });

  bool get isHealthy => healthStatus.toLowerCase() == 'healthy';

  factory GatewayConfig.fromJson(Map<String, dynamic>? json) {
    final methods = <PaymentMode>{};
    final rawMethods = json?['supportedMethods'];
    if (rawMethods is Iterable) {
      for (final value in rawMethods) {
        final mode = PaymentMode.fromJson(value);
        if (mode != null) methods.add(mode);
      }
    }

    return GatewayConfig(
      isEnabled: json?['isEnabled'] == true,
      healthStatus: json?['healthStatus']?.toString() ?? 'healthy',
      supportedMethods: methods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'healthStatus': healthStatus,
      'supportedMethods': supportedMethods.map((mode) => mode.name).toList(),
    };
  }
}

class PaymentBreakdown {
  final List<PaymentComponent> components;
  final double totalAmount;
  final double walletAppliedAmount;
  final double remainingPayableAmount;

  const PaymentBreakdown({
    this.components = const [],
    this.totalAmount = 0,
    this.walletAppliedAmount = 0,
    this.remainingPayableAmount = 0,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic>? json) {
    final rawComponents = json?['components'];
    final components = <PaymentComponent>[];
    if (rawComponents is Iterable) {
      for (final value in rawComponents) {
        if (value is Map) {
          components.add(
            PaymentComponent.fromJson(Map<String, dynamic>.from(value)),
          );
        }
      }
    }

    return PaymentBreakdown(
      components: components,
      totalAmount: _doubleValue(json?['totalAmount']),
      walletAppliedAmount: _doubleValue(json?['walletAppliedAmount']),
      remainingPayableAmount: _doubleValue(json?['remainingPayableAmount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'components': components.map((component) => component.toJson()).toList(),
      'totalAmount': totalAmount,
      'walletAppliedAmount': walletAppliedAmount,
      'remainingPayableAmount': remainingPayableAmount,
    };
  }

  PaymentBreakdown copyWith({
    List<PaymentComponent>? components,
    double? totalAmount,
    double? walletAppliedAmount,
    double? remainingPayableAmount,
  }) {
    return PaymentBreakdown(
      components: components ?? this.components,
      totalAmount: totalAmount ?? this.totalAmount,
      walletAppliedAmount: walletAppliedAmount ?? this.walletAppliedAmount,
      remainingPayableAmount:
          remainingPayableAmount ?? this.remainingPayableAmount,
    );
  }
}

class PaymentComponent {
  final PaymentMode mode;
  final PaymentGatewayType? gateway;
  final double amount;
  final PaymentComponentStatus status;
  final String? transactionId;
  final RefundStatus refundStatus;
  final RefundDestination? refundDestination;
  final double refundedAmount;
  final String? refundReference;

  const PaymentComponent({
    required this.mode,
    this.gateway,
    this.amount = 0,
    this.status = PaymentComponentStatus.pending,
    this.transactionId,
    this.refundStatus = RefundStatus.none,
    this.refundDestination,
    this.refundedAmount = 0,
    this.refundReference,
  });

  factory PaymentComponent.fromJson(Map<String, dynamic>? json) {
    return PaymentComponent(
      mode: PaymentMode.fromJson(json?['mode']) ?? PaymentMode.cod,
      gateway: PaymentGatewayType.fromJson(json?['gateway']),
      amount: _doubleValue(json?['amount']),
      status: PaymentComponentStatus.fromJson(json?['status']),
      transactionId: json?['transactionId']?.toString(),
      refundStatus: RefundStatus.fromJson(json?['refundStatus']),
      refundDestination: RefundDestination.fromJson(json?['refundDestination']),
      refundedAmount: _doubleValue(json?['refundedAmount']),
      refundReference: json?['refundReference']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'gateway': gateway?.name,
      'amount': amount,
      'status': status.name,
      'transactionId': transactionId,
      'refundStatus': refundStatus.name,
      'refundDestination': refundDestination?.name,
      'refundedAmount': refundedAmount,
      'refundReference': refundReference,
    };
  }

  PaymentComponent copyWith({
    PaymentMode? mode,
    PaymentGatewayType? gateway,
    double? amount,
    PaymentComponentStatus? status,
    String? transactionId,
    RefundStatus? refundStatus,
    RefundDestination? refundDestination,
    double? refundedAmount,
    String? refundReference,
  }) {
    return PaymentComponent(
      mode: mode ?? this.mode,
      gateway: gateway ?? this.gateway,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      refundStatus: refundStatus ?? this.refundStatus,
      refundDestination: refundDestination ?? this.refundDestination,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      refundReference: refundReference ?? this.refundReference,
    );
  }
}

class PaymentPreferences {
  final PaymentMode? lastUsedPaymentMode;
  final String? lastUsedUpiApp;
  final String? lastUsedCard;
  final PaymentGatewayType? lastUsedGateway;
  final Timestamp? lastSuccessfulPaymentTimestamp;

  const PaymentPreferences({
    this.lastUsedPaymentMode,
    this.lastUsedUpiApp,
    this.lastUsedCard,
    this.lastUsedGateway,
    this.lastSuccessfulPaymentTimestamp,
  });

  factory PaymentPreferences.fromJson(Map<String, dynamic>? json) {
    return PaymentPreferences(
      lastUsedPaymentMode: PaymentMode.fromJson(json?['lastUsedPaymentMode']),
      lastUsedUpiApp: json?['lastUsedUpiApp']?.toString(),
      lastUsedCard: json?['lastUsedCard']?.toString(),
      lastUsedGateway: PaymentGatewayType.fromJson(json?['lastUsedGateway']),
      lastSuccessfulPaymentTimestamp:
          json?['lastSuccessfulPaymentTimestamp'] is Timestamp
              ? json!['lastSuccessfulPaymentTimestamp'] as Timestamp
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUsedPaymentMode': lastUsedPaymentMode?.name,
      'lastUsedUpiApp': lastUsedUpiApp,
      'lastUsedCard': lastUsedCard,
      'lastUsedGateway': lastUsedGateway?.name,
      'lastSuccessfulPaymentTimestamp': lastSuccessfulPaymentTimestamp,
    };
  }
}

double _doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
