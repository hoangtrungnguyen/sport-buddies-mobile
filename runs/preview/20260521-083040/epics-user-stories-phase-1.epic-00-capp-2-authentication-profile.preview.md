# Epic [0]: CAPP-2: Authentication & Profile

- ref_key: `epic:0`
- type_id: `(none — type missing)`

## Description

  Player identity. Logic lives in `spb_core`; UI in `apps/customer`.
  
  ```
  graph TD
      CAPP2["<b>CAPP-2</b><br/>Authentication & Profile"]
      CAPP4["<b>CAPP-4</b><br/>Court Discovery"]
      CAPP5["<b>CAPP-5</b><br/>Court Detail & Booking"]
      CAPP5A["<b>CAPP-5A</b><br/>Recurring Bookings"]
      CAPP6["<b>CAPP-6</b><br/>My Bookings"]
      CAPP10["<b>CAPP-10</b><br/>Player Notifications"]
  
      CAPP2 -->|session required| CAPP4
      CAPP4 -->|map → court detail| CAPP5
      CAPP4 -.->|CAPP-054 join slot uses slot list| CAPP6
      CAPP5 -->|entry from court detail 07| CAPP5A
      CAPP5 -->|bookings & confirmed status| CAPP6
      CAPP5A -->|series rows in list| CAPP6
      CAPP5 -.->|booking status events| CAPP10
      CAPP6 -.->|deep-link target| CAPP10
  
      classDef critical fill:#ffe9c2,stroke:#c2691a,stroke-width:3px,color:#000
      classDef parallel fill:#e3f0ff,stroke:#1a66c2,stroke-width:2px,color:#000
      classDef cross fill:#f0e6ff,stroke:#6633b3,stroke-width:2px,color:#000
  
      class CAPP2,CAPP4,CAPP5,CAPP6 critical
      class CAPP5A parallel
      class CAPP10 cross
  
  ```

## Stories

### Story [0.0]: CAPP-010 — Email + password signup & login `M`
- ref_key: `story:0.0`
- type_id: `(none — type missing)`

  > ⚙ **Rewritten:** Phone OTP → Email + password (verification email via Resend, forgot-password flow)
  
  As a player, I want to sign up and log in with my email address and a password so I have a stable account I can recover.

Tasks:
- (0.0.0) Build sign-up and login screens
- (0.0.1) Wire Supabase Auth (`signUp` + `signInWithPassword`) with Resend verification email
- (0.0.2) Implement forgot-password flow via Resend
- (0.0.3) Configure session persistence (`persistSession: true` via `shared_preferences`)
- (0.0.4) Add resend-verification link with rate limit

### Story [0.1]: CAPP-011 — Google OAuth login `M`
- ref_key: `story:0.1`
- type_id: `(none — type missing)`

  As a player, I want to log in with my Gmail account so I don't have to remember a password.

Tasks:
- (0.1.0) Integrate Supabase OAuth flow with Google provider
- (0.1.1) Implement user creation / merge logic in `users` table
- (0.1.2) Wire redirect back to map screen

### Story [0.2]: CAPP-012 — Profile view & edit `S`
- ref_key: `story:0.2`
- type_id: `(none — type missing)`

  As a player, I want to see and update my name and avatar so courts know who I am.

Tasks:
- (0.2.0) Build profile screen with `full_name`, `phone`, `avatar_url` fields
- (0.2.1) Implement `full_name` edit
- (0.2.2) Implement avatar upload to Supabase Storage

### Story [0.3]: CAPP-014 — Language selection `S`
- ref_key: `story:0.3`
- type_id: `(none — type missing)`

  As a player, I want to switch the app language between Vietnamese and English so I can use it comfortably.

Tasks:
- (0.3.0) Add `flutter_localizations` (SDK) and `intl` packages
- (0.3.1) Create ARB files: `lib/l10n/app_vi.arb` (default) + `lib/l10n/app_en.arb`
- (0.3.2) Wire `MaterialApp.localizationsDelegates` to `AppLocalizations.delegates`
- (0.3.3) Build language picker UI in profile screen
- (0.3.4) Persist selection to `shared_preferences` (`locale` key)
