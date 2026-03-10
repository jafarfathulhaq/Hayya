import { useState } from "react";

const C = {
  bg: "#FDFBF7", primary: "#5B8C6F", primaryLight: "#E8F0EB", primarySoft: "#A8CBB7",
  accent: "#D4A843", accentLight: "#FFF6E3", text: "#2C2C2C", textSecondary: "#8E8E93",
  textMuted: "#B5B5BA", done: "#7FC4A0", doneLight: "#EEFAF3", missed: "#E8878F",
  missedLight: "#FFF0F1", qadha: "#E0B86B", border: "#EBEBF0", destructive: "#E25C5C",
  destructiveLight: "#FFF0F0",
};

const calcMethods = [
  { id: "Kemenag RI", region: "Indonesia", fajr: "20°", isha: "18°" },
  { id: "JAKIM", region: "Malaysia", fajr: "20°", isha: "18°" },
  { id: "MUIS (Singapore)", region: "Singapore", fajr: "20°", isha: "18°" },
  { id: "MWL", region: "Europe, Far East", fajr: "18°", isha: "17°" },
  { id: "ISNA", region: "North America", fajr: "15°", isha: "15°" },
  { id: "Egyptian", region: "Africa, Middle East", fajr: "19.5°", isha: "17.5°" },
  { id: "Umm Al-Qura", region: "Saudi Arabia, Gulf", fajr: "18.5°", isha: "90 min" },
  { id: "Karachi", region: "Pakistan, India, Bangladesh", fajr: "18°", isha: "18°" },
  { id: "Dubai", region: "UAE", fajr: "18.2°", isha: "18.2°" },
  { id: "Qatar", region: "Qatar", fajr: "18°", isha: "90 min" },
  { id: "Kuwait", region: "Kuwait", fajr: "18°", isha: "17.5°" },
  { id: "Moonsighting", region: "N. America (alt)", fajr: "18°", isha: "18°" },
  { id: "Diyanet", region: "Turkey", fajr: "18°", isha: "17°" },
  { id: "Tehran", region: "Iran, Shia", fajr: "17.7°", isha: "14°" },
  { id: "Algeria", region: "Algeria, N. Africa", fajr: "18°", isha: "17°" },
  { id: "Tunisia", region: "Tunisia", fajr: "18°", isha: "18°" },
  { id: "France (UOIF)", region: "France", fajr: "12°", isha: "12°" },
  { id: "Russia", region: "Russia", fajr: "16°", isha: "14.5°" },
  { id: "Custom", region: "Set your own angles", fajr: "—", isha: "—" },
];
const madhabs = ["Shafi'i", "Hanafi"];
const highLatRules = ["None", "Middle of the Night", "Seventh of the Night", "Twilight Angle"];

