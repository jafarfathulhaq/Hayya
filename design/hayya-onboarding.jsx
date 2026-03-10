import { useState, useEffect } from "react";

const C = {
  bg: "#FDFBF7", primary: "#5B8C6F", primaryLight: "#E8F0EB", primarySoft: "#A8CBB7",
  accent: "#D4A843", accentLight: "#FFF6E3", text: "#2C2C2C", textSecondary: "#8E8E93",
  textMuted: "#B5B5BA", border: "#EBEBF0", done: "#7FC4A0",
  gentle: "#A8C8D4", gentleLight: "#E4EEF2",
  moderate: "#5B8C6F", moderateLight: "#E8F0EB",
  urgent: "#D4A843", urgentLight: "#FFF6E3",
  wakeup: "#C47A5A", wakeupLight: "#FAEEE8",
  overlay: "rgba(0,0,0,0.35)",
};

const DL = {
  gentle: { level: 1, label: "Gentle", desc: "Silent push", color: C.gentle, bg: C.gentleLight },
  moderate: { level: 2, label: "Moderate", desc: "Sound + vibration", color: C.moderate, bg: C.moderateLight },
  urgent: { level: 3, label: "Urgent", desc: "Repeats until opened", color: C.urgent, bg: C.urgentLight },
  wakeup: { level: 4, label: "Wake-Up", desc: "Full alarm", color: C.wakeup, bg: C.wakeupLight },
};
const DKeys = ["gentle", "moderate", "urgent", "wakeup"];

const temporalThemes = {
  ashar: { bg: "#FAF7F2", accent: "#8B7D5E", accentLight: "#F0EBDF", emoji: "🌤️" },
};

const SCREENS = ["identity", "empathy", "setup", "alarm", "dashboard", "companion"];
const LABELS = ["Welcome", "We Understand", "Quick Setup", "Smart Alarm", "You're Ready", "Share the Journey"];

function Bars({ level, color, size = "sm" }) {
  const s = { sm: { w: 3, g: 2, h: [6, 10, 14, 18] }, md: { w: 4, g: 2.5, h: [8, 13, 18, 23] } }[size];
  return (
    <div style={{ display: "flex", alignItems: "flex-end", gap: s.g, height: s.h[3] }}>
      {[0,1,2,3].map(i => <div key={i} style={{ width: s.w, height: s.h[i], borderRadius: s.w/2, background: i < level ? color : C.border }} />)}
    </div>
  );
}

export default function HayyaOnboarding() {
  const [screen, setScreen] = useState(0);
  const [fadeIn, setFadeIn] = useState(true);
  const [busy, setBusy] = useState(false);

  const goTo = (i) => {
    if (busy || i === screen || i < 0 || i >= SCREENS.length) return;
    setBusy(true); setFadeIn(false);
    setTimeout(() => { setScreen(i); setFadeIn(true); setBusy(false); }, 250);
  };

  return (
    <div style={{ minHeight: "100vh", background: "linear-gradient(135deg,#F0EDE6,#E8E4DC 50%,#F2EFE8)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "20px 16px", fontFamily: "'DM Sans','Nunito',system-ui,-apple-system,sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=Noto+Naskh+Arabic:wght@400;500;600&display=swap" rel="stylesheet" />
      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <h1 style={{ fontSize: 16, fontWeight: 600, color: C.text, letterSpacing: 0.5, margin: 0 }}>HAYYA — Onboarding v5</h1>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: "3px 0 0" }}>{screen + 1}/{SCREENS.length}: {LABELS[screen]}</p>
      </div>

      {/* Phone */}
      <div style={{ width: 375, height: 812, borderRadius: 44, background: "#000", padding: 8, boxShadow: "0 24px 80px rgba(0,0,0,0.15),0 8px 24px rgba(0,0,0,0.1)" }}>
        <div style={{ width: "100%", height: "100%", borderRadius: 38, background: C.bg, overflow: "hidden", position: "relative" }}>
          <StatusBar />
          <div style={{ height: "calc(100% - 50px)", opacity: fadeIn ? 1 : 0, transform: fadeIn ? "translateY(0)" : "translateY(6px)", transition: "opacity .25s,transform .25s" }}>
            {screen === 0 && <ScreenIdentity />}
            {screen === 1 && <ScreenEmpathy />}
            {screen === 2 && <ScreenSetup onNext={() => goTo(3)} />}
            {screen === 3 && <ScreenAlarm onNext={() => goTo(4)} />}
            {screen === 4 && <ScreenDashboard />}
            {screen === 5 && <ScreenCompanion />}
          </div>
        </div>
      </div>

      <div style={{ display: "flex", alignItems: "center", gap: 16, marginTop: 18 }}>
        <NavBtn dir="←" disabled={screen === 0} onClick={() => goTo(screen - 1)} />
        <div style={{ display: "flex", gap: 6 }}>
          {SCREENS.map((_, i) => <button key={i} onClick={() => goTo(i)} style={{ width: i === screen ? 24 : 8, height: 8, borderRadius: 4, background: i === screen ? C.primary : C.border, border: "none", cursor: "pointer", transition: "all .3s" }} />)}
        </div>
        <NavBtn dir="→" primary disabled={screen === SCREENS.length - 1} onClick={() => goTo(screen + 1)} />
      </div>
      <p style={{ fontSize: 11, color: C.textMuted, marginTop: 8 }}>Tap arrows or dots to navigate</p>
    </div>
  );
}

