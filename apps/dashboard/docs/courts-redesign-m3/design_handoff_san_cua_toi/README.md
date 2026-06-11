# Handoff: Sân của tôi (My Courts) — Material 3 redesign with AI-assisted data entry

**Target:** SnB Owner Dashboard (Flutter Web) · **Design system:** Material 3, seed `#16A34A`

## Overview
`Sân của tôi` is the court-management section of the owner dashboard. It replaces the old screens (plain form + a small "text-to-JSON" textarea bottom sheet) with a full **Material 3** redesign and a first-class **AI-assisted data entry** experience. Three sub-screens:

1. **My courts** (`/courts`) — all courts (facilities) of this owner, as M3 cards with photo, status, venue count and sport chips.
2. **Court form** (`/courts/new`, `/courts/:id/edit`) — create/edit one court: identity, location, description, amenities, operating hours, photos, plus quick-add of venues.
3. **Venues form** (`/courts/:id/venues`) — manage the venues (playing surfaces) inside a court: list grouped by sport, add/edit dialog, and AI bulk creation.

AI entry works in every flow: the owner pastes free text / a Maps link / a flyer photo (or chats with an assistant), the model extracts structured data, the owner **reviews it row-by-row before anything touches the form**, and AI-filled fields stay visibly marked until manually edited.

---

## Terminology
This prototype uses the **correct** domain words (unlike the older Lịch sân reference):

| Term | Meaning | In code |
|---|---|---|
| **Court** | The business / physical facility. e.g. *SnB Đại Lộc*. | `courts`, `CourtFormScreen` |
| **Venue** | One playing surface inside a court. e.g. *Sân 1 (pickleball)*. | `venues`, `VenueDialog` |

Use `Court` / `Venue` in Flutter models exactly like this.

## About the Design Files
Files in `reference/` are a **design reference built in HTML + React (in-browser Babel)** — a working prototype of the intended look and behaviour, including real LLM calls. **They are not production code to port.** Recreate the screens natively in the existing Flutter web app with its established conventions: **BLoC** for state, **Freezed** models, a **service layer**, and **abstract repositories** with injected implementations.

Open `San cua toi (M3).html` in a browser to use the live prototype. Its **Tweaks panel** switches between the three flow variants (A/B/C), the three AI-entry presentations (bottom sheet / side sheet / inline card), and outlined vs filled text fields.

## Fidelity
**High-fidelity** for layout, components, color roles, type roles and interaction. One deliberate difference from pixel-perfection: the prototype hand-implements Material 3, while **Flutter should use real M3 widgets** (`useMaterial3: true`) and let them carry their own metrics. Match the **token values and component choices** in this document; do not replicate the prototype's CSS px-by-px where an equivalent M3 widget exists.

---

## Material 3 theme

### Color scheme (light)
Built from seed `#16A34A` (SnB brand green) but with the brand color **forced** as `primary` (a plain `ColorScheme.fromSeed` would shift it). Exact roles used by the design:

| Role | Hex | | Role | Hex |
|---|---|---|---|---|
| primary | `#16A34A` | | surface | `#F8FAF2` |
| onPrimary | `#FFFFFF` | | surfaceContainerLowest | `#FFFFFF` |
| primaryContainer | `#DCFCE7` | | surfaceContainerLow | `#F2F5EC` |
| onPrimaryContainer | `#14532D` | | surfaceContainer | `#ECEFE6` |
| secondary | `#52634F` | | surfaceContainerHigh | `#E6E9E1` |
| secondaryContainer | `#D5E8CE` | | surfaceContainerHighest | `#E1E4DB` |
| onSecondaryContainer | `#101F0F` | | onSurface | `#191D17` |
| tertiary | `#0E6F9E` | | onSurfaceVariant | `#43483F` |
| tertiaryContainer | `#CBE6FF` | | outline | `#73796E` |
| onTertiaryContainer | `#001E30` | | outlineVariant | `#C3C8BC` |
| error | `#BA1A1A` | | inverseSurface | `#2E322B` |
| errorContainer | `#FFDAD6` | | inverseOnSurface | `#EFF2E9` |
| onErrorContainer | `#410002` | | inversePrimary | `#4ADE80` |
| *custom* warnContainer | `#FEF3C0` | | *custom* onWarnContainer | `#574500` |