export default function SettingsScreen() {
  const [location, setLocation] = useState("Jakarta, Indonesia");
  const [calcMethod, setCalcMethod] = useState("Kemenag RI");
  const [madhab, setMadhab] = useState("Shafi'i");
  const [appearance, setAppearance] = useState("system");
  const [highLat, setHighLat] = useState("None");
  const [showAdvCalc, setShowAdvCalc] = useState(false);
  const [customFajr, setCustomFajr] = useState("20");
  const [customIsha, setCustomIsha] = useState("18");
  const [prayerAdjust, setPrayerAdjust] = useState({ Subuh: 0, Dzuhur: 0, Ashar: 0, Maghrib: 0, Isya: 0 });
  const [trackQuality, setTrackQuality] = useState(false);
  const [notifEnabled, setNotifEnabled] = useState(true);
  const [criticalAlerts, setCriticalAlerts] = useState(true);

  // Companion privacy
  const [sharingPaused, setSharingPaused] = useState(false);
  const [silentMode, setSilentMode] = useState(false);
  const [hiddenPrayers, setHiddenPrayers] = useState({ Subuh: false, Dzuhur: false, Ashar: false, Maghrib: false, Isya: false });
  const [showHidePrayers, setShowHidePrayers] = useState(false);
  const [showDisconnect, setShowDisconnect] = useState(false);

  // Drill-down states
  const [activeSheet, setActiveSheet] = useState(null); // 'calc' | 'madhab' | 'about' | 'subscription'

  return (
    <div style={{ minHeight: "100vh", background: "linear-gradient(135deg,#F0EDE6,#E8E4DC 50%,#F2EFE8)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "20px 16px", fontFamily: "'DM Sans','Nunito',system-ui,-apple-system,sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&display=swap" rel="stylesheet" />

      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <h1 style={{ fontSize: 16, fontWeight: 600, color: C.text, letterSpacing: 0.5, margin: 0 }}>HAYYA — Settings</h1>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: "3px 0 0" }}>Tap any row to interact • Toggles are functional</p>
      </div>

      {/* Phone Frame */}
      <div style={{ width: 375, height: 812, borderRadius: 44, background: "#000", padding: 8, boxShadow: "0 24px 80px rgba(0,0,0,0.15),0 8px 24px rgba(0,0,0,0.1)" }}>
        <div style={{ width: "100%", height: "100%", borderRadius: 38, background: C.bg, overflow: "hidden", display: "flex", flexDirection: "column", position: "relative" }}>

          {/* Status Bar */}
          <div style={{ height: 50, display: "flex", alignItems: "flex-end", justifyContent: "space-between", padding: "0 28px 4px", fontSize: 14, fontWeight: 600, color: C.text, flexShrink: 0 }}>
            <span>9:41</span>
            <div style={{ display: "flex", gap: 4, alignItems: "center" }}>
              <svg width="16" height="12" viewBox="0 0 16 12"><rect x="0" y="6" width="3" height="6" rx=".5" fill={C.text}/><rect x="4.5" y="4" width="3" height="8" rx=".5" fill={C.text}/><rect x="9" y="1.5" width="3" height="10.5" rx=".5" fill={C.text}/><rect x="13" y="0" width="3" height="12" rx=".5" fill={C.text}/></svg>
              <span>100%</span>
            </div>
          </div>

          {/* Header */}
          <div style={{ padding: "4px 20px 12px", flexShrink: 0 }}>
            <h2 style={{ fontSize: 28, fontWeight: 700, color: C.text, margin: "0 0 4px" }}>Settings</h2>
            <p style={{ fontSize: 12, color: C.textMuted, margin: 0 }}>☁️ iCloud connected · Jafar</p>
          </div>

          {/* Scrollable Content */}
          <div style={{ flex: 1, overflowY: "auto", padding: "0 14px 14px" }}>

            {/* ===== PRAYER SETTINGS ===== */}
            <SectionHeader label="Prayer" />
            <GroupCard>
              <Row
                icon="📍" label="Location" value={location}
                onClick={() => {}}
              />
              <Divider />
              <Row
                icon="🧭" label="Calculation Method" value={calcMethod}
                onClick={() => setActiveSheet(activeSheet === "calc" ? null : "calc")}
              />
              {activeSheet === "calc" && (
                <div style={{ padding: "4px 14px 12px" }}>
                  <div style={{ maxHeight: 200, overflowY: "auto", display: "flex", flexDirection: "column", gap: 3 }}>
                    {calcMethods.map(m => (
                      <button key={m.id} onClick={() => { setCalcMethod(m.id); if (m.id !== "Custom") setActiveSheet(null); }} style={{
                        padding: "8px 12px", borderRadius: 10, textAlign: "left",
                        border: calcMethod === m.id ? `1.5px solid ${C.primary}` : `1px solid ${C.border}`,
                        background: calcMethod === m.id ? C.primaryLight : "white",
                        cursor: "pointer", display: "flex", justifyContent: "space-between", alignItems: "center",
                      }}>
                        <div>
                          <span style={{ fontSize: 12, fontWeight: calcMethod === m.id ? 600 : 400, color: calcMethod === m.id ? C.primary : C.text }}>{m.id}</span>
                          <span style={{ fontSize: 10, color: C.textMuted, marginLeft: 6 }}>{m.region}</span>
                        </div>
                        <span style={{ fontSize: 9, color: C.textMuted }}>F:{m.fajr} I:{m.isha}</span>
                      </button>
                    ))}
                  </div>
                  {calcMethod === "Custom" && (
                    <div style={{ marginTop: 8, display: "flex", gap: 8 }}>
                      <div style={{ flex: 1 }}>
                        <p style={{ fontSize: 10, color: C.textMuted, margin: "0 0 4px" }}>Fajr angle (°)</p>
                        <input value={customFajr} onChange={(e) => setCustomFajr(e.target.value)} style={{ width: "100%", padding: "8px", borderRadius: 8, border: `1px solid ${C.border}`, fontSize: 13, textAlign: "center" }} />
                      </div>
                      <div style={{ flex: 1 }}>
                        <p style={{ fontSize: 10, color: C.textMuted, margin: "0 0 4px" }}>Isha angle (°)</p>
                        <input value={customIsha} onChange={(e) => setCustomIsha(e.target.value)} style={{ width: "100%", padding: "8px", borderRadius: 8, border: `1px solid ${C.border}`, fontSize: 13, textAlign: "center" }} />
                      </div>
                    </div>
                  )}
                  <p style={{ fontSize: 10, color: C.textMuted, margin: "6px 0 0" }}>Choose the method used by your local mosque for best accuracy</p>
                </div>
              )}
              <Divider />
              <Row
                icon="📖" label="Asr Calculation" value={madhab}
                onClick={() => setActiveSheet(activeSheet === "madhab" ? null : "madhab")}
              />
              {activeSheet === "madhab" && (
                <PickerInline
                  options={madhabs}
                  selected={madhab}
                  onSelect={(v) => { setMadhab(v); setActiveSheet(null); }}
                  note={madhab === "Hanafi" ? "Asr when shadow = 2× object height" : "Asr when shadow = 1× object height (default)"}
                />
              )}
            </GroupCard>

            {/* Prayer Time Preview */}
            <div style={{ margin: "6px 0 4px", padding: "10px 14px", background: C.primaryLight, borderRadius: 14 }}>
              <p style={{ fontSize: 10, fontWeight: 600, color: C.primary, margin: "0 0 4px" }}>TODAY'S TIMES · {calcMethod}</p>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                {[
                  { n: "Subuh", t: "04:52" }, { n: "Dzuhur", t: "11:58" }, { n: "Ashar", t: "15:12" },
                  { n: "Maghrib", t: "17:54" }, { n: "Isya", t: "19:08" },
                ].map(p => (
                  <div key={p.n} style={{ textAlign: "center" }}>
                    <p style={{ fontSize: 12, fontWeight: 600, color: C.text, margin: 0 }}>{p.t}</p>
                    <p style={{ fontSize: 9, color: C.textSecondary, margin: "1px 0 0" }}>{p.n}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Advanced Calculation */}
            <GroupCard>
              <button onClick={() => setShowAdvCalc(!showAdvCalc)} style={{ width: "100%", padding: "12px 14px", background: "none", border: "none", cursor: "pointer", display: "flex", alignItems: "center", gap: 10, textAlign: "left" }}>
                <span style={{ fontSize: 16, width: 24, textAlign: "center" }}>⚙️</span>
                <div style={{ flex: 1 }}>
                  <p style={{ fontSize: 14, fontWeight: 500, color: C.text, margin: 0 }}>Advanced Calculation</p>
                  <p style={{ fontSize: 11, color: C.textMuted, margin: "2px 0 0" }}>High latitude, manual adjustments</p>
                </div>
                <span style={{ fontSize: 10, color: C.textMuted, transform: showAdvCalc ? "rotate(180deg)" : "rotate(0)", transition: "transform .2s" }}>▾</span>
              </button>
              {showAdvCalc && (
                <div style={{ padding: "0 14px 14px" }}>
                  {/* High Latitude Rule */}
                  <p style={{ fontSize: 10, fontWeight: 600, color: C.textMuted, margin: "0 0 6px" }}>HIGH LATITUDE ADJUSTMENT</p>
                  <p style={{ fontSize: 10, color: C.textMuted, margin: "0 0 6px" }}>For locations above 48° where twilight persists in summer</p>
                  <div style={{ display: "flex", flexDirection: "column", gap: 3, marginBottom: 14 }}>
                    {highLatRules.map(r => (
                      <button key={r} onClick={() => setHighLat(r)} style={{
                        padding: "8px 12px", borderRadius: 8, textAlign: "left",
                        border: highLat === r ? `1.5px solid ${C.primary}` : `1px solid ${C.border}`,
                        background: highLat === r ? C.primaryLight : "white",
                        fontSize: 12, fontWeight: highLat === r ? 600 : 400,
                        color: highLat === r ? C.primary : C.text, cursor: "pointer",
                      }}>{r}{r === "None" ? " (default)" : ""}</button>
                    ))}
                  </div>

                  {/* Per-prayer manual adjustments */}
                  <p style={{ fontSize: 10, fontWeight: 600, color: C.textMuted, margin: "0 0 6px" }}>MANUAL TIME ADJUSTMENTS</p>
                  <p style={{ fontSize: 10, color: C.textMuted, margin: "0 0 8px" }}>Fine-tune ±minutes per prayer to match your mosque</p>
                  <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
                    {["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"].map(p => (
                      <div key={p} style={{ display: "flex", alignItems: "center", gap: 8 }}>
                        <span style={{ fontSize: 11, width: 50, color: C.textSecondary }}>{p}</span>
                        <button onClick={() => setPrayerAdjust(prev => ({ ...prev, [p]: prev[p] - 1 }))} style={{ width: 28, height: 28, borderRadius: 8, border: `1px solid ${C.border}`, background: "white", cursor: "pointer", fontSize: 14, color: C.textSecondary, display: "flex", alignItems: "center", justifyContent: "center" }}>−</button>
                        <span style={{ fontSize: 13, fontWeight: 600, color: prayerAdjust[p] === 0 ? C.textMuted : C.primary, width: 36, textAlign: "center" }}>
                          {prayerAdjust[p] === 0 ? "0" : prayerAdjust[p] > 0 ? `+${prayerAdjust[p]}` : prayerAdjust[p]}
                        </span>
                        <button onClick={() => setPrayerAdjust(prev => ({ ...prev, [p]: prev[p] + 1 }))} style={{ width: 28, height: 28, borderRadius: 8, border: `1px solid ${C.border}`, background: "white", cursor: "pointer", fontSize: 14, color: C.textSecondary, display: "flex", alignItems: "center", justifyContent: "center" }}>+</button>
                        <span style={{ fontSize: 10, color: C.textMuted }}>min</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </GroupCard>

            {/* ===== NOTIFICATIONS ===== */}
            <SectionHeader label="Notifications" />
            <GroupCard>
              <Row
                icon="🔔" label="Notifications"
                right={<StatusBadge ok={notifEnabled} label={notifEnabled ? "Enabled" : "Disabled"} />}
                onClick={() => setNotifEnabled(!notifEnabled)}
              />
              <Divider />
              <Row
                icon="🚨" label="Critical Alerts"
                subtitle="Required for Wake-Up alarms"
                right={<StatusBadge ok={criticalAlerts} label={criticalAlerts ? "Granted" : "Not granted"} />}
                onClick={() => setCriticalAlerts(!criticalAlerts)}
              />
              <Divider />
              <Row
                icon="⏰" label="Alarm Settings"
                subtitle="Disruption levels, sounds, offsets"
                onClick={() => {}}
                chevron
              />
            </GroupCard>

            {/* ===== PRAYER QUALITY ===== */}
            <SectionHeader label="Features" />
            <GroupCard>
              <Row
                icon="🏷️" label="Track Prayer Quality"
                subtitle="Jamaah, prayed early tags after check-in"
                right={<Toggle value={trackQuality} onToggle={() => setTrackQuality(!trackQuality)} />}
              />
            </GroupCard>

            {/* ===== APPEARANCE ===== */}
            <SectionHeader label="Appearance" />
            <GroupCard>
              <div style={{ padding: "10px 14px" }}>
                <div style={{ display: "flex", gap: 6 }}>
                  {[
                    { id: "light", label: "Light", icon: "☀️" },
                    { id: "dark", label: "Dark", icon: "🌙" },
                    { id: "system", label: "System", icon: "📱" },
                  ].map(opt => (
                    <button key={opt.id} onClick={() => setAppearance(opt.id)} style={{
                      flex: 1, padding: "10px 6px", borderRadius: 12,
                      border: appearance === opt.id ? `2px solid ${C.primary}` : `1.5px solid ${C.border}`,
                      background: appearance === opt.id ? C.primaryLight : "white",
                      cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", gap: 3,
                    }}>
                      <span style={{ fontSize: 18 }}>{opt.icon}</span>
                      <span style={{ fontSize: 11, fontWeight: appearance === opt.id ? 600 : 400, color: appearance === opt.id ? C.primary : C.textSecondary }}>{opt.label}</span>
                    </button>
                  ))}
                </div>
              </div>
            </GroupCard>

            {/* ===== HALAQAH PRIVACY ===== */}
            <SectionHeader label="Together (Companion)" />
            <GroupCard>
              <Row
                icon="👩" label="Connected to"
                value="Aisha"
                subtitle="Praying together since 1 Ramadan"
              />
              <Divider />
              <Row
                icon="⏸️" label="Pause Sharing"
                subtitle="Your status won't be visible to Aisha"
                right={<Toggle value={sharingPaused} onToggle={() => setSharingPaused(!sharingPaused)} color={C.accent} />}
              />
              <Divider />
              <Row
                icon="🔕" label="Silent Mode"
                subtitle="Still share status, but don't receive reminders"
                right={<Toggle value={silentMode} onToggle={() => setSilentMode(!silentMode)} />}
              />
              <Divider />
              <Row
                icon="👁️" label="Hide Specific Prayers"
                subtitle={Object.values(hiddenPrayers).some(Boolean) ? `Hiding: ${Object.entries(hiddenPrayers).filter(([,v]) => v).map(([k]) => k).join(", ")}` : "All prayers visible"}
                onClick={() => setShowHidePrayers(!showHidePrayers)}
                chevron
              />
              {showHidePrayers && (
                <div style={{ padding: "4px 14px 12px" }}>
                  <p style={{ fontSize: 10, color: C.textMuted, margin: "0 0 8px" }}>Hidden prayers won't be shared with Aisha</p>
                  <div style={{ display: "flex", gap: 5 }}>
                    {["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"].map(p => (
                      <button key={p} onClick={() => setHiddenPrayers(prev => ({ ...prev, [p]: !prev[p] }))} style={{
                        flex: 1, padding: "8px 4px", borderRadius: 10,
                        border: hiddenPrayers[p] ? `1.5px solid ${C.accent}` : `1px solid ${C.border}`,
                        background: hiddenPrayers[p] ? C.accentLight : "white",
                        cursor: "pointer", textAlign: "center",
                      }}>
                        <span style={{ fontSize: 10, fontWeight: hiddenPrayers[p] ? 600 : 400, color: hiddenPrayers[p] ? C.accent : C.textSecondary }}>
                          {hiddenPrayers[p] ? "🙈" : "👁️"} {p}
                        </span>
                      </button>
                    ))}
                  </div>
                </div>
              )}
              <Divider />
              <Row
                icon="🔗" label="Disconnect"
                subtitle="Remove connection with Aisha"
                labelColor={C.destructive}
                onClick={() => setShowDisconnect(true)}
                chevron
              />
              {showDisconnect && (
                <div style={{ padding: "8px 14px 12px" }}>
                  <div style={{ background: C.destructiveLight, borderRadius: 12, padding: "12px 14px", marginBottom: 8 }}>
                    <p style={{ fontSize: 12, color: C.destructive, margin: 0, lineHeight: 1.5 }}>
                      This will remove your connection with Aisha. Your prayer data stays private. You can reconnect anytime with a new invite.
                    </p>
                  </div>
                  <div style={{ display: "flex", gap: 8 }}>
                    <button style={{ flex: 1, padding: "10px", borderRadius: 10, border: "none", background: C.destructive, color: "white", fontSize: 13, fontWeight: 600, cursor: "pointer" }}>
                      Disconnect
                    </button>
                    <button onClick={() => setShowDisconnect(false)} style={{ flex: 1, padding: "10px", borderRadius: 10, border: `1px solid ${C.border}`, background: "white", fontSize: 13, color: C.textSecondary, cursor: "pointer" }}>
                      Cancel
                    </button>
                  </div>
                </div>
              )}
            </GroupCard>

            {/* ===== SUBSCRIPTION ===== */}
            <SectionHeader label="Subscription" />
            <GroupCard>
              <div style={{ padding: "14px 14px" }}>
                <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 10 }}>
                  <div>
                    <p style={{ fontSize: 15, fontWeight: 600, color: C.text, margin: 0 }}>Free Plan</p>
                    <p style={{ fontSize: 11, color: C.textSecondary, margin: "2px 0 0" }}>Alarms, check-in, qadha, streak, Subuh Mode</p>
                  </div>
                  <span style={{ fontSize: 11, fontWeight: 600, color: C.primary, background: C.primaryLight, padding: "4px 10px", borderRadius: 8 }}>Active</span>
                </div>
                <div style={{ background: C.accentLight, borderRadius: 14, padding: "12px 14px", marginBottom: 10 }}>
                  <p style={{ fontSize: 13, fontWeight: 600, color: C.accent, margin: "0 0 4px" }}>Upgrade to Premium</p>
                  <p style={{ fontSize: 11, color: C.textSecondary, margin: "0 0 8px", lineHeight: 1.4 }}>
                    Companion sharing, reminders, Prayed Together, couple widgets, custom sounds, stats
                  </p>
                  <div style={{ display: "flex", gap: 6 }}>
                    <div style={{ flex: 1, background: "white", borderRadius: 10, padding: "8px", textAlign: "center", border: `1px solid ${C.accent}40` }}>
                      <p style={{ fontSize: 14, fontWeight: 700, color: C.accent, margin: 0 }}>$1.99</p>
                      <p style={{ fontSize: 9, color: C.textMuted, margin: "1px 0 0" }}>/ month</p>
                    </div>
                    <div style={{ flex: 1, background: "white", borderRadius: 10, padding: "8px", textAlign: "center", border: `2px solid ${C.accent}` }}>
                      <p style={{ fontSize: 14, fontWeight: 700, color: C.accent, margin: 0 }}>$14.99</p>
                      <p style={{ fontSize: 9, color: C.textMuted, margin: "1px 0 0" }}>/ year (save 37%)</p>
                    </div>
                    <div style={{ flex: 1, background: "white", borderRadius: 10, padding: "8px", textAlign: "center", border: `1px solid ${C.accent}40` }}>
                      <p style={{ fontSize: 14, fontWeight: 700, color: C.accent, margin: 0 }}>$39.99</p>
                      <p style={{ fontSize: 9, color: C.textMuted, margin: "1px 0 0" }}>lifetime</p>
                    </div>
                  </div>
                </div>
                <button style={{ width: "100%", padding: 0, background: "none", border: "none", cursor: "pointer", textAlign: "left" }}>
                  <span style={{ fontSize: 12, color: C.textMuted }}>Restore purchases</span>
                </button>
              </div>
            </GroupCard>

            {/* ===== ABOUT & SUPPORT ===== */}
            <SectionHeader label="Support" />
            <GroupCard>
              <Row icon="❓" label="Help & FAQ" chevron onClick={() => {}} />
              <Divider />
              <Row icon="💬" label="Send Feedback" chevron onClick={() => {}} />
              <Divider />
              <Row icon="⭐" label="Rate Hayya" chevron onClick={() => {}} />
              <Divider />
              <Row icon="📋" label="Privacy Policy" chevron onClick={() => {}} />
              <Divider />
              <Row icon="📄" label="Terms of Service" chevron onClick={() => {}} />
            </GroupCard>

            {/* ===== DATA ===== */}
            <SectionHeader label="Data" />
            <GroupCard>
              <Row icon="📊" label="Export Prayer History" subtitle="Download as CSV" chevron onClick={() => {}} />
              <Divider />
              <Row icon="🗑️" label="Reset All Data" labelColor={C.destructive} subtitle="Cannot be undone" onClick={() => {}} chevron />
            </GroupCard>

            {/* App version */}
            <p style={{ fontSize: 11, color: C.textMuted, textAlign: "center", margin: "16px 0 8px" }}>
              Hayya v1.0.0 (build 1)<br />
              Made with 🤲 for the ummah
            </p>
          </div>

          {/* Floating Tab Bar */}
          <div style={{ padding: "0 24px 16px", flexShrink: 0 }}>
            <div style={{ display: "flex", justifyContent: "space-around", padding: "8px 6px", background: "rgba(255,255,255,0.88)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)", borderRadius: 28, boxShadow: "0 2px 20px rgba(0,0,0,0.06), 0 0 0 0.5px rgba(0,0,0,0.04)" }}>
              {[
                { label: "Today", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M3 7v11a3 3 0 003 3h12a3 3 0 003-3V7"/><path d="M3 7l9 6 9-6"/><path d="M3 7h18"/><circle cx="12" cy="4" r="1.5" fill={c} stroke="none"/></svg> },
                { label: "Together", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="8" r="3"/><circle cx="17" cy="8" r="2.5"/><path d="M3 21v-1a5 5 0 015-5h2a5 5 0 015 5v1"/><path d="M17 13.5a3.5 3.5 0 013.5 3.5V21"/></svg> },
                { label: "Alarms", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/><path d="M6 2L3 4"/><path d="M18 2l3 2"/></svg> },
                { label: "Settings", active: true, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg> },
              ].map((tab, i) => (
                <div key={i} style={{ textAlign: "center", cursor: "pointer", padding: "6px 12px", borderRadius: 20, background: tab.active ? C.primaryLight : "transparent" }}>
                  {tab.icon(tab.active ? C.primary : "#8E8E93")}
                  <p style={{ fontSize: 9, margin: "2px 0 0", fontWeight: tab.active ? 600 : 400, color: tab.active ? C.primary : "#8E8E93" }}>{tab.label}</p>
                </div>
              ))}
            </div>
          </div>

        </div>
      </div>

      <p style={{ fontSize: 11, color: C.textMuted, marginTop: 14, textAlign: "center" }}>
        Tap Calculation Method or Madhab to see inline pickers<br />
        Toggle Track Prayer Quality, Pause Sharing, Silent Mode<br />
        Tap Hide Specific Prayers or Disconnect to see expanded states
      </p>
    </div>
  );
}

// ============================================
// REUSABLE COMPONENTS
// ============================================
function SectionHeader({ label }) {
  return (
    <p style={{ fontSize: 12, fontWeight: 600, color: C.textMuted, textTransform: "uppercase", letterSpacing: 0.6, margin: "16px 4px 6px", padding: 0 }}>{label}</p>
  );
}

function GroupCard({ children }) {
  return (
    <div style={{
      background: "white", borderRadius: 16, overflow: "hidden",
      border: `1px solid ${C.border}`, marginBottom: 2,
    }}>
      {children}
    </div>
  );
}

function Row({ icon, label, value, subtitle, right, onClick, chevron, labelColor }) {
  return (
    <button
      onClick={onClick}
      style={{
        width: "100%", padding: "12px 14px",
        background: "none", border: "none", cursor: onClick ? "pointer" : "default",
        display: "flex", alignItems: "center", gap: 10, textAlign: "left",
      }}
    >
      {icon && <span style={{ fontSize: 16, width: 24, textAlign: "center", flexShrink: 0 }}>{icon}</span>}
      <div style={{ flex: 1, minWidth: 0 }}>
        <p style={{ fontSize: 14, fontWeight: 500, color: labelColor || C.text, margin: 0 }}>{label}</p>
        {subtitle && <p style={{ fontSize: 11, color: C.textMuted, margin: "2px 0 0", lineHeight: 1.3 }}>{subtitle}</p>}
      </div>
      {value && <span style={{ fontSize: 13, color: C.textSecondary, flexShrink: 0 }}>{value}</span>}
      {right}
      {chevron && <span style={{ fontSize: 14, color: C.textMuted, flexShrink: 0 }}>›</span>}
    </button>
  );
}

function Divider() {
  return <div style={{ height: 0.5, background: C.border, marginLeft: 48 }} />;
}

function Toggle({ value, onToggle, color }) {
  const c = color || C.primary;
  return (
    <div
      onClick={(e) => { e.stopPropagation(); onToggle(); }}
      style={{
        width: 44, height: 26, borderRadius: 13, flexShrink: 0,
        background: value ? c : C.border, position: "relative", cursor: "pointer",
        transition: "background .2s",
      }}
    >
      <div style={{
        width: 20, height: 20, borderRadius: 10, background: "white",
        position: "absolute", top: 3, left: value ? 21 : 3,
        transition: "left .2s", boxShadow: "0 1px 3px rgba(0,0,0,.15)",
      }} />
    </div>
  );
}

function StatusBadge({ ok, label }) {
  return (
    <span style={{
      fontSize: 11, fontWeight: 500, flexShrink: 0,
      color: ok ? C.done : C.missed,
      background: ok ? C.doneLight : C.missedLight,
      padding: "3px 8px", borderRadius: 8,
    }}>
      {ok ? "✓" : "✕"} {label}
    </span>
  );
}

function PickerInline({ options, selected, onSelect, note }) {
  return (
    <div style={{ padding: "4px 14px 12px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
        {options.map(opt => (
          <button key={opt} onClick={() => onSelect(opt)} style={{
            padding: "10px 14px", borderRadius: 10, textAlign: "left",
            border: selected === opt ? `1.5px solid ${C.primary}` : `1px solid ${C.border}`,
            background: selected === opt ? C.primaryLight : "white",
            cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "space-between",
          }}>
            <span style={{ fontSize: 13, fontWeight: selected === opt ? 600 : 400, color: selected === opt ? C.primary : C.text }}>{opt}</span>
            {selected === opt && <span style={{ fontSize: 12, color: C.primary }}>✓</span>}
          </button>
        ))}
      </div>
      {note && <p style={{ fontSize: 10, color: C.textMuted, margin: "6px 0 0" }}>{note}</p>}
    </div>
  );
}
