# Cross-App Changes — Restaurant App

Changes made in the customer app that require corresponding updates in the restaurant app.

| # | Change | Reason | Priority | Date |
|---|--------|--------|----------|------|
| 1 | **Remove `takeawayOption` toggle from product add/edit** | Customer app ignores this field. Toggle is misleading to restaurant owners. | Medium | 2026-06-17 |
| 2 | **Ensure `workingHours` management is prominent** | Accurate hours now directly affect customer-facing display and sort order. Restaurants with missing hours appear last with "Opens next week". | High | 2026-06-17 |
| 3 | **Simplify product query — remove `takeawayOption` filter** | If restaurant app has a product listing view using the same `getProductByVendorId` pattern with `takeawayOption` filter, it will also return 0 results for products missing the field. Remove the filter. | High | 2026-06-17 |
| 4 | **Font consolidation: single `Urbanist` family with weight variants** | Customer app consolidated from per-weight families (`Urbanist-Bold`, `Urbanist-SemiBold`) to single `Urbanist` family with `fontWeight` variants. Update `pubspec.yaml` fonts section + all `fontFamily` references. | Low | 2026-06-17 |
| 5 | **Theme detection: `Theme.of(context).brightness` replaces `Provider.of<DarkThemeProvider>`** | Customer app removed DarkThemeProvider dependency. Simpler, no Provider import needed. | Low | 2026-06-17 |
| 6 | **`withOpacity()` → `withValues(alpha:)` deprecation** | Flutter deprecated `withOpacity()`. Migrate all calls to `withValues(alpha:)`. | Low | 2026-06-17 |
| 7 | **Category cache in `fire_store_utils.dart`** | Customer app added `_categoryCache` static map to avoid redundant Firestore reads for vendor categories. Same optimization applies if restaurant app fetches categories repeatedly. | Low | 2026-06-17 |
| 8 | **`NestedScrollView` body scroll bug** | If any screen uses `SingleChildScrollView(physics: NeverScrollableScrollPhysics())` inside `NestedScrollView.body`, content below the fold is unreachable. Remove the `NeverScrollableScrollPhysics`. | Medium | 2026-06-17 |
| 9 | **Display cover image approval status on restaurant dashboard** | Restaurant owners should see whether their cover image has been approved by admin (`is_cover_image_approved` field). Read-only status indicator on the dashboard. | Medium | 2026-06-17 |
| 10 | **Cover image upload with quality guidelines** | Restaurant app may allow owners to upload candidate cover images. **Required size: 1280×720px (16:9 landscape), JPEG/WebP 70-85% quality, food-focused, well-lit.** Admin then approves via the admin panel. Image stored at `cover_image_url` on vendor document. | Medium | 2026-06-17 |