function StatusBar() {
  return (
    <div style={{ height: 50, display: "flex", alignItems: "flex-end", justifyContent: "space-between", padding: "0 28px 4px", fontSize: 14, fontWeight: 600, color: C.text, flexShrink: 0 }}>
      <span>9:41</span><span style={{ fontSize: 12 }}>100%</span>
    </div>
  );
}

function NavBtn({ dir, primary, disabled, onClick }) {
  return (
    <button onClick={onClick} disabled={disabled} style={{ width: 44, height: 44, borderRadius: 22, border: primary ? "none" : `2px solid ${disabled ? C.border : C.primary}`, background: primary ? (disabled ? C.border : C.primary) : "transparent", cursor: disabled ? "default" : "pointer", display: "flex", alignItems: "center", justifyContent: "center", opacity: disabled ? 0.3 : 1, transition: "opacity .2s" }}>
      <span style={{ fontSize: 18, color: primary ? "white" : C.primary, marginLeft: dir === "→" ? 2 : -2 }}>{dir}</span>
    </button>
  );
}

// ============================================
// SCREEN 1: IDENTITY — Welcome
// ============================================
function ScreenIdentity() {
  const [s, setS] = useState(false);
  useEffect(() => { setTimeout(() => setS(true), 100); }, []);

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 40px", textAlign: "center" }}>
      <div style={{ width: 76, height: 76, borderRadius: 22, background: `linear-gradient(135deg,${C.primary},${C.primarySoft})`, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 28, opacity: s ? 1 : 0, transform: s ? "scale(1)" : "scale(.8)", transition: "all .6s cubic-bezier(.34,1.56,.64,1)" }}>
        <span style={{ fontSize: 34, color: "white" }}>☽</span>
      </div>
      <h1 style={{ fontSize: 44, fontWeight: 700, color: C.primary, margin: "0 0 10px", letterSpacing: -1, opacity: s ? 1 : 0, transform: s ? "translateY(0)" : "translateY(16px)", transition: "all .6s ease .15s" }}>Hayya</h1>
      <p style={{ fontSize: 20, color: C.text, fontWeight: 500, margin: "0 0 12px", lineHeight: 1.4, opacity: s ? 1 : 0, transition: "all .5s ease .3s" }}>
        A gentle companion<br />for your prayers.
      </p>
      <p style={{ fontSize: 15, color: C.textSecondary, margin: "0 0 16px", lineHeight: 1.6, fontStyle: "italic", opacity: s ? 1 : 0, transition: "opacity .5s ease .45s" }}>
        For the days you pray on time,<br />and the days you're trying to come back.
      </p>
      <div style={{ marginTop: 48, opacity: s ? 1 : 0, transition: "opacity .6s ease .8s" }}>
        <div style={{ display: "flex", gap: 8, justifyContent: "center", marginBottom: 20 }}>
          {["#B8D4C8", "#F2D49B", "#D4B8E0", "#F2B8A8", "#A8C8D4"].map((c, i) => (
            <div key={i} style={{ width: 10, height: 10, borderRadius: 5, background: c, opacity: .7 }} />
          ))}
        </div>
        <button style={{ background: C.primary, color: "white", border: "none", borderRadius: 16, padding: "14px 48px", fontSize: 16, fontWeight: 600, cursor: "pointer" }}>Begin</button>
      </div>
    </div>
  );
}

