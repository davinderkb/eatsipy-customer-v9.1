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