```dart
final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)).copyWith(
  primary: const Color(0xFF16A34A),
  primaryContainer: const Color(0xFFDCFCE7),
  onPrimaryContainer: const Color(0xFF14532D),
  // …override remaining roles from the table above
);
final theme = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: 'Roboto');
```
`warnContainer/onWarnContainer` (the "Chờ duyệt" pending chip) are custom roles — add as a `ThemeExtension`.

### Semantic color conventions in this design
- **Primary** = actions (filled buttons, FAB container, checked review rows, focused field borders).
- **SecondaryContainer** = *selection* (selected filter chips, segmented button active, nav active indicator, venue icon tiles).
- **Tertiary** = *AI provenance*. Everything the AI wrote is marked in tertiary: the "✦ Điền bởi AI" supporting text, the live-fill notice in chat, the AI-fill pulse highlight (`tertiaryContainer`). Never use tertiary for ordinary UI.
- **PrimaryContainer→tertiaryContainer 135° gradient** = the AI "spark" avatar tiles (40px, radius 12; 64px, radius 20 on the intake hero).
- Status chips: active → `primaryContainer`/`onPrimaryContainer` + filled `check_circle`; pending → warnContainer + `hourglass_top`; draft → `surfaceContainerHighest` + `edit_note`. 26px tall, radius 8, 12px/500 text, icon 14px, never wraps.

### Typography
**Roboto** (M3 default; full Vietnamese support) — only family in the UI. Placeholder/mono accents: Roboto Mono. M3 type scale as-is; roles used:

| Usage | Role | Spec |
|---|---|---|
| Screen titles ("Sân của tôi") | headlineMedium | 28/36, w400 |
| Top app bar title, intake hero | titleLarge / headlineMedium | 22/28 w400 · 28/36 |
| Dialog titles | headlineSmall | 24/32, w400 |
| Section heads, card names | titleMedium | 16/24, w500 |
| Field labels (floated), chips, buttons | labelLarge | 14/20, w500 |
| Body, supporting copy | bodyMedium | 14/20 |
| Helper/meta ("Điền bởi AI…") | bodySmall | 12/16 |

### Shape & elevation
M3 defaults: extra-small 4 (text fields, snackbar) · small 8 (chips) · medium 12 (cards) · large 16 (FAB, inline AI card, side sheet) · extra-large 28 (dialogs, bottom sheet top corners) · full (buttons, nav indicator). Elevation: level 1 on cards, level 2 sheets/FAB, level 3 dialogs.

### Icons
**Material Symbols Rounded** (variable; FILL 0 default, FILL 1 for active nav / status check). Key glyphs: `auto_awesome` (everything AI), `stadium`, `grid_view` (venues), `location_on`, `badge`, `description`, `category`, `schedule`, `photo_library`, `call`, `map`, `notes`, `link`, `photo_camera`, `forum`, `fact_check`, `document_scanner`, `travel_explore`, `roofing` (indoor), `sunny` (outdoor), `check_circle`, `hourglass_top`, `edit_note`, `send`, `playlist_add`, `wb_twilight` / `bedtime` (open/close hours). In Flutter use `material_symbols_icons` (Rounded set).

---

## Screens

### Shell
- **M3 Navigation drawer (standard, always visible)** — 280px, `surfaceContainerLow`. Brand row (44px radius-12 primary tile "S" + name + "Chủ sân · Quận 7"); section labels "QUẢN LÝ" / "HỆ THỐNG" (11px/500, +0.8 tracking, uppercase); items = 56px full-pill rows, active = `secondaryContainer` + filled icon; trailing badge counts as plain `labelLarge` numbers. Footer: owner row (40px circle avatar in `tertiaryContainer`) + trial card (`primaryContainer`, radius 16: "Gói miễn phí 3 tháng / Hết hạn 04/08/2026 · Nâng cấp"). In Flutter this shell likely exists — restyle to M3 `NavigationDrawer`, don't rebuild.
- **Top app bar (small, 64px)** — back arrow on sub-screens, title 22/400, trailing `search` + `notifications` icon buttons. On the court form (variant A only) a **tonal button "Nhập nhanh bằng AI"** with `auto_awesome` sits before the icons — the single AI entry point.
- Content column max-width **920px**, centered, 32px side padding, 120px bottom padding.