// ============================================
// SCREEN 2: EMPATHY — "We understand"
// ============================================
function ScreenEmpathy() {
  const [s, setS] = useState(false);
  const [s2, setS2] = useState(false);
  useEffect(() => { setTimeout(() => setS(true), 100); setTimeout(() => setS2(true), 500); }, []);

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 32px", textAlign: "center" }}>
      <p style={{ fontSize: 14, fontWeight: 500, color: C.primary, textTransform: "uppercase", letterSpacing: 2, margin: "0 0 32px", opacity: s ? 1 : 0, transition: "opacity .4s" }}>
        You're not alone in this
      </p>
      <div style={{ width: "100%", maxWidth: 300, display: "flex", flexDirection: "column", gap: 10 }}>
        {[
          { text: "I keep missing Subuh…", delay: 0.1, bg: "#F8F0E8" },
          { text: "I do well for a week, then fall off.", delay: 0.25, bg: "#E8F0EB" },
          { text: "I want to be better, but I keep starting over.", delay: 0.4, bg: "#E4EEF2" },
        ].map((item, i) => (
          <div key={i} style={{ background: item.bg, borderRadius: 16, padding: "14px 18px", textAlign: "left", opacity: s ? 1 : 0, transform: s ? "translateX(0)" : "translateX(-16px)", transition: `all .45s ease ${item.delay}s` }}>
            <p style={{ fontSize: 15, color: C.text, margin: 0, lineHeight: 1.4, fontStyle: "italic" }}>"{item.text}"</p>
          </div>
        ))}
      </div>
      <div style={{ marginTop: 40, opacity: s2 ? 1 : 0, transition: "all .5s ease" }}>
        <h2 style={{ fontSize: 22, fontWeight: 600, color: C.text, margin: "0 0 10px" }}>Every Muslim has felt this.</h2>
        <p style={{ fontSize: 15, color: C.textSecondary, margin: "0 0 12px", lineHeight: 1.5 }}>
          Hayya doesn't judge you for missing a prayer.<br />It helps you come back — every time.
        </p>
        <p style={{ fontSize: 15, color: C.primary, fontWeight: 500, margin: 0, lineHeight: 1.5 }}>
          Just start with the next prayer.
        </p>
      </div>
    </div>
  );
}

