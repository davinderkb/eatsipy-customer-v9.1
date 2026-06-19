# Eatsipy Checkout Payment Modernization Plan

## Current Status

- Current phase: Phase 8 verification after checkout modernization implementation.
- Baseline verification: `flutter test` passed with 42 tests before checkout modernization work.
- Latest verification: `flutter test` passed with 69 tests after checkout widget/golden coverage and final mounted-guard cleanup. `dart format --set-exit-if-changed` passed on touched checkout/payment files. Newly added payment layers and checkout component tests pass scoped analyzer with no issues; wider touched-file analyzer still exits non-zero because of legacy info-level lints in older cart/select-payment/Firestore files.
- Existing uncommitted fixes to preserve:
  - `lib/app/cart_screen/cart_screen.dart`
  - `lib/controllers/cart_controller.dart`
  - `lib/payment/rozorpayConroller.dart`
- Active checkout gateway rule: the customer app supports PhonePe, Cashfree, and Razorpay in code, but admin selects exactly one active online gateway at a time.
- Customer-facing payment modes: UPI, Wallet, Card, Net Banking, COD.
- Customers must never choose or see gateway names such as PhonePe, Cashfree, or Razorpay during checkout.

## Completed Work

- Baseline test run captured.
- Persistent execution plan created.
- Added checkout payment models:
  - `PaymentMode`: `upi`, `wallet`, `card`, `netBanking`, `cod`.
  - `PaymentGatewayType`: `phonePe`, `cashfree`, `razorpay`.
  - `PaymentGatewayConfig`, `GatewayConfig`, `PaymentBreakdown`, `PaymentComponent`, refund metadata, and `PaymentPreferences`.
- Extended `OrderModel` with nullable `paymentBreakdown` while keeping legacy `payment_method`.
- Extended `UserModel` with nullable `paymentPreferences`.
- Added `ActivePaymentGatewayResolver` for admin-selected single active online gateway.
- Added Firestore loader for `settings/paymentGatewayConfig`.
- Missing `settings/paymentGatewayConfig` now hides online modes instead of silently selecting a default online gateway.
- Changed checkout settings loading to load Wallet, COD, and only the admin-selected online gateway settings.
- Prevented checkout from initializing unused Stripe/payment SDK setup during settings load.
- Added `WalletSplitCalculator` pure helper for wallet-only, wallet + remaining payment, and no-wallet cases.
- Added unit tests under `test/unit/payment` for payment serialization, resolver permutations, and wallet split math.
- Stabilized home cart badge golden test by waiting for the SVG asset to settle before snapshot comparison.
- Updated cross-app/instruction docs for admin, Firebase, restaurant, driver, design system, Claude context, and UI modernization guide.
- Replaced cart checkout gateway branching with `CartController.startSelectedPayment(context)`.
- Cart payment selection is now customer-facing modes only: Wallet, COD, UPI, Card, Net Banking.
- Cart payment selection opens a draggable bottom sheet instead of navigating to the old full payment page.
- Checkout routes UPI/card/net-banking through the admin-selected active gateway internally.
- Checkout writes `paymentBreakdown` on new orders.
- Wallet split tender debits only the wallet-applied amount and only during order creation after online success.
- Payment failures/cancellations reset the processing lock instead of leaving checkout stuck.
- Cancellation refund logic now handles split tenders:
  - wallet portions refund to wallet,
  - COD portions do not create prepaid refunds,
  - online portions are marked `pendingManualReview` for source refund.
- Added `PaymentGatewayAdapter` interface and PhonePe, Cashfree, Razorpay adapters.
- Cart checkout now opens full bill details in a draggable bottom sheet instead of rendering the full bill table inline.
- Suggested add-ons show safe simple products from the cart vendor and hide completely when unavailable.
- Cancellation now shows a refund destination sheet when online prepaid portions exist.
- Added reusable checkout widgets for compact bill summary, wallet toggle, and payment mode rows.
- Added widget tests for checkout payment mode presentation and gateway-name hiding.
- Added golden tests for checkout bill summary and payment mode rows.
- Added mounted guards around checkout payment handoff to avoid launching payment after cart screen disposal.

## Pending Work

- Phase 1: complete for model/schema/test scaffolding; runtime order creation now populates `paymentBreakdown`.
- Phase 2: resolver and checkout config loading are complete; cart UI now uses resolver modes.
- Phase 3: wallet split math and runtime wallet toggle/split order creation are implemented; deeper transaction/compensation tests are still pending.
- Phase 4: gateway adapter interface and active gateway adapters are implemented.
- Phase 5: payment bottom sheet, compact bill bottom sheet, wallet deduction row, suggested add-ons, and sticky CTA amount are implemented.
- Phase 6: split refund metadata behavior and refund choice bottom sheet are implemented. Automated source refund APIs remain backend/admin work; source refund is marked `pendingManualReview`.
- Phase 7: cross-app documentation updates are complete.
- Phase 8: unit, widget, golden, format, analyzer, and full test verification completed for the implemented checkout scope.

