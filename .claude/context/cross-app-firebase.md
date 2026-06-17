# Cross-App Changes — Firebase / Firestore Schema

Firestore schema changes required by the customer app. This file consolidates all pending field additions, new documents, and Cloud Function requirements.

---

## New Fields on Vendor Document (`vendors/{vendorId}`)

| Field | Type | Default | Purpose | Set By |
|-------|------|---------|---------|--------|
| `is_cover_image_approved` | bool | `false` | Admin approval flag for cover image | Admin panel |
| `cover_image_url` | String | `null` | Approved restaurant cover image URL (1280×720px, 16:9, JPEG/WebP 70-85%) | Admin panel / Restaurant app upload → admin approval |
| `show_card_showcase` | bool | `false` | Enable food showcase slider on customer card | Admin panel |
| `card_showcase_items` | List\<Map\> | `null` | Max 5 denormalized featured dishes for card showcase | Admin panel |

### `card_showcase_items` Array Item Schema

| Field | Type | Required | Purpose |
|-------|------|----------|---------|
| `product_id` | String | Yes | Reference to source product document |
| `name` | String | Yes | Dish name (denormalized from product) |
| `price` | String | Yes | Dish price (denormalized from product) |
| `image_url` | String | Yes | Food image URL (1280×720px, 16:9, JPEG/WebP 70-85%) |
| `display_order` | int | Yes | Sort position (0-based) |
| `is_active` | bool | Yes (default `true`) | Admin can temporarily hide individual items |

---

## New Settings Document (`settings/category_stock_images`)

Stores curated food stock photos per cuisine category. Used as fallback images on restaurant cards when no showcase or cover image is available.

### Schema

Map of lowercase category keyword → list of image URLs:

```json
{
  "pizza": [
    "https://firebasestorage.googleapis.com/.../pizza_1.jpg",
    "https://firebasestorage.googleapis.com/.../pizza_2.jpg",
    "https://firebasestorage.googleapis.com/.../pizza_3.jpg"
  ],
  "indian": ["..."],
  "chinese": ["..."],
  "burger": ["..."],
  "default": ["..."]
}
```

- Minimum 3-5 images per category for variety
- Image size: 1280×720px (16:9 landscape), JPEG/WebP 70-85% quality
- `default` key is required — used when restaurant category doesn't match any specific key
- Customer app loads this once on startup and caches in memory
- Admin panel needs a management UI to upload images to Firebase Storage and maintain the URL lists

---

## Cloud Functions (Recommended)

| Function | Trigger | Purpose | Priority |
|----------|---------|---------|----------|
| `syncShowcaseItems` | `onUpdate` of product document | When a product's name, price, or photo changes, find all vendor documents where `card_showcase_items` contains that `product_id` and update the denormalized fields | Medium |
| `validateCoverImage` | `onUpdate` of vendor document (when `cover_image_url` changes) | Optional: validate image dimensions meet 1280×720 minimum, auto-set `is_cover_image_approved = false` when a new cover is uploaded pending admin review | Low |

---

## Image Size Reference

| Image Type | Display Area | Source Size | Aspect Ratio | Format |
|------------|-------------|-------------|--------------|--------|
| Showcase food items | Card image (200px × full width) | 1280 × 720px | 16:9 landscape | JPEG/WebP 70-85% |
| Cover image | Card image (200px × full width) | 1280 × 720px | 16:9 landscape | JPEG/WebP 70-85% |
| Category stock photos | Card image (200px × full width) | 1280 × 720px | 16:9 landscape | JPEG/WebP 70-85% |
| Category icons | Small circles (64×64dp) | 256 × 256px | 1:1 square | PNG/WebP |

---

## Backward Compatibility

All new vendor fields default to `null` or `false`. Existing vendor documents without these fields will render using the category stock image fallback (tier 4) or the neutral placeholder. No migration of existing documents is required — fields are populated as admin enables features per vendor.
