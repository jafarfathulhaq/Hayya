import { useState } from "react";

const C = {
  bg: "#FDFBF7", primary: "#5B8C6F", primaryLight: "#E8F0EB", primarySoft: "#A8CBB7",
  accent: "#D4A843", accentLight: "#FFF6E3", text: "#2C2C2C", textSecondary: "#8E8E93",
  textMuted: "#B5B5BA", done: "#7FC4A0", doneLight: "#EEFAF3", missed: "#E8878F",
  missedLight: "#FFF0F1", qadha: "#E0B86B", qadhaLight: "#FFF8EC", upcoming: "#D1D1D6",
  upcomingLight: "#F5F5F7", border: "#EBEBF0", whatsapp: "#25D366",
};

const partnerPrayers = [
  { name: "Subuh", status: "done" },
  { name: "Dzuhur", status: "done" },
  { name: "Ashar", status: "done" },
  { name: "Maghrib", status: "active" },
  { name: "Isya", status: "upcoming" },
];

const prayedTogetherHistory = [
  { prayer: "Subuh", date: "Today", time: "04:58" },
  { prayer: "Dzuhur", date: "Today", time: "12:12" },
  { prayer: "Isya", date: "Yesterday", time: "19:22" },
  { prayer: "Maghrib", date: "Yesterday", time: "18:02" },
  { prayer: "Subuh", date: "Yesterday", time: "05:01" },
  { prayer: "Maghrib", date: "2 days ago", time: "17:58" },
  { prayer: "Dzuhur", date: "2 days ago", time: "12:08" },
  { prayer: "Isya", date: "3 days ago", time: "19:18" },
];

const statusDot = (status) => {
  const colors = { done: C.done, upcoming: C.upcoming, missed: C.missed, qadha: C.qadha };
  return colors[status] || C.upcoming;
};

