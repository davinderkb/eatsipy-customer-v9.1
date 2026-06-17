# Flutter App UI/UX Modernization Guide

A reusable prompt you can feed to an AI assistant on **any** Flutter codebase to modernize it to a premium Material 3 experience. No repo-specific field names — only patterns to detect and principles to apply.

---

## Goal

Transform a dated Flutter app into a polished, modern Material 3 experience while **preserving all existing functionality, state management, and business logic**. Only the UI layer changes.

---

## Step 0: Audit the Codebase First

Before changing anything, the AI should:

1. **Identify the app's primary color** — look in constants files, theme files, or Firebase remote config for the hex value used as the brand color.
2. **Identify the font situation** — check `pubspec.yaml` for how fonts are declared. Are there multiple family names for different weights (e.g., `AppFontBold`, `AppFontRegular`)? Or one family with proper weight variants?
3. **Identify the dark mode pattern** — search for `isDarkMode`, `brightness == Brightness.dark`, or similar helper functions. Note how dark/light colors are toggled.
4. **Identify the navigation pattern** — is primary nav a Drawer, TabBar, BottomNavigationBar, or custom?
5. **Identify the state management** — Provider, Bloc, Riverpod, GetX, setState? Don't change it.
6. **Identify the router** — MaterialApp, GetMaterialApp, go_router? Don't change it.
7. **List all screen files** — `find lib/ui -name "*.dart" | sort` to understand scope.

Only after this audit should changes begin.

---

## Step 1: Material 3 Theme System (Foundation)

### Detect
Look for `ThemeData(` in the codebase. It's typically in a `Styles.dart`, `app_theme.dart`, or directly in `main.dart`.

### Apply
Rewrite the theme to use M3 with `ColorScheme.fromSeed`:

```dart
static ThemeData buildTheme(bool isDark, Color primaryColor) {
  final brightness = isDark ? Brightness.dark : Brightness.light;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'YOUR_FONT',  // whatever the app uses
    scaffoldBackgroundColor: colorScheme.surface,

    // Card: no elevation, rounded corners
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
    ),

    // AppBar: flat, no shadow until scrolled
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),

    // Buttons: flat, rounded 12px
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Input fields: rounded 12px
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Bottom sheets: rounded top
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Bottom nav
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
    ),
  );
}
```

### Why
`ColorScheme.fromSeed` generates a full harmonious palette (surface, onSurface, primary, secondary, tertiary, containers, etc.) for both light AND dark mode from one color. This eliminates the need for manual dark-mode color constants.

---

## Step 2: Font Consolidation

### Detect
Check `pubspec.yaml` for font declarations. Look for patterns like:
```yaml
- family: AppFontBold
  fonts:
    - asset: assets/fonts/Font-Bold.ttf
- family: AppFontRegular
  fonts:
    - asset: assets/fonts/Font-Regular.ttf
```

Also grep for `fontFamily:` across all dart files to see what names are used.

### Apply
If multiple family names exist for the same font at different weights:

1. **Consolidate** `pubspec.yaml` to one family with weight variants:
```yaml
fonts:
  - family: AppFont
    fonts:
      - asset: assets/fonts/Font-Light.ttf
        weight: 300
      - asset: assets/fonts/Font-Regular.ttf
        weight: 400
      - asset: assets/fonts/Font-Medium.ttf
        weight: 500
      - asset: assets/fonts/Font-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Font-Bold.ttf
        weight: 700
```

2. **Search and replace** across all dart files (process longest variant names first):
```
fontFamily: "AppFontBold"     -> fontFamily: "AppFont", fontWeight: FontWeight.w700
fontFamily: "AppFontSemiBold" -> fontFamily: "AppFont", fontWeight: FontWeight.w600
fontFamily: "AppFontMedium"   -> fontFamily: "AppFont", fontWeight: FontWeight.w500
fontFamily: "AppFontRegular"  -> fontFamily: "AppFont", fontWeight: FontWeight.w400
fontFamily: "AppFontLight"    -> fontFamily: "AppFont", fontWeight: FontWeight.w300
```

3. **Fix duplicate fontWeight** — when old code had both `fontFamily: "AppFontBold"` AND `fontWeight: FontWeight.bold`, the replacement creates two `fontWeight` params. Find and remove duplicates.

### Skip if
The app already uses one font family with proper weight variants.

---

## Step 3: Eliminate Hardcoded Dark Mode Ternaries

### Detect
```bash
grep -rn "isDarkMode\|brightness == Brightness" lib/ --include="*.dart" | wc -l
```
This tells you the scale of the problem.

### Apply
The core principle: **replace every `isDarkMode ? colorA : colorB` with a single `Theme.of(context).colorScheme.X` token that adapts automatically.**

Map each usage by its semantic purpose:

