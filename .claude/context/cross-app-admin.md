# Cross-App Changes — Admin Panel

Changes made in the customer app that require corresponding updates in the admin panel.

| # | Change | Reason | Priority | Date |
|---|--------|--------|----------|------|
| 1 | **Remove `takeawayOption` field from product add/edit forms** | Customer app no longer filters by this — all published products are shown. Field is dead weight in the UI. | Medium | 2026-06-17 |
| 2 | **Consider removing `takeawayOption` from Firestore product schema** | No app reads it. Phased removal: stop writing first, then clean existing docs. | Low | 2026-06-17 |
| 3 | **Validate `workingHours` is properly set for all vendors** | Customer app displays smart opening time ("Opens in 15 mins", "Opens tomorrow") and sorts closed restaurants by nearest opening time. Missing hours → permanent "Opens next week". | High | 2026-06-17 |
| 4 | **Enforce recommended image sizes for restaurant uploads** | Customer cards: **1280×720px** (16:9). Category icons: **256×256px** square. JPEG/WebP 70-85% quality. | Medium | 2026-06-17 |
| 5 | **Font consolidation: single `Urbanist` family** | Customer app moved from `Urbanist-Bold`, `Urbanist-SemiBold` etc. to single `Urbanist` family with `fontWeight` variants in pubspec.yaml. Admin panel should match if it's Flutter-based. | Low | 2026-06-17 |
| 6 | **`withOpacity()` → `withValues(alpha:)` deprecation** | Flutter deprecated `withOpacity()`. Customer app migrated all calls. Admin panel likely has same warnings. | Low | 2026-06-17 |
| 7 | **Add `is_cover_image_approved` toggle on vendor detail page** | Admin must approve restaurant cover images before they show on customer cards. Boolean toggle on the vendor management screen. | High | 2026-06-17 |
| 8 | **Add `cover_image_url` upload field on vendor detail page** | Admin uploads/approves a specific cover image separate from gallery photos. **Required size: 1280×720px (16:9 landscape), JPEG/WebP 70-85% quality.** | High | 2026-06-17 |
| 9 | **Add `show_card_showcase` toggle on vendor detail page** | Admin enables/disables the food showcase slider per restaurant. | High | 2026-06-17 |
| 10 | **Add `card_showcase_items` management UI on vendor detail page** | Admin can add/edit/remove up to 5 showcase items per vendor: product picker + image + name + price + display_order + is_active toggle. Data is denormalized from products collection onto the vendor document. Fields per item: `product_id`, `name`, `price`, `image_url`, `display_order`, `is_active`. **Showcase food images: 1280×720px (16:9 landscape), JPEG/WebP 70-85% quality.** | High | 2026-06-17 |
| 11 | **Showcase item sync: keep `card_showcase_items` updated when source product changes** | Since items are denormalized, admin panel needs a mechanism (Cloud Function or manual sync button) to update showcase items when the source product's price, name, or photo changes. | Medium | 2026-06-17 |
| 12 | **Add `settings/category_stock_images` management page** | New Firestore document `settings/category_stock_images` stores curated food stock photos per cuisine category (map of category keyword → list of image URLs). Admin needs UI to upload photos to Firebase Storage and manage the URL lists. Categories: pizza, indian, chinese, burger, default, etc. Minimum 3-5 images per category. **Stock photos: 1280×720px (16:9 landscape), JPEG/WebP 70-85% quality.** | High | 2026-06-17 |
