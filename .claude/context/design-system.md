# Design System — AppThemeData

## File: `lib/themes/app_them_data.dart`

### Spacing Constants
| Name | Value |
|------|-------|
| space4 | 4 |
| space8 | 8 |
| space12 | 12 |
| space16 | 16 |
| space20 | 20 |
| space24 | 24 |
| space32 | 32 |

### Border Radius Constants
| Name | Value |
|------|-------|
| radius8 | 8 |
| radius12 | 12 |
| radius16 | 16 |
| radius20 | 20 |
| radius24 | 24 |

### Shadows (methods, take `bool isDark`)
- `shadowSm(isDark)` — blurRadius: 4, offset: (0,2), alpha: isDark ? 0.2 : 0.06
- `shadowMd(isDark)` — blurRadius: 8, offset: (0,4), alpha: isDark ? 0.25 : 0.08
- `shadowLg(isDark)` — blurRadius: 16, offset: (0,8), alpha: isDark ? 0.3 : 0.1

### Desaturation Filters (static const ColorFilter)
- `desatLight` — 25% desaturation, used for closed restaurants in mixed lists
- `desatMuted` — 35% desaturation, used for "Opening Soon" section cards

### Card Dimensions
| Name | Value |
|------|-------|
| restaurantImageHeight | 200 |
| categoryIconSize | 85 |
| offerCardWidthPercent | 88 |
| featuredCardWidthPercent | 72 |

### Color Palette

**Primary (Green)**
- primary50: #E5FBF0
- primary100: #B2F3D3
- primary200: #66E8A8
- primary300: #00D96F (brand color — NOT const, loaded from Firestore)
- primary400: #00B85C
- primary500: #004B26
- primary600: darker variant

**Danger (Red)**
- danger50: #FFE5E6
- danger300: #FF3840
- cartBadge: #E11D48 — tomato red for cart-count badges. Use this instead of `secondary300`/purple for cart counts.
- cartBar: #047857 — premium emerald for the floating restaurant-detail "items added / View Cart" island.

**Warning (Yellow/Amber)**
- warning300: #FFCB39

**Success (Green — separate from primary)**
- success400: #10B271
- lightGreen: #EFF9EB
- darkGreen: #3F8826

**Secondary**
- secondary50, secondary300, secondary600 (purple/blue tones). Avoid using these for cart counts or cart status strips.

**Grey Scale**
- grey50: #FFFFFF (white)
- grey100, grey200 (light borders/backgrounds)
- grey400: #9CA3AF
- grey500: #6B7280
- grey600, grey700, grey800 (dark mode backgrounds)
- grey900: #111827 (near-black)

**Surface**
- surface: light mode background
- surfaceDark: dark mode background

### Typography
- Font family: `Urbanist` (all weights from 400-900)
- Common patterns: title (16px w700), body (14px w400-w500), caption (12-13px w400-w500), label (11px w600)

---

## UI Patterns (Restaurant Cards — Home Screen)

### Food Showcase Overlay (RestaurantImageView)
Shown only in showcase slider mode (2+ active `card_showcase_items`):
- **Gradient:** Bottom-to-top `LinearGradient`, `black@0.65` → `transparent`, from `bottomCenter` to `center`
- **Dish name:** white, 14px Urbanist w600, `Expanded` with `ellipsis`
- **Price:** white, 14px Urbanist w700, uses `Constant.amountShow()`
- **Layout:** `Padding(horizontal: 12, bottom: 20)` → `Row` inside gradient container
- **Pagination dots:** `AnimatedContainer` circles, 6px inactive (white@0.5), 8px active (white), `bottom: 8` center-aligned
- **Timer:** 6-second auto-slide interval, pauses on user drag, resumes after 3s idle
- Single showcase / cover / stock image modes: no overlay, no dots, no timer — just a clean food photo

---

## UI Patterns (Restaurant Details Screen)

### Typography-First Header
No banner/carousel images. Flat `AppBar(elevation: 0, scrolledUnderElevation: 0.5)` with back arrow, heart toggle, red cart badge (`cartBadge`). Restaurant info in a text-only block: name (22px w700) + rating pill, cuisine row, quick meta row (distance + estimated delivery time), timing row with clock icon. Entire info block wrapped in `InkWell` → opens timing bottom sheet, with chevron_right indicator.

