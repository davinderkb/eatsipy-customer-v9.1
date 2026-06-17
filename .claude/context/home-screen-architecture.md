# Home Screen Architecture

## File: `lib/app/home_screen/home_screen.dart`

Scaffold with GetX<HomeController>. Gradient background (secondary colors fading to surface).

### Layout Structure (List View mode)

**Fixed header** (Column, 16px horizontal padding):
1. Location bar — InkWell Row: `[pin icon] [address text] [down arrow]`. Taps navigate to AddressListScreen (logged in) or LocationPickerScreen (guest).
2. SizedBox(12)
3. Search bar (48px height, radius12) + Cart button (48x48, manual `Stack` badge with count)
4. SizedBox(8) → Quick Filters (40px height horizontal ListView of FilterChips)
5. SizedBox(4)

**Scrollable content** (CustomScrollView with slivers):
1. SliverToBoxAdapter — Column of static sections:
   - **Categories**: `titleView("Explore the Categories")` + `CategoryView` (100px height horizontal list)
   - **Top Banner**: if `bannerModel.isNotEmpty` → `BannerView` (150px PageView with dots)
   - **Largest Discounts**: if `couponRestaurantList.isNotEmpty` → `titleView` + `OfferView` (22% height PageView)
   - **Featured & Trending**: if `newArrivalRestaurantList.length >= 3` → `NewArrival` (28% height horizontal ListView, max 10). List contains only open restaurants.
   - **Stories**: if storyList not empty + enabled → `StoryView` (180px horizontal)
   - **Advertisements**: if ads enabled + list not empty → horizontal cards (220px)

2. **Empty state banner**: if `openRestaurantList.isEmpty && closedRestaurantList.isNotEmpty` → compact warning banner (schedule icon + text + count)

3. **Restaurants Delivering Now**: if `openRestaurantList.isNotEmpty` → `_sectionHeader` + `AllRestaurant(isMuted: false)`

4. **Opening Soon / Currently Unavailable**: if `closedRestaurantList.isNotEmpty` → `_sectionHeader(subtitle: "Sorted by nearest opening time")` + `AllRestaurant(isMuted: true)`

### Helper Methods
- `_sectionHeader(isDark, title, count, {subtitle?})` — Padding(16,24,16,12) → Column with Row(title + count) + optional subtitle
- `titleView(isDark, title, onTap)` — Row with title + "View all" link
- `_buildShimmerSkeleton()` — loading placeholder

### Cart Count Badge
- Theme 1 uses a manual `Stack` badge over the 48x48 cart button for exact positioning.
- Badge color: `AppThemeData.cartBadge` (#E11D48), white text, 18px minimum size, white/dark border for contrast.
- Avoid `badges.Badge` package defaults for this home cart count because default offsets can look misaligned.
- Theme 2 cart count should use the same red `cartBadge` token when present.

### FAB (Floating Toolbar)
Pill-shaped bar at bottom center with: List/Map toggle, QR scan, Order type dropdown (Delivery/TakeAway).

## Theme 2 Parity Notes

`lib/app/home_screen/home_screen_two.dart` has its own header/cart UI. When cart count behavior, profile tab index, or shared home navigation behavior changes in theme 1, check theme 2 as well.

## File: `lib/controllers/home_controller.dart`

### Key Observable State
- `isLoading`, `isListView`, `selectedOrderTypeValue`
- `allNearestRestaurant` — full unfiltered list (sorted: open first, then by rating)
- `filteredAllList` — after applying filter chips
- `openRestaurantList` — open restaurants from filteredAllList
- `closedRestaurantList` — closed restaurants, sorted by nearest opening time (nulls last)
- `newArrivalRestaurantList` — **open restaurants only**, sorted by hybrid score (70% rating + 30% recency, 30-day decay)
- `selectedFilters` — RxSet<String>
- `favouriteList` — RxList<FavouriteModel>
- `couponRestaurantList`, `couponList` — matched vendor/coupon pairs
- `vendorCategoryModel`, `bannerModel`, `storyList`, `advertisementList`

### Filter Keys (static const)
`['Nearest', 'Rating 4.0+', 'Free Delivery', 'Offers']`

### Data Flow
1. `getData()` → `_listenForRestaurants()` (Firestore stream)
2. Sort by open status + rating → `allNearestRestaurant`
3. Compute `newArrivalRestaurantList` (hybrid score sort)
4. `_applyFilters()` → `filteredAllList` → `_splitByStatus()`
5. `_splitByStatus()`: partition into open/closed, sort closed by `getNextOpeningDateTime()`
6. Parallel: `_fetchCoupons()`, `_fetchStories()`, `_fetchAds()`

## Widget Files (`lib/app/home_screen/widgets/`)

| File | Widget | Height | Type |
|------|--------|--------|------|
| `all_restaurant.dart` | AllRestaurant | dynamic | SliverList.builder wrapping RestaurantCard |
| `category_view.dart` | CategoryView | 100px | Horizontal ListView, 64x64 circular images |
| `banner_view.dart` | BannerView | 150px | PageView with dot indicators |
| `offer_view.dart` | OfferView | 22% screen | PageView (viewportFraction: 0.88) |
| `new_arrival.dart` | NewArrival | 28% screen | Horizontal ListView (72% width cards) |
| `story_view_widget.dart` | StoryView | 180px | Horizontal ListView (134px wide) |
| `advertisement_home_card.dart` | AdvertisementHomeCard | 220px | Card with image/video + info |
| `map_view.dart` | MapView | full | Google Maps/OSM with markers |
