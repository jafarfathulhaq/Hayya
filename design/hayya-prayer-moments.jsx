import { useState } from "react";

// Temporal color themes per prayer
const themes = {
  Subuh: {
    bg: "#0D1B2A", bgGlow: "#1B2D45", text: "#E8E4DC", textSoft: "#8B9BB4", textMuted: "#4A5568",
    accent: "#7EAFC4", accentSoft: "#3D5A73", hadithBg: "#3D3220", hadithBorder: "#D4A84320",
    hadithText: "#D4A843", btnGrad: "linear-gradient(135deg, #7FC4A0, #7EAFC4)", btnText: "#0D1B2A",
    btnGlow: "#7FC4A030", emoji: "🌙", label: "Pre-dawn", isDark: true,
  },
  Dzuhur: {
    bg: "#FDFBF7", bgGlow: "#F7F3EC", text: "#2C2C2C", textSoft: "#8E8E93", textMuted: "#B5B5BA",
    accent: "#5B8C6F", accentSoft: "#E8F0EB", hadithBg: "#E8F0EB", hadithBorder: "#5B8C6F20",
    hadithText: "#5B8C6F", btnGrad: "linear-gradient(135deg, #5B8C6F, #7FC4A0)", btnText: "#FFFFFF",
    btnGlow: "#5B8C6F20", emoji: "☀️", label: "Midday", isDark: false,
  },
  Ashar: {
    bg: "#FAF7F2", bgGlow: "#F2EFE8", text: "#2C2C2C", textSoft: "#8E8E93", textMuted: "#B5B5BA",
    accent: "#8B7D5E", accentSoft: "#F0EBDF", hadithBg: "#F0EBDF", hadithBorder: "#8B7D5E20",
    hadithText: "#8B7D5E", btnGrad: "linear-gradient(135deg, #5B8C6F, #8B9E7D)", btnText: "#FFFFFF",
    btnGlow: "#5B8C6F20", emoji: "🌤️", label: "Afternoon", isDark: false,
  },
  Maghrib: {
    bg: "#FFF8F0", bgGlow: "#F8EDE0", text: "#2C2C2C", textSoft: "#8E8E93", textMuted: "#B5B5BA",
    accent: "#D4A843", accentSoft: "#FFF6E3", hadithBg: "#FFF6E3", hadithBorder: "#D4A84330",
    hadithText: "#D4A843", btnGrad: "linear-gradient(135deg, #D4A843, #E0C06A)", btnText: "#FFFFFF",
    btnGlow: "#D4A84320", emoji: "🌅", label: "Sunset", isDark: false,
    urgent: true,
  },
  Isya: {
    bg: "#1A1F2E", bgGlow: "#252B3D", text: "#E0DCD4", textSoft: "#8B9BB4", textMuted: "#4A5568",
    accent: "#8B9BB4", accentSoft: "#2A3045", hadithBg: "#2A3045", hadithBorder: "#8B9BB430",
    hadithText: "#A8B8D0", btnGrad: "linear-gradient(135deg, #5B8C6F, #7EAFC4)", btnText: "#1A1F2E",
    btnGlow: "#5B8C6F20", emoji: "🌃", label: "Night", isDark: true,
  },
};

const prayerData = {
  Subuh: { arabic: "الصبح", time: "04:52", nextPrayer: "Dzuhur", nextTime: "11:58" },
  Dzuhur: { arabic: "الظهر", time: "11:58", nextPrayer: "Ashar", nextTime: "15:12" },
  Ashar: { arabic: "العصر", time: "15:12", nextPrayer: "Maghrib", nextTime: "17:54" },
  Maghrib: { arabic: "المغرب", time: "17:54", nextPrayer: "Isya", nextTime: "19:08" },
  Isya: { arabic: "العشاء", time: "19:08", nextPrayer: "Subuh", nextTime: "04:52" },
};

const prayerHadiths = {
  Subuh: [
    { text: "Whoever prays Fajr is under the protection of Allah.", source: "Sahih Muslim" },
    { text: "The two rak'ahs of Fajr are better than the world and all it contains.", source: "Sahih Muslim" },
  ],
  Dzuhur: [
    { text: "The first matter the servant will be questioned about is prayer.", source: "Sunan An-Nasa'i" },
    { text: "Between each two adhans there is a prayer for the one who wants to pray.", source: "Sahih Bukhari" },
  ],
  Ashar: [
    { text: "Whoever prays the two cool prayers will enter Paradise.", source: "Sahih Bukhari" },
    { text: "Guard strictly the middle prayer.", source: "Al-Baqarah 2:238" },
  ],
  Maghrib: [
    { text: "Hasten to break the fast and hasten to prayer.", source: "Hadith" },
    { text: "You remembered Allah at the day's end. That matters.", source: "Encouragement" },
  ],
  Isya: [
    { text: "Whoever prays Isha in congregation, it is as if they stood half the night.", source: "Sahih Muslim" },
    { text: "The night prayer is the most virtuous prayer after the obligatory.", source: "Sahih Muslim" },
  ],
};

