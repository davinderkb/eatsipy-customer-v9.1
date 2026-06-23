# Eatsipy Customer App v9.1

## Project Overview
Flutter food delivery customer app. Firebase/Firestore backend. GetX state management (`GetX<T>`, `.obs`, `RxList`, `RxSet`, `Obx`). Material 3 (`useMaterial3: true`).

## Key Conventions
- **Font**: Single `Urbanist` family with weight variants (w400-w900)
- **i18n**: `TranslatedText` widget + `.tr` extension for all user-facing strings
- **Theme detection**: `Theme.of(context).brightness == Brightness.dark`
- **Brand color**: `primary300 = Color(0xFF00D96F)` (green) — dynamically overwritten from Firestore, NOT const
- **Sizing**: `Responsive.width(percent, context)` and `Responsive.height(percent, context)`
- **Navigation**: `Get.to(Screen(), arguments: {...})`
- **Images**: `RestaurantImageView` (wraps `CachedNetworkImage` with shimmer), `NetworkImageWidget` for general images

## Critical Rules
- Theme-specific home screens both exist: `home_screen.dart` (theme_1) and `home_screen_two.dart` (theme_2). Keep shared behavior consistent when a feature appears in both themes.
- Do NOT rebuild from scratch — modify existing files
- Do NOT replace existing business logic
- Do NOT create duplicate screens
- Reuse existing controllers, models, APIs, navigation
- No `closed.PNG` overlays — use desaturation matrices + pill badges for closed restaurants
- Restaurant details must render the basic header immediately from passed `VendorModel`; menu/items load separately with skeleton/retry states. Do not reintroduce a blocking full-page spinner for menu loading.
- Restaurant detail menu navigation uses a floating bottom-right Menu pill with a static menu icon + draggable category sheet backed by cached `MenuCategoryMeta`; category rows show name and count without guessed icons, and category taps must land with the section heading visible.
- Cart count badges use `AppThemeData.cartBadge`; the restaurant-detail cart strip uses `AppThemeData.cartBar`.
- Bottom navigation is Home, Favourites, Orders, Profile. Wallet is a separate Profile section when `Constant.walletSetting == true`.
- Vegetarian item labels should display `Veg`, not `Pure veg.`.
- Restaurant menu item descriptions fade at the edge in list previews. Product image taps open the existing detail bottom sheet with larger image and full description while preserving current add/cart behavior.
- Restaurant menu items without photos still reserve the trailing action column so text and ADD/quantity placement aligns with photo items.
- Restaurant menu search uses a local in-memory index; never query Firebase per keystroke. Search mode hides the floating menu navigator/cart strip, scrolls the search section into view, and adds keyboard-aware bottom spacing for reachable results.
- Home and restaurant menu quality coverage now lives under `test/unit`, `test/widget`, and `test/golden`. Keep logic that affects image priority, home section visibility, menu search, category metadata, floating menu visibility, keyboard-safe search layouts, no-photo card alignment, and cart badge placement covered by tests.
- Checkout supports PhonePe, Cashfree, and Razorpay in code, but admin selects exactly one active online gateway through `settings/paymentGatewayConfig`. Customers must choose payment modes only: UPI, Wallet, Card, Net Banking, or COD.
- Checkout should load only Wallet, COD, and the admin-selected active gateway settings. Do not initialize unused payment SDKs during checkout.
- Wallet split tender is a first-class scenario: wallet-only, COD-only, online-only, wallet + COD, and wallet + online must parse and serialize through `paymentBreakdown`. Debit wallet only after online success and immediately before order creation.
- New order/user payment fields must stay backward-compatible. Old orders with only `payment_method` and users without `paymentPreferences` must continue to parse safely.
- Online checkout routing goes through `PaymentGatewayAdapterRegistry` and the PhonePe/Cashfree/Razorpay adapters. Keep gateway-specific SDK/link creation out of cart UI.
- Cart checkout follows the compact conversion hierarchy: Your Order, Complete Your Meal, Offers, Delivery, Order Total, Tip Your Delivery Partner, sticky CTA. Keep all ordered items, a lightly elevated `Add More Items`, and an input-like `Add note for restaurant` row inside one order card; note entry opens a bottom sheet with only recent user notes below the text field, not hardcoded quick suggestions. Checkout order items do not show food images; item name and customization/add-on text share the same left edge, with quantity/final price on the right. Customizable checkout items show `Edit`, item-row taps open the editor instead of restaurant/menu navigation, preselect existing add-ons, and save add-on selection changes back to the same cart row. Payment mode selection lives in the sticky footer `Change` affordance, not a duplicate body section. Use one grouped delivery card, a draggable order-total bottom sheet, a mode-only payment bottom sheet, one tip section, and only enough bottom clearance to keep Tip above the sticky CTA.
- Checkout scheduled delivery is controlled by `settings/globalSettings.is_scheduled_order_enabled`; hide Schedule and use instant delivery when disabled.
- Refund cancellation UX should offer wallet refund vs original-source/manual-review when prepaid online components exist.

## Quality Checks
- For focused changes, run scoped format/analyze checks on the touched Dart files plus `test`, then run `flutter test`.
- Current verified scoped gate for the Home/Restaurant menu quality work:
  - `dart format --set-exit-if-changed lib/utils/quality lib/widget/restaurant_image_view.dart lib/controllers/home_controller.dart lib/controllers/restaurant_details_controller.dart lib/app/home_screen/home_screen.dart test`
  - `flutter analyze lib/utils/quality lib/widget/restaurant_image_view.dart lib/controllers/home_controller.dart lib/controllers/restaurant_details_controller.dart lib/app/home_screen/home_screen.dart test`
  - `flutter test`
- Do not rely on live Firebase, network, or Firestore initialization in these tests; use local fakes/helpers.
- Golden coverage should stay limited to stable UI surfaces such as cart badge placement and menu/item layout states.
- Payment quality coverage lives in `test/unit/payment`. Keep resolver, payment JSON, wallet split, refund state, and "no wallet debit on failure" logic covered as implementation expands.

## Context Files
Detailed architecture documentation is in `.claude/context/`:
- `home-screen-architecture.md` — home screen layout, sections, controller, filters
- `design-system.md` — AppThemeData constants, colors, spacing, shadows, desaturation
- `restaurant-card.md` — RestaurantCard widget, visual states, parameters

## Cross-App Change Tracking
When making changes that affect Firestore schema, shared data models, or patterns that exist in companion apps, update the relevant tracking file:
- `cross-app-admin.md` — Admin panel changes needed
- `cross-app-restaurant.md` — Restaurant app changes needed
- `cross-app-driver.md` — Driver app changes needed