### 1) My courts
- Header row: headlineMedium title + subtitle "`N` cụm sân · `M` sân con" + **FilledButton "Thêm sân mới"** (icon `add`).
- **Card grid**: `repeat(auto-fill, minmax(280px, 1fr))`, 16px gap. Each card = M3 **elevated card** (radius 12, surfaceContainerLowest, level 1; hover → level 2):
  - 140px photo area (placeholder: 45° stripes of surfaceContainer/surfaceContainerHigh + `stadium` icon + mono caption — replace with real court photo). Status chip overlaid top-left (12px inset, elevation 1).
  - Body (14–16px padding): name (titleMedium) · address row (`location_on` 16px + bodyMedium onSurfaceVariant) · chip row: small outlined chip "`N` sân con" (icon `grid_view`) + one small **selected** chip per distinct sport (Pickleball, Cầu lông…). Small chips: 26px, radius 7, 12px text.
  - Action row: TextButtons **Sửa** (`edit`) and **Sân con** (`grid_view`), kebab `more_vert` right-aligned.
- Card tap → edit form; "Sân con" → venues screen (stop propagation).
- Last grid cell = **add card**: outlined card, centered 52px radius-16 `primaryContainer` tile with `add`, "Thêm sân mới" + caption "Nhập tay hoặc để AI điền giúp từ văn bản, liên kết, ảnh".

### 2) Court form
Single scrolling page of **sections** (no card per section — flat on surface). Section head: 22px primary icon + titleMedium + bodySmall subtitle, 20px top / 14px bottom padding. Two-column rows via grid `1fr 1fr`, 16px gap (stack < 900px).

| Section | Icon | Fields |
|---|---|---|
| Thông tin cơ bản | `badge` | Tên sân* · Số điện thoại (leading `call`) |
| Vị trí | `location_on` | Địa chỉ* · Vĩ độ (lat) + Kinh độ (lng) (one row) · Google Maps URL (leading `map`) |
| Mô tả | `description` | 3-row textarea + assist chip **"Viết mô tả bằng AI"** / "Viết lại bằng AI" (spinner + "AI đang viết…" while busy) |
| Tiện ích | `category` | 8 **FilterChips**: Bãi đậu xe `local_parking`, Phòng thay đồ `checkroom`, Nhà vệ sinh `wc`, Căng tin `storefront`, Thuê thiết bị `sports_tennis`, WiFi `wifi`, Đèn chiếu sáng `lightbulb`, Mái che `roofing` |
| Giờ hoạt động | `schedule` | Mở cửa + Đóng cửa dropdowns (05:00–23:30, 30-min steps), leading `wb_twilight` / `bedtime`, max-width 480 |
| Ảnh sân | `photo_library` | photo placeholders 92px radius-12 + dashed "Thêm ảnh" tile (4-col grid) |
| Sân con (N) | `grid_view` | compact venue list (36px icon tile, name, sport · indoor/outdoor, price, remove ✕) + assist chips **"Thêm sân con"** and **"Tạo nhanh bằng AI"** |

- **Text fields**: M3 `TextFormField`, **outlined** by default (filled is a theme toggle — both must work). 56px min height, floating label, supporting text line below. Required-empty on submit → error state + supporting "Bắt buộc — nhập tên sân/địa chỉ".
- **AI-filled state** (custom): after AI fills a field — supporting text swaps to tertiary "✦ Điền bởi AI — hãy kiểm tra lại" (`auto_awesome` 14px) and the container flashes `tertiaryContainer` (~1.6s ease-out). **Any manual edit clears the mark for that field.** Non-field targets get a tertiary helper line instead (amenities, hours).
- **Sticky footer** (sticky bottom, surface gradient fade): TextButton **Huỷ** · OutlinedButton **Lưu nháp** · FilledButton **Tạo sân** / **Lưu thay đổi** (icon `check`). Validation: name + address required; failure also snackbars "Còn trường bắt buộc chưa điền".
- Saving a new court → status `pending` ("Chờ duyệt", SpB team approves); "Lưu nháp" → `draft`. Snackbar: "Đã tạo `name` — chờ SnB duyệt".

