import { useState } from "react";

const C = {
  bg: "#FDFBF7", primary: "#5B8C6F", primaryLight: "#E8F0EB", primarySoft: "#A8CBB7",
  accent: "#D4A843", accentLight: "#FFF6E3", text: "#2C2C2C", textSecondary: "#8E8E93",
  textMuted: "#B5B5BA", done: "#7FC4A0", doneLight: "#EEFAF3", missed: "#E8878F",
  missedLight: "#FFF0F1", qadha: "#E0B86B", qadhaLight: "#FFF8EC", upcoming: "#D1D1D6",
  upcomingLight: "#F5F5F7", border: "#EBEBF0",
};

// Simulated weekly data: 5 prayers x 7 days
// Statuses: "done" | "missed" | "qadha" | null (future)
const thisWeek = {
  Subuh:   ["done", "missed", "done", "done", "missed", "qadha", "done"],
  Dzuhur:  ["done", "done", "done", "done", "done", "done", "done"],
  Ashar:   ["done", "done", "missed", "done", "done", "done", null],
  Maghrib: ["done", "done", "done", "done", "done", "done", null],
  Isya:    ["done", "missed", "done", "done", "missed", "done", null],
};

const lastWeek = {
  Subuh:   ["missed", "missed", "done", "done", "missed", "done", "done"],
  Dzuhur:  ["done", "done", "done", "missed", "done", "done", "done"],
  Ashar:   ["done", "missed", "done", "done", "done", "missed", "done"],
  Maghrib: ["done", "done", "done", "done", "done", "done", "done"],
  Isya:    ["done", "done", "missed", "done", "done", "missed", "done"],
};

const dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const prayerNames = ["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"];

const countStatus = (week, status) => {
  let count = 0;
  for (const p of prayerNames) {
    for (const d of week[p]) {
      if (d === status) count++;
    }
  }
  return count;
};

const countAll = (week) => {
  let count = 0;
  for (const p of prayerNames) {
    for (const d of week[p]) {
      if (d === "done" || d === "qadha") count++;
    }
  }
  return count;
};

const dotColor = (status) => {
  if (status === "done") return C.done;
  if (status === "missed") return C.missed;
  if (status === "qadha") return C.qadha;
  return "transparent";
};

const dotBg = (status) => {
  if (status === "done") return C.doneLight;
  if (status === "missed") return C.missedLight;
  if (status === "qadha") return C.qadhaLight;
  return C.upcomingLight;
};