// ============================================
// SCREEN 3: QUICK SETUP — Location + Method + Notifications
// ============================================
function ScreenSetup({ onNext }) {
  const [locGranted, setLocGranted] = useState(false);
  const [notifGranted, setNotifGranted] = useState(false);
  const [showChange, setShowChange] = useState(false);
  const [method, setMethod] = useState("Kemenag RI");

  const methods = [
    { id: "Kemenag RI", region: "Indonesia", f: "20°", i: "18°" },
    { id: "MWL", region: "Europe, Global", f: "18°", i: "17°" },
    { id: "ISNA", region: "North America", f: "15°", i: "15°" },
    { id: "Egyptian", region: "Africa, Middle East", f: "19.5°", i: "17.5°" },
    { id: "Umm Al-Qura", region: "Saudi Arabia", f: "18.5°", i: "90min" },
    { id: "JAKIM", region: "Malaysia", f: "20°", i: "18°" },
    { id: "Karachi", region: "Pakistan, India", f: "18°", i: "18°" },
    { id: "Singapore", region: "Singapore", f: "20°", i: "18°" },
    { id: "Diyanet", region: "Turkey", f: "18°", i: "17°" },
    { id: "Dubai", region: "UAE", f: "18.2°", i: "18.2°" },
    { id: "Tehran", region: "Iran", f: "17.7°", i: "14°" },
    { id: "Kuwait", region: "Kuwait", f: "18°", i: "17.5°" },
  ];
  const times = { Subuh: "04:52", Dzuhur: "11:58", Ashar: "15:12", Maghrib: "17:54", Isya: "19:08" };

  return (
    <div style={{ height: "100%", overflowY: "auto", padding: "16px 20px 30px" }}>
      <h2 style={{ fontSize: 24, fontWeight: 700, color: C.text, margin: "0 0 4px" }}>Quick Setup</h2>
      <p style={{ fontSize: 13, color: C.textSecondary, margin: "0 0 20px" }}>Under 30 seconds. Then you're ready.</p>

      {/* 1. Location */}
      <p style={{ fontSize: 11, fontWeight: 600, color: C.textMuted, textTransform: "uppercase", letterSpacing: 0.6, margin: "0 0 8px" }}>1. Your Location</p>
      {!locGranted ? (
        <button onClick={() => setLocGranted(true)} style={{ width: "100%", padding: "16px", borderRadius: 16, border: `1.5px solid ${C.primary}`, background: C.primaryLight, cursor: "pointer", textAlign: "center", marginBottom: 16 }}>
          <p style={{ fontSize: 14, fontWeight: 600, color: C.primary, margin: "0 0 4px" }}>📍 Allow Location Access</p>
          <p style={{ fontSize: 11, color: C.textSecondary, margin: 0 }}>Needed to calculate accurate prayer times</p>
        </button>
      ) : (
        <div style={{ background: "white", borderRadius: 16, padding: "12px 14px", border: `1px solid ${C.border}`, display: "flex", alignItems: "center", gap: 10, marginBottom: 16 }}>
          <span style={{ fontSize: 18 }}>📍</span>
          <div style={{ flex: 1 }}>
            <p style={{ fontSize: 15, fontWeight: 600, color: C.text, margin: 0 }}>Jakarta, Indonesia</p>
            <p style={{ fontSize: 11, color: C.done, margin: "2px 0 0" }}>✓ Location detected</p>
          </div>
        </div>
      )}

      {/* 2. Prayer Times */}
      {locGranted && (
        <>
          <p style={{ fontSize: 11, fontWeight: 600, color: C.textMuted, textTransform: "uppercase", letterSpacing: 0.6, margin: "0 0 8px" }}>2. Prayer Times</p>
          <div style={{ background: "white", borderRadius: 16, padding: "14px", border: `1px solid ${C.border}`, marginBottom: 16 }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
              <div>
                <p style={{ fontSize: 14, fontWeight: 600, color: C.text, margin: 0 }}>{method}</p>
                <p style={{ fontSize: 11, color: C.textSecondary, margin: "2px 0 0" }}>Recommended for your location</p>
              </div>
              <button onClick={() => setShowChange(!showChange)} style={{ background: "none", border: "none", cursor: "pointer" }}>
                <span style={{ fontSize: 12, color: C.primary, fontWeight: 500 }}>{showChange ? "Done" : "Change"}</span>
              </button>
            </div>
            {showChange && (
              <div style={{ maxHeight: 140, overflowY: "auto", display: "flex", flexDirection: "column", gap: 4, marginBottom: 10 }}>
                {methods.map(m => (
                  <button key={m.id} onClick={() => { setMethod(m.id); setShowChange(false); }} style={{ padding: "8px 12px", borderRadius: 10, textAlign: "left", border: method === m.id ? `1.5px solid ${C.primary}` : `1px solid ${C.border}`, background: method === m.id ? C.primaryLight : "white", cursor: "pointer", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <div>
                      <span style={{ fontSize: 12, fontWeight: method === m.id ? 600 : 400, color: method === m.id ? C.primary : C.text }}>{m.id}</span>
                      <span style={{ fontSize: 10, color: C.textMuted, marginLeft: 6 }}>{m.region}</span>
                    </div>
                    <span style={{ fontSize: 9, color: C.textMuted }}>F:{m.f} I:{m.i}</span>
                  </button>
                ))}
              </div>
            )}
            <div style={{ background: C.primaryLight, borderRadius: 12, padding: "10px 12px" }}>
              <p style={{ fontSize: 10, fontWeight: 600, color: C.primary, margin: "0 0 6px" }}>TODAY'S PRAYER TIMES</p>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                {Object.entries(times).map(([n, t]) => (
                  <div key={n} style={{ textAlign: "center" }}>
                    <p style={{ fontSize: 13, fontWeight: 600, color: C.text, margin: 0 }}>{t}</p>
                    <p style={{ fontSize: 9, color: C.textSecondary, margin: "2px 0 0" }}>{n}</p>
                  </div>
                ))}
              </div>
            </div>
            <p style={{ fontSize: 10, color: C.textMuted, margin: "6px 0 0", textAlign: "center" }}>Verify these match your local mosque</p>
          </div>
        </>
      )}

      {/* 3. Notifications */}
      {locGranted && (
        <>
          <p style={{ fontSize: 11, fontWeight: 600, color: C.textMuted, textTransform: "uppercase", letterSpacing: 0.6, margin: "0 0 8px" }}>3. Notifications</p>
          {!notifGranted ? (
            <button onClick={() => setNotifGranted(true)} style={{ width: "100%", padding: "14px", borderRadius: 16, border: `1.5px solid ${C.primary}`, background: "white", cursor: "pointer", textAlign: "center", marginBottom: 20 }}>
              <p style={{ fontSize: 14, fontWeight: 600, color: C.primary, margin: "0 0 4px" }}>🔔 Allow Notifications</p>
              <p style={{ fontSize: 11, color: C.textSecondary, margin: 0 }}>So Hayya can remind you at each prayer time</p>
            </button>
          ) : (
            <div style={{ background: "white", borderRadius: 16, padding: "12px 14px", border: `1px solid ${C.border}`, display: "flex", alignItems: "center", gap: 10, marginBottom: 20 }}>
              <span style={{ fontSize: 18 }}>🔔</span>
              <div>
                <p style={{ fontSize: 14, fontWeight: 500, color: C.text, margin: 0 }}>Notifications enabled</p>
                <p style={{ fontSize: 11, color: C.done, margin: "2px 0 0" }}>✓ Hayya will remind you for each prayer</p>
              </div>
            </div>
          )}
        </>
      )}

      {locGranted && notifGranted && (
        <button onClick={onNext} style={{ width: "100%", padding: "16px", borderRadius: 16, border: "none", background: C.primary, color: "white", fontSize: 16, fontWeight: 600, cursor: "pointer" }}>
          Next: set up your first alarm →
        </button>
      )}
    </div>
  );
}