### 3) Venues form
- Header: headlineMedium "Sân con · `court name`" + "`N` sân · mở cửa `open`–`close`"; actions: tonal **"Tạo nhanh bằng AI"** (`auto_awesome`) + filled **"Thêm sân con"** (`add`).
- **List grouped by sport.** Group label: 18px sport icon + "`Sport` · `n` sân" (titleSmall, onSurfaceVariant). Group body = outlined card (surfaceContainerLowest) of rows divided by `outlineVariant` hairlines (inset 16px):
  - Row: 44px radius-12 `secondaryContainer` tile (`roofing` indoor / `sunny` outdoor) · name (15/500) + "Trong nhà/Ngoài trời · sport" (12.5 onSurfaceVariant) · right-aligned price "`120.000đ` / mỗi giờ" · icon buttons `edit`, `delete`. Hover row → surfaceContainer.
- Delete → snackbar with **Hoàn tác** (undo restores).
- Empty state: centered `grid_view` icon, "Chưa có sân con nào", "Thêm từng sân, hoặc mô tả tất cả trong một câu để AI tạo giúp."
- **Add/edit dialog** — M3 dialog (radius 28, surfaceContainerHigh, hero icon `sports_tennis` centered): Tên sân con · row [Môn thể thao dropdown (pickleball/badminton/football/tennis) + Giá/giờ number (supporting = live-formatted "120.000đ/giờ")] · **SegmentedButton** Trong nhà `roofing` / Ngoài trời `sunny`. Actions: Huỷ (text) / Lưu (filled, disabled until name).
- **Bulk AI sheet** — bottom sheet (see AI section): textarea → AI splits into venues → review rows (checkbox · name · sport · indoor · price) → FilledButton "Tạo `N` sân con" (`playlist_add`) → snackbar "Đã tạo N sân con bằng AI".

---

## AI-assisted entry

### The assist panel (shared component)
Header: spark tile + "Nhập nhanh bằng AI" + "Dán văn bản, liên kết hoặc ảnh — AI điền form, bạn duyệt lại". **4 tabs** (M3 primary tabs, 2.5px primary underline): 

1. **Văn bản** `notes` — large textarea (radius 12, outlined; placeholder shows a realistic example), hint "Mẹo: dán nguyên bài đăng Facebook, tin Zalo hoặc ghi chú…", full-width FilledButton **"Phân tích bằng AI"** (disabled while empty).
2. **Liên kết** `link` — one URL field (leading `link`, supporting "Toạ độ và tên địa điểm được đọc trực tiếp từ liên kết") + **"Đọc liên kết"** (`travel_explore`). Lat/lng/name are parsed **client-side** from the URL (regexes: `@lat,lng`, `?q=lat,lng`, `!3d…!4d…`, `/place/<name>`), then merged over an LLM pass on the URL text. Client-side parse wins on conflict.
3. **Ảnh** `photo_camera` — dashed drop/upload tile + **"Đọc ảnh"** (`document_scanner`). *Prototype simulates the OCR result; production = vision model (image + same JSON instruction).* 
4. **Hỏi đáp** `forum` — chat assistant (below).

**Phases:** `input → loading → review`. Loading = centered spinner + "AI đang phân tích…" + caption + indeterminate linear bar. Errors return to input with an `errorContainer` banner ("AI không trả về JSON hợp lệ" / network).

### The review step (the core UX contract)
**Nothing is written into the form without review.** Review screen: `fact_check` + "Kiểm tra trước khi điền", copy "Bỏ chọn những dòng không đúng — chỉ các dòng được chọn sẽ điền vào form." Then a bordered list (radius 12, hairline rows): 22px checkbox (checked = primary) · field label (110px, labelSmall) · extracted value. Unchecked rows dim to 40% + strikethrough. Rows render only for non-empty extractions; amenities show as labels joined by "·"; venues as "`N` sân: Sân 1 (Pickleball · 120.000đ/giờ), …". Footer: text "Sửa lại" (back) + filled **"Điền vào form"** (`auto_awesome`).

Applying merges checked keys into the form, marks them AI-filled, snackbars "AI đã điền `k` trường — các trường được đánh dấu ✦".

### Extraction contract (production)
One prompt per source; the model must return **only JSON**:

