# CLAUDE.md — Hayya Prayer Companion App

## What is Hayya?
An iOS prayer companion app for Muslims. Tagline: "A gentle companion for your prayers."
Core positioning: personal companion first, shared accountability second.

## Architecture

### Stack
- **Language:** Swift 5.9+
- **UI:** SwiftUI (iOS 17+ minimum deployment target)
- **Storage:** SwiftData (local), CloudKit (Companion sync only)
- **Prayer Times:** Adhan-Swift (SPM: https://github.com/batoulapps/adhan-swift)
- **Widgets:** WidgetKit + App Groups shared container
- **Subscriptions:** StoreKit 2
- **Notifications:** UNUserNotificationCenter + Critical Alerts (Subuh Mode)

### Project Structure
```
Hayya/
├── App/
│   ├── HayyaApp.swift                 # Entry point
│   └── ContentView.swift              # Tab bar container
├── Models/
│   ├── PrayerRecord.swift             # SwiftData: prayer check-in records
│   ├── UserSettings.swift             # SwiftData: all user preferences
│   ├── CompanionConnection.swift      # CloudKit: partner connections
│   └── SpiritualContent.swift         # Hadith & encouragement data
├── Services/
│   ├── PrayerTimeService.swift        # Adhan-Swift wrapper, calculation methods
│   ├── NotificationService.swift      # Alarm scheduling, disruption levels
│   ├── StreakService.swift             # Streak calculation, protected days, recovery
│   ├── CloudKitService.swift          # Companion sync (Phase 2)
│   └── LocationService.swift          # GPS, auto-detect calculation method
├── Views/
│   ├── Today/
│   │   ├── TodayTabView.swift         # Prayer cards, stats bar, Your Journey card
│   │   ├── PrayerCardView.swift       # Individual prayer card (5 states)
│   │   └── SpiritualToastView.swift   # Non-blocking hadith toast after check-in
│   ├── PrayerMoment/
│   │   ├── PrayerMomentView.swift     # Notification landing screen (all 5 prayers)
│   │   ├── SubuhModeView.swift        # Full dark alarm takeover
│   │   └── TemporalTheme.swift        # Color palettes per prayer time
│   ├── Dashboard/
│   │   ├── PersonalDashboardView.swift # Days protected, dot grid, encouragement
│   │   └── WeeklyDotGrid.swift        # 5×7 prayer visualization
│   ├── Together/
│   │   ├── TogetherTabView.swift      # Empty/connected/weekly states
│   │   ├── PartnerCardView.swift      # Partner profile + prayer dots
│   │   └── ReminderView.swift         # Time-aware reminder system
│   ├── Alarms/
│   │   ├── AlarmTabView.swift         # Overview strip + prayer accordion
│   │   ├── IntensityBarsView.swift    # 4-level disruption visual
│   │   └── SoundPickerView.swift      # Tone + azan grouped picker
│   ├── Settings/
│   │   ├── SettingsTabView.swift      # iOS-style grouped sections
│   │   ├── CalculationMethodPicker.swift # 19 methods + custom angles
│   │   └── CompanionPrivacyView.swift # Hide prayers, pause, disconnect
│   └── Onboarding/
│       ├── OnboardingFlow.swift       # 6-screen flow
│       ├── AlarmPersonalityView.swift  # 2-question quiz
│       └── QuickSetupView.swift       # Location + method + notifications
├── Widgets/
│   ├── SmallWidget.swift              # Personal prayer dots
│   ├── MediumWidget.swift             # Couple "Together" widget
│   └── LargeWidget.swift              # Full "Today" widget
└── Resources/
    ├── SpiritualContent.json          # 50+ hadith, categorized by prayer
    ├── CalculationMethods.json        # 19 methods with angles
    └── Sounds/                        # Alarm tones + azan recordings
```

## Design System

### Colors
- Primary: #5B8C6F (green)
- Accent: #D4A843 (gold)
- Background: #FDFBF7 (warm cream)
- Done: #7FC4A0 (prayer completed)
- Missed: #E8878F (soft pink, not angry red)
- Qadha: #E0B86B (amber recovery)
- Upcoming: #D1D1D6 (muted gray)

### Typography
- UI: DM Sans (weights: 300, 400, 500, 600, 700)
- Arabic/Hadith: Noto Naskh Arabic (400, 500, 600)

### Temporal Themes (per prayer)
- Subuh: deep navy #0D1B2A, teal accent #7EAFC4
- Dzuhur: warm cream #FDFBF7, green accent #5B8C6F
- Ashar: soft warm #FAF7F2, olive accent #8B7D5E
- Maghrib: amber tint #FFF8F0, gold accent #D4A843
- Isya: dark navy #1A1F2E, blue-gray accent #8B9BB4

## Key Business Rules

### Prayer States
1. UPCOMING — before azan time, muted card
2. ACTIVE — prayer window open, green highlight, "Check In" button
3. DONE — completed, green checkmark, no timestamp shown
4. MISSED — window passed, soft pink, "Qadha" button
5. QADHA — recovered via qadha, amber, "Recovered" badge

### Protected Day
A protected day = all 5 prayers completed (on time OR via qadha).
Dashboard shows: "4 days protected (2 with recovery)" for honest record.
"Perfect day" badge = 5/5 on time with no qadha.

### Streak
A streak day requires at least 4 out of 5 prayers completed (on time or qadha).
Streak pauses (not breaks) when a day falls below 4.
Display format: "🔥 6 +2" (6 days, 2 recoveries).

### Qadha Rules
- Available until next Fajr (not midnight)
- ALL missed prayers from today recoverable (not just the most recent)
- Tracked separately in stats for honest self-reflection

### Companion Reminders
- One reminder per prayer per person
- Current active prayer ONLY — never for missed prayers
- Sender never chooses urgency — system adjusts based on time remaining:
  - Plenty of time: silent push, warm copy
  - <30 min: sound + vibration
  - <10 min: sound + vibration + repeat
- Reminder messages are system-generated, never custom text

### Alarm Defaults
- All offsets default to 0 (alarm at azan time)
- All sounds default to "Default chime" (safe, neutral)
- Azan voice is a global setting in Settings, not per-prayer
- Snooze is pre-set per prayer (one tap at alarm time, zero decisions)
- Context-aware snooze: Subuh/Maghrib: 5/10/15 min, Dzuhur/Ashar/Isya: 5/15/30 min
- Subuh default: Wake-Up, snooze 5m ×3
- Dzuhur/Ashar/Isya default: Gentle/Gentle/Moderate, snooze 15m ×2
- Maghrib default: Urgent, snooze 5m ×2
- Per-prayer editor uses bottom sheet (~85% screen, slides up, drag to dismiss)
- Control order in sheet: Disruption → Snooze → Offset → Sound → Heads-up → Subuh Mode (if Subuh)

### Check-In
- Instant one-tap (no confirmation sheet)
- Non-blocking spiritual toast (2.5s, frosted glass)
- New toasts replace old ones (no queue)
- 5/5 milestone: full celebration overlay (3s)

## Calculation Methods (19 supported)
Auto-detected by country. All computed via Adhan-Swift.
| Method | Fajr | Isha | Region |
|--------|------|------|--------|
| Kemenag RI | 20° | 18° | Indonesia (default) |
| JAKIM | 20° | 18° | Malaysia |
| MUIS | 20° | 18° | Singapore |
| MWL | 18° | 17° | Europe, global |
| ISNA | 15° | 15° | North America |
| Egyptian | 19.5° | 17.5° | Africa, Middle East |
| Umm Al-Qura | 18.5° | 90min | Saudi Arabia |
| Karachi | 18° | 18° | Pakistan, India |
| Dubai | 18.2° | 18.2° | UAE |
| Qatar | 18° | 90min | Qatar |
| Kuwait | 18° | 17.5° | Kuwait |
| Moonsighting | 18° | 18°+seasonal | N. America alt |
| Diyanet | 18° | 17° | Turkey |
| Tehran | 17.7° | 14° | Iran |
| Algeria | 18° | 17° | Algeria |
| Tunisia | 18° | 18° | Tunisia |
| France UOIF | 12° | 12° | France |
| Russia | 16° | 14.5° | Russia |
| Custom | User | User | Any |

## Spiritual Content Guidelines
- All hadith must be sahih (authentic) with source attribution
- Encouragement never shames — celebrates returning, not perfection
- No comparative language ("most people didn't")
- Tags are positive only (jamaah, prayed early) — no negative tags
- "Focus area" not "needs attention" — neutral, forward-looking
- Qadha messages celebrate recovery, not failure
- Ahlus Sunnah wal Jamaah framing

## Onboarding Flow (6 screens)
1. Identity — Hayya logo + tagline
2. Empathy — "You're not alone" struggle cards
3. Quick Setup — location + prayer time confirmation (auto-detect method) + notifications
4. Smart Alarm — hands-on setup of ONE prayer (next upcoming), smart defaults for rest
5. Dashboard Preview — prayer cards ready, staggered animation
6. Companion Invite — optional, skippable, hadith about congregation

## Phase 1 Scope (No Developer Account Needed)
Everything local: prayer time calculation, Today tab, check-in flow, qadha,
Subuh Mode, Prayer Moments (all 5 themes), personal dashboard, alarm settings,
settings (19 methods), onboarding, widgets (Small only without CloudKit).

## Phase 2 Scope (Requires Developer Account)
CloudKit: Companion sync, Together tab connected state, reminders,
"Prayed Together" detection, Medium + Large widgets, StoreKit subscriptions.

## Naming Conventions
- Feature: "Companion" (not Halaqah)
- Tab: "Together"
- Metric: "Days Protected" (not "streak days" or "completion rate")
- Recovery: "Qadha" (Islamic term, keep as-is)
- Alarm levels: Gentle / Moderate / Urgent / Wake-Up
- No percentages anywhere in the UI
- English UI with Islamic vocabulary (Alhamdulillah, Subuh, etc.)
