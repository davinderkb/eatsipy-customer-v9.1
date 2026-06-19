# Cross-App Changes — Driver App

Changes made in the customer app that require corresponding updates in the driver app.

| # | Change | Reason | Priority | Date |
|---|--------|--------|----------|------|
| 1 | **Font consolidation: single `Urbanist` family with weight variants** | Customer app consolidated from per-weight families to single `Urbanist` family. Update `pubspec.yaml` fonts section + all `fontFamily` references. | Low | 2026-06-17 |
| 2 | **Theme detection: `Theme.of(context).brightness` replaces `Provider.of<DarkThemeProvider>`** | Customer app removed DarkThemeProvider dependency. Simpler, no Provider import needed. | Low | 2026-06-17 |
| 3 | **`withOpacity()` → `withValues(alpha:)` deprecation** | Flutter deprecated `withOpacity()`. Migrate all calls to `withValues(alpha:)`. | Low | 2026-06-17 |
| 4 | **`NestedScrollView` body scroll bug** | If any screen uses `SingleChildScrollView(physics: NeverScrollableScrollPhysics())` inside `NestedScrollView.body`, content below the fold is unreachable. Remove the `NeverScrollableScrollPhysics`. | Low | 2026-06-17 |
| 5 | **Read order payment data defensively** | Customer orders may include new `paymentBreakdown` data while old orders only have `payment_method`. Driver screens should continue to display simple payment mode/payment status safely and should not depend on checkout gateway config. | Medium | 2026-06-18 |
