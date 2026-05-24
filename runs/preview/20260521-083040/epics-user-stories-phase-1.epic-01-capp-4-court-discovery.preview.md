# Epic [1]: CAPP-4: Court Discovery

- ref_key: `epic:1`
- type_id: `(none — type missing)`

## Description

  The map — first screen a player sees when they open the app.

## Stories

### Story [1.0]: CAPP-030 — Map screen `M`
- ref_key: `story:1.0`
- type_id: `(none — type missing)`

  As a player, I want to see a map of nearby courts so I know what's around me.

Tasks:
- (1.0.0) Initialize `vietmap_flutter_gl` with API key (env var `VIETMAP_API_KEY`)
- (1.0.1) Request location permission; implement GPS-based centering with HCMC fallback
- (1.0.2) Query and render approved courts

### Story [1.1]: CAPP-031 — Court availability pins `M`
- ref_key: `story:1.1`
- type_id: `(none — type missing)`

  As a player, I want to see at a glance which courts have open slots so I skip fully booked ones.

Tasks:
- (1.1.0) Implement pin colour logic from `slots` data
- (1.1.1) Wire Supabase Realtime subscription on `slots` table for live pin updates

### Story [1.2]: CAPP-032 — Filter by sport type `M`
- ref_key: `story:1.2`
- type_id: `(none — type missing)`

  > ⚙ **Rewritten:** 3 sports → 5 sports (added Tennis, Đa năng)
  
  As a player, I want to filter by sport so I only see relevant courts.

Tasks:
- (1.2.0) Build sport filter chips
- (1.2.1) Wire re-query with array-overlap operator

### Story [1.3]: CAPP-033 — Filter by distance `S`
- ref_key: `story:1.3`
- type_id: `(none — type missing)`

  As a player, I want to filter courts within X km so I don't see courts far away.

Tasks:
- (1.3.0) Build distance chip selector
- (1.3.1) Implement Haversine distance filter from current location
- (1.3.2) Handle empty state

### Story [1.4]: CAPP-034 — Open slot list tab `S`
- ref_key: `story:1.4`
- type_id: `(none — type missing)`

  As a player looking for a group game, I want a tab listing open slots so I can browse games to join without panning the map.

Tasks:
- (1.4.0) Add second tab on map screen ("Slot trống")
- (1.4.1) Build slot list query and row UI
- (1.4.2) Wire navigation to slot detail

### Story [1.5]: CAPP-035 — Slot fullness indicator `S`
- ref_key: `story:1.5`
- type_id: `(none — type missing)`

  As a player, I want to see remaining spots in a slot so I know if I can still join before requesting.

Tasks:
- (1.5.0) Build slot detail screen
- (1.5.1) Derive participant count from `slot_participants` vs `slots.max_players`
- (1.5.2) Implement "Đã đủ người" badge state
