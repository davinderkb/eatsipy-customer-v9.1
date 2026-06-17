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

**Warning (Yellow/Amber)**
- warning300: #FFCB39

**Success (Green — separate from primary)**
- success400: #10B271
- lightGreen: #EFF9EB
- darkGreen: #3F8826

**Secondary**
- secondary50, secondary300, secondary600 (blue tones)

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