// ============================================
// SCREEN 4: SMART ALARM — Hands-on setup of ONE prayer
// ============================================
function ScreenAlarm({ onNext }) {
  const [disruption, setDisruption] = useState("moderate");
  const [snooze, setSnooze] = useState(15);
  const [maxSnooze, setMaxSnooze] = useState(2);
  const [offset, setOffset] = useState(0);
  const [sound, setSound] = useState("Default chime");
  const [done, setDone] = useState(false);

  const meta = DL[disruption];
  const sounds = ["Default chime", "Soft bell", "Gentle pulse", "Morning birds"];

  const computeTime = (off) => {
    let t = 15 * 60 + 12 + off; // Ashar 15:12
    return `${String(Math.floor(t / 60) % 24).padStart(2, "0")}:${String(t % 60).padStart(2, "0")}`;
  };

  if (done) {
    return (
      <div style={{ height: "100%", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 28px", textAlign: "center" }}>
        <div style={{ width: 56, height: 56, borderRadius: 18, background: C.primaryLight, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 16 }}>
          <span style={{ fontSize: 24, color: C.primary }}>✓</span>
        </div>
        <h2 style={{ fontSize: 22, fontWeight: 700, color: C.text, margin: "0 0 8px" }}>Your alarms are ready</h2>
        <p style={{ fontSize: 14, color: C.textSecondary, margin: "0 0 20px", lineHeight: 1.5 }}>
          We've set smart defaults for your other 4 prayers<br />based on your Ashar setup. Customize anytime.
        </p>

        <div style={{ width: "100%", background: C.primaryLight, borderRadius: 16, padding: "14px 16px", marginBottom: 24 }}>
          <p style={{ fontSize: 12, fontWeight: 600, color: C.primary, margin: "0 0 10px" }}>Your alarm profile</p>
          {[
            { n: "Subuh", lvl: "Wake-Up", clr: C.wakeup, l: 4 },
            { n: "Dzuhur", lvl: meta.label, clr: meta.color, l: meta.level },
            { n: "Ashar", lvl: meta.label, clr: meta.color, l: meta.level, you: true },
            { n: "Maghrib", lvl: "Urgent", clr: C.urgent, l: 3 },
            { n: "Isya", lvl: meta.label, clr: meta.color, l: meta.level },
          ].map((p, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "6px 0", borderBottom: i < 4 ? `1px solid ${C.border}` : "none" }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <Bars level={p.l} color={p.clr} />
                <span style={{ fontSize: 13, fontWeight: 500, color: C.text }}>{p.n}</span>
                {p.you && <span style={{ fontSize: 9, color: C.primary, background: C.primaryLight, padding: "1px 6px", borderRadius: 6, fontWeight: 600 }}>you set this</span>}
              </div>
              <span style={{ fontSize: 12, color: p.clr, fontWeight: 500 }}>{p.lvl}</span>
            </div>
          ))}
        </div>
        <p style={{ fontSize: 11, color: C.textMuted, margin: "0 0 16px" }}>Subuh is always Wake-Up. Maghrib is always Urgent.<br />Short prayer windows need stronger reminders.</p>

        <button onClick={onNext} style={{ width: "100%", padding: "16px", borderRadius: 16, border: "none", background: C.primary, color: "white", fontSize: 16, fontWeight: 600, cursor: "pointer" }}>
          See your dashboard →
        </button>
      </div>
    );
  }

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column" }}>
      {/* Header */}
      <div style={{ padding: "12px 20px 10px", flexShrink: 0 }}>
        <p style={{ fontSize: 12, fontWeight: 500, color: C.primary, textTransform: "uppercase", letterSpacing: 1, margin: "0 0 4px" }}>Set up your first alarm</p>
        <h2 style={{ fontSize: 22, fontWeight: 700, color: C.text, margin: "0 0 4px" }}>Ashar · 15:12</h2>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: 0 }}>Your next prayer. Configure it, then we'll set the rest.</p>
      </div>

      {/* Bottom sheet style editor (inline, no overlay) */}
      <div style={{ flex: 1, overflowY: "auto", background: "white", borderRadius: "20px 20px 0 0", padding: "16px 20px 20px", borderTop: `1px solid ${C.border}` }}>
        {/* Drag handle visual */}
        <div style={{ display: "flex", justifyContent: "center", marginBottom: 14 }}>
          <div style={{ width: 36, height: 4, borderRadius: 2, background: C.border }} />
        </div>

        {/* 1. Disruption */}
        <Label>How should Hayya remind you?</Label>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, marginBottom: 20 }}>
          {DKeys.map(key => {
            const d = DL[key];
            const sel = disruption === key;
            return (
              <button key={key} onClick={() => setDisruption(key)} style={{ padding: "12px", borderRadius: 16, border: sel ? `2px solid ${d.color}` : `1.5px solid ${C.border}`, background: sel ? d.bg : "white", cursor: "pointer", textAlign: "left", display: "flex", alignItems: "center", gap: 10 }}>
                <Bars level={d.level} color={sel ? d.color : C.textMuted} />
                <div>
                  <p style={{ fontSize: 13, fontWeight: sel ? 600 : 400, color: sel ? d.color : C.text, margin: 0 }}>{d.label}</p>
                  <p style={{ fontSize: 10, color: C.textSecondary, margin: "2px 0 0" }}>{d.desc}</p>
                </div>
              </button>
            );
          })}
        </div>

        {/* 2. Snooze */}
        <Label>Snooze interval</Label>
        <div style={{ display: "flex", gap: 6, marginBottom: 8 }}>
          {[0, 5, 15, 30].map(v => (
            <button key={v} onClick={() => setSnooze(v)} style={{ flex: 1, padding: "10px 0", borderRadius: 12, textAlign: "center", border: snooze === v ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`, background: snooze === v ? meta.bg : "white", fontSize: 13, fontWeight: snooze === v ? 600 : 400, color: snooze === v ? meta.color : C.textSecondary, cursor: "pointer" }}>{v === 0 ? "Off" : `${v} min`}</button>
          ))}
        </div>
        {snooze > 0 && (
          <div style={{ marginBottom: 8 }}>
            <p style={{ fontSize: 11, color: C.textMuted, margin: "0 0 6px" }}>Repeat count</p>
            <div style={{ display: "flex", gap: 6 }}>
              {[1, 2, 3].map(v => (
                <button key={v} onClick={() => setMaxSnooze(v)} style={{ flex: 1, padding: "10px 0", borderRadius: 12, textAlign: "center", border: maxSnooze === v ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`, background: maxSnooze === v ? meta.bg : "white", fontSize: 13, fontWeight: maxSnooze === v ? 600 : 400, color: maxSnooze === v ? meta.color : C.textSecondary, cursor: "pointer" }}>{v} time{v > 1 ? "s" : ""}</button>
              ))}
            </div>
          </div>
        )}
        <p style={{ fontSize: 11, color: C.textMuted, margin: "0 0 20px" }}>
          {snooze === 0 ? "No snooze — alarm fires once" : `One tap at alarm time. Window: ${snooze * maxSnooze} min`}
        </p>

        {/* 3. Offset */}
        <Label>Offset from azan</Label>
        <div style={{ display: "flex", gap: 6, justifyContent: "center", marginBottom: 6 }}>
          {[-5, 0, 5, 10, 15].map(v => (
            <button key={v} onClick={() => setOffset(v)} style={{ padding: "8px 14px", borderRadius: 12, border: offset === v ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`, background: offset === v ? meta.bg : "white", fontSize: 13, fontWeight: offset === v ? 600 : 400, color: offset === v ? meta.color : C.textSecondary, cursor: "pointer" }}>{v === 0 ? "0" : v > 0 ? `+${v}` : `${v}`}</button>
          ))}
        </div>
        <p style={{ fontSize: 12, color: meta.color, fontWeight: 500, textAlign: "center", margin: "0 0 2px" }}>
          {offset === 0 ? "At azan time" : offset > 0 ? `${offset} min after azan` : `${Math.abs(offset)} min before azan`}
        </p>
        <p style={{ fontSize: 18, color: C.text, fontWeight: 700, textAlign: "center", margin: "0 0 20px" }}>
          Alarm at {computeTime(offset)}
        </p>

        {/* 4. Sound */}
        <Label>Sound</Label>
        <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 24 }}>
          {sounds.map(s => (
            <button key={s} onClick={() => setSound(s)} style={{ padding: "8px 14px", borderRadius: 12, border: sound === s ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`, background: sound === s ? meta.bg : "white", fontSize: 12, fontWeight: sound === s ? 600 : 400, color: sound === s ? meta.color : C.textSecondary, cursor: "pointer", display: "flex", alignItems: "center", gap: 5 }}>
              <span style={{ fontSize: 10, opacity: 0.5 }}>▶</span>{s}
            </button>
          ))}
        </div>

        {/* Confirm */}
        <button onClick={() => setDone(true)} style={{ width: "100%", padding: "16px", borderRadius: 16, border: "none", background: C.primary, color: "white", fontSize: 16, fontWeight: 600, cursor: "pointer" }}>
          Set Ashar alarm →
        </button>
        <p style={{ fontSize: 10, color: C.textMuted, textAlign: "center", margin: "8px 0 0" }}>We'll set smart defaults for the other 4 prayers</p>
      </div>
    </div>
  );
}