export default function PersonalDashboard() {
  const [showDashboard, setShowDashboard] = useState(false);
  const [selectedWeek, setSelectedWeek] = useState("this");
  const [showMore, setShowMore] = useState(false);

  const week = selectedWeek === "this" ? thisWeek : lastWeek;
  const thisCount = countAll(thisWeek);
  const lastCount = countAll(lastWeek);
  const diff = thisCount - lastCount;
  const streak = 6;
  const recoveries = 1;

  // Days protected: all 5 prayers done/qadha
  const countProtectedDays = (w) => {
    let count = 0;
    for (let d = 0; d < 7; d++) {
      const dayStatuses = prayerNames.map(p => w[p][d]);
      const allDone = dayStatuses.every(s => s === "done" || s === "qadha");
      const hasNull = dayStatuses.some(s => s === null);
      if (allDone && !hasNull) count++;
    }
    return count;
  };

  // Recovery days: a day where user prayed again after a non-protected day
  const countRecoveryDays = (w) => {
    let count = 0;
    for (let d = 1; d < 7; d++) {
      const prevDay = prayerNames.map(p => w[p][d - 1]);
      const thisDay = prayerNames.map(p => w[p][d]);
      const prevHadMiss = prevDay.some(s => s === "missed");
      const prevNotNull = prevDay.every(s => s !== null);
      const thisDoneCount = thisDay.filter(s => s === "done" || s === "qadha").length;
      const thisNotNull = thisDay.filter(s => s !== null).length;
      // Recovery = previous day had a miss AND this day user prayed at least once
      if (prevNotNull && prevHadMiss && thisDoneCount > 0 && thisNotNull > 0) count++;
    }
    return count;
  };

  const thisProtected = countProtectedDays(thisWeek);
  const lastProtected = countProtectedDays(lastWeek);
  const thisRecovery = countRecoveryDays(thisWeek);
  const currentProtected = selectedWeek === "this" ? thisProtected : lastProtected;
  const currentRecovery = selectedWeek === "this" ? thisRecovery : countRecoveryDays(lastWeek);
  const currentTotal = 7;

  // Today is Sunday (index 6) in our sim
  const todayIndex = 6;

  // Jamaah tag data (simulated)
  const jamaahCount = 8;
  const jamaahMosque = 5;
  const jamaahHome = 3;
  const earlyCount = 14;

  // Find strongest and weakest prayer
  const prayerCounts = prayerNames.map(p => ({
    name: p,
    done: week[p].filter(d => d === "done" || d === "qadha").length,
    total: week[p].filter(d => d !== null).length,
  }));
  const strongest = prayerCounts.reduce((a, b) => a.done >= b.done ? a : b);
  const weakest = prayerCounts.reduce((a, b) => a.done <= b.done ? a : b);

  return (
    <div style={{ minHeight: "100vh", background: "linear-gradient(135deg,#F0EDE6,#E8E4DC 50%,#F2EFE8)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "20px 16px", fontFamily: "'DM Sans','Nunito',system-ui,-apple-system,sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=Noto+Naskh+Arabic:wght@400;500;600&display=swap" rel="stylesheet" />

      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <h1 style={{ fontSize: 16, fontWeight: 600, color: C.text, letterSpacing: 0.5, margin: 0 }}>HAYYA — Personal Dashboard</h1>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: "3px 0 0" }}>Tap the streak flame 🔥 to open your personal reflection</p>
      </div>

      {/* Phone Frame */}
      <div style={{ width: 375, height: 812, borderRadius: 44, background: "#000", padding: 8, boxShadow: "0 24px 80px rgba(0,0,0,0.15),0 8px 24px rgba(0,0,0,0.1)" }}>
        <div style={{ width: "100%", height: "100%", borderRadius: 38, background: "linear-gradient(180deg, #FBF9F3 0%, #F7F3EC 50%, #FBF9F3 100%)", overflow: "hidden", display: "flex", flexDirection: "column", position: "relative" }}>

          {/* Status Bar */}
          <div style={{ height: 50, display: "flex", alignItems: "flex-end", justifyContent: "space-between", padding: "0 28px 4px", fontSize: 14, fontWeight: 600, color: C.text, flexShrink: 0 }}>
            <span>9:41</span>
            <div style={{ display: "flex", gap: 4, alignItems: "center" }}>
              <svg width="16" height="12" viewBox="0 0 16 12"><rect x="0" y="6" width="3" height="6" rx=".5" fill={C.text}/><rect x="4.5" y="4" width="3" height="8" rx=".5" fill={C.text}/><rect x="9" y="1.5" width="3" height="10.5" rx=".5" fill={C.text}/><rect x="13" y="0" width="3" height="12" rx=".5" fill={C.text}/></svg>
              <span>100%</span>
            </div>
          </div>

          {/* ====== TODAY TAB HEADER (with tappable streak) ====== */}
          {!showDashboard && (
            <>
              <div style={{ padding: "4px 18px 8px", flexShrink: 0 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div>
                    <p style={{ fontSize: 12, color: C.textSecondary, margin: "0 0 1px" }}>14 Ramadan 1447 · 10 Mar 2026</p>
                    <p style={{ fontSize: 11, color: C.textMuted, margin: 0 }}>📍 Jakarta</p>
                  </div>
                  <button
                    onClick={() => setShowDashboard(true)}
                    style={{
                      display: "flex", alignItems: "center", gap: 4,
                      background: C.accentLight, padding: "6px 12px", borderRadius: 16,
                      border: "none", cursor: "pointer",
                      transition: "transform .15s",
                    }}
                    onMouseDown={(e) => e.currentTarget.style.transform = "scale(0.93)"}
                    onMouseUp={(e) => e.currentTarget.style.transform = "scale(1)"}
                  >
                    <span style={{ fontSize: 13 }}>🔥</span>
                    <span style={{ fontSize: 14, fontWeight: 700, color: C.accent }}>
                      {streak}{recoveries > 0 ? ` +${recoveries}` : ""}
                    </span>
                    <span style={{ fontSize: 10, color: C.accent, marginLeft: 2 }}>›</span>
                  </button>
                </div>
                <p style={{ fontSize: 11, color: C.textMuted, margin: "8px 0 0", textAlign: "center" }}>
                  Today: 4/5 · This week: {thisCount}/35
                </p>
              </div>

              {/* Simulated prayer cards */}
              <div style={{ flex: 1, overflowY: "auto", padding: "4px 14px 14px", display: "flex", flexDirection: "column", gap: 10 }}>
                {[
                  { name: "Subuh", arabic: "الصبح", time: "04:52", status: "done" },
                  { name: "Dzuhur", arabic: "الظهر", time: "11:58", status: "done" },
                  { name: "Ashar", arabic: "العصر", time: "15:12", status: "done" },
                  { name: "Maghrib", arabic: "المغرب", time: "17:54", status: "done" },
                  { name: "Isya", arabic: "العشاء", time: "19:08", status: "active" },
                ].map((prayer, idx) => {
                  const colors = { done: C.done, active: C.primary, missed: C.missed, upcoming: C.upcoming };
                  const bgs = { done: C.doneLight, active: C.primaryLight, missed: C.missedLight, upcoming: C.upcomingLight };
                  const icons = { done: "✓", active: "●", missed: "✕", upcoming: "○" };
                  return (
                    <div key={idx} style={{
                      background: prayer.status === "active" ? "rgba(255,255,255,0.95)" : "rgba(255,255,255,0.8)",
                      borderRadius: 20, padding: "18px 16px",
                      border: prayer.status === "active" ? `2px solid ${C.primary}` : `1px solid rgba(235,235,240,0.8)`,
                      display: "flex", alignItems: "center", gap: 14,
                    }}>
                      <div style={{ width: 46, height: 46, borderRadius: 23, background: bgs[prayer.status], display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20, color: colors[prayer.status], fontWeight: 700 }}>
                        {icons[prayer.status]}
                      </div>
                      <div style={{ flex: 1 }}>
                        <div style={{ display: "flex", alignItems: "baseline", gap: 6 }}>
                          <p style={{ fontSize: 17, fontWeight: 600, color: C.text, margin: 0 }}>{prayer.name}</p>
                          <p style={{ fontSize: 14, color: C.textMuted, margin: 0, fontFamily: "'Noto Naskh Arabic',serif" }}>{prayer.arabic}</p>
                        </div>
                        <p style={{ fontSize: 12, color: C.textSecondary, margin: "3px 0 0" }}>{prayer.time}</p>
                      </div>
                      {prayer.status === "active" && (
                        <div style={{ padding: "10px 18px", borderRadius: 14, background: C.primary, color: "white", fontSize: 14, fontWeight: 600 }}>Check In</div>
                      )}
                      {prayer.status === "done" && <span style={{ fontSize: 12, color: C.done, fontWeight: 500 }}>✓</span>}
                    </div>
                  );
                })}

                {/* Your Journey entry point */}
                <button
                  onClick={() => setShowDashboard(true)}
                  style={{
                    width: "100%", padding: "14px 16px", borderRadius: 18,
                    border: `1px solid ${C.border}`, background: "rgba(255,255,255,0.7)",
                    cursor: "pointer", display: "flex", alignItems: "center", gap: 12,
                    transition: "background .15s",
                  }}
                >
                  <div style={{
                    width: 38, height: 38, borderRadius: 14, background: C.accentLight,
                    display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0,
                  }}>
                    <span style={{ fontSize: 16 }}>🔥</span>
                  </div>
                  <div style={{ flex: 1, textAlign: "left" }}>
                    <p style={{ fontSize: 14, fontWeight: 600, color: C.text, margin: 0 }}>Your Journey</p>
                    <p style={{ fontSize: 11, color: C.textMuted, margin: "2px 0 0" }}>
                      {thisProtected}/7 days protected this week{thisRecovery > 0 ? ` · ${thisRecovery} recovery` : ""}
                    </p>
                  </div>
                  <span style={{ fontSize: 14, color: C.textMuted }}>›</span>
                </button>
              </div>
            </>
          )}

          {/* ====== PERSONAL DASHBOARD ====== */}
          {showDashboard && (
            <>
              {/* Header */}
              <div style={{ padding: "4px 18px 12px", flexShrink: 0 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                  <button onClick={() => setShowDashboard(false)} style={{ background: "none", border: "none", cursor: "pointer", padding: "4px 0", fontSize: 20, color: C.textMuted }}>‹</button>
                  <div style={{ flex: 1 }}>
                    <h2 style={{ fontSize: 24, fontWeight: 700, color: C.text, margin: 0 }}>Your Journey</h2>
                    <p style={{ fontSize: 12, color: C.textSecondary, margin: "2px 0 0" }}>Personal prayer reflection</p>
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: 4, background: C.accentLight, padding: "5px 10px", borderRadius: 14 }}>
                    <span style={{ fontSize: 12 }}>🔥</span>
                    <span style={{ fontSize: 14, fontWeight: 700, color: C.accent }}>{streak}{recoveries > 0 ? ` +${recoveries}` : ""}</span>
                  </div>
                </div>
              </div>

              <div style={{ flex: 1, overflowY: "auto", padding: "0 14px 14px" }}>

                {/* ===== DAYS PROTECTED — Hero Metric ===== */}
                <div style={{
                  background: C.primaryLight, borderRadius: 20, padding: "18px 16px",
                  marginBottom: 14, textAlign: "center",
                }}>
                  <p style={{ fontSize: 12, fontWeight: 600, color: C.primary, margin: "0 0 6px" }}>Days protected this week</p>
                  <div style={{ display: "flex", alignItems: "baseline", justifyContent: "center", gap: 4 }}>
                    <span style={{ fontSize: 40, fontWeight: 700, color: C.primary }}>{thisProtected}</span>
                    <span style={{ fontSize: 18, fontWeight: 500, color: C.primarySoft }}>/7</span>
                  </div>
                  <p style={{ fontSize: 12, color: C.textSecondary, margin: "4px 0 0" }}>
                    {thisProtected === 7 ? "Every single day. MasyaAllah." :
                     thisProtected >= 5 ? "Strong week. Keep protecting your prayers." :
                     thisProtected >= 3 ? "You can still protect tomorrow." :
                     "Every new day is a chance to protect your prayers."}
                  </p>
                  {thisRecovery > 0 && (
                    <div style={{
                      marginTop: 10, paddingTop: 10, borderTop: `1px solid ${C.primary}20`,
                      display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
                    }}>
                      <span style={{ fontSize: 13, color: C.qadha, fontWeight: 700 }}>↩ {thisRecovery}</span>
                      <span style={{ fontSize: 12, color: C.textSecondary }}>
                        {thisRecovery === 1 ? "day you came back after missing" : "days you came back after missing"}
                      </span>
                    </div>
                  )}
                </div>

                {/* Week Toggle */}
                <div style={{ display: "flex", gap: 6, marginBottom: 14 }}>
                  {[
                    { id: "this", label: "This week" },
                    { id: "last", label: "Last week" },
                  ].map(w => (
                    <button key={w.id} onClick={() => setSelectedWeek(w.id)} style={{
                      flex: 1, padding: "8px", borderRadius: 12,
                      border: selectedWeek === w.id ? `1.5px solid ${C.primary}` : `1px solid ${C.border}`,
                      background: selectedWeek === w.id ? C.primaryLight : "white",
                      fontSize: 12, fontWeight: selectedWeek === w.id ? 600 : 400,
                      color: selectedWeek === w.id ? C.primary : C.textSecondary,
                      cursor: "pointer",
                    }}>{w.label}</button>
                  ))}
                </div>

                {/* ===== WEEKLY DOT GRID ===== */}
                <div style={{
                  background: "white", borderRadius: 20, padding: "16px 14px",
                  border: `1px solid ${C.border}`, marginBottom: 12,
                }}>
                  {/* Day labels header */}
                  <div style={{ display: "flex", marginBottom: 8, paddingLeft: 52 }}>
                    {dayLabels.map((d, i) => (
                      <div key={i} style={{
                        flex: 1, textAlign: "center", fontSize: 9,
                        color: selectedWeek === "this" && i === todayIndex ? C.primary : C.textMuted,
                        fontWeight: selectedWeek === "this" && i === todayIndex ? 700 : 500,
                      }}>{d}</div>
                    ))}
                    <span style={{ width: 28 }} />
                  </div>

                  {/* Prayer rows */}
                  {prayerNames.map((prayer, pi) => {
                    const row = week[prayer];
                    const doneInRow = row.filter(d => d === "done" || d === "qadha").length;
                    const totalInRow = row.filter(d => d !== null).length;
                    return (
                      <div key={pi} style={{ display: "flex", alignItems: "center", marginBottom: pi < 4 ? 8 : 0 }}>
                        <span style={{ width: 52, fontSize: 11, fontWeight: 500, color: C.textSecondary }}>{prayer}</span>
                        {row.map((status, di) => (
                          <div key={di} style={{
                            flex: 1, display: "flex", justifyContent: "center",
                            background: selectedWeek === "this" && di === todayIndex ? `${C.primary}08` : "transparent",
                            borderRadius: 6, padding: "2px 0",
                          }}>
                            {status !== null ? (
                              <div style={{
                                width: 22, height: 22, borderRadius: 11,
                                background: dotBg(status),
                                display: "flex", alignItems: "center", justifyContent: "center",
                              }}>
                                {status === "done" && <div style={{ width: 8, height: 8, borderRadius: 4, background: C.done }} />}
                                {status === "missed" && <span style={{ fontSize: 8, color: C.missed, fontWeight: 700 }}>✕</span>}
                                {status === "qadha" && <span style={{ fontSize: 8, color: C.qadha, fontWeight: 700 }}>↩</span>}
                              </div>
                            ) : (
                              <div style={{ width: 22, height: 22, borderRadius: 11, background: C.upcomingLight, border: `1px dashed ${C.border}` }} />
                            )}
                          </div>
                        ))}
                        <span style={{ width: 28, textAlign: "right", fontSize: 11, fontWeight: 600, color: doneInRow === totalInRow ? C.done : C.textSecondary }}>
                          {doneInRow}/{totalInRow}
                        </span>
                      </div>
                    );
                  })}

                  {/* Legend */}
                  <div style={{ display: "flex", gap: 12, justifyContent: "center", marginTop: 12, paddingTop: 10, borderTop: `1px solid ${C.border}` }}>
                    {[
                      { color: C.done, label: "Done", type: "fill" },
                      { color: C.missed, label: "Missed", type: "fill" },
                      { color: C.qadha, label: "Qadha", type: "fill" },
                      { color: C.border, label: "Upcoming", type: "dash" },
                    ].map(l => (
                      <div key={l.label} style={{ display: "flex", alignItems: "center", gap: 4 }}>
                        <div style={{ width: 8, height: 8, borderRadius: 4, background: l.type === "dash" ? "transparent" : l.color, border: l.type === "dash" ? `1px dashed ${l.color}` : "none" }} />
                        <span style={{ fontSize: 9, color: C.textMuted }}>{l.label}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* ===== WEEKLY TOTAL + TREND ===== */}
                <div style={{ display: "flex", gap: 10, marginBottom: 12 }}>
                  <div style={{
                    flex: 1, background: "white", borderRadius: 18, padding: "16px 14px",
                    border: `1px solid ${C.border}`, textAlign: "center",
                  }}>
                    <p style={{ fontSize: 11, fontWeight: 600, color: C.textSecondary, margin: "0 0 4px" }}>Prayers</p>
                    <p style={{ fontSize: 28, fontWeight: 700, color: C.primary, margin: "0 0 2px" }}>
                      {selectedWeek === "this" ? thisCount : lastCount}
                    </p>
                    <p style={{ fontSize: 11, color: C.textMuted, margin: 0 }}>of 35</p>
                  </div>
                  <div style={{
                    flex: 1, background: "white", borderRadius: 18, padding: "16px 14px",
                    border: `1px solid ${C.border}`, textAlign: "center",
                  }}>
                    <p style={{ fontSize: 11, fontWeight: 600, color: C.textSecondary, margin: "0 0 4px" }}>Protected</p>
                    <p style={{ fontSize: 28, fontWeight: 700, color: C.accent, margin: "0 0 2px" }}>
                      {currentProtected}
                    </p>
                    <p style={{ fontSize: 11, color: C.textMuted, margin: 0 }}>of 7 days</p>
                  </div>
                  <div style={{
                    flex: 1, background: "white", borderRadius: 18, padding: "16px 14px",
                    border: `1px solid ${C.border}`, textAlign: "center",
                  }}>
                    <p style={{ fontSize: 11, fontWeight: 600, color: C.textSecondary, margin: "0 0 4px" }}>vs last week</p>
                    <p style={{ fontSize: 28, fontWeight: 700, color: Math.abs(diff) <= 1 ? C.textSecondary : diff > 0 ? C.done : C.missed, margin: "0 0 2px" }}>
                      {Math.abs(diff) <= 1 ? "≈" : diff > 0 ? `+${diff}` : diff}
                    </p>
                    <p style={{ fontSize: 11, color: C.textMuted, margin: 0 }}>
                      {Math.abs(diff) <= 1 ? "about the same" : diff > 0 ? "prayers more" : "prayers fewer"}
                    </p>
                  </div>
                </div>

                {/* ===== ENCOURAGEMENT ===== */}
                <div style={{
                  background: C.primaryLight, borderRadius: 16, padding: "14px 16px",
                  marginBottom: 12,
                }}>
                  {thisCount < 15 ? (
                    <p style={{ fontSize: 13, color: C.primary, margin: 0, textAlign: "center", lineHeight: 1.5 }}>
                      Even one sincere prayer matters.<br />
                      <span style={{ fontStyle: "italic", fontSize: 12 }}>Every new prayer is a fresh start.</span>
                    </p>
                  ) : thisRecovery > 0 && thisProtected < 5 ? (
                    <p style={{ fontSize: 13, color: C.primary, margin: 0, textAlign: "center", lineHeight: 1.5 }}>
                      You fell, and you came back <span style={{ fontWeight: 700 }}>{thisRecovery} {thisRecovery === 1 ? "time" : "times"}</span> this week.<br />
                      <span style={{ fontStyle: "italic", fontSize: 12 }}>Returning after a lapse is itself an act of devotion.</span>
                    </p>
                  ) : diff > 1 ? (
                    <p style={{ fontSize: 13, color: C.primary, margin: 0, textAlign: "center", lineHeight: 1.5 }}>
                      You protected <span style={{ fontWeight: 700 }}>{thisProtected} days</span> this week.<br />
                      <span style={{ fontStyle: "italic", fontSize: 12 }}>Keep going. Consistency is beloved to Allah.</span>
                    </p>
                  ) : Math.abs(diff) <= 1 ? (
                    <p style={{ fontSize: 13, color: C.primary, margin: 0, textAlign: "center", lineHeight: 1.5 }}>
                      Steady and consistent. That's istiqamah.<br />
                      <span style={{ fontStyle: "italic", fontSize: 12 }}>The most beloved deeds are those done consistently.</span>
                    </p>
                  ) : (
                    <p style={{ fontSize: 13, color: C.primary, margin: 0, textAlign: "center", lineHeight: 1.5 }}>
                      A lighter week. That's okay.<br />
                      <span style={{ fontStyle: "italic", fontSize: 12 }}>You can still protect tomorrow.</span>
                    </p>
                  )}
                </div>

                {/* ===== PRAYER INSIGHTS ===== */}
                <div style={{
                  background: "white", borderRadius: 18, padding: "16px 16px",
                  border: `1px solid ${C.border}`, marginBottom: 12,
                }}>
                  <p style={{ fontSize: 13, fontWeight: 600, color: C.text, margin: "0 0 12px" }}>Insights</p>

                  <div style={{ display: "flex", gap: 10, marginBottom: 10 }}>
                    <div style={{ flex: 1, background: C.doneLight, borderRadius: 14, padding: "12px 10px", textAlign: "center" }}>
                      <p style={{ fontSize: 10, color: C.done, fontWeight: 600, margin: "0 0 2px" }}>Strongest</p>
                      <p style={{ fontSize: 15, fontWeight: 700, color: C.text, margin: "0 0 1px" }}>{strongest.name}</p>
                      <p style={{ fontSize: 10, color: C.textMuted, margin: 0 }}>{strongest.done}/{strongest.total} this week</p>
                    </div>
                    <div style={{ flex: 1, background: C.missedLight, borderRadius: 14, padding: "12px 10px", textAlign: "center" }}>
                      <p style={{ fontSize: 10, color: C.missed, fontWeight: 600, margin: "0 0 2px" }}>Focus area</p>
                      <p style={{ fontSize: 15, fontWeight: 700, color: C.text, margin: "0 0 1px" }}>{weakest.name}</p>
                      <p style={{ fontSize: 10, color: C.textMuted, margin: 0 }}>{weakest.done}/{weakest.total} this week</p>
                    </div>
                  </div>

                  {/* Qadha recoveries */}
                  {countStatus(week, "qadha") > 0 && (
                    <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "8px 0 0" }}>
                      <div style={{ width: 24, height: 24, borderRadius: 12, background: C.qadhaLight, display: "flex", alignItems: "center", justifyContent: "center" }}>
                        <span style={{ fontSize: 10, color: C.qadha, fontWeight: 700 }}>↩</span>
                      </div>
                      <p style={{ fontSize: 12, color: C.textSecondary, margin: 0 }}>
                        <span style={{ fontWeight: 600, color: C.qadha }}>{countStatus(week, "qadha")} prayer{countStatus(week, "qadha") > 1 ? "s" : ""}</span> recovered via qadha
                      </p>
                    </div>
                  )}
                </div>

                {/* ===== MORE INSIGHTS (collapsed) ===== */}
                <button
                  onClick={() => setShowMore(!showMore)}
                  style={{ background: "none", border: "none", cursor: "pointer", padding: "4px 0", display: "flex", alignItems: "center", gap: 5, marginBottom: showMore ? 10 : 12 }}
                >
                  <span style={{ fontSize: 12, color: C.textMuted, fontWeight: 500 }}>
                    {showMore ? "Less insights" : "More insights"}
                  </span>
                  <span style={{ fontSize: 10, color: C.textMuted, transform: showMore ? "rotate(180deg)" : "rotate(0)", transition: "transform .2s" }}>▾</span>
                </button>

                {showMore && (
                <div style={{
                  background: "white", borderRadius: 18, padding: "16px 16px",
                  border: `1px solid ${C.border}`, marginBottom: 12,
                }}>
                  <p style={{ fontSize: 13, fontWeight: 600, color: C.text, margin: "0 0 12px" }}>Jamaah this month</p>
                  <div style={{ display: "flex", gap: 10 }}>
                    <div style={{ flex: 1, textAlign: "center" }}>
                      <p style={{ fontSize: 24, fontWeight: 700, color: C.accent, margin: "0 0 2px" }}>{jamaahCount}</p>
                      <p style={{ fontSize: 10, color: C.textMuted, margin: 0 }}>total jamaah</p>
                    </div>
                    <div style={{ width: 1, background: C.border }} />
                    <div style={{ flex: 1, textAlign: "center" }}>
                      <p style={{ fontSize: 18, fontWeight: 700, color: C.textSecondary, margin: "0 0 2px" }}>🕌 {jamaahMosque}</p>
                      <p style={{ fontSize: 10, color: C.textMuted, margin: 0 }}>at mosque</p>
                    </div>
                    <div style={{ width: 1, background: C.border }} />
                    <div style={{ flex: 1, textAlign: "center" }}>
                      <p style={{ fontSize: 18, fontWeight: 700, color: C.textSecondary, margin: "0 0 2px" }}>🏠 {jamaahHome}</p>
                      <p style={{ fontSize: 10, color: C.textMuted, margin: 0 }}>at home</p>
                    </div>
                  </div>
                  <div style={{ marginTop: 10, padding: "8px 0 0", borderTop: `1px solid ${C.border}`, display: "flex", alignItems: "center", gap: 6 }}>
                    <span style={{ fontSize: 12 }}>⏰</span>
                    <p style={{ fontSize: 12, color: C.textSecondary, margin: 0 }}>
                      <span style={{ fontWeight: 600 }}>{earlyCount} prayers</span> prayed early this month
                    </p>
                  </div>
                </div>
                )}

                {/* ===== DU'A FOOTER ===== */}
                <div style={{
                  background: C.accentLight, borderRadius: 16, padding: "14px 16px",
                  textAlign: "center", marginBottom: 8,
                }}>
                  <p style={{ fontSize: 12, color: C.textSecondary, margin: "0 0 4px" }}>
                    <span style={{ fontWeight: 700, color: C.accent }}>{thisCount + lastCount + 48} prayers protected</span> since joining Hayya
                  </p>
                  <p style={{ fontSize: 12, color: C.accent, margin: 0, fontStyle: "italic" }}>
                    May every prayer be accepted. Ameen.
                  </p>
                </div>

                <p style={{ fontSize: 10, color: C.textMuted, textAlign: "center", margin: "4px 0 0" }}>
                  This is your <span style={{ fontWeight: 600 }}>private reflection</span>. No one else sees this data.
                </p>
              </div>
            </>
          )}

          {/* Floating Tab Bar */}
          <div style={{ padding: "0 24px 16px", flexShrink: 0 }}>
            <div style={{ display: "flex", justifyContent: "space-around", padding: "8px 6px", background: "rgba(255,255,255,0.88)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)", borderRadius: 28, boxShadow: "0 2px 20px rgba(0,0,0,0.06), 0 0 0 0.5px rgba(0,0,0,0.04)" }}>
              {[
                { label: "Today", active: true, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M3 7v11a3 3 0 003 3h12a3 3 0 003-3V7"/><path d="M3 7l9 6 9-6"/><path d="M3 7h18"/><circle cx="12" cy="4" r="1.5" fill={c} stroke="none"/></svg> },
                { label: "Together", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="8" r="3"/><circle cx="17" cy="8" r="2.5"/><path d="M3 21v-1a5 5 0 015-5h2a5 5 0 015 5v1"/><path d="M17 13.5a3.5 3.5 0 013.5 3.5V21"/></svg> },
                { label: "Alarms", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/><path d="M6 2L3 4"/><path d="M18 2l3 2"/></svg> },
                { label: "Settings", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg> },
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
        Tap the 🔥 streak flame to enter your personal dashboard<br />
        Toggle "This week" / "Last week" to compare<br />
        Tap ‹ back arrow to return to Today
      </p>
    </div>
  );
}
