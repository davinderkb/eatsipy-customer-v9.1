# RestaurantCard Widget

## File: `lib/widget/restaurant_card.dart`

Shared reusable restaurant card used across home screen, search, category, restaurant list, and favourite screens.

### Parameters
| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| vendorModel | VendorModel | required | Restaurant data |
| isMuted | bool | false | 35% desat + 0.85 opacity for "Opening Soon" section |
| onTap | VoidCallback? | navigate to RestaurantDetailsScreen | Card tap action |
| favouriteList | RxList<FavouriteModel>? | null | If provided, shows favourite toggle button |
| onFavouriteRemoved | VoidCallback? | null | Extra callback after unfavouriting |
| offerText | String? | null | If provided, shows offer badge on image |

### Visual States (3)
| State | Condition | Image Filter | Closed Pill | Opens at | Badges | Opacity |
|-------|-----------|-------------|-------------|----------|--------|---------|
| Open | `!isMuted && isOpen` | None | No | No | Yes | 1.0 |
| Closed (mixed) | `!isMuted && !isOpen` | desatLight (25%) | Yes | Yes | No | 1.0 |
| Muted (unavailable section) | `isMuted` | desatMuted (35%) | No | Yes | No | 0.85 |

### Card Structure
```
Container(shadowSm, radius16, theme-aware bg)
  ClipRRect(top corners radius16)
    SizedBox(height: restaurantImageHeight=200, width: infinity)
      Stack:
        ColorFiltered(desatLight/desatMuted/transparent) → RestaurantImageView
        if closedPill: Positioned(top-left) "Closed" badge (grey900@0.75, radius8)
        if favouriteList: Positioned(top-right) heart button in dark circle 36x36
        if offerText & open: Positioned(top-left) offer badge (primary300, radius8)
        if freeDelivery & open: Positioned(bottom-left) "Free Delivery" badge
  Padding(16)
    Column:
      Title (16px, w700)
      Category text (13px, w400, if available)
      SizedBox(8)
      Row: star + rating + dot + distance icon + distance
      SizedBox(height: 16) — ALWAYS reserved for layout symmetry:
        if !isOpen: "Opens in 15 mins" / "Opens at 8 PM" / etc. (12px, danger300)
        if isOpen: SizedBox.shrink() (empty placeholder)
```

### Recommended Image Sizes
| Usage | Display Size | Recommended Source | Aspect Ratio |
|-------|-------------|-------------------|--------------|
| RestaurantCard image | 200px × full width (~375dp) | **1280 × 720px** | 16:9 |
| Featured & Trending | 72% width × ~60% container | **1080 × 720px** | 3:2 |
| Category icon | 64 × 64dp | **256 × 256px** | 1:1 (square) |

All images use `BoxFit.cover` — slightly oversized is better than undersized. Source images should be JPEG/WebP at 70-85% quality.

### Opening Time Display Logic
Method: `Constant.getNextOpeningTime(vendor, now)` in `lib/constant/constant.dart`

| Condition | Output |
|-----------|--------|
| No opening in 7 days | "Opens next week" |
| Within 60 minutes | "Opens in N mins" |
| Later today | "Opens at 8:00 PM" |
| Tomorrow | "Opens tomorrow" |
| Within 7 days | "Opens Friday" |
| Beyond 7 days | "Opens next week" |

Companion method `Constant.getNextOpeningDateTime(vendor, now)` returns `DateTime?` for sorting.

### Screens Using RestaurantCard
| Screen | File | favouriteList | offerText | Special onTap |
|--------|------|--------------|-----------|---------------|
| Home (AllRestaurant) | `widgets/all_restaurant.dart` | controller.favouriteList | from couponList | refresh favourites on return |
| Search | `search_screen/search_screen.dart` | null | null | simple navigation |
| Restaurant List | `home_screen/restaurant_list_screen.dart` | controller.favouriteList | null | refresh favourites on return |
| Category | `home_screen/category_restaurant_screen.dart` | null | null | simple navigation |
| Favourites | `favourite_screens/favourite_screen.dart` | controller.favouriteList | null | zone check + onFavouriteRemoved |

### Restaurant Detail Navigation Contract
- Card taps pass the available `VendorModel` immediately: `Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel})`.
- Do not prefetch menu/products before navigating from cards. The detail screen is responsible for staged loading.
- `RestaurantDetailsScreen` must render the basic text header immediately from the passed model, then load menu/categories with skeleton and retry states.
- Detail screen category navigation is a floating bottom-right Menu pill + draggable sheet, not an inline horizontal chip row.
- Detail screen menu search is local/indexed after menu load; do not query Firebase per keystroke. Search mode hides the floating Menu navigator/cart strip, keeps results keyboard-aware, and avoids scroll animation on every typed character.
- Detail screen item cards use faded two-line descriptions. Product image taps open the existing product detail bottom sheet with larger image and full description.
- Menu items without photos must keep the same left text width and right ADD/quantity action slot as photo items; only omit the image surface.
- If adding new card-sourced metadata such as offer text, keep it optional and do not change Firestore/vendor models unless explicitly required.

### Vendor Working Hours Model
```
vendorModel.workingHours: List<WorkingHours>?
  WorkingHours: { day: String ("Monday"), timeslot: List<Timeslot>? }
  Timeslot: { from: String ("09:00"), to: String ("22:00") }
```

Status check: `Constant.statusCheckOpenORClose(vendorModel:)` — checks if current time falls within any timeslot for today's day name.
