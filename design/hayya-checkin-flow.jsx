import { useState, useEffect } from "react";

const C = {
  bg: "#FDFBF7", primary: "#5B8C6F", primaryLight: "#E8F0EB", primarySoft: "#A8CBB7",
  accent: "#D4A843", accentLight: "#FFF6E3", text: "#2C2C2C", textSecondary: "#8E8E93",
  textMuted: "#B5B5BA", done: "#7FC4A0", doneLight: "#EEFAF3", missed: "#E8878F",
  missedLight: "#FFF0F1", qadha: "#E0B86B", qadhaLight: "#FFF8EC", upcoming: "#D1D1D6",
  upcomingLight: "#F5F5F7", border: "#EBEBF0",
};

const spiritualMessages = {
  Subuh: ["Whoever prays Fajr is under the protection of Allah. — Muslim", "The two rak'ahs of Fajr are better than the world. — Muslim"],
  Dzuhur: ["The first matter questioned about is prayer. — An-Nasa'i", "Prayer is the pillar of the religion."],
  Ashar: ["Whoever prays the two cool prayers enters Paradise. — Bukhari", "May Allah bless the remainder of your day."],
  Maghrib: ["You remembered Allah at the day's end. That matters.", "Hasten to prayer, hasten to success."],
  Isya: ["Whoever prays Isha in congregation stood half the night. — Muslim", "The night prayer is most virtuous after obligatory. — Muslim"],
};

const qadhaMessages = [
  "Everyone makes mistakes. What matters is that you came back.",
  "The door of repentance remains open. You walked through it.",
  "You missed one prayer. You didn't miss your chance.",
  "A servant who returns after slipping is beloved to Allah.",
];

const initialPrayers = [
  { name: "Subuh", arabic: "الصبح", time: "04:52", status: "done", checkedAt: "04:58" },
  { name: "Dzuhur", arabic: "الظهر", time: "11:58", status: "active" },
  { name: "Ashar", arabic: "العصر", time: "15:12", status: "active" },
  { name: "Maghrib", arabic: "المغرب", time: "17:54", status: "missed" },
  { name: "Isya", arabic: "العشاء", time: "19:08", status: "active" },
];

const statusStyles = {
  done: { color: C.done, bg: C.doneLight, icon: "✓" },
  active: { color: C.primary, bg: C.primaryLight, icon: "●" },
  missed: { color: C.missed, bg: C.missedLight, icon: "✕" },
  qadha: { color: C.qadha, bg: C.qadhaLight, icon: "↩" },
  upcoming: { color: C.upcoming, bg: C.upcomingLight, icon: "○" },
};

