# CLAUDE.md — Hayya Prayer Companion App

## What is Hayya?
An iOS prayer companion app for Muslims. Tagline: "A gentle companion for your prayers."
Core positioning: personal companion first, shared accountability second.

## Architecture

### Stack
- **Language:** Swift 5.9+
- **UI:** SwiftUI (iOS 26+ deployment target, Xcode 26.3)
- **Storage:** SwiftData (local), CloudKit (Companion sync only)
- **Prayer Times:** Adhan-Swift 1.4.0 (SPM: https://github.com/batoulapps/adhan-swift)
- **Widgets:** WidgetKit (Small widget implemented, App Groups for Phase 2)
- **Subscriptions:** StoreKit 2 (Phase 2)
- **Notifications:** UNUserNotificationCenter + Critical Alerts (Subuh Mode)
- **Bundle ID:** com.jafarfh.Hayya
- **Dev Team:** WMXNR469QP (free provisioning)
- **Concurrency:** MainActor default isolation, nonisolated Codable conformance

### Project Structure
```
Hayya/
├── App/
│   ├── HayyaApp.swift                 # Entry point, ModelContainer, notifications
│   └── ContentView.swift              # Floating pill tab bar (5 tabs)
├── Models/
│   ├── PrayerRecord.swift             # SwiftData: PrayerName, PrayerStatus, DaySummary
│   ├── UserSettings.swift             # SwiftData: AlarmSetting (nonisolated Codable)
│   └── SpiritualContent.swift         # Hadith & encouragement data
├── Services/
│   ├── PrayerTimeService.swift        # Adhan-Swift wrapper, 19 calculation methods
│   ├── NotificationService.swift      # Alarm scheduling, disruption levels
│   ├── StreakService.swift             # WeeklyStats, StreakInfo, dot grid builder
│   └── LocationService.swift          # GPS, MKLocalSearch geocoding, widget defaults
├── Views/
│   ├── Today/
│   │   ├── TodayTabView.swift         # Prayer cards, streak badge, journey card
│   │   ├── TodayViewModel.swift       # Prayer state machine, check-in logic
│   │   ├── PrayerCardView.swift       # Individual prayer card (5 states)
│   │   └── SpiritualToastView.swift   # Non-blocking hadith toast after check-in
│   ├── PrayerMoment/
│   │   ├── PrayerMomentView.swift     # Notification landing screen (all 5 prayers)
│   │   ├── SubuhModeView.swift        # Full dark alarm takeover
│   │   └── TemporalTheme.swift        # Color palettes + Color(hex:) extension
│   ├── Dashboard/
│   │   ├── PersonalDashboardView.swift # Wired to SwiftData via StreakService
│   │   └── WeeklyDotGrid.swift        # 5×7 prayer visualization
│   ├── Together/
│   │   └── TogetherTabView.swift      # Placeholder (Phase 2: CloudKit)
│   ├── Alarms/
│   │   ├── AlarmTabView.swift         # SwiftData persistence, LocationService
│   │   ├── AlarmEditorSheet.swift     # Per-prayer editor (85% sheet)
│   │   └── IntensityBarsView.swift    # 4-level disruption visual
│   ├── Settings/
│   │   ├── SettingsTabView.swift      # iOS-style grouped sections
│   │   └── CalculationMethodPicker.swift # 19 methods + custom angles
│   └── Onboarding/
│       ├── OnboardingFlow.swift       # 6-screen flow
│       ├── AlarmPersonalityView.swift  # 2-question quiz
│       └── QuickSetupView.swift       # Location + method + notifications
└── Resources/
    ├── SpiritualContent.json          # 50+ hadith, categorized by prayer
    └── CalculationMethods.json        # 19 methods with angles

HayyaWidget/                           # Widget Extension target
├── HayyaWidgetBundle.swift            # @main widget bundle entry point
├── HayyaPrayerWidget.swift            # Timeline provider + widget config
├── SmallPrayerWidgetView.swift        # Small widget: next prayer + 5 dots
└── WidgetDataProvider.swift           # Lightweight Adhan-Swift wrapper

HayyaWidget-Info.plist                 # NSExtension dictionary for widget
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

## Phase 1 Status (Complete)
All Phase 1 features implemented and running on device:
- Prayer time calculation (Adhan-Swift, 19 methods, auto-detect by country)
- Today tab with prayer cards, check-in, qadha recovery, streak badge
- Personal dashboard wired to SwiftData (WeeklyStats, dot grid, insights)
- Alarm settings with per-prayer editor, persisted to SwiftData
- Settings tab with calculation method picker
- Onboarding flow (6 screens)
- Prayer Moment views with temporal themes (all 5 prayers)
- Subuh Mode (full dark alarm takeover)
- Small widget (prayer times + next prayer highlight)
- Notifications via UNUserNotificationCenter
- Location via CoreLocation + MKLocalSearch geocoding (iOS 26 API)

## Phase 2 Scope (Requires Developer Account)
CloudKit: Companion sync, Together tab connected state, reminders,
"Prayed Together" detection, Medium + Large widgets, StoreKit subscriptions,
App Groups for widget check-in data sharing.

## Technical Notes
- **MainActor default isolation:** Build flag `-default-isolation MainActor`. AlarmSetting uses explicit `nonisolated init(from:)` / `nonisolated func encode(to:)` for Codable.
- **#Predicate limitation:** Can't compare enums in SwiftData predicates. StreakService fetches all records and filters in Swift.
- **iOS 26 geocoding:** CLGeocoder deprecated. Uses MKLocalSearch + MKAddressRepresentations (cityName, regionName, region.identifier).
- **Widget data sharing:** Currently uses UserDefaults.standard. When App Groups configured, switch to `UserDefaults(suiteName: "group.com.jafarfh.hayya.shared")` — marked with TODO comments in LocationService and HayyaPrayerWidget.
- **Free provisioning:** 7-day signing expiry, no push notifications, no App Groups, no Critical Alerts. Bundle ID must be unique (com.jafarfh.Hayya).

## Naming Conventions
- Feature: "Companion" (not Halaqah)
- Tab: "Together"
- Metric: "Days Protected" (not "streak days" or "completion rate")
- Recovery: "Qadha" (Islamic term, keep as-is)
- Alarm levels: Gentle / Moderate / Urgent / Wake-Up
- No percentages anywhere in the UI
- English UI with Islamic vocabulary (Alhamdulillah, Subuh, etc.)
