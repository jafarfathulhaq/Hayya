import { useState } from "react";

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
  gentle: { level: 1, label: "Gentle", desc: "Silent push notification", color: C.gentle, bg: C.gentleLight },
  moderate: { level: 2, label: "Moderate", desc: "Sound + vibration, once", color: C.moderate, bg: C.moderateLight },
  urgent: { level: 3, label: "Urgent", desc: "Repeats until opened", color: C.urgent, bg: C.urgentLight },
  wakeup: { level: 4, label: "Wake-Up", desc: "Full alarm until dismissed", color: C.wakeup, bg: C.wakeupLight },
};
const DKeys = ["gentle", "moderate", "urgent", "wakeup"];
const sounds = ["Default chime", "Soft bell", "Gentle pulse", "Morning birds"];

const initPrayers = [
  { name: "Subuh", arabic: "الصبح", time: "04:52", disruption: "wakeup", offset: 0, sound: "Default chime", snooze: 5, maxSnooze: 3, preAlarm: 30, shortWindow: true },
  { name: "Dzuhur", arabic: "الظهر", time: "11:58", disruption: "gentle", offset: 0, sound: "Default chime", snooze: 15, maxSnooze: 2, preAlarm: 0, shortWindow: false },
  { name: "Ashar", arabic: "العصر", time: "15:12", disruption: "gentle", offset: 0, sound: "Default chime", snooze: 15, maxSnooze: 2, preAlarm: 0, shortWindow: false },
  { name: "Maghrib", arabic: "المغرب", time: "17:54", disruption: "urgent", offset: 0, sound: "Default chime", snooze: 5, maxSnooze: 2, preAlarm: 15, shortWindow: true },
  { name: "Isya", arabic: "العشاء", time: "19:08", disruption: "moderate", offset: 0, sound: "Default chime", snooze: 15, maxSnooze: 2, preAlarm: 0, shortWindow: false },
];

function Bars({ level, color, size = "md", pulse = false }) {
  const s = { sm: { w: 3, g: 2, h: [6, 10, 14, 18] }, md: { w: 4, g: 2.5, h: [8, 13, 18, 23] } }[size];
  return (
    <div style={{ display: "flex", alignItems: "flex-end", gap: s.g, height: s.h[3], animation: pulse ? "pulse 3s ease-in-out infinite" : "none" }}>
      <style>{`@keyframes pulse { 0%,100% { opacity:.85; } 50% { opacity:1; } }`}</style>
      {[0,1,2,3].map(i => <div key={i} style={{ width: s.w, height: s.h[i], borderRadius: s.w/2, background: i < level ? color : C.border }} />)}
    </div>
  );
}

function computeTime(base, offset) {
  const [h, m] = base.split(":").map(Number);
  let t = h * 60 + m + offset;
  if (t < 0) t += 1440;
  return `${String(Math.floor(t / 60) % 24).padStart(2, "0")}:${String(t % 60).padStart(2, "0")}`;
}