```json
{
  "name": "string|null", "address": "string|null",
  "lat": 10.762622, "lng": 106.660172,
  "mapsUrl": "string|null", "phone": "string|null",
  "description": "string|null",
  "openTime": "HH:MM", "closeTime": "HH:MM",
  "amenities": ["parking","locker","toilet","canteen","equipment","wifi","lights","roof"],
  "venues": [{"name": "Sân 1", "sport": "pickleball|badminton|football|tennis", "price": 120000, "indoor": true}]
}
```
Rules baked into the prompt (keep them): missing → `null`; "120k" → `120000`; "6h" → `"06:00"`; "4 sân pickleball giá 120k" → four numbered venue objects. Parse defensively: take the first `{`…last `}`, `json.decode` in try/catch; invalid → user-facing retry error, never a crash. Venue-only extraction (bulk sheet) uses a reduced schema `{"venues":[…]}`. Exact prompt text (Vietnamese): `reference/courts-ai.jsx` → `aiExtractCourt`, `aiExtractVenues`, `aiWriteDescription`, `CHAT_PREAMBLE`.

### Inline per-field AI
"Viết mô tả bằng AI" assist chip → prompt composed from current form values (name, address, hours, amenities, venues) asking for 2–3 friendly Vietnamese sentences, no emoji, no hyperbole → fills Mô tả + AI mark. Failure → snackbar "Không gọi được AI — thử lại nhé".

### Chat assistant
Stateful conversation. The preamble instructs the model: ask **one short question at a time** (name+address → hours → amenities → venues), and append to every reply a ```json block with **all data gathered so far** (full schema). The UI strips the JSON block from the visible bubble, parses it, and keeps the latest snapshot. Bubbles: user = `primaryContainer` right-aligned, assistant = `surfaceContainerHigh` left-aligned, radius 16 with a 4px tail corner; "Đang suy nghĩ…" spinner bubble while waiting. Pill input (48px, radius full) + filled `send` icon button. When enough is gathered the model says "Đã đủ thông tin chính — bạn có thể bấm Hoàn tất."; a tonal **"Xem dữ liệu đã thu thập"** button routes into the same review step. In variant C the snapshot **fills the form live** (silently, marks only) after each turn instead.

### Flow variants (pick one to ship; all are in the prototype's Tweaks)
- **A · Form + trợ lý (default)** — "Thêm sân mới" opens the form; AI panel opens on demand from the top-bar tonal button. Presentation sub-options: **bottom sheet** (default; max-width 720, drag handle, radius 28 top), **side sheet** (right, 420px, radius 16 left corners), or **inline card** (collapsible `surfaceContainer` radius-16 card above the form).
- **B · AI nhập trước** — "Thêm sân mới" lands on an **intake screen**: centered hero (64px spark tile, "Thêm sân mới" headline, explainer) + a 640px card holding the same 4-tab panel; "Điền vào form" navigates to the form pre-filled; text escape "Bỏ qua — tự nhập tay" (`keyboard`).
- **C · Chat từng bước** — create-only split layout: 380px chat pane left (surfaceContainerLow, hairline divider) + the form right, filled live each turn, tertiary notice "Form bên phải được điền tự động sau mỗi câu trả lời". Editing an existing court always uses variant A.

---

## State management (BLoC sketch)

```text
MyCourtsBloc      loaded(courts) · CourtSaved/CourtUpdated upsert + snackbar
CourtFormBloc     fields, errors{name,address}, aiFilledKeys: Set<String>,
                  venuesDraft, descBusy
                  events: fieldChanged(k,v)→clears aiFilled[k]+error[k]
                          aiApplied(Map data)→merge non-null keys, mark aiFilled
                          writeDescriptionPressed · submit(draft|publish)
AiAssistBloc      source(text|link|photo|chat) · phase(input|loading|review)
                  result: CourtExtraction? · checked: Map<String,bool>
                  events: analyzeText/Link/Photo · toggleRow(k) · apply → emits
                          AiDataApproved(checked subset) consumed by CourtFormBloc