## Affected Files

### Runtime / Models

- `lib/models/payment/checkout_payment_models.dart` - new checkout payment mode, active gateway config, payment breakdown, refund metadata, and payment preference models.
- `lib/models/order_model.dart` - backward-compatible `paymentBreakdown` parsing/serialization.
- `lib/models/user_model.dart` - backward-compatible `paymentPreferences` parsing/serialization.
- `lib/services/payment/active_payment_gateway_resolver.dart` - active admin-selected online gateway resolution.
- `lib/services/payment/payment_gateway_adapter.dart` - gateway adapter interface, registry, and PhonePe/Cashfree/Razorpay adapters.
- `lib/services/payment/wallet_split_calculator.dart` - pure wallet split tender calculations.
- `lib/utils/fire_store_utils.dart` - `settings/paymentGatewayConfig` read and checkout-scoped payment setting loader.
- `lib/controllers/cart_controller.dart` - checkout payment settings now load Wallet, COD, and only the active online gateway.
- `lib/app/cart_screen/cart_screen.dart` - cart payment row, wallet deduction display, bottom-sheet payment selection, and single checkout action routing.
- `lib/app/cart_screen/widgets/checkout_payment_widgets.dart` - reusable checkout bill, wallet, and payment-mode display widgets.
- `lib/app/cart_screen/select_payment_screen.dart` - legacy full payment screen now shows customer-facing modes only if opened directly.
- `lib/app/order_list_screen/order_details_screen.dart` - split cancellation refund behavior and refund metadata updates.

### Tests

- `test/unit/payment/payment_models_test.dart`
- `test/unit/payment/active_payment_gateway_resolver_test.dart`
- `test/unit/payment/payment_gateway_adapter_test.dart`
- `test/unit/payment/wallet_split_calculator_test.dart`
- `test/widget/checkout/checkout_payment_widgets_test.dart`
- `test/golden/checkout/checkout_payment_widgets_golden_test.dart`
- `test/golden/checkout/goldens/checkout_bill_summary.png`
- `test/golden/checkout/goldens/checkout_payment_mode.png`

### Documentation / Instructions

- `CHECKOUT_PAYMENT_MODERNIZATION_PLAN.md`
- `CLAUDE.md`
- `FLUTTER_UI_MODERNIZATION_GUIDE.md`
- `.claude/context/design-system.md`
- `.claude/context/cross-app-firebase.md`
- `.claude/context/cross-app-admin.md`
- `.claude/context/cross-app-restaurant.md`
- `.claude/context/cross-app-driver.md`

## Test Matrix

### Covered By Current Unit Tests

- Old order JSON without `paymentBreakdown`.
- New order JSON with wallet + online payment breakdown.
- User JSON with and without `paymentPreferences`.
- Refund metadata serialization.
- Gateway adapter registry and supported mode checks.
- Active gateway permutations for PhonePe, Cashfree, Razorpay.
- Missing, disabled, unhealthy, and unsupported active gateway config.
- Wallet split cases: zero balance, partial balance, exact bill balance, wallet greater than bill, wallet off, wallet + COD, wallet + online, COD-only, online-only.
- Checkout payment tile displays customer-facing modes and hides gateway names.
- Checkout bill summary and payment mode rows have golden coverage.
- Existing home cart badge golden remains stable after checkout work.

### Remaining Follow-Up Test Opportunities

- No wallet debit on online failure/cancel.
- Wallet debit exactly once after online success and before order creation.
- Full `CartScreen` widget coverage with Firebase/GetX seams for payment bottom sheet, sticky CTA amount, no duplicate tip/remarks, and bill details sheet.
- Order-detail refund choice widget coverage with split refund states.
- Full-screen golden coverage for full wallet, wallet + online, COD, payment sheet, bill sheet, and refund sheet.

## Phase Checklist

### Phase 1 - Payment Models And Order Schema

- [x] Add `PaymentMode`: `upi`, `wallet`, `card`, `netBanking`, `cod`.
- [x] Add `PaymentGatewayType`: `phonePe`, `cashfree`, `razorpay`.
- [x] Add admin active-gateway config model for `settings/paymentGatewayConfig`.
- [x] Add payment breakdown model for full wallet, full COD, full online, wallet + COD, wallet + online.
- [x] Extend `OrderModel` backwards-compatibly with `paymentBreakdown`.
- [x] Extend `UserModel` with `paymentPreferences`.
- [x] Add unit tests for old/new JSON parsing.

### Phase 2 - Admin-Selected Gateway Resolver