| Purpose | What you'll find | Replace with |
|---|---|---|
| **Page/card background** | Dark constant or `Colors.black` vs `Colors.white` | `theme.colorScheme.surface` |
| **Primary text** | `Colors.white` vs `Colors.black` (in text styles) | `theme.colorScheme.onSurface` |
| **Secondary/muted text** | `Colors.white70` / `Colors.white60` vs grey hex codes | `theme.colorScheme.onSurfaceVariant` |
| **Foreground on primary buttons** | `Colors.black` vs `Colors.white` (on colored button) | `theme.colorScheme.onPrimary` |
| **Borders/dividers** | Dark border constant vs `Colors.grey.shade100` | `theme.colorScheme.outlineVariant` |
| **Shadows** | `BoxShadow()` (empty) vs `BoxShadow(grey)` | Unified: `BoxShadow(color: theme.shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: Offset(0, 2))` |
| **Shimmer base** | `Colors.black` vs `Colors.white` | `theme.colorScheme.surfaceContainerHighest` |
| **Shimmer highlight** | primary color | `theme.colorScheme.surfaceContainerLow` |
| **AppBar icon color** | `Colors.white` vs `Colors.black` | `theme.colorScheme.onSurface` |
| **Scaffold background** | Dark bg constant vs white | `theme.colorScheme.surface` |

### Technique
Use `sed` for bulk passes first, then handle edge cases. Work from most common patterns to least:

```bash
# Find all files with the dark mode helper
FILES=$(find lib -name "*.dart" -exec grep -l "isDarkMode\|isDark" {} \;)

# Run sed replacements (adjust patterns to match YOUR codebase's actual strings)
echo "$FILES" | xargs sed -i '' \
  -e 's/isDarkMode(context) ? Colors\.white : Colors\.black/Theme.of(context).colorScheme.onSurface/g'
  # ... add more patterns
```

After sed passes, grep again to see what's left. Remaining patterns are usually:
- Commented-out code (safe to ignore)
- Apple Sign-In button style (legitimately needs isDarkMode — leave it)
- Non-standard color combos (handle manually or leave)

---

## Step 4: Navigation Modernization

### Detect
Look at the main container/shell screen. Is it using a `Drawer` for primary navigation? Or an old-style `BottomNavigationBar`?

### Apply
For food delivery / e-commerce apps, the standard is:

**Bottom NavigationBar with 5 tabs:**
- Home
- Search / Explore
- Orders
- Cart (with item count badge)
- Profile / Account

Use M3 `NavigationBar` widget (not the older `BottomNavigationBar`):

```dart
NavigationBar(
  selectedIndex: _currentIndex,
  onDestinationSelected: (i) => setState(() => _currentIndex = i),
  destinations: [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
    NavigationDestination(
      icon: Badge(label: Text('$cartCount'), child: Icon(Icons.shopping_cart_outlined)),
      selectedIcon: Badge(label: Text('$cartCount'), child: Icon(Icons.shopping_cart)),
      label: 'Cart',
    ),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

Keep the Drawer for secondary items (Wallet, Settings, Referral, etc.) if the app has them.

### Also
- Replace any `WillPopScope` with `PopScope`
- Replace `MaterialStateProperty` with `WidgetStateProperty`

---

## Step 5: Screen-by-Screen Modernization

For **every screen**, apply these principles:

### Scaffold
```dart
Scaffold(
  backgroundColor: theme.colorScheme.surface,  // never hardcode Colors.white
  ...
)
```

### AppBar
```dart
AppBar(
  backgroundColor: Colors.transparent,  // or theme.colorScheme.surface
  iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
  elevation: 0,
)
```

### Text Styles
Use theme text styles instead of manual `TextStyle(fontSize: X)`:
```dart
theme.textTheme.headlineSmall   // page titles
theme.textTheme.titleMedium     // section headers
theme.textTheme.titleSmall      // card titles
theme.textTheme.bodyLarge       // body text
theme.textTheme.bodyMedium      // secondary body
theme.textTheme.bodySmall       // captions, metadata
theme.textTheme.labelLarge      // button text
```

When you need custom weight or color on theme text:
```dart
theme.textTheme.titleSmall?.copyWith(
  fontWeight: FontWeight.w600,
  color: theme.colorScheme.onSurface,
)
```

### Cards & Containers
Replace inline `BoxDecoration` with consistent patterns:
```dart
Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
    boxShadow: [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
)
```

### Input Fields
```dart
TextFormField(
  cursorColor: theme.colorScheme.primary,
  decoration: InputDecoration(
    hintText: 'Placeholder',
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.error),
    ),
  ),
)
```

### Buttons
- **Primary action**: `ElevatedButton` — let theme handle colors
- **Secondary action**: `OutlinedButton` with `side: BorderSide(color: theme.colorScheme.primary)`
- **Tertiary/text action**: `TextButton`
- **Remove** manual `ElevatedButton.styleFrom(backgroundColor: ...)` when theme already covers it

### Images
Use `ClipRRect` for rounded corners on network images:
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(14),
  child: CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    width: 110,
    height: 110,
    placeholder: (_, __) => Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(child: CircularProgressIndicator.adaptive()),
    ),
    errorWidget: (_, __, ___) => Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(Icons.image, color: theme.colorScheme.onSurfaceVariant),
    ),
  ),
)
```