const prayerNames = ["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"];

export default function PrayerMoments() {
  const [activePrayer, setActivePrayer] = useState("Subuh");
  const [phase, setPhase] = useState("moment"); // moment | checkedin | snoozed
  const [snoozeCount, setSnoozeCount] = useState(0);

  const t = themes[activePrayer];
  const data = prayerData[activePrayer];
  const hadiths = prayerHadiths[activePrayer];
  const hadith = hadiths[0];
  const isSubuh = activePrayer === "Subuh";

  const switchPrayer = (name) => {
    setActivePrayer(name);
    setPhase("moment");
    setSnoozeCount(0);
  };

  const handleCheckIn = () => {
    setPhase("checkedin");
  };

  const handleSnooze = () => {
    if (snoozeCount >= 3) return;
    setSnoozeCount(s => s + 1);
    setPhase("snoozed");
    setTimeout(() => setPhase("moment"), 2500);
  };

  return (
    <div style={{ minHeight: "100vh", background: "#0A0F1A", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "20px 16px", fontFamily: "'DM Sans','Nunito',system-ui,-apple-system,sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=Noto+Naskh+Arabic:wght@400;500;600&display=swap" rel="stylesheet" />

      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <h1 style={{ fontSize: 16, fontWeight: 600, color: "#E8E4DC", letterSpacing: 0.5, margin: 0 }}>HAYYA — Prayer Moments</h1>
        <p style={{ fontSize: 12, color: "#8B9BB4", margin: "3px 0 0" }}>What users see when opening a prayer notification. Tap prayers below to switch.</p>
      </div>

      {/* Prayer Switcher */}
      <div style={{ display: "flex", gap: 4, marginBottom: 14 }}>
        {prayerNames.map(name => {
          const pt = themes[name];
          const active = activePrayer === name;
          return (
            <button key={name} onClick={() => switchPrayer(name)} style={{
              padding: "5px 12px", borderRadius: 14,
              border: active ? `2px solid ${pt.accent}` : `1px solid #333`,
              background: active ? (pt.isDark ? pt.bgGlow : pt.accentSoft) : "transparent",
              fontSize: 11, fontWeight: active ? 600 : 400,
              color: active ? pt.accent : "#8B9BB4", cursor: "pointer",
              display: "flex", alignItems: "center", gap: 4,
            }}>
              <span style={{ fontSize: 12 }}>{pt.emoji}</span>{name}
            </button>
          );
        })}
      </div>

      {/* Phone Frame */}
      <div style={{ width: 375, height: 812, borderRadius: 44, background: "#000", padding: 8, boxShadow: "0 24px 80px rgba(0,0,0,0.4)" }}>
        <div style={{
          width: "100%", height: "100%", borderRadius: 38, overflow: "hidden",
          background: isSubuh
            ? `radial-gradient(ellipse at 50% 30%, ${t.bgGlow} 0%, ${t.bg} 70%)`
            : `linear-gradient(180deg, ${t.bg} 0%, ${t.bgGlow} 100%)`,
          display: "flex", flexDirection: "column", position: "relative",
          transition: "background .5s ease",
        }}>

          {/* Status Bar */}
          <div style={{ height: 50, display: "flex", alignItems: "flex-end", justifyContent: "space-between", padding: "0 28px 4px", fontSize: 14, fontWeight: 600, color: t.textMuted, flexShrink: 0 }}>
            <span>{data.time}</span>
            <div style={{ display: "flex", gap: 4, alignItems: "center" }}>
              <svg width="16" height="12" viewBox="0 0 16 12"><rect x="0" y="6" width="3" height="6" rx=".5" fill={t.textMuted}/><rect x="4.5" y="4" width="3" height="8" rx=".5" fill={t.textMuted}/><rect x="9" y="1.5" width="3" height="10.5" rx=".5" fill={t.textMuted}/><rect x="13" y="0" width="3" height="12" rx=".5" fill={t.textMuted}/></svg>
              <span>87%</span>
            </div>
          </div>

          {/* Content */}
          <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 28px" }}>

            {/* ===== MOMENT STATE ===== */}
            {phase === "moment" && (
              <>
                {/* Emoji with glow */}
                <div style={{ position: "relative", marginBottom: isSubuh ? 20 : 16 }}>
                  <span style={{ fontSize: isSubuh ? 48 : 40 }}>{t.emoji}</span>
                  {isSubuh && (
                    <div style={{
                      position: "absolute", top: "50%", left: "50%", transform: "translate(-50%, -50%)",
                      width: 100, height: 100, borderRadius: 50,
                      background: `radial-gradient(circle, ${t.accentSoft}40 0%, transparent 70%)`,
                      animation: "breathe 4s ease-in-out infinite",
                    }} />
                  )}
                  <style>{`@keyframes breathe { 0%, 100% { opacity: 0.4; transform: translate(-50%,-50%) scale(1); } 50% { opacity: 0.8; transform: translate(-50%,-50%) scale(1.15); } }`}</style>
                </div>

                {/* Prayer identity */}
                {isSubuh && (
                  <p style={{ fontSize: 14, fontWeight: 500, color: t.textSoft, margin: "0 0 4px", letterSpacing: 1.5, textTransform: "uppercase" }}>
                    It's time for
                  </p>
                )}
                {!isSubuh && (
                  <p style={{ fontSize: 12, fontWeight: 500, color: t.textSoft, margin: "0 0 4px", letterSpacing: 1 }}>
                    {t.label} · It's time for
                  </p>
                )}
                <h1 style={{ fontSize: isSubuh ? 42 : 36, fontWeight: 700, color: t.text, margin: "0 0 4px" }}>{activePrayer}</h1>
                <p style={{ fontSize: isSubuh ? 22 : 18, color: t.textSoft, margin: "0 0 6px", fontFamily: "'Noto Naskh Arabic',serif" }}>{data.arabic}</p>
                <p style={{ fontSize: 15, color: t.accent, fontWeight: 600, margin: `0 0 ${isSubuh ? 24 : 20}px` }}>
                  Azan at {data.time}
                </p>

                {/* Urgency badge for Maghrib */}
                {t.urgent && (
                  <div style={{
                    background: `${t.accent}15`, borderRadius: 10, padding: "6px 14px",
                    marginBottom: 16, border: `1px solid ${t.accent}30`,
                  }}>
                    <p style={{ fontSize: 12, color: t.accent, margin: 0, fontWeight: 600 }}>
                      ⚡ Short window — pray before Isya at {prayerData.Isya.time}
                    </p>
                  </div>
                )}

                {/* Hadith card */}
                <div style={{
                  background: t.hadithBg, borderRadius: 16, padding: "14px 18px",
                  width: "100%", textAlign: "center", marginBottom: isSubuh ? 32 : 28,
                  border: `1px solid ${t.hadithBorder}`,
                }}>
                  <p style={{ fontSize: 14, color: t.hadithText, margin: "0 0 4px", lineHeight: 1.6, fontStyle: "italic" }}>
                    "{hadith.text}"
                  </p>
                  <p style={{ fontSize: 10, color: t.textMuted, margin: 0 }}>— {hadith.source}</p>
                </div>

                {/* Check-in button */}
                <button onClick={handleCheckIn} style={{
                  width: "100%", padding: isSubuh ? "18px" : "16px", borderRadius: 18, border: "none",
                  background: t.btnGrad, color: t.btnText,
                  fontSize: isSubuh ? 18 : 16, fontWeight: 700, cursor: "pointer",
                  boxShadow: `0 4px 24px ${t.btnGlow}`,
                  marginBottom: isSubuh ? 12 : 10,
                }}>
                  Alhamdulillah, I've prayed ✓
                </button>

                {/* Snooze (Subuh only) */}
                {isSubuh && snoozeCount < 3 && (
                  <button onClick={handleSnooze} style={{
                    width: "100%", padding: "14px", borderRadius: 16,
                    border: `1px solid ${t.textMuted}`, background: "transparent",
                    color: t.textSoft, fontSize: 15, fontWeight: 500, cursor: "pointer",
                  }}>
                    Snooze 5 min <span style={{ fontSize: 11, color: t.textMuted, marginLeft: 6 }}>({3 - snoozeCount} left)</span>
                  </button>
                )}
                {isSubuh && snoozeCount >= 3 && (
                  <p style={{ fontSize: 12, color: t.textMuted, textAlign: "center", margin: "6px 0 0" }}>No more snoozes. Time to pray.</p>
                )}

                {/* Go to dashboard (non-Subuh) */}
                {!isSubuh && (
                  <button style={{
                    width: "100%", padding: "12px", borderRadius: 14,
                    border: `1px solid ${t.isDark ? t.textMuted : "#EBEBF0"}`,
                    background: "transparent", color: t.textSoft,
                    fontSize: 13, fontWeight: 500, cursor: "pointer",
                  }}>
                    Open dashboard instead
                  </button>
                )}
              </>
            )}

            {/* ===== SNOOZED STATE (Subuh only) ===== */}
            {phase === "snoozed" && (
              <div style={{ textAlign: "center" }}>
                <span style={{ fontSize: 40, display: "block", marginBottom: 16 }}>😴</span>
                <h2 style={{ fontSize: 24, fontWeight: 600, color: t.textSoft, margin: "0 0 8px" }}>Snoozed</h2>
                <p style={{ fontSize: 16, color: t.accent, margin: "0 0 4px" }}>Alarm returns in a moment...</p>
                <p style={{ fontSize: 13, color: t.textMuted, margin: 0 }}>Snooze {snoozeCount} of 3</p>
                <p style={{ fontSize: 10, color: t.textMuted, margin: "20px 0 0", fontStyle: "italic" }}>Simulated: returns in 2.5s</p>
              </div>
            )}

            {/* ===== CHECKED IN STATE ===== */}
            {phase === "checkedin" && (
              <div style={{ textAlign: "center" }}>
                <div style={{
                  width: 64, height: 64, borderRadius: 32,
                  background: t.isDark ? "#1A3328" : "#EEFAF3",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  margin: "0 auto 16px", boxShadow: `0 0 30px ${t.isDark ? "#7FC4A020" : "#7FC4A015"}`,
                }}>
                  <span style={{ fontSize: 28, color: "#7FC4A0" }}>✓</span>
                </div>

                <h2 style={{ fontSize: 26, fontWeight: 700, color: t.text, margin: "0 0 4px" }}>Alhamdulillah</h2>
                <p style={{ fontSize: 15, color: t.textSoft, margin: "0 0 20px" }}>{activePrayer} completed</p>

                {/* Spiritual message */}
                <div style={{
                  background: t.hadithBg, borderRadius: 14, padding: "12px 16px",
                  width: "100%", textAlign: "center", border: `1px solid ${t.hadithBorder}`,
                  marginBottom: 20,
                }}>
                  <p style={{ fontSize: 13, color: t.hadithText, margin: 0, lineHeight: 1.6, fontStyle: "italic" }}>
                    {isSubuh ? "\"You are now under Allah's protection for the rest of the day.\""
                      : activePrayer === "Isya" ? "\"Rest well. You finished the day in prayer.\""
                      : `"${hadith.text}"`}
                  </p>
                </div>

                {/* Next prayer */}
                <div style={{
                  background: t.isDark ? "#1B2535" : "#F5F5F7",
                  borderRadius: 14, padding: "12px 16px", width: "100%",
                  display: "flex", alignItems: "center", justifyContent: "space-between",
                  marginBottom: 16,
                }}>
                  <div>
                    <p style={{ fontSize: 11, color: t.textMuted, margin: 0 }}>Next prayer</p>
                    <p style={{ fontSize: 15, fontWeight: 600, color: t.text, margin: "2px 0 0" }}>{data.nextPrayer}</p>
                  </div>
                  <p style={{ fontSize: 15, fontWeight: 600, color: t.accent, margin: 0 }}>{data.nextTime}</p>
                </div>

                {/* Contextual closing */}
                <p style={{ fontSize: 12, color: t.textMuted, margin: 0 }}>
                  {isSubuh ? "Go back to sleep. Hayya will remind you for Dzuhur. 🌙"
                    : activePrayer === "Isya" ? "Sleep well. Hayya will wake you for Subuh. 🌙"
                    : "Hayya will remind you when it's time."}
                </p>
              </div>
            )}

          </div>

          {/* Bottom safe area */}
          <div style={{ height: 34, flexShrink: 0 }} />
        </div>
      </div>

      {/* Instructions */}
      <p style={{ fontSize: 11, color: "#4A5568", marginTop: 14, textAlign: "center" }}>
        Switch prayers above to see each temporal theme<br />
        Subuh: dark + snooze • Maghrib: urgent badge • Isya: dark calm<br />
        Dzuhur/Ashar: light daytime mode
      </p>
    </div>
  );
}