- [x] Add `ActivePaymentGatewayResolver`.
- [x] Resolve `activeGateway`, `isEnabled`, `healthStatus`, `supportedMethods`, and enabled modes.
- [x] Hide online modes when config is invalid, missing, disabled, or unhealthy.
- [x] Keep Wallet and COD independent of online gateway config.
- [x] Add unit tests for PhonePe, Cashfree, Razorpay, invalid, disabled, and unhealthy configs.
- [x] Finish payment-mode UI wiring so resolver modes, not gateway names, drive checkout selection.

### Phase 3 - Wallet Split Tender Logic

- [x] Add bill total, wallet applied amount, remaining payable, wallet toggle, and selected remaining payment mode in pure helper.
- [x] Auto-apply wallet by default when enabled and balance is positive in pure helper.
- [x] Allow user to turn wallet off in pure helper.
- [x] Support wallet-only, wallet + COD, wallet + online, COD-only, online-only in pure helper tests.
- [x] Ensure wallet debit occurs only after online success and immediately before order creation.
- [x] Prevent duplicate order/payment with one processing lock.
- [x] Add pure math permutation tests.
- [ ] Add runtime debit/order creation tests with Firebase fakes or repository seams.

### Phase 4 - Gateway Adapters

- [x] Add adapter interface for initialize/start/verify/success/failure normalization.
- [x] Implement PhonePe adapter.
- [x] Implement Cashfree adapter.
- [x] Implement Razorpay adapter.
- [x] Move gateway-specific checkout logic out of `CartScreen`.
- [x] Keep legacy gateway code present but isolated.

### Phase 5 - Checkout UI Redesign

- [x] Refactor cart checkout surfaces into smaller widget methods.
- [x] Replace full payment page from checkout with payment bottom sheet.
- [x] Move full bill details into bottom sheet.
- [x] Show wallet deduction row only when wallet is applied.
- [x] Remove duplicate tip and remarks sections.
- [x] Use existing menu/product data for suggested add-ons.
- [x] Ensure gateway names are never shown to customers in cart checkout.

### Phase 6 - Refund UX

- [x] Add refund choice UI: instant wallet refund or original source refund.
- [x] Support split refund state per payment component.
- [x] Mark source refund as `pending_manual_review` when gateway automation is unavailable.
- [x] Update order detail cancellation/refund logic.

### Phase 7 - Cross-App Documentation

- [x] Update `CLAUDE.md`.
- [x] Update `FLUTTER_UI_MODERNIZATION_GUIDE.md`.
- [x] Update `.claude/context/design-system.md`.
- [x] Update `.claude/context/cross-app-firebase.md`.
- [x] Update `.claude/context/cross-app-admin.md`.
- [x] Update `.claude/context/cross-app-restaurant.md`.
- [x] Update `.claude/context/cross-app-driver.md` if order display changes require driver awareness.

### Phase 8 - Tests And Verification

- [x] Unit tests for payment config, resolver, split tender, payment breakdown, user preferences, refunds, and adapter support.
- [x] Widget tests for extracted checkout payment widgets and gateway-name hiding.
- [x] Golden tests for extracted checkout bill summary and payment mode widgets.
- [x] Run scoped format/analyze for touched files.
- [x] Run `flutter test`.

## Resume Notes

If context usage approaches 95%, stop at a clean checkpoint and update this file with:

- Current phase number.
- Completed files/changes.
- Pending files/changes.
- Tests already run.
- Tests still needed.
- Known risks/blockers.
- Exact resume prompt.

Exact resume prompt:

`Continue Eatsipy checkout modernization from CHECKOUT_PAYMENT_MODERNIZATION_PLAN.md. Read Current Status, Completed Work, Pending Work, Current Phase, and Resume Notes first. Preserve all existing behavior and user changes. Continue from the next unchecked item, run listed verification, and update the plan document before stopping.`

## Risks

- Split payment requires backward-compatible order schema changes.
- Wallet debit and order creation need compensating handling to avoid paid-but-no-order state.
- Source refunds require gateway transaction IDs and may need backend/admin support.
- Cashback currently depends on a single payment method string.
- Wallet top-up remains legacy in this pass.
- Legacy gateway dependency removal is deferred.
- Cart checkout UI is now customer-mode based; wallet top-up and other legacy payment entry points may still use older gateway-centric screens.
- Scoped analyzer on legacy cart/select-payment/firestore files reports info-level legacy lints; newly added payment layers and checkout widget tests analyze cleanly.
- Source refund API automation is not implemented in the customer app; online refunds are marked for manual review.
- Full cart/order-detail widget coverage remains a follow-up because current screen construction still initializes GetX/Firebase-heavy runtime dependencies. Component widget/golden coverage and pure payment unit coverage are in place.