export default function TogetherTab() {
  const [view, setView] = useState("connected"); // empty | connected | history
  const [buzzSent, setBuzzSent] = useState({});
  const [showInvite, setShowInvite] = useState(false);
  const [inviteType, setInviteType] = useState(null);

  return (
    <div style={{ minHeight: "100vh", background: "linear-gradient(135deg,#F0EDE6,#E8E4DC 50%,#F2EFE8)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "20px 16px", fontFamily: "'DM Sans','Nunito',system-ui,-apple-system,sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=Noto+Naskh+Arabic:wght@400;500;600&display=swap" rel="stylesheet" />

      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <h1 style={{ fontSize: 16, fontWeight: 600, color: C.text, letterSpacing: 0.5, margin: 0 }}>HAYYA — Together Tab</h1>
        <p style={{ fontSize: 12, color: C.textSecondary, margin: "3px 0 0" }}>Switch between states to see the full journey</p>
      </div>

      {/* State Toggle */}
      <div style={{ display: "flex", gap: 6, marginBottom: 14 }}>
        {[
          { id: "empty", label: "Solo (empty)" },
          { id: "connected", label: "Connected" },
          { id: "history", label: "Weekly summary" },
        ].map(s => (
          <button key={s.id} onClick={() => { setView(s.id); setBuzzSent({}); setShowInvite(false); setInviteType(null); }} style={{
            padding: "5px 14px", borderRadius: 16,
            border: view === s.id ? `2px solid ${C.primary}` : `1px solid ${C.border}`,
            background: view === s.id ? C.primaryLight : "white",
            fontSize: 11, fontWeight: view === s.id ? 600 : 400,
            color: view === s.id ? C.primary : C.textSecondary, cursor: "pointer",
          }}>{s.label}</button>
        ))}
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
          <div style={{ padding: "4px 20px 14px", flexShrink: 0 }}>
            <h2 style={{ fontSize: 28, fontWeight: 700, color: C.text, margin: "0 0 4px" }}>Together</h2>
            <p style={{ fontSize: 13, color: C.textSecondary, margin: 0 }}>
              {view === "empty" ? "Pray with someone you love." : "Your shared prayer journey."}
            </p>
          </div>

          {/* Content */}
          <div style={{ flex: 1, overflowY: "auto", padding: "0 14px 14px" }}>

            {/* ===== EMPTY STATE ===== */}
            {view === "empty" && (
              <div style={{ display: "flex", flexDirection: "column", alignItems: "center", padding: "20px 16px" }}>
                {/* Spiritual Reflection */}
                <div style={{
                  width: "100%", background: C.primaryLight, borderRadius: 18,
                  padding: "20px 18px", textAlign: "center", marginBottom: 16,
                }}>
                  <p style={{ fontSize: 14, color: C.text, margin: "0 0 6px", lineHeight: 1.6, fontStyle: "italic" }}>
                    "The prayer in congregation is twenty-seven times better than the prayer offered alone."
                  </p>
                  <p style={{ fontSize: 11, color: C.textMuted, margin: "0 0 10px" }}>— Sahih Bukhari & Muslim</p>
                  <p style={{ fontSize: 12, color: C.primary, margin: 0, fontWeight: 500 }}>Invite someone when you're ready.</p>
                </div>

                {/* Prayed Together Preview Card */}
                <div style={{
                  width: "100%", background: "white", borderRadius: 24,
                  padding: "28px 20px", textAlign: "center", marginBottom: 20,
                  border: `1px solid ${C.border}`,
                  boxShadow: "0 4px 16px rgba(0,0,0,0.03)",
                }}>
                  <div style={{ fontSize: 36, marginBottom: 8, opacity: 0.4 }}>🤲</div>
                  <h3 style={{ fontSize: 20, fontWeight: 700, color: C.accent, margin: "0 0 4px", opacity: 0.5 }}>Prayed Together</h3>
                  <p style={{ fontSize: 14, color: C.textMuted, margin: "0 0 4px" }}>Maghrib</p>
                  <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 10, marginTop: 10 }}>
                    <div style={{ width: 32, height: 32, borderRadius: 16, background: C.primaryLight, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14 }}>👤</div>
                    <span style={{ fontSize: 16, color: C.border }}>♥</span>
                    <div style={{ width: 32, height: 32, borderRadius: 16, background: C.border, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14, color: C.textMuted }}>?</div>
                  </div>
                  <p style={{ fontSize: 13, color: C.textMuted, margin: "12px 0 0" }}>You & ...</p>
                </div>

                <p style={{ fontSize: 16, fontWeight: 600, color: C.text, margin: "0 0 8px", textAlign: "center" }}>
                  Share this moment with someone you love.
                </p>
                <p style={{ fontSize: 14, color: C.textSecondary, margin: "0 0 24px", textAlign: "center", lineHeight: 1.5 }}>
                  Invite someone you trust to share<br />your prayer journey with you.
                </p>

                {!showInvite ? (
                  <button onClick={() => setShowInvite(true)} style={{
                    width: "100%", padding: "15px", borderRadius: 16, border: "none",
                    background: C.primary, color: "white", fontSize: 16, fontWeight: 600, cursor: "pointer",
                    marginBottom: 20,
                  }}>
                    Invite someone
                  </button>
                ) : (
                  <div style={{ width: "100%", marginBottom: 20 }}>
                    <p style={{ fontSize: 13, fontWeight: 600, color: C.text, margin: "0 0 8px" }}>Who would you like to invite?</p>
                    <div style={{ display: "flex", gap: 8 }}>
                      {[
                        { label: "My spouse", icon: "💑" },
                        { label: "Family", icon: "👨‍👩‍👧" },
                        { label: "Friend", icon: "🤝" },
                      ].map(opt => (
                        <button key={opt.label} onClick={() => setInviteType(opt.label)} style={{
                          flex: 1, padding: "12px 6px", borderRadius: 14,
                          border: inviteType === opt.label ? `2px solid ${C.primary}` : `1.5px solid ${C.border}`,
                          background: inviteType === opt.label ? C.primaryLight : "white",
                          cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
                        }}>
                          <span style={{ fontSize: 20 }}>{opt.icon}</span>
                          <span style={{ fontSize: 11, fontWeight: inviteType === opt.label ? 600 : 400, color: inviteType === opt.label ? C.primary : C.textSecondary }}>{opt.label}</span>
                        </button>
                      ))}
                    </div>
                  </div>
                )}

                {/* Social proof */}
                <div style={{ background: C.primaryLight, borderRadius: 14, padding: "12px 16px", width: "100%", textAlign: "center" }}>
                  <p style={{ fontSize: 12, color: C.primary, margin: 0, lineHeight: 1.5 }}>
                    🤲 Couples who pray together on Hayya check in<br />more consistently than solo users.
                  </p>
                </div>

                {/* WhatsApp invite preview */}
                {inviteType && (
                  <div style={{ marginTop: 0, width: "100%", background: "#F0FFF0", borderRadius: 16, padding: "16px 18px", border: `1.5px solid ${C.whatsapp}30` }}>
                    <p style={{ fontSize: 12, fontWeight: 600, color: C.text, margin: "0 0 8px" }}>Your {inviteType.toLowerCase()} will see:</p>
                    <div style={{ background: "white", borderRadius: 12, padding: "12px 14px", border: `1px solid ${C.border}` }}>
                      <p style={{ fontSize: 13, color: C.text, margin: 0, lineHeight: 1.5 }}>
                        <span style={{ fontWeight: 600 }}>You</span> invited you to pray together on Hayya.
                      </p>
                      <p style={{ fontSize: 13, color: C.text, margin: "4px 0 0", fontStyle: "italic" }}>"Let's help each other keep our prayers 🤲"</p>
                    </div>
                    <button style={{ width: "100%", marginTop: 10, padding: "12px", borderRadius: 12, border: "none", background: C.whatsapp, color: "white", fontSize: 14, fontWeight: 600, cursor: "pointer" }}>
                      Send via WhatsApp
                    </button>
                  </div>
                )}
              </div>
            )}

            {/* ===== CONNECTED STATE ===== */}
            {(view === "connected" || view === "history") && (
              <>
                {/* Partner Profile Card */}
                <div style={{
                  background: "white", borderRadius: 22, padding: "20px 18px",
                  border: `1px solid ${C.border}`, marginBottom: 12,
                  boxShadow: "0 2px 12px rgba(0,0,0,0.03)",
                }}>
                  {/* Top: avatar + name + streak */}
                  <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16 }}>
                    <div style={{
                      width: 48, height: 48, borderRadius: 24,
                      background: `linear-gradient(135deg, ${C.primaryLight}, ${C.accentLight})`,
                      display: "flex", alignItems: "center", justifyContent: "center",
                      fontSize: 22,
                    }}>
                      👩
                    </div>
                    <div style={{ flex: 1 }}>
                      <p style={{ fontSize: 18, fontWeight: 700, color: C.text, margin: 0 }}>Aisha</p>
                      <p style={{ fontSize: 12, color: C.textSecondary, margin: "2px 0 0" }}>Praying together since 1 Ramadan</p>
                    </div>
                    <div style={{ display: "flex", alignItems: "center", gap: 4, background: C.accentLight, padding: "5px 10px", borderRadius: 14 }}>
                      <span style={{ fontSize: 11 }}>🔥</span>
                      <span style={{ fontSize: 13, fontWeight: 700, color: C.accent }}>4</span>
                    </div>
                  </div>

                  {/* Prayer Dots — large, with active state */}
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 16 }}>
                    {partnerPrayers.map((p, i) => {
                      const dotColor = p.status === "done" ? C.done : p.status === "active" ? C.accent : C.upcoming;
                      const dotBg = p.status === "done" ? C.doneLight : p.status === "active" ? C.accentLight : C.upcomingLight;
                      const dotIcon = p.status === "done" ? "✓" : p.status === "active" ? "●" : "○";
                      return (
                        <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, flex: 1 }}>
                          <div style={{
                            width: 32, height: 32, borderRadius: 16, background: dotBg,
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontSize: 14, color: dotColor, fontWeight: 700,
                            boxShadow: p.status === "active" ? `0 0 8px ${C.accent}30` : "none",
                          }}>
                            {dotIcon}
                          </div>
                          <span style={{ fontSize: 10, color: p.status === "upcoming" ? C.textMuted : dotColor, fontWeight: p.status === "upcoming" ? 400 : 500 }}>
                            {p.name}
                          </span>
                        </div>
                      );
                    })}
                  </div>

                  {/* Reminder — only for the current active prayer */}
                  {(() => {
                    const activePrayer = partnerPrayers.find(p => p.status === "active");
                    if (!activePrayer) return null;
                    const sent = buzzSent[activePrayer.name];
                    // Simulate timing: Maghrib window closing soon
                    const timeLeft = 22; // minutes left in window (simulated)
                    const urgency = timeLeft <= 10 ? "urgent" : timeLeft <= 30 ? "late" : "early";
                    const sentCopy = {
                      early: `Time to pray — a gentle reminder from you 🤲`,
                      late: `${activePrayer.name} time is almost up. A reminder from you 🤲`,
                      urgent: `${activePrayer.name} sebentar lagi berakhir 🤲`,
                    };
                    return (
                      <div>
                        <button
                          onClick={() => !sent && setBuzzSent(prev => ({ ...prev, [activePrayer.name]: true }))}
                          style={{
                            width: "100%", padding: "12px 16px", borderRadius: 14,
                            border: sent ? `1.5px solid ${C.done}` : `1.5px solid ${C.primary}`,
                            background: sent ? C.doneLight : "white",
                            cursor: sent ? "default" : "pointer",
                            display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                            transition: "all .2s",
                          }}
                        >
                          <span style={{ fontSize: 13 }}>{sent ? "✓" : "👆"}</span>
                          <span style={{ fontSize: 13, fontWeight: 600, color: sent ? C.done : C.primary }}>
                            {sent ? "Reminder sent 🤲" : `Remind Aisha for ${activePrayer.name}`}
                          </span>
                        </button>
                        {/* Sent copy preview */}
                        {sent && (
                          <div style={{
                            marginTop: 8, padding: "8px 12px", borderRadius: 10,
                            background: C.doneLight, textAlign: "center",
                          }}>
                            <p style={{ fontSize: 10, color: C.textMuted, margin: "0 0 2px" }}>Aisha received:</p>
                            <p style={{ fontSize: 11, color: C.done, margin: 0, fontStyle: "italic" }}>
                              "{sentCopy[urgency]}"
                            </p>
                          </div>
                        )}
                        {/* Timing context */}
                        {!sent && (
                          <p style={{ fontSize: 10, color: urgency === "early" ? C.textMuted : C.accent, margin: "6px 0 0", textAlign: "center" }}>
                            {urgency === "early" ? `${timeLeft} min left in ${activePrayer.name} window` : urgency === "late" ? `⚡ Only ${timeLeft} min left — reminder will be stronger` : `⚡ Less than 10 min — urgent reminder`}
                          </p>
                        )}
                      </div>
                    );
                  })()}
                </div>

                {/* Buzz Info */}
                <p style={{ fontSize: 11, color: C.textMuted, textAlign: "center", margin: "4px 0 16px", lineHeight: 1.4 }}>
                  One reminder per prayer. Hayya adjusts the tone<br />based on how much time is left.
                </p>

                {/* Today's Prayed Together */}
                {(view === "connected" || view === "history") && (
                  <div style={{ marginBottom: 12 }}>
                    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 2px", marginBottom: 10 }}>
                      <p style={{ fontSize: 13, fontWeight: 600, color: C.text, margin: 0 }}>Today</p>
                      {prayedTogetherHistory.filter(m => m.date === "Today").length > 0 && (
                        <span style={{ fontSize: 12, fontWeight: 600, color: C.accent }}>
                          {prayedTogetherHistory.filter(m => m.date === "Today").length} prayers together
                        </span>
                      )}
                    </div>
                    <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                      {prayedTogetherHistory.filter(m => m.date === "Today").map((moment, i) => (
                        <PrayedTogetherCard key={i} moment={moment} />
                      ))}
                      {prayedTogetherHistory.filter(m => m.date === "Today").length === 0 && (
                        <p style={{ fontSize: 12, color: C.textMuted, textAlign: "center", padding: "8px 0" }}>No shared prayers yet today. Keep going!</p>
                      )}
                    </div>
                  </div>
                )}

                {/* Weekly Summary — replaces per-prayer history */}
                {view === "history" && (
                  <div style={{ display: "flex", flexDirection: "column", gap: 10, marginBottom: 12 }}>
                    {/* This week */}
                    <div style={{
                      background: "white", borderRadius: 18, padding: "18px 18px",
                      border: `1px solid ${C.border}`,
                    }}>
                      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
                        <p style={{ fontSize: 13, fontWeight: 600, color: C.text, margin: 0 }}>This week</p>
                        <span style={{ fontSize: 20, fontWeight: 700, color: C.accent }}>8</span>
                      </div>
                      {/* 7 day dots */}
                      <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 10 }}>
                        {[
                          { day: "Mon", count: 2 },
                          { day: "Tue", count: 1 },
                          { day: "Wed", count: 0 },
                          { day: "Thu", count: 3 },
                          { day: "Fri", count: 0 },
                          { day: "Sat", count: 0 },
                          { day: "Sun", count: 2 },
                        ].map((d, i) => (
                          <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, flex: 1 }}>
                            <div style={{
                              width: 28, height: 28, borderRadius: 14,
                              background: d.count > 0 ? (d.count >= 3 ? C.accent : d.count >= 2 ? C.accentLight : "#FFF6E3") : C.upcomingLight,
                              display: "flex", alignItems: "center", justifyContent: "center",
                              border: d.count > 0 ? `1.5px solid ${d.count >= 3 ? C.accent : C.accent}40` : `1px solid ${C.border}`,
                            }}>
                              {d.count > 0 && <span style={{ fontSize: 10, fontWeight: 700, color: C.accent }}>{d.count}</span>}
                            </div>
                            <span style={{ fontSize: 9, color: d.count > 0 ? C.textSecondary : C.textMuted }}>{d.day}</span>
                          </div>
                        ))}
                      </div>
                      <p style={{ fontSize: 12, color: C.textSecondary, margin: 0, textAlign: "center" }}>
                        8 prayers together with Aisha
                      </p>
                    </div>

                    {/* Last week */}
                    <div style={{
                      background: "white", borderRadius: 18, padding: "16px 18px",
                      border: `1px solid ${C.border}`,
                    }}>
                      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 10 }}>
                        <p style={{ fontSize: 13, fontWeight: 600, color: C.textSecondary, margin: 0 }}>Last week</p>
                        <span style={{ fontSize: 18, fontWeight: 700, color: C.textSecondary }}>5</span>
                      </div>
                      <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
                        {[
                          { day: "Mon", count: 1 },
                          { day: "Tue", count: 0 },
                          { day: "Wed", count: 2 },
                          { day: "Thu", count: 0 },
                          { day: "Fri", count: 1 },
                          { day: "Sat", count: 0 },
                          { day: "Sun", count: 1 },
                        ].map((d, i) => (
                          <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, flex: 1 }}>
                            <div style={{
                              width: 24, height: 24, borderRadius: 12,
                              background: d.count > 0 ? C.accentLight : C.upcomingLight,
                              display: "flex", alignItems: "center", justifyContent: "center",
                              border: d.count > 0 ? `1px solid ${C.accent}30` : `1px solid ${C.border}`,
                            }}>
                              {d.count > 0 && <span style={{ fontSize: 9, fontWeight: 600, color: C.accent }}>{d.count}</span>}
                            </div>
                            <span style={{ fontSize: 8, color: C.textMuted }}>{d.day}</span>
                          </div>
                        ))}
                      </div>
                      <p style={{ fontSize: 11, color: C.textMuted, margin: 0, textAlign: "center" }}>
                        5 prayers together
                      </p>
                    </div>

                    {/* Trend + best week */}
                    <div style={{ display: "flex", gap: 10 }}>
                      <div style={{
                        flex: 1, background: C.primaryLight, borderRadius: 16, padding: "14px 12px", textAlign: "center",
                      }}>
                        <p style={{ fontSize: 11, fontWeight: 600, color: C.primary, margin: "0 0 2px" }}>Trend</p>
                        <p style={{ fontSize: 20, fontWeight: 700, color: C.primary, margin: 0 }}>↑ 60%</p>
                        <p style={{ fontSize: 10, color: C.textSecondary, margin: "2px 0 0" }}>vs last week</p>
                      </div>
                      <div style={{
                        flex: 1, background: C.accentLight, borderRadius: 16, padding: "14px 12px", textAlign: "center",
                      }}>
                        <p style={{ fontSize: 11, fontWeight: 600, color: C.accent, margin: "0 0 2px" }}>Best week</p>
                        <p style={{ fontSize: 20, fontWeight: 700, color: C.accent, margin: 0 }}>12</p>
                        <p style={{ fontSize: 10, color: C.textSecondary, margin: "2px 0 0" }}>prayers together</p>
                      </div>
                    </div>

                    {/* Du'a card */}
                    <div style={{
                      background: C.accentLight, borderRadius: 16, padding: "14px 16px",
                      textAlign: "center",
                    }}>
                      <p style={{ fontSize: 12, color: C.textSecondary, margin: "0 0 4px" }}>
                        You've prayed together <span style={{ fontWeight: 700, color: C.accent }}>13 times</span> since 1 Ramadan
                      </p>
                      <p style={{ fontSize: 12, color: C.accent, margin: 0, fontStyle: "italic" }}>May Allah accept them.</p>
                    </div>
                  </div>
                )}

                {/* Privacy note */}
                <div style={{ textAlign: "center", padding: "16px 12px 8px" }}>
                  <p style={{ fontSize: 10, color: C.textMuted, margin: 0, lineHeight: 1.5 }}>
                    <span style={{ fontWeight: 600 }}>Only today's status is shared.</span> No historical data.<br />
                    You can pause sharing or disconnect anytime in Settings.
                  </p>
                </div>
              </>
            )}
          </div>

          {/* Floating Tab Bar */}
          <div style={{ padding: "0 24px 16px", flexShrink: 0 }}>
            <div style={{ display: "flex", justifyContent: "space-around", padding: "8px 6px", background: "rgba(255,255,255,0.88)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)", borderRadius: 28, boxShadow: "0 2px 20px rgba(0,0,0,0.06), 0 0 0 0.5px rgba(0,0,0,0.04)" }}>
              {[
                { label: "Today", active: false, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><path d="M3 7v11a3 3 0 003 3h12a3 3 0 003-3V7"/><path d="M3 7l9 6 9-6"/><path d="M3 7h18"/><circle cx="12" cy="4" r="1.5" fill={c} stroke="none"/></svg> },
                { label: "Together", active: true, icon: (c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="8" r="3"/><circle cx="17" cy="8" r="2.5"/><path d="M3 21v-1a5 5 0 015-5h2a5 5 0 015 5v1"/><path d="M17 13.5a3.5 3.5 0 013.5 3.5V21"/></svg> },
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
        Toggle states above • Try buzzing for Maghrib/Isya • Tap "Invite" in empty state
      </p>
    </div>
  );
}

// ============================================
// PRAYED TOGETHER CARD
// ============================================
function PrayedTogetherCard({ moment, muted = false }) {
  return (
    <div style={{
      background: muted ? "rgba(255,255,255,0.6)" : "white",
      borderRadius: 16, padding: "12px 16px",
      border: `1px solid ${muted ? C.border : C.accentLight}`,
      display: "flex", alignItems: "center", gap: 12,
      boxShadow: muted ? "none" : "0 1px 6px rgba(212,168,67,0.06)",
    }}>
      <div style={{
        width: 38, height: 38, borderRadius: 19,
        background: muted ? C.upcomingLight : C.accentLight,
        display: "flex", alignItems: "center", justifyContent: "center",
        fontSize: 18,
      }}>
        🤲
      </div>
      <div style={{ flex: 1 }}>
        <p style={{ fontSize: 14, fontWeight: 600, color: muted ? C.textSecondary : C.text, margin: 0 }}>
          {moment.prayer}
        </p>
        <p style={{ fontSize: 11, color: C.textMuted, margin: "2px 0 0" }}>
          You & Aisha · {moment.time}
        </p>
      </div>
      <span style={{ fontSize: 11, color: muted ? C.textMuted : C.accent, fontWeight: 500 }}>
        Prayed Together
      </span>
    </div>
  );
}