### Detail Loading UX
- On restaurant tap, navigate immediately with the passed `VendorModel`; do not block behind a full-page spinner while products/categories load.
- `RestaurantDetailsController.isLoading` is only for initial argument/header setup. `isMenuLoading` controls menu skeletons.
- While menu data loads, show `RestaurantMenuLoadingView` with rotating copy and category/product skeleton cards.
- If loading exceeds 4 seconds, show "Taking a little longer than usual...".
- If menu loading fails, show `RestaurantMenuRetryView` and call `retryLoadMenu()`; do not leave an endless spinner.
- Page body entry uses fade + slight slide-up via `TweenAnimationBuilder`.
- Menu item descriptions use a subtle two-line fade instead of ellipsis. Product image taps open the existing product detail bottom sheet with the large image, full description, pricing, customization, and add controls.
- Menu items without product photos should keep the same left text column width and trailing ADD/quantity action position as photo items; only omit the image surface.
- Restaurant menu search is local and instant: build an in-memory `MenuSearchEntry` index after menu/category load, search name/category/description/diet tags without Firebase calls per keystroke, and rebuild the index only after fresh menu data is loaded.
- While restaurant menu search is active, show result count/empty state, provide a clear button, hide the floating menu navigator and cart strip, actively scroll the search section under the app bar, and add keyboard-aware bottom spacing so result cards and ADD buttons stay visible/reachable.

### Floating Menu Navigator
- Do not use inline horizontal category chips on restaurant detail.
- Use `RestaurantMenuFloatingButton` at bottom-right (`FloatingActionButtonLocation.endFloat`), with Material pill styling and elevation.
- Hide button when `productList.length < 10`, `menuCategoryMetaList.length <= 1`, loading, error, or restaurant menu search is active.
- Button label stays as "Menu" with the static menu icon; do not switch labels or icons based on category.
- The button opens `RestaurantMenuNavigatorSheet`, a draggable bottom sheet with grouped category sections: Recommended For You, Offers / Discounted Items, Best Sellers, Frequently Ordered, Remaining Categories.
- Category rows show category name and item count only, with active highlighting; do not add guessed emoji/category icons.
- Category metadata comes from cached `MenuCategoryMeta` in the controller: `categoryId`, `categoryName`, `itemCount`, `scrollOffset`.
- Category taps must smooth-scroll with the selected section heading visible below the app bar; keep a small top gap instead of letting the first item crop the heading.
- Search/filter changes must rebuild metadata and hide empty categories.
- Tapping category uses `scrollToCategory(index)` with an explicit app-bar-aware scroll offset; avoid jumps and cropped headings.

### Floating Cart Island
- Restaurant-detail bottom cart status is an independent floating island, not a full-width baseline bar.
- Margins: left/right 12, bottom 16 via `SafeArea(minimum: ...)`.
- Shape: radius 16, height 56, emerald `cartBar`, shadow `black@0.15 blur 12 offset (0,4)`.
- Content: left status with correct pluralization (`1 Item added`, `N Items added`), right bold `View Cart` + chevron.
- Floating menu button must pad above this island when cart has items.

### Floating ADD Button
Use `Stack(clipBehavior: Clip.none)` so the button overflows the image bottom edge. Image in its own `ClipRRect(radius16)`. Button: `Positioned(bottom: -16, left: 12, right: 12)`, 32px height, white/dark bg, `primary300` border (1.5px), `shadowSm`, `radius8`. Text: "ADD" in primary300 w600. Add `SizedBox(height: 18)` below the Stack to prevent parent clipping.

### "customisable" Label
Below the floating ADD button on items with variants/addons: `Text('customisable', fontSize: 11, w400, grey400/grey500)`, centered.

### Differentiated Veg/NonVeg Filter Pills
- Veg selected: bg `lightGreen` (dark: `primary600`), border `darkGreen`, text `darkGreen`
- NonVeg selected: bg `danger50` (dark: `#3D1012`), border `danger300`, text `danger300`
- Unselected: bg `transparent`, border `grey200` (dark: `grey700`)
- Item diet labels display `Veg` / `Non Veg.`. Do not use `Pure veg.` in item rows.

### Radio-Style Variant Rows (Bottom Sheet)
Replace `Wrap` of `Chip` widgets with a `Column` of `InkWell` rows. Each row: option name (left, Expanded) + custom radio circle (right, 20×20, border primary300 when selected with 10×10 filled dot, border grey300/grey600 when unselected). Thin dividers between rows.

### Addon Rows (Bottom Sheet)
No nested card container. Name + price stacked vertically on left (name 14px w500, price 13px w400 grey400/grey500). Rounded checkbox flush right (`shape: RoundedRectangleBorder(borderRadius: 4)`). `ListView.separated` with thin dividers.

### Bottom Sheet Standards
- Scrim: `barrierColor: Colors.black.withValues(alpha: 0.5)`
- Drag handle: 40×4 rounded pill, `grey300`/`grey600`, centered at top
- Compact header: veg/nonveg icon (16px) + item name (18px w700, Expanded) + heart toggle + close (X) button
- Description: 13px w400 `grey400`/`grey500`, maxLines: 2
- Footer: `grey50`/`grey900` bg, top border `grey200`/`grey700`, quantity counter bg `grey100`/`grey800`