export default function CheckInFlow() {
  const [prayers, setPrayers] = useState(initialPrayers);
  const [toast, setToast] = useState(null);
  const [toastKey, setToastKey] = useState(0);
  const [qadhaSheet, setQadhaSheet] = useState(null);
  const [milestone, setMilestone] = useState(null);
  const [streak, setStreak] = useState(6);
  const [recoveries, setRecoveries] = useState(0);
  const [tags, setTags] = useState({}); // { idx: ['jamaah_mosque', 'on_time'] }

  const doneCount = prayers.filter(p => p.status === "done" || p.status === "qadha").length;

  // Instant check-in: one tap, card updates, toast shows
  const checkIn = (idx) => {
    const now = new Date();
    const timeStr = `${String(now.getHours()).padStart(2, "0")}:${String(now.getMinutes()).padStart(2, "0")}`;
    const prayer = prayers[idx];

    setPrayers(prev => prev.map((p, i) => i === idx ? { ...p, status: "done", checkedAt: timeStr } : p));

    // Show spiritual toast
    const msgs = spiritualMessages[prayer.name];
    const msg = msgs[Math.floor(Math.random() * msgs.length)];
    setToast({ prayer: prayer.name, message: msg });
    setToastKey(k => k + 1);

    // Check for 5/5 milestone
    const newDoneCount = prayers.filter((p, i) => i === idx ? true : p.status === "done" || p.status === "qadha").length;
    if (newDoneCount === 5) {
      setTimeout(() => {
        setMilestone("complete");
        setTimeout(() => setMilestone(null), 3200);
      }, 800);
    }
  };

  // Qadha: open bottom sheet
  const openQadha = (idx) => {
    setQadhaSheet({ idx, phase: "confirm" });
  };

  const confirmQadha = () => {
    if (!qadhaSheet) return;
    const { idx } = qadhaSheet;
    const now = new Date();
    const timeStr = `${String(now.getHours()).padStart(2, "0")}:${String(now.getMinutes()).padStart(2, "0")}`;
    const prayer = prayers[idx];

    setPrayers(prev => prev.map((p, i) => i === idx ? { ...p, status: "qadha", checkedAt: timeStr } : p));
    setRecoveries(r => r + 1);

    // Show warm message in sheet
    const msg = qadhaMessages[Math.floor(Math.random() * qadhaMessages.length)];
    setQadhaSheet({ idx, phase: "message", message: msg });

    // Auto-dismiss
    setTimeout(() => setQadhaSheet(null), 2800);

    // Check for 5/5
    const newDoneCount = prayers.filter((p, i) => i === idx ? true : p.status === "done" || p.status === "qadha").length;
    if (newDoneCount === 5) {
      setTimeout(() => {
        setMilestone("complete");
        setTimeout(() => setMilestone(null), 3200);
      }, 3200);
    }
  };

  const toggleTag = (idx, tagId) => {
    setTags(prev => {
      const current = prev[idx] || [];
      const has = current.includes(tagId);
      return { ...prev, [idx]: has ? current.filter(t => t !== tagId) : [...current, tagId] };
    });
  };

  const resetDemo = () => {
    setPrayers(initialPrayers);
    setToast(null);
    setQadhaSheet(null);
    setMilestone(null);
    setStreak(6);
    setRecoveries(0);
    setTags({});
  };

  return (
    <div style={{ minHeight: "100vh", background: "linear-gradient(135deg,#F0EDE6,#E8E4DC 50%,#F2EFE8)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "20px 16px", fontFamily: "'DM Sans','Nunito',system-ui,-apple-system,sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=Noto+Naskh+Arabic:wght@400;500;600&display=swap" rel="stylesheet" />

      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <h1 style={{ fontSize: 16, fontWeight: 600, color: C.text, letterSpacing: 0.5, margin: 0 }}>HAYYA — Check-In & Qadha Flow</h1>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: "3px 0 0" }}>Tap Check In on any active prayer • Tap Qadha on Maghrib • Try checking all 4 to see milestone</p>
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

          {/* Header */}
          <div style={{ padding: "4px 18px 8px", flexShrink: 0 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div>
                <p style={{ fontSize: 12, color: C.textSecondary, margin: "0 0 1px" }}>14 Ramadan 1447 · 10 Mar 2026</p>
                <p style={{ fontSize: 11, color: C.textMuted, margin: 0 }}>📍 Jakarta</p>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 4, background: C.accentLight, padding: "5px 10px", borderRadius: 16 }}>
                <span style={{ fontSize: 12 }}>🔥</span>
                <span style={{ fontSize: 13, fontWeight: 700, color: C.accent }}>
                  {streak}{recoveries > 0 ? ` +${recoveries}` : ""}
                </span>
              </div>
            </div>
            <p style={{ fontSize: 11, color: C.textMuted, margin: "8px 0 0", textAlign: "center" }}>
              Today: {doneCount}/5 · This week: {25 + doneCount}/35 · Best: 12 days
            </p>
          </div>

          {/* Prayer Cards */}
          <div style={{ flex: 1, overflowY: "auto", padding: "4px 14px 14px", display: "flex", flexDirection: "column", gap: 10 }}>
            {prayers.map((prayer, idx) => (
              <PrayerCard
                key={idx}
                prayer={prayer}
                idx={idx}
                onCheckIn={checkIn}
                onQadha={openQadha}
                tags={tags[idx] || []}
                onToggleTag={(tagId) => toggleTag(idx, tagId)}
              />
            ))}
          </div>

          {/* Spiritual Toast */}
          <SpiritualToast key={toastKey} toast={toast} />

          {/* Qadha Bottom Sheet */}
          {qadhaSheet && (
            <QadhaSheet
              sheet={qadhaSheet}
              prayer={prayers[qadhaSheet.idx]}
              onConfirm={confirmQadha}
              onClose={() => setQadhaSheet(null)}
              doneCount={doneCount}
              streak={streak}
              recoveries={recoveries}
            />
          )}

          {/* 5/5 Milestone Celebration */}
          {milestone === "complete" && <MilestoneCelebration streak={streak} recoveries={recoveries} />}

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

      <div style={{ display: "flex", gap: 12, marginTop: 16 }}>
        <button onClick={resetDemo} style={{ padding: "8px 20px", borderRadius: 12, border: `1px solid ${C.border}`, background: "white", fontSize: 12, fontWeight: 500, color: C.textSecondary, cursor: "pointer" }}>Reset demo</button>
      </div>
      <p style={{ fontSize: 11, color: C.textMuted, marginTop: 8, textAlign: "center" }}>Rapid-fire: tap Dzuhur → Ashar → Isya quickly to feel the speed<br/>Then tap Qadha on Maghrib for the recovery flow<br/>On completed prayers, tap "Add detail" to tag Jamaah/On time/Late<br/>Check all 4 to see the 5/5 milestone</p>
    </div>
  );
}