// ============================================
// SCREEN 5: DASHBOARD — You're ready
// ============================================
function ScreenDashboard() {
  const [s, setS] = useState(false);
  useEffect(() => { setTimeout(() => setS(true), 100); }, []);

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", padding: "8px 14px" }}>
      <div style={{ padding: "4px 6px 8px" }}>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: "0 0 1px" }}>14 Ramadan 1447 · 10 Mar 2026</p>
        <p style={{ fontSize: 11, color: C.textMuted, margin: 0 }}>📍 Jakarta</p>
      </div>

      <div style={{ flex: 1, overflowY: "auto", display: "flex", flexDirection: "column", gap: 8, padding: "4px 0" }}>
        {[
          { name: "Subuh", ar: "الصبح", time: "04:52", status: "done" },
          { name: "Dzuhur", ar: "الظهر", time: "11:58", status: "done" },
          { name: "Ashar", ar: "العصر", time: "15:12", status: "active" },
          { name: "Maghrib", ar: "المغرب", time: "17:54", status: "upcoming" },
          { name: "Isya", ar: "العشاء", time: "19:08", status: "upcoming" },
        ].map((p, i) => {
          const colors = { done: C.done, active: C.primary, upcoming: C.border };
          return (
            <div key={i} style={{
              background: "white", borderRadius: 18, padding: "14px 16px",
              border: p.status === "active" ? `1.5px solid ${C.primary}` : `1px solid ${C.border}`,
              display: "flex", alignItems: "center", gap: 12,
              opacity: s ? 1 : 0, transform: s ? "translateY(0)" : "translateY(8px)",
              transition: `all .4s ease ${i * 0.08}s`,
            }}>
              <div style={{ width: 36, height: 36, borderRadius: 12, background: p.status === "done" ? "#EEFAF3" : p.status === "active" ? C.primaryLight : "#F5F5F7", display: "flex", alignItems: "center", justifyContent: "center" }}>
                {p.status === "done" && <span style={{ fontSize: 14, color: C.done }}>✓</span>}
                {p.status === "active" && <span style={{ fontSize: 14, color: C.primary }}>●</span>}
                {p.status === "upcoming" && <span style={{ fontSize: 14, color: C.textMuted }}>○</span>}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ display: "flex", alignItems: "baseline", gap: 6 }}>
                  <span style={{ fontSize: 16, fontWeight: 600, color: C.text }}>{p.name}</span>
                  <span style={{ fontSize: 13, color: C.textMuted, fontFamily: "'Noto Naskh Arabic',serif" }}>{p.ar}</span>
                </div>
                <span style={{ fontSize: 12, color: C.textSecondary }}>{p.time}</span>
              </div>
              {p.status === "active" && <div style={{ padding: "8px 16px", borderRadius: 12, background: C.primary, color: "white", fontSize: 13, fontWeight: 600 }}>Check In</div>}
            </div>
          );
        })}
      </div>

      <div style={{ textAlign: "center", padding: "12px 0 8px", opacity: s ? 1 : 0, transition: "opacity .5s ease .5s" }}>
        <p style={{ fontSize: 15, fontWeight: 600, color: C.text, margin: "0 0 4px" }}>Your prayers are ready.</p>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: 0 }}>Hayya will remind you at each prayer time.</p>
      </div>
    </div>
  );
}

