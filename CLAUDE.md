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
- Only modify `home_screen.dart` (theme_1), NOT `home_screen_two.dart` (theme_2)
- Do NOT rebuild from scratch — modify existing files
- Do NOT replace existing business logic
- Do NOT create duplicate screens
- Reuse existing controllers, models, APIs, navigation
- No `closed.PNG` overlays — use desaturation matrices + pill badges for closed restaurants

## Context Files
Detailed architecture documentation is in `.claude/context/`:
- `home-screen-architecture.md` — home screen layout, sections, controller, filters
- `design-system.md` — AppThemeData constants, colors, spacing, shadows, desaturation
- `restaurant-card.md` — RestaurantCard widget, visual states, parameters