// ============================================
// PRAYER CARD
// ============================================
function PrayerCard({ prayer, idx, onCheckIn, onQadha, tags, onToggleTag }) {
  const s = statusStyles[prayer.status];
  const isActive = prayer.status === "active";
  const isMissed = prayer.status === "missed";
  const isDone = prayer.status === "done" || prayer.status === "qadha";
  const [justChecked, setJustChecked] = useState(false);
  const [showTags, setShowTags] = useState(false);

  const tagOptions = [
    { id: "jamaah_mosque", label: "Jamaah at mosque", icon: "🕌" },
    { id: "jamaah_home", label: "Jamaah at home", icon: "🏠" },
    { id: "prayed_early", label: "Prayed early", icon: "⏰" },
  ];

  useEffect(() => {
    if (prayer.status === "done" && !prayer.checkedAt?.startsWith("04")) {
      setJustChecked(true);
      const t = setTimeout(() => setJustChecked(false), 500);
      return () => clearTimeout(t);
    }
  }, [prayer.status]);

  return (
    <div style={{
      background: isActive ? "rgba(255,255,255,0.95)" : isMissed ? "rgba(255,240,241,0.6)" : "rgba(255,255,255,0.8)",
      borderRadius: 20, padding: "18px 16px",
      border: isActive ? `2px solid ${C.primary}` : isMissed ? `1.5px solid ${C.missed}40` : `1px solid rgba(235,235,240,0.8)`,
      boxShadow: justChecked ? `0 0 0 3px ${C.done}30` : isActive ? "0 4px 20px rgba(91,140,111,0.1)" : "0 1px 3px rgba(0,0,0,0.02)",
      transition: "all .35s ease",
      transform: justChecked ? "scale(0.98)" : "scale(1)",
    }}>
      <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
        {/* Status Circle */}
        <div style={{
          width: 46, height: 46, borderRadius: 23, background: s.bg,
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: isDone ? 20 : 16, color: s.color, fontWeight: 700, flexShrink: 0,
          transition: "all .35s", transform: justChecked ? "scale(1.15)" : "scale(1)",
        }}>
          {s.icon}
        </div>

        {/* Info */}
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", alignItems: "baseline", gap: 6 }}>
            <p style={{ fontSize: 17, fontWeight: 600, color: C.text, margin: 0 }}>{prayer.name}</p>
            <p style={{ fontSize: 14, color: C.textMuted, margin: 0, fontFamily: "'Noto Naskh Arabic',serif" }}>{prayer.arabic}</p>
          </div>
          <p style={{ fontSize: 12, color: C.textSecondary, margin: "3px 0 0" }}>{prayer.time}</p>
          {prayer.status === "qadha" && (
            <div style={{ display: "inline-flex", alignItems: "center", gap: 3, background: C.qadhaLight, padding: "3px 10px", borderRadius: 10, marginTop: 6 }}>
              <span style={{ fontSize: 11 }}>↩</span>
              <span style={{ fontSize: 11, fontWeight: 600, color: C.qadha }}>Recovered</span>
            </div>
          )}
        </div>

        {/* Action */}
        {isActive && (
          <button onClick={() => onCheckIn(idx)} style={{
            padding: "10px 18px", borderRadius: 14, border: "none",
            background: C.primary, color: "white", fontSize: 14, fontWeight: 600,
            cursor: "pointer", flexShrink: 0, transition: "transform .1s",
          }}
          onMouseDown={(e) => e.currentTarget.style.transform = "scale(0.95)"}
          onMouseUp={(e) => e.currentTarget.style.transform = "scale(1)"}
          >
            Check In
          </button>
        )}
        {isMissed && (
          <button onClick={() => onQadha(idx)} style={{
            padding: "10px 16px", borderRadius: 14, border: "none",
            background: C.qadha, color: "white", fontSize: 14, fontWeight: 600,
            cursor: "pointer", flexShrink: 0,
          }}>
            Qadha
          </button>
        )}
        {isDone && (
          <span style={{ fontSize: 12, color: s.color, fontWeight: 500 }}>✓</span>
        )}
      </div>

      {/* Tags Section — only for done/qadha prayers */}
      {isDone && (
        <div style={{ marginTop: tags.length > 0 || showTags ? 10 : 4, marginLeft: 60 }}>
          {/* Show selected tags as small badges */}
          {tags.length > 0 && !showTags && (
            <div style={{ display: "flex", flexWrap: "wrap", gap: 4, alignItems: "center" }}>
              {tags.map(tagId => {
                const tag = tagOptions.find(t => t.id === tagId);
                if (!tag) return null;
                return (
                  <span key={tagId} style={{
                    fontSize: 10, color: C.primary, fontWeight: 500,
                    background: C.primaryLight, padding: "2px 8px", borderRadius: 8,
                    display: "inline-flex", alignItems: "center", gap: 3,
                  }}>
                    {tag.icon} {tag.label}
                  </span>
                );
              })}
              <button onClick={() => setShowTags(true)} style={{
                background: "none", border: "none", cursor: "pointer", padding: "2px 4px",
                fontSize: 10, color: C.textMuted,
              }}>
                Edit
              </button>
            </div>
          )}

          {/* "Add detail" link */}
          {tags.length === 0 && !showTags && (
            <button onClick={() => setShowTags(true)} style={{
              background: "none", border: "none", cursor: "pointer", padding: 0,
              display: "flex", alignItems: "center", gap: 4,
            }}>
              <span style={{ fontSize: 11, color: C.textMuted }}>Add detail</span>
              <span style={{ fontSize: 9, color: C.textMuted }}>›</span>
            </button>
          )}

          {/* Expanded tag pills */}
          {showTags && (
            <div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 6, marginBottom: 8 }}>
                {tagOptions.map(tag => {
                  const selected = tags.includes(tag.id);
                  return (
                    <button
                      key={tag.id}
                      onClick={() => onToggleTag(tag.id)}
                      style={{
                        height: 52, borderRadius: 12,
                        border: selected ? `1.5px solid ${C.primary}` : `1px solid ${C.border}`,
                        background: selected ? C.primaryLight : "white",
                        cursor: "pointer", transition: "all .15s",
                        display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 2,
                      }}
                    >
                      <span style={{ fontSize: 16 }}>{tag.icon}</span>
                      <span style={{ fontSize: 9, fontWeight: selected ? 600 : 400, color: selected ? C.primary : C.textSecondary, lineHeight: 1.2, textAlign: "center" }}>
                        {tag.label}
                      </span>
                    </button>
                  );
                })}
              </div>
              <button onClick={() => setShowTags(false)} style={{
                background: "none", border: "none", cursor: "pointer", padding: 0,
              }}>
                <span style={{ fontSize: 10, color: C.textMuted }}>Done</span>
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

// ============================================
// SPIRITUAL TOAST — non-blocking, stacks gracefully
// ============================================
function SpiritualToast({ toast }) {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    if (!toast) return;
    setVisible(true);
    const t = setTimeout(() => setVisible(false), 2500);
    return () => clearTimeout(t);
  }, [toast]);

  if (!toast) return null;

  return (
    <div style={{
      position: "absolute", bottom: 90, left: 16, right: 16,
      zIndex: 80, pointerEvents: "none",
    }}>
      <div style={{
        background: "rgba(255,255,255,0.94)",
        backdropFilter: "blur(16px)", WebkitBackdropFilter: "blur(16px)",
        borderRadius: 16, padding: "12px 16px",
        boxShadow: "0 4px 20px rgba(0,0,0,0.08), 0 0 0 0.5px rgba(0,0,0,0.04)",
        opacity: visible ? 1 : 0,
        transform: visible ? "translateY(0)" : "translateY(12px)",
        transition: "all .35s ease",
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
          <div style={{ width: 20, height: 20, borderRadius: 10, background: C.doneLight, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <span style={{ fontSize: 11, color: C.done, fontWeight: 700 }}>✓</span>
          </div>
          <span style={{ fontSize: 13, fontWeight: 600, color: C.primary }}>{toast.prayer}</span>
        </div>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: 0, lineHeight: 1.5, fontStyle: "italic" }}>
          {toast.message}
        </p>
      </div>
    </div>
  );
}

// ============================================
// QADHA BOTTOM SHEET — warm, intentional
// ============================================
function QadhaSheet({ sheet, prayer, onConfirm, onClose, doneCount, streak, recoveries }) {
  return (
    <>
      <div onClick={sheet.phase === "confirm" ? onClose : undefined} style={{
        position: "absolute", inset: 0, borderRadius: 38,
        background: "rgba(0,0,0,0.18)", zIndex: 90,
      }} />

      <div style={{
        position: "absolute", bottom: 0, left: 0, right: 0,
        background: "white", borderRadius: "24px 24px 0 0",
        padding: "20px 24px 40px", zIndex: 100,
        boxShadow: "0 -4px 24px rgba(0,0,0,0.08)",
      }}>
        <div style={{ width: 36, height: 4, borderRadius: 2, background: C.border, margin: "0 auto 20px" }} />

        {sheet.phase === "confirm" && (
          <div style={{ textAlign: "center" }}>
            <div style={{
              width: 52, height: 52, borderRadius: 18, background: C.qadhaLight,
              display: "flex", alignItems: "center", justifyContent: "center",
              margin: "0 auto 14px",
            }}>
              <span style={{ fontSize: 24, color: C.qadha }}>↩</span>
            </div>

            <h3 style={{ fontSize: 20, fontWeight: 700, color: C.text, margin: "0 0 4px" }}>
              Make up {prayer.name}?
            </h3>
            <p style={{ fontSize: 14, color: C.textSecondary, margin: "0 0 4px" }}>
              {prayer.arabic} · Azan was at {prayer.time}
            </p>
            <p style={{ fontSize: 13, color: C.qadha, margin: "0 0 24px", lineHeight: 1.5 }}>
              You missed this prayer, but you can still recover it.<br />
              Your streak won't break.
            </p>

            <button onClick={onConfirm} style={{
              width: "100%", padding: "16px", borderRadius: 16, border: "none",
              background: C.qadha, color: "white", fontSize: 16, fontWeight: 600, cursor: "pointer",
            }}>
              I prayed Qadha ✓
            </button>

            <button onClick={onClose} style={{ background: "none", border: "none", cursor: "pointer", padding: "14px", width: "100%" }}>
              <span style={{ fontSize: 14, color: C.textMuted }}>Not yet</span>
            </button>
          </div>
        )}

        {sheet.phase === "message" && (
          <QadhaMessage prayer={prayer} message={sheet.message} doneCount={doneCount + 1} streak={streak} recoveries={recoveries + 1} />
        )}
      </div>
    </>
  );
}

function QadhaMessage({ prayer, message, doneCount, streak, recoveries }) {
  const [show, setShow] = useState(false);
  useEffect(() => { setTimeout(() => setShow(true), 100); }, []);

  return (
    <div style={{ textAlign: "center" }}>
      <div style={{
        width: 52, height: 52, borderRadius: 26, background: C.qadhaLight,
        display: "flex", alignItems: "center", justifyContent: "center",
        margin: "0 auto 12px",
      }}>
        <span style={{ fontSize: 26, color: C.qadha }}>✓</span>
      </div>

      <p style={{ fontSize: 18, fontWeight: 700, color: C.text, margin: "0 0 2px" }}>
        {prayer.name} recovered
      </p>
      <p style={{ fontSize: 13, color: C.textSecondary, margin: "0 0 16px" }}>
        {doneCount}/5 today · 🔥 {streak} +{recoveries} days
      </p>

      <div style={{
        background: C.qadhaLight, borderRadius: 16, padding: "14px 18px",
        opacity: show ? 1 : 0, transform: show ? "translateY(0)" : "translateY(6px)",
        transition: "all .4s ease",
      }}>
        <p style={{ fontSize: 15, color: C.text, margin: 0, lineHeight: 1.6 }}>
          "{message}"
        </p>
      </div>

      <p style={{
        fontSize: 12, color: C.qadha, margin: "12px 0 0", fontWeight: 500,
        opacity: show ? 1 : 0, transition: "opacity .4s ease .2s",
      }}>
        Your streak continues. This recovery is noted.
      </p>
    </div>
  );
}

// ============================================
// 5/5 MILESTONE CELEBRATION
// ============================================
function MilestoneCelebration({ streak, recoveries }) {
  const [phase, setPhase] = useState(0);
  useEffect(() => {
    setTimeout(() => setPhase(1), 100);
    setTimeout(() => setPhase(2), 2800);
  }, []);

  return (
    <div style={{
      position: "absolute", inset: 0, borderRadius: 38,
      background: phase === 2 ? "rgba(253,251,247,0)" : "rgba(253,251,247,0.97)",
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
      zIndex: 120, transition: "background .4s",
      pointerEvents: phase === 2 ? "none" : "auto",
    }}>
      <div style={{
        opacity: phase === 1 ? 1 : 0,
        transform: phase === 1 ? "scale(1)" : "scale(0.9)",
        transition: "all .6s cubic-bezier(.34,1.56,.64,1)",
        textAlign: "center", padding: "0 32px",
      }}>
        <div style={{ fontSize: 52, marginBottom: 8 }}>🤲</div>
        <h2 style={{ fontSize: 28, fontWeight: 700, color: C.primary, margin: "0 0 6px" }}>
          Alhamdulillah
        </h2>
        <p style={{ fontSize: 18, color: C.text, fontWeight: 500, margin: "0 0 4px" }}>
          All 5 prayers completed
        </p>
        <p style={{ fontSize: 15, color: C.textSecondary, margin: "0 0 20px" }}>
          🔥 {streak}{recoveries > 0 ? ` +${recoveries}` : ""} days
        </p>
        <p style={{ fontSize: 13, color: C.textMuted, fontStyle: "italic", lineHeight: 1.6 }}>
          "Whoever guards their five daily prayers,<br />they shall have light, proof, and salvation<br />on the Day of Resurrection."
        </p>
        <p style={{ fontSize: 11, color: C.textMuted, margin: "6px 0 0" }}>— Ahmad</p>

        {/* 5 completed dots */}
        <div style={{ display: "flex", gap: 8, justifyContent: "center", marginTop: 20 }}>
          {[C.done, C.done, C.done, C.done, C.done].map((c, i) => (
            <div key={i} style={{ width: 10, height: 10, borderRadius: 5, background: c }} />
          ))}
        </div>
      </div>
    </div>
  );
}