export default function AlarmSettings() {
  const [prayers, setPrayers] = useState(initPrayers.map(p => ({ ...p })));
  const [sheet, setSheet] = useState(null); // index of open prayer
  const [toast, setToast] = useState(null);
  const nextIdx = 4; // Isya is next

  const update = (idx, key, val) => setPrayers(prev => prev.map((p, i) => i === idx ? { ...p, [key]: val } : p));
  const showToast = (msg) => { setToast(msg); setTimeout(() => setToast(null), 2200); };

  const applyToOthers = (fromIdx, targetIdxs) => {
    const src = prayers[fromIdx];
    setPrayers(prev => prev.map((p, i) => targetIdxs.includes(i) ? { ...p, disruption: src.disruption, snooze: src.snooze, offset: src.offset, sound: src.sound, preAlarm: src.preAlarm } : p));
    showToast(`✓ Applied to ${targetIdxs.length} prayer${targetIdxs.length > 1 ? "s" : ""}`);
    setSheet(null);
  };

  const prayer = sheet !== null ? prayers[sheet] : null;
  const meta = prayer ? DL[prayer.disruption] : null;

  return (
    <div style={{ minHeight: "100vh", background: "linear-gradient(135deg,#F0EDE6,#E8E4DC 50%,#F2EFE8)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "20px 16px", fontFamily: "'DM Sans','Nunito',system-ui,-apple-system,sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=Noto+Naskh+Arabic:wght@400;500;600&display=swap" rel="stylesheet" />
      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <h1 style={{ fontSize: 16, fontWeight: 600, color: C.text, letterSpacing: 0.5, margin: 0 }}>HAYYA — Alarm Settings v2</h1>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: "3px 0 0" }}>Bottom sheet editor • Tap any prayer to configure</p>
      </div>

      {/* Phone */}
      <div style={{ width: 375, height: 812, borderRadius: 44, background: "#000", padding: 8, boxShadow: "0 24px 80px rgba(0,0,0,0.15)" }}>
        <div style={{ width: "100%", height: "100%", borderRadius: 38, background: C.bg, overflow: "hidden", display: "flex", flexDirection: "column", position: "relative" }}>

          {/* Status Bar */}
          <div style={{ height: 50, display: "flex", alignItems: "flex-end", justifyContent: "space-between", padding: "0 28px 4px", fontSize: 14, fontWeight: 600, color: C.text, flexShrink: 0 }}>
            <span>9:41</span><span style={{ fontSize: 12 }}>100%</span>
          </div>

          {/* Header */}
          <div style={{ padding: "4px 20px 10px", flexShrink: 0 }}>
            <h2 style={{ fontSize: 26, fontWeight: 700, color: C.text, margin: "0 0 3px" }}>Alarms</h2>
            <p style={{ fontSize: 12, color: C.textMuted, margin: 0 }}>Set each prayer's alarm, your way.</p>
          </div>

          {/* Overview Strip */}
          <div style={{ padding: "0 16px 10px", flexShrink: 0 }}>
            <div style={{ display: "flex", justifyContent: "space-between", background: "white", borderRadius: 16, padding: "10px 12px", border: `1px solid ${C.border}` }}>
              {prayers.map((p, i) => {
                const m = DL[p.disruption];
                const isNext = i === nextIdx;
                return (
                  <button key={i} onClick={() => setSheet(i)} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 3, background: "none", border: "none", cursor: "pointer", padding: "2px 4px", borderRadius: 8 }}>
                    <Bars level={m.level} color={m.color} size="sm" pulse={isNext} />
                    <span style={{ fontSize: 11, fontWeight: 600, color: C.text }}>{computeTime(p.time, p.offset)}</span>
                    <span style={{ fontSize: 9, color: isNext ? C.primary : C.textMuted, fontWeight: isNext ? 600 : 400 }}>{p.name}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Prayer List */}
          <div style={{ flex: 1, overflowY: "auto", padding: "0 14px 14px" }}>
            {prayers.map((p, i) => {
              const m = DL[p.disruption];
              const isNext = i === nextIdx;
              return (
                <button key={i} onClick={() => setSheet(i)} style={{
                  width: "100%", background: "white", borderRadius: 18, padding: "14px 14px",
                  border: isNext ? `1.5px solid ${C.primary}` : `1px solid ${C.border}`,
                  cursor: "pointer", display: "flex", alignItems: "center", gap: 12,
                  marginBottom: 8, textAlign: "left", transition: "all .15s",
                }}>
                  <div style={{ width: 40, height: 40, borderRadius: 14, background: m.bg, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                    <Bars level={m.level} color={m.color} size="sm" />
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: "flex", alignItems: "baseline", gap: 6 }}>
                      <span style={{ fontSize: 16, fontWeight: 600, color: C.text }}>{p.name}</span>
                      <span style={{ fontSize: 13, color: C.textMuted, fontFamily: "'Noto Naskh Arabic',serif" }}>{p.arabic}</span>
                    </div>
                    <div style={{ display: "flex", alignItems: "center", gap: 6, marginTop: 2 }}>
                      <span style={{ fontSize: 13, fontWeight: 500, color: C.text }}>{computeTime(p.time, p.offset)}</span>
                      <span style={{ fontSize: 10, color: C.textMuted }}>
                        {p.offset === 0 ? "at azan" : `azan ${p.time}`} · {m.label} · Snooze {p.snooze === 0 ? "off" : `${p.snooze}m`}
                      </span>
                    </div>
                  </div>
                  <span style={{ fontSize: 18, color: C.textMuted }}>›</span>
                </button>
              );
            })}

            <p style={{ fontSize: 11, color: C.textMuted, textAlign: "center", margin: "8px 0 0", lineHeight: 1.5 }}>
              Changes saved automatically.<br />Azan voice can be set in Settings → Sound.
            </p>
          </div>

          {/* Tab Bar */}
          <div style={{ padding: "0 24px 16px", flexShrink: 0 }}>
            <div style={{ display: "flex", justifyContent: "space-around", padding: "8px 6px", background: "rgba(255,255,255,0.88)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)", borderRadius: 28, boxShadow: "0 2px 20px rgba(0,0,0,0.06), 0 0 0 0.5px rgba(0,0,0,0.04)" }}>
              {[
                { label: "Today", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M3 7v11a3 3 0 003 3h12a3 3 0 003-3V7"/><path d="M3 7l9 6 9-6"/><path d="M3 7h18"/><circle cx="12" cy="4" r="1.5" fill={c} stroke="none"/></svg> },
                { label: "Together", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="8" r="3"/><circle cx="17" cy="8" r="2.5"/><path d="M3 21v-1a5 5 0 015-5h2a5 5 0 015 5v1"/><path d="M17 13.5a3.5 3.5 0 013.5 3.5V21"/></svg> },
                { label: "Alarms", active: true, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/><path d="M6 2L3 4"/><path d="M18 2l3 2"/></svg> },
                { label: "Settings", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg> },
              ].map((tab, i) => (
                <div key={i} style={{ textAlign: "center", cursor: "pointer", padding: tab.active ? "7px 16px" : "7px 12px", borderRadius: 22, background: tab.active ? C.primaryLight : "transparent" }}>
                  {tab.icon(tab.active ? C.primary : "#8E8E93")}
                  <p style={{ fontSize: 9, margin: "2px 0 0", fontWeight: tab.active ? 600 : 400, color: tab.active ? C.primary : "#8E8E93" }}>{tab.label}</p>
                </div>
              ))}
            </div>
          </div>

          {/* ===== BOTTOM SHEET OVERLAY ===== */}
          {sheet !== null && (
            <>
              {/* Dim background */}
              <div onClick={() => setSheet(null)} style={{ position: "absolute", inset: 0, background: C.overlay, zIndex: 90, borderRadius: 38 }} />

              {/* Sheet */}
              <div style={{
                position: "absolute", bottom: 0, left: 0, right: 0,
                height: "85%", background: "white", borderRadius: "24px 24px 0 0",
                zIndex: 100, display: "flex", flexDirection: "column",
                boxShadow: "0 -8px 40px rgba(0,0,0,0.1)",
              }}>
                {/* Drag handle */}
                <div style={{ display: "flex", justifyContent: "center", padding: "10px 0 4px" }}>
                  <div style={{ width: 36, height: 4, borderRadius: 2, background: C.border }} />
                </div>

                {/* Prayer identity header */}
                <div style={{ padding: "4px 20px 14px", display: "flex", alignItems: "center", justifyContent: "space-between", borderBottom: `1px solid ${C.border}` }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                    <div style={{ width: 40, height: 40, borderRadius: 14, background: meta.bg, display: "flex", alignItems: "center", justifyContent: "center" }}>
                      <Bars level={meta.level} color={meta.color} size="sm" />
                    </div>
                    <div>
                      <div style={{ display: "flex", alignItems: "baseline", gap: 6 }}>
                        <span style={{ fontSize: 18, fontWeight: 700, color: C.text }}>{prayer.name}</span>
                        <span style={{ fontSize: 15, color: C.textMuted, fontFamily: "'Noto Naskh Arabic',serif" }}>{prayer.arabic}</span>
                      </div>
                      <span style={{ fontSize: 12, color: C.textSecondary }}>Azan at {prayer.time} · Alarm at {computeTime(prayer.time, prayer.offset)}</span>
                    </div>
                  </div>
                  <button onClick={() => setSheet(null)} style={{ background: C.border, width: 28, height: 28, borderRadius: 14, border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <span style={{ fontSize: 14, color: C.textSecondary }}>✕</span>
                  </button>
                </div>

                {/* Scrollable controls */}
                <div style={{ flex: 1, overflowY: "auto", padding: "16px 20px 20px" }}>

                  {/* 1. Disruption Level */}
                  <Label>Disruption Level</Label>
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, marginBottom: 22 }}>
                    {DKeys.map(key => {
                      const d = DL[key];
                      const sel = prayer.disruption === key;
                      return (
                        <button key={key} onClick={() => update(sheet, "disruption", key)} style={{
                          padding: "12px 12px", borderRadius: 16,
                          border: sel ? `2px solid ${d.color}` : `1.5px solid ${C.border}`,
                          background: sel ? d.bg : "white", cursor: "pointer", textAlign: "left",
                          display: "flex", alignItems: "center", gap: 10,
                        }}>
                          <Bars level={d.level} color={sel ? d.color : C.textMuted} size="sm" />
                          <div>
                            <p style={{ fontSize: 13, fontWeight: sel ? 600 : 400, color: sel ? d.color : C.text, margin: 0 }}>{d.label}</p>
                            <p style={{ fontSize: 10, color: C.textSecondary, margin: "2px 0 0" }}>{d.desc}</p>
                          </div>
                        </button>
                      );
                    })}
                  </div>

                  {/* 2. Snooze Interval */}
                  <Label>Snooze Interval</Label>
                  <div style={{ display: "flex", gap: 6, marginBottom: 8 }}>
                    {(prayer.shortWindow ? [0, 5, 10, 15] : [0, 5, 15, 30]).map(v => (
                      <button key={v} onClick={() => update(sheet, "snooze", v)} style={{
                        flex: 1, padding: "10px 0", borderRadius: 12, textAlign: "center",
                        border: prayer.snooze === v ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`,
                        background: prayer.snooze === v ? meta.bg : "white",
                        fontSize: 13, fontWeight: prayer.snooze === v ? 600 : 400,
                        color: prayer.snooze === v ? meta.color : C.textSecondary, cursor: "pointer",
                      }}>{v === 0 ? "Off" : `${v} min`}</button>
                    ))}
                  </div>
                  {prayer.snooze > 0 && (
                    <div style={{ marginBottom: 8 }}>
                      <p style={{ fontSize: 11, color: C.textMuted, margin: "0 0 6px" }}>Repeat count</p>
                      <div style={{ display: "flex", gap: 6 }}>
                        {[1, 2, 3].map(v => (
                          <button key={v} onClick={() => update(sheet, "maxSnooze", v)} style={{
                            flex: 1, padding: "10px 0", borderRadius: 12, textAlign: "center",
                            border: prayer.maxSnooze === v ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`,
                            background: prayer.maxSnooze === v ? meta.bg : "white",
                            fontSize: 13, fontWeight: prayer.maxSnooze === v ? 600 : 400,
                            color: prayer.maxSnooze === v ? meta.color : C.textSecondary, cursor: "pointer",
                          }}>{v} time{v > 1 ? "s" : ""}</button>
                        ))}
                      </div>
                    </div>
                  )}
                  <p style={{ fontSize: 11, color: C.textMuted, margin: "0 0 22px" }}>
                    {prayer.snooze === 0 ? "No snooze — alarm fires once" : `One tap at alarm time. Total window: ${prayer.snooze * prayer.maxSnooze} min`}
                    {prayer.shortWindow && prayer.snooze > 0 ? ` · ${prayer.name === "Subuh" ? "Shorter options — sunrise deadline" : "Shorter options — short prayer window"}` : ""}
                  </p>

                  {/* 3. Offset */}
                  <Label>Offset from Azan</Label>
                  <div style={{ display: "flex", gap: 6, justifyContent: "center", marginBottom: 6 }}>
                    {(prayer.name === "Subuh" ? [-15, -10, -5, 0, 5] : [-5, 0, 5, 10, 15]).map(v => (
                      <button key={v} onClick={() => update(sheet, "offset", v)} style={{
                        padding: "8px 14px", borderRadius: 12,
                        border: prayer.offset === v ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`,
                        background: prayer.offset === v ? meta.bg : "white",
                        fontSize: 13, fontWeight: prayer.offset === v ? 600 : 400,
                        color: prayer.offset === v ? meta.color : C.textSecondary, cursor: "pointer",
                      }}>{v === 0 ? "0" : v > 0 ? `+${v}` : `${v}`}</button>
                    ))}
                  </div>
                  <p style={{ fontSize: 12, color: meta.color, fontWeight: 500, textAlign: "center", margin: "0 0 2px" }}>
                    {prayer.offset === 0 ? "At azan time" : prayer.offset > 0 ? `${prayer.offset} min after azan` : `${Math.abs(prayer.offset)} min before azan`}
                  </p>
                  <p style={{ fontSize: 18, color: C.text, fontWeight: 700, textAlign: "center", margin: "0 0 22px" }}>
                    Alarm at {computeTime(prayer.time, prayer.offset)}
                  </p>

                  {/* 4. Sound */}
                  <Label>Sound</Label>
                  <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 22 }}>
                    {sounds.map(s => (
                      <button key={s} onClick={() => update(sheet, "sound", s)} style={{
                        padding: "8px 14px", borderRadius: 12,
                        border: prayer.sound === s ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`,
                        background: prayer.sound === s ? meta.bg : "white",
                        fontSize: 12, fontWeight: prayer.sound === s ? 600 : 400,
                        color: prayer.sound === s ? meta.color : C.textSecondary,
                        cursor: "pointer", display: "flex", alignItems: "center", gap: 5,
                      }}>
                        <span style={{ fontSize: 10, opacity: 0.5 }}>▶</span>{s}
                      </button>
                    ))}
                  </div>

                  {/* 5. Heads-up */}
                  <Label>Heads-up Before Azan</Label>
                  <div style={{ display: "flex", gap: 6, marginBottom: 22 }}>
                    {[0, 15, 30, 60].map(v => (
                      <button key={v} onClick={() => update(sheet, "preAlarm", v)} style={{
                        padding: "8px 14px", borderRadius: 12,
                        border: prayer.preAlarm === v ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`,
                        background: prayer.preAlarm === v ? meta.bg : "white",
                        fontSize: 13, fontWeight: prayer.preAlarm === v ? 600 : 400,
                        color: prayer.preAlarm === v ? meta.color : C.textSecondary, cursor: "pointer",
                      }}>{v === 0 ? "Off" : `${v}m`}</button>
                    ))}
                  </div>

                  {/* 6. Subuh Mode (only for Subuh) */}
                  {prayer.name === "Subuh" && (
                    <div style={{ padding: "14px", background: C.wakeupLight, borderRadius: 16, display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 22 }}>
                      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                        <span style={{ fontSize: 20 }}>🌙</span>
                        <div>
                          <p style={{ fontSize: 13, fontWeight: 600, color: C.wakeup, margin: 0 }}>Subuh Mode</p>
                          <p style={{ fontSize: 11, color: C.textSecondary, margin: "2px 0 0" }}>Full-screen wake-up experience</p>
                        </div>
                      </div>
                      <div style={{ width: 44, height: 26, borderRadius: 13, background: C.wakeup, position: "relative", cursor: "pointer" }}>
                        <div style={{ width: 20, height: 20, borderRadius: 10, background: "white", position: "absolute", top: 3, left: 21, boxShadow: "0 1px 3px rgba(0,0,0,.15)" }} />
                      </div>
                    </div>
                  )}

                  {/* 7. Apply to others */}
                  <ApplyToOthers prayers={prayers} fromIdx={sheet} onApply={applyToOthers} meta={meta} />

                </div>
              </div>
            </>
          )}

          {/* Toast */}
          {toast && (
            <div style={{ position: "absolute", bottom: 74, left: "50%", transform: "translateX(-50%)", background: C.primary, color: "white", padding: "10px 24px", borderRadius: 14, fontSize: 13, fontWeight: 600, boxShadow: "0 4px 16px rgba(91,140,111,0.3)", zIndex: 200, whiteSpace: "nowrap" }}>
              {toast}
            </div>
          )}

        </div>
      </div>

      <p style={{ fontSize: 11, color: C.textMuted, marginTop: 12, textAlign: "center" }}>
        Tap any prayer card or overview strip dot to open the bottom sheet editor
      </p>
    </div>
  );
}

function Label({ children }) {
  return <p style={{ fontSize: 11, fontWeight: 600, color: C.textMuted, textTransform: "uppercase", letterSpacing: 0.8, margin: "0 0 8px" }}>{children}</p>;
}

function ApplyToOthers({ prayers, fromIdx, onApply, meta }) {
  const [show, setShow] = useState(false);
  const [targets, setTargets] = useState({});

  if (!show) {
    return (
      <button onClick={() => { setShow(true); const t = {}; prayers.forEach((_, i) => { if (i !== fromIdx) t[i] = true; }); setTargets(t); }} style={{ width: "100%", padding: "14px", borderRadius: 14, border: `1.5px solid ${C.border}`, background: "white", cursor: "pointer", fontSize: 13, color: C.textSecondary, fontWeight: 500 }}>
        Use this setup for other prayers →
      </button>
    );
  }

  return (
    <div style={{ border: `1.5px solid ${meta.color}`, borderRadius: 16, padding: "14px" }}>
      <p style={{ fontSize: 12, fontWeight: 600, color: meta.color, margin: "0 0 10px" }}>Apply this setup to:</p>
      <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 12 }}>
        {prayers.map((p, i) => {
          if (i === fromIdx) return null;
          const sel = !!targets[i];
          return (
            <button key={i} onClick={() => setTargets(prev => ({ ...prev, [i]: !prev[i] }))} style={{
              padding: "8px 14px", borderRadius: 12,
              border: sel ? `2px solid ${meta.color}` : `1.5px solid ${C.border}`,
              background: sel ? meta.bg : "white", cursor: "pointer",
              display: "flex", alignItems: "center", gap: 6,
            }}>
              <span style={{ fontSize: 12, fontWeight: sel ? 600 : 400, color: sel ? meta.color : C.textSecondary }}>{p.name}</span>
              {sel && <span style={{ fontSize: 10, color: meta.color }}>✓</span>}
            </button>
          );
        })}
      </div>
      <div style={{ display: "flex", gap: 8 }}>
        <button onClick={() => { const idxs = Object.entries(targets).filter(([,v]) => v).map(([k]) => parseInt(k)); if (idxs.length) onApply(fromIdx, idxs); }} disabled={!Object.values(targets).some(Boolean)} style={{ flex: 1, padding: "12px", borderRadius: 12, border: "none", background: Object.values(targets).some(Boolean) ? meta.color : C.border, color: "white", fontSize: 13, fontWeight: 600, cursor: "pointer" }}>
          Apply to {Object.values(targets).filter(Boolean).length}
        </button>
        <button onClick={() => setShow(false)} style={{ padding: "12px 16px", borderRadius: 12, border: `1px solid ${C.border}`, background: "white", fontSize: 13, color: C.textSecondary, cursor: "pointer" }}>Cancel</button>
      </div>
    </div>
  );
}