// ============================================
// SCREEN 6: COMPANION — Optional invite
// ============================================
function ScreenCompanion() {
  const [s, setS] = useState(false);
  useEffect(() => { setTimeout(() => setS(true), 100); }, []);

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 28px", textAlign: "center" }}>
      {/* Spiritual reflection */}
      <div style={{
        width: "100%", background: C.primaryLight, borderRadius: 18,
        padding: "20px 18px", textAlign: "center", marginBottom: 24,
        opacity: s ? 1 : 0, transition: "opacity .5s ease .1s",
      }}>
        <p style={{ fontSize: 14, color: C.text, margin: "0 0 6px", lineHeight: 1.6, fontStyle: "italic" }}>
          "The prayer in congregation is twenty-seven times better than the prayer offered alone."
        </p>
        <p style={{ fontSize: 11, color: C.textMuted, margin: 0 }}>— Sahih Bukhari & Muslim</p>
      </div>

      <h2 style={{ fontSize: 22, fontWeight: 600, color: C.text, margin: "0 0 8px", opacity: s ? 1 : 0, transition: "opacity .5s ease .2s" }}>
        Share this journey?
      </h2>
      <p style={{ fontSize: 14, color: C.textSecondary, margin: "0 0 24px", lineHeight: 1.5, opacity: s ? 1 : 0, transition: "opacity .5s ease .3s" }}>
        Invite someone you trust to pray alongside you.<br />See each other's progress. Remind each other gently.
      </p>

      <div style={{ width: "100%", display: "flex", flexDirection: "column", gap: 8, marginBottom: 20, opacity: s ? 1 : 0, transition: "opacity .5s ease .4s" }}>
        {[
          { icon: "💑", label: "My spouse" },
          { icon: "👨‍👩‍👧", label: "Family" },
          { icon: "🤝", label: "Friend" },
        ].map((r, i) => (
          <button key={i} style={{ width: "100%", padding: "14px 16px", borderRadius: 14, border: `1.5px solid ${C.border}`, background: "white", cursor: "pointer", display: "flex", alignItems: "center", gap: 12, textAlign: "left" }}>
            <span style={{ fontSize: 20 }}>{r.icon}</span>
            <span style={{ fontSize: 14, fontWeight: 500, color: C.text }}>{r.label}</span>
            <span style={{ marginLeft: "auto", fontSize: 14, color: C.textMuted }}>›</span>
          </button>
        ))}
      </div>

      <button style={{ width: "100%", padding: "14px", borderRadius: 14, border: "none", background: C.primary, color: "white", fontSize: 15, fontWeight: 600, cursor: "pointer", opacity: s ? 1 : 0, transition: "opacity .5s ease .5s" }}>
        Invite via WhatsApp
      </button>

      <button style={{ background: "none", border: "none", cursor: "pointer", marginTop: 12, padding: "8px", opacity: s ? 1 : 0, transition: "opacity .5s ease .6s" }}>
        <span style={{ fontSize: 13, color: C.textMuted }}>Skip — I'll do this later</span>
      </button>
      <p style={{ fontSize: 10, color: C.textMuted, margin: "6px 0 0", opacity: s ? 1 : 0, transition: "opacity .5s ease .7s" }}>
        You can always invite someone from the Together tab
      </p>
    </div>
  );
}

function Label({ children }) {
  return <p style={{ fontSize: 11, fontWeight: 600, color: C.textMuted, textTransform: "uppercase", letterSpacing: 0.8, margin: "0 0 8px" }}>{children}</p>;
}