ChatAssistBloc    messages[] · busy · snapshot: CourtExtraction?
VenuesBloc        court · dialog(venue?) · bulk phase/rows · undo buffer (delete)
```

```dart
@freezed class Court with _$Court { const factory Court({
  required String id, required String name, required String address,
  double? lat, double? lng, String? mapsUrl, String? phone,
  @Default('') String description, @Default([]) List<String> amenities,
  @Default('06:00') String openTime, @Default('22:00') String closeTime,
  @Default(CourtStatus.draft) CourtStatus status,
  @Default([]) List<Venue> venues}) = _Court; }

@freezed class Venue with _$Venue { const factory Venue({
  required String id, required String name, required SportType sport,
  required int pricePerHour, @Default(false) bool indoor}) = _Venue; }

enum CourtStatus { active, pending, draft }
enum SportType { pickleball, badminton, football, tennis }

abstract class CourtRepository {
  Future<List<Court>> getMyCourts();
  Future<Court> createCourt(Court c);     // server sets status=pending
  Future<Court> updateCourt(Court c);
  Future<void> deleteVenue(String courtId, String venueId);
}
abstract class AiIntakeRepository {
  Future<CourtExtraction> extractFromText(String text);
  Future<CourtExtraction> extractFromImage(Uint8List image);   // vision
  Future<List<VenueExtraction>> extractVenues(String text);
  Future<String> writeDescription(Court draft);
  Stream<ChatTurn> chat(List<ChatMessage> history);
}
```
`Bloc → Service → Repository(abstract) ← Impl → DataSource` as elsewhere in the app. LLM calls go through the backend (key security + logging) — never from the client.

## Interactions & micro-behavior
- Sheet/dialog/scrim: scrim `rgba(0,0,0,.45)`, tap-outside dismisses; bottom sheet slides up ~260ms `cubic-bezier(.2,0,0,1)`, side sheet ~240ms from right, dialog scale .96→1 fade ~220ms.
- AI-fill pulse: field container animates `tertiaryContainer → transparent`, 1.6s, once.
- Snackbar: M3 (inverseSurface, radius 4, bottom-center, 4.5s, single action — "Hoàn tác"/"OK").
- Buttons with async work get a 14–16px inline spinner replacing the icon (desc chip, chat send).
- Hover: cards level 1→2; list rows tint `surfaceContainer`; standard M3 state layers (8%/12%) on everything interactive.
- Responsive: drawer → rail-like 84px icons-only < 1100px; form rows stack and chat pane hides < 900px (mobile chat = full-screen step before the form).

## Design tokens (quick sheet)
Colors: table above. Type: Roboto / M3 scale. Radius: 4 / 8 / 12 / 16 / 28 / full. Spacing: 4-grid — section gap 20/14, field gap 16, card pad 14–16, content pad 32, content max 920. Elevation 1/2/3 per M3. Motion: `cubic-bezier(0.2, 0, 0, 1)`, 150ms state / 220–260ms surfaces. VND format: `vi-VN` grouping + `đ` (`120.000đ`).

## Assets
No raster assets. Photos are striped placeholders (45°, surfaceContainer/High, 10px bands) + Roboto Mono caption — swap for real court photos (`image_slot` pattern: first photo = cover). Icons: Material Symbols Rounded (`material_symbols_icons`). Font: Roboto + Roboto Mono (`google_fonts` or bundled, Vietnamese subset).

## Files (in `reference/`)
- `San cua toi (M3).html` — entry point (open in browser; Tweaks panel switches variants).
- `m3.css` — the full hand-built M3 kit: every token + component style. **Source of truth for exact values.**
- `courts-layout.css` — shell, cards, form sections, venue rows, AI panel/review/chat styling.
- `m3-components.jsx` — component primitives (field float-label behavior, dialog/sheet chrome, snackbar host).
- `courts-data.jsx` — amenity/sport catalogs, hour steps, seed courts, review-field metadata. **Best model reference.**
- `courts-ai.jsx` — **all prompts**, JSON parsing, URL parsing regexes, review list, chat assistant, the 4-tab panel state machine.
- `courts-screens.jsx` — My courts grid, venue dialog, bulk-AI sheet, venues screen.
- `courts-form.jsx` — court form body, the three flow variants, intake screen, AI-fill merge/marking logic.
- `courts-app.jsx` — shell, routing, save semantics, tweak wiring. · `tweaks-panel.jsx` — prototype-only harness; do not port.
