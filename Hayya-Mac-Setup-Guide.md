# Hayya — Getting Started Guide
## From zero to your first prayer times on screen

---

## Step 1: Create the project folder

Open **Terminal** (search "Terminal" in Spotlight) and run:

```bash
mkdir -p ~/Projects/Hayya
```

---

## Step 2: Create the Xcode project

1. Open **Xcode**
2. File → New → Project
3. Choose **iOS → App**
4. Fill in:
   - Product Name: **Hayya**
   - Team: your personal team (your Apple ID)
   - Organization Identifier: **com.hayya**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData** ✅ (check this box)
   - Include Tests: ✅
5. When it asks where to save → choose **~/Projects/Hayya/**
6. In the project, select **Hayya** target → **General** tab → set **Minimum Deployments** to **iOS 17.0**
7. Add Adhan-Swift: File → Add Package Dependencies → paste `https://github.com/batoulapps/adhan-swift` → Add Package
8. Press **⌘R** to verify it builds (you'll see a blank "Hello World" in the simulator)
9. **Close Xcode** — Claude Code needs file access without Xcode locking things

---

## Step 3: Copy your files into the project

Download ALL files from our conversation and organize them like this:

**Documents** — put directly in ~/Projects/Hayya/:
- CLAUDE.md
- Hayya-Product-Spec-FINAL.docx
- Hayya-Mac-Setup-Guide.md (this file)

**Design prototypes** — put in a design subfolder:

Open Terminal and run:
```bash
mkdir ~/Projects/Hayya/design
```

Then copy these 8 JSX files into ~/Projects/Hayya/design/:
- hayya-onboarding.jsx
- hayya-alarm-settings.jsx
- hayya-checkin-flow.jsx
- hayya-together-tab.jsx
- hayya-personal-dashboard.jsx
- hayya-settings.jsx
- hayya-prayer-moments.jsx
- hayya-widgets.jsx

You can drag them from your Downloads folder into the design folder via Finder, or run:
```bash
cp ~/Downloads/hayya-*.jsx ~/Projects/Hayya/design/
```

Your folder should look like this:
```
~/Projects/Hayya/
├── CLAUDE.md                          ← Claude Code reads this every session
├── Hayya-Product-Spec-FINAL.docx      ← Full spec for reference
├── Hayya-Mac-Setup-Guide.md           ← This file
├── design/
│   ├── hayya-onboarding.jsx           ← 6-screen onboarding flow
│   ├── hayya-alarm-settings.jsx       ← Bottom sheet alarm editor
│   ├── hayya-checkin-flow.jsx         ← Instant check-in + qadha
│   ├── hayya-together-tab.jsx         ← Companion sharing tab
│   ├── hayya-personal-dashboard.jsx   ← Days protected + dot grid
│   ├── hayya-settings.jsx             ← 19 calc methods + privacy
│   ├── hayya-prayer-moments.jsx       ← All 5 temporal prayer screens
│   └── hayya-widgets.jsx              ← Small/Medium/Large widgets
├── Hayya/                             ← Xcode project (auto-created)
│   ├── HayyaApp.swift
│   ├── ContentView.swift
│   └── ...
└── Hayya.xcodeproj
```

---

## Step 4: Initialize git

Open Terminal:
```bash
cd ~/Projects/Hayya
git init
git add .
git commit -m "Initial project with Adhan-Swift, spec, and design prototypes"
```

---

## Step 5: Open Claude Code for Mac

1. Open the **Claude Code** desktop app
2. It will ask you to choose a folder — navigate to **~/Projects/Hayya** and select it
3. When it asks for permissions (file access, terminal commands, etc.) — **allow everything**. Claude Code needs full access to read your files, create Swift code, and run terminal commands.

---

## Step 6: First message to Claude Code

Copy and paste this:

```
Read CLAUDE.md in this project root. This is Hayya, an iOS prayer companion app for Muslims.

The design/ folder contains 8 interactive prototypes (JSX files) that show the exact layout, spacing, colors, and interactions for each screen. Reference these when building the SwiftUI views — they are your design mockups.

The full product spec is in Hayya-Product-Spec-FINAL.docx if you need deeper context on any feature.

Let's start with Session 1: Build the PrayerTimeService.

Create a PrayerTimeService.swift in a Services group that:
1. Wraps the Adhan-Swift library
2. Has a CalculationMethodType enum with all 19 methods listed in CLAUDE.md
3. Has a function that takes coordinates, date, and calculation method, and returns a PrayerTimes struct with all 5 prayer times (Subuh, Dzuhur, Ashar, Maghrib, Isya) plus sunrise
4. Has a function that auto-detects the recommended calculation method based on country code
5. Defaults to Kemenag RI (Fajr 20°, Isha 18°)

Then create a simple test view that shows today's 5 prayer times for Jakarta (-6.2088, 106.8456) on screen so I can verify the times are correct.

Use the design system from CLAUDE.md: DM Sans font, #5B8C6F primary green, #FDFBF7 warm cream background.
```

---

## After Session 1

1. Open **Xcode** and press **⌘R** to build and run
2. You should see 5 prayer times for Jakarta in the simulator
3. Compare with your local mosque schedule or Muslim Pro to verify accuracy
4. Go back to Terminal and commit:
```bash
cd ~/Projects/Hayya
git add .
git commit -m "Session 1: PrayerTimeService with 19 calculation methods"
```

---

## Session-by-Session Roadmap

For each session, open Claude Code, tell it what to build, and reference the matching prototype. Example messages:

**Session 2 — SwiftData Models:**
```
Read CLAUDE.md. Build the SwiftData models: PrayerRecord and UserSettings as described in the data model section. Include all fields listed.
```

**Session 3 — Today Tab:**
```
Read CLAUDE.md. Build the Today tab with prayer cards. Reference design/hayya-personal-dashboard.jsx for the layout — look at the prayer card section with 5 states (done, active, missed, qadha, upcoming). Include the date header, stats bar, and floating pill tab bar.
```

**Session 4 — Check-In Flow:**
```
Read CLAUDE.md. Build the check-in flow. Reference design/hayya-checkin-flow.jsx for the exact interaction: instant one-tap check-in, non-blocking spiritual toast, qadha bottom sheet. Follow the ceremony hierarchy in CLAUDE.md.
```

**Session 5 — Notification Scheduling:**
```
Read CLAUDE.md. Build the notification system. Schedule 5 daily prayer alarms using UNUserNotificationCenter. Use the disruption levels and smart defaults from CLAUDE.md. Handle the iOS 64 notification limit.
```

**Session 6 — Prayer Moments:**
```
Read CLAUDE.md. Build the Prayer Moment screens. Reference design/hayya-prayer-moments.jsx — it has all 5 temporal themes. Subuh gets the full dark alarm with snooze. Others get lightweight focused screens. Follow the temporal color palettes in CLAUDE.md.
```

**Session 7 — Alarm Settings:**
```
Read CLAUDE.md. Build the alarm settings screen. Reference design/hayya-alarm-settings.jsx — bottom sheet pattern, overview strip at top, prayer card list, tap to open sheet. Follow the control order: Disruption → Snooze → Offset → Sound → Heads-up. Context-aware snooze intervals.
```

**Session 8 — Personal Dashboard:**
```
Read CLAUDE.md. Build the personal dashboard. Reference design/hayya-personal-dashboard.jsx for layout: days protected hero metric, recovery days, 5×7 weekly dot grid, encouragement card, prayer insights. Tap streak flame or Your Journey card to open.
```

**Session 9 — Settings:**
```
Read CLAUDE.md. Build the settings screen. Reference design/hayya-settings.jsx — iOS-style grouped sections, 19 calculation methods with inline picker, prayer time preview, advanced calculation (high latitude, manual adjustments), Companion privacy controls, subscription.
```

**Session 10 — Onboarding:**
```
Read CLAUDE.md. Build the onboarding flow. Reference design/hayya-onboarding.jsx — 6 screens: Identity → Empathy → Quick Setup (location + method + notifications) → Smart Alarm (hands-on one prayer setup) → Dashboard preview → Companion invite (optional, skippable).
```

**Session 11 — Together Tab:**
```
Read CLAUDE.md. Build the Together tab. Reference design/hayya-together-tab.jsx — three states: spiritual empty state with hadith, connected state with partner dots and reminder button, weekly summary. This needs CloudKit so build the UI with mock data for now.
```

**Session 12 — Small Widget:**
```
Read CLAUDE.md. Build the Small (2×2) home screen widget using WidgetKit. Reference design/hayya-widgets.jsx for layout: prayer dots with active prayer gold ring, streak count, next prayer with countdown. Set up App Groups for shared data.
```

**Session 13 — Qadha + Streak Logic:**
```
Read CLAUDE.md. Build the qadha recovery flow and streak calculation engine. Rules: protected day = all 5 done (on time or qadha). Streak day = at least 4/5. Qadha available until next Fajr. All missed prayers recoverable. Recovery days tracked.
```

**Session 14 — Polish + Device Testing:**
```
Read CLAUDE.md. Integration pass: make sure all screens connect properly via the tab bar navigation. Test the full flow: onboarding → alarm setup → prayer notification → prayer moment → check-in → dashboard update. Build on my physical device for real testing.
```

---

## Tips for Working with Claude Code for Mac

- **Always start with "Read CLAUDE.md"** — this orients Claude Code on the project
- **Reference specific prototype files** — "look at design/hayya-alarm-settings.jsx" gives Claude Code the exact layout to match
- **One screen per session** — don't try to build everything at once
- **Open Xcode to test, close it before going back to Claude Code** — Xcode can lock files
- **Commit after every session** — your safety net if anything goes wrong
- **If Claude Code gets confused** — say "Read CLAUDE.md again" and restate your goal
- **If something looks wrong** — tell Claude Code exactly what to fix: "The prayer card needs 16px padding not 8px" or "The snooze buttons should be full-width"