### Rating Badges (for review/delivery apps)
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: rating >= 4 ? Colors.green : rating >= 3 ? Colors.orange : Colors.grey,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.star, size: 12, color: Colors.white),
      const SizedBox(width: 2),
      Text(ratingStr, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    ],
  ),
)
```

### List Item Cards (restaurant/product)
Use a horizontal `Row` layout:
- Left: Image with `ClipRRect`
- Right: Column with name, subtitle, rating, metadata
- Optional: Favourite icon or action button in top-right

---

## Step 6: Specific Screen Patterns

### Auth/Login/SignUp
- Wrap body in `SafeArea`
- Title: `theme.textTheme.headlineSmall` in primary color
- Subtitle: `theme.textTheme.bodyLarge` in `onSurfaceVariant`
- Social login buttons: brand-specific colors, but with 12px radius
- "or" divider text: `theme.colorScheme.onSurfaceVariant`
- "Forgot password?" link: `theme.colorScheme.primary`, `FontWeight.w600`

### Onboarding
- Page background: `theme.colorScheme.primaryContainer.withValues(alpha: 0.3)` for image area
- Indicator dots: primary + primaryContainer colors
- Skip: `TextButton`, Get Started/Next: `ElevatedButton`
- Wrap in `SafeArea`

### Cart / Checkout
- Dividers: `theme.colorScheme.outlineVariant`
- Labels: `theme.colorScheme.primary`
- Empty widgets: `SizedBox.shrink()` not `Container()`
- Sticky bottom button for "Place Order" / "Proceed"

### Order Details
- Status chips with semantic colors
- Timeline/stepper for order tracking

---

## Step 7: Deprecation Fixes

Search and fix these across the entire codebase:

| Deprecated | Replacement |
|---|---|
| `.withOpacity(x)` | `.withValues(alpha: x)` |
| `WillPopScope` | `PopScope` |
| `MaterialStateProperty` | `WidgetStateProperty` |
| `MaterialState` | `WidgetState` |

---

## Step 8: Firebase / Data Optimization (If Applicable)

If the app fetches entire Firestore collections without limits:

1. Add cursor-based pagination using `startAfterDocument`
2. Create a generic `PaginatedResult<T>` class
3. Home screen: limit each section to 6 items
4. "View All" screens: infinite scroll with `ScrollController`

---

## Design Tokens

| Token | Value |
|---|---|
| Card corner radius | 16px |
| Button corner radius | 12px |
| Input field corner radius | 12px |
| Chip corner radius | 20px |
| Shadow opacity | 0.06 |
| Shadow blur | 8px |
| Shadow offset | (0, 2) |
| Section horizontal padding | 16px |
| Card horizontal margin | 16px |
| Card vertical margin | 6px |

---

## M3 ColorScheme Token Cheat Sheet

| What you need | Token |
|---|---|
| Page background | `colorScheme.surface` |
| Card background | `colorScheme.surface` |
| Primary text | `colorScheme.onSurface` |
| Secondary/muted text | `colorScheme.onSurfaceVariant` |
| Brand/accent color | `colorScheme.primary` |
| Text on primary buttons | `colorScheme.onPrimary` |
| Subtle borders | `colorScheme.outlineVariant` |
| Strong borders | `colorScheme.outline` |
| Container background (subtle) | `colorScheme.surfaceContainerHighest` |
| Category/chip background | `colorScheme.primaryContainer` |
| Error states | `colorScheme.error` |
| Error text | `colorScheme.onError` |
| Shadow | `ThemeData.shadowColor` |

---

## Execution Priority

1. **Theme system** — everything else depends on this
2. **Font consolidation** — mechanical, high impact
3. **Bulk isDarkMode elimination** — biggest cleanup, use sed scripts
4. **Navigation** — structural change, do early
5. **Home screen** — highest-visibility screen
6. **Auth flow** — first thing new users see
7. **Core flow screens** — restaurant detail, cart, checkout
8. **Secondary screens** — profile, orders, settings, etc.
9. **Deprecation fixes** — run `flutter analyze` and fix
10. **Dark mode audit** — verify everything looks correct in dark theme

---

## Rules for the AI

- **Never touch business logic** — only `build()` methods, widget trees, decorations, colors
- **Preserve all state management** — whatever the app uses, keep it
- **Preserve all navigation logic** — onTap handlers, routes, arguments stay unchanged
- **No new packages** unless absolutely necessary
- **Always use `Theme.of(context)`** — never hardcode colors
- **Run `flutter analyze`** after each batch of changes to catch errors early
- **Test the golden path** after each major phase
- **Be efficient** — use sed/bulk scripts for repetitive patterns, manual edits for unique screens
- **Start with `final theme = Theme.of(context);`** at the top of every `build()` method for cleaner references
