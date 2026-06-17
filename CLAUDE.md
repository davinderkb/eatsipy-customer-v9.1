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
