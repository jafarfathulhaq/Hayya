import { useState } from "react";

const C = {
  light: {
    bg: "#FFFFFF", bgSoft: "#F9F7F3", text: "#2C2C2C", textSoft: "#8E8E93", textMuted: "#B5B5BA",
    done: "#7FC4A0", doneSoft: "#A8D4BC", missed: "#E8878F", qadha: "#E0B86B", upcoming: "#D1D1D6",
    accent: "#D4A843", accentLight: "#FFF6E3", primary: "#5B8C6F", primaryLight: "#E8F0EB",
    border: "#EBEBF0", active: "#D4A843", activeBg: "#FFF6E3",
  },
  dark: {
    bg: "#1C1C1E", bgSoft: "#2C2C2E", text: "#E8E4DC", textSoft: "#8B9BB4", textMuted: "#4A5568",
    done: "#7FC4A0", doneSoft: "#5A9E7A", missed: "#E8878F", qadha: "#E0B86B", upcoming: "#3A3A3C",
    accent: "#D4A843", accentLight: "#3D3220", primary: "#7FC4A0", primaryLight: "#1A3328",
    border: "#3A3A3C", active: "#D4A843", activeBg: "#3D3220",
  },
};

const myPrayers = ["done", "done", "done", "missed", "upcoming"];
const partnerPrayers = ["done", "done", "done", "done", "upcoming"];
const prayerNames = ["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"];
const prayedTogether = [true, true, false, false, false];
const activePrayerIdx = 4; // Isya is next/active
const togetherCount = 2;

function Dot({ status, isActive, size = 24, partner = false, c }) {
  const bg = status === "done"
    ? (partner ? c.doneSoft : c.done)
    : status === "missed" ? c.missed
    : status === "qadha" ? c.qadha
    : c.upcoming;
  return (
    <div style={{
      width: size, height: size, borderRadius: size / 2, background: bg,
      display: "flex", alignItems: "center", justifyContent: "center",
      boxShadow: isActive ? `0 0 0 2px ${c.active}, 0 0 8px ${c.active}30` : "none",
    }}>
      {status === "done" && <span style={{ fontSize: size * 0.42, color: "white", fontWeight: 700 }}>✓</span>}
      {status === "missed" && <span style={{ fontSize: size * 0.38, color: "white", fontWeight: 700 }}>✕</span>}
    </div>
  );
}

function PrayedTogetherBadge({ size = 14, c }) {
  return (
    <div style={{
      position: "absolute", top: -3, right: -4,
      width: size, height: size, borderRadius: size / 2,
      background: c.accentLight, display: "flex", alignItems: "center", justifyContent: "center",
      border: `1.5px solid ${c.bg}`,
    }}>
      <span style={{ fontSize: size * 0.55 }}>🤲</span>
    </div>
  );
}

export default function Widgets() {
  const [mode, setMode] = useState("light");
  const c = C[mode];

  return (
    <div style={{
      minHeight: "100vh",
      background: mode === "dark" ? "#000000" : "linear-gradient(135deg,#F0EDE6,#E8E4DC 50%,#F2EFE8)",
      display: "flex", flexDirection: "column", alignItems: "center",
      padding: "20px 16px",
      fontFamily: "'DM Sans','Nunito',system-ui,-apple-system,sans-serif",
      transition: "background .3s",
    }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&display=swap" rel="stylesheet" />

      <div style={{ textAlign: "center", marginBottom: 14 }}>
        <h1 style={{ fontSize: 16, fontWeight: 600, color: c.text, letterSpacing: 0.5, margin: 0 }}>HAYYA — Home Screen Widgets</h1>
        <p style={{ fontSize: 12, color: c.textSoft, margin: "3px 0 0" }}>Small (2×2) · Medium (4×2) · Large (4×4)</p>
      </div>

      <div style={{ display: "flex", gap: 6, marginBottom: 20 }}>
        {["light", "dark"].map(m => (
          <button key={m} onClick={() => setMode(m)} style={{
            padding: "6px 18px", borderRadius: 14,
            border: mode === m ? `2px solid ${c.primary}` : `1px solid ${c.border}`,
            background: mode === m ? c.primaryLight : "transparent",
            fontSize: 12, fontWeight: mode === m ? 600 : 400,
            color: mode === m ? c.primary : c.textSoft, cursor: "pointer",
          }}>{m === "light" ? "☀️ Light" : "🌙 Dark"}</button>
        ))}
      </div>

      {/* Home screen simulation */}
      <div style={{
        width: 375, padding: "20px 16px",
        background: mode === "dark"
          ? "linear-gradient(180deg, #1A1A2E 0%, #0D0D1A 100%)"
          : "linear-gradient(180deg, #E8E0D4 0%, #D4CCC0 100%)",
        borderRadius: 24,
        display: "flex", flexDirection: "column", gap: 16, alignItems: "center",
      }}>

        {/* ===== SMALL WIDGET (2×2) — My Prayers ===== */}
        <div style={{ width: "100%", display: "flex", gap: 12 }}>
          <div style={{
            width: 170, height: 170, borderRadius: 22,
            background: c.bg, padding: "14px",
            display: "flex", flexDirection: "column", justifyContent: "space-between",
            boxShadow: mode === "dark" ? "0 2px 12px rgba(0,0,0,0.3)" : "0 2px 12px rgba(0,0,0,0.06)",
            position: "relative",
          }}>
            <div>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 2 }}>
                <p style={{ fontSize: 13, fontWeight: 700, color: c.text, margin: 0 }}>My Prayers</p>
                <span style={{ fontSize: 10, color: c.accent }}>🔥 6</span>
              </div>
              <p style={{ fontSize: 9, color: c.textMuted, margin: 0 }}>Today</p>
            </div>

            <div style={{ display: "flex", justifyContent: "space-between", padding: "0 2px" }}>
              {myPrayers.map((status, i) => (
                <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 3 }}>
                  <Dot status={status} isActive={i === activePrayerIdx} size={20} c={c} />
                  <span style={{ fontSize: 7, color: c.textMuted }}>{prayerNames[i].slice(0, 3)}</span>
                </div>
              ))}
            </div>

            {/* Next prayer with countdown */}
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
              <div>
                <p style={{ fontSize: 9, color: c.textMuted, margin: 0 }}>Next</p>
                <p style={{ fontSize: 12, fontWeight: 600, color: c.text, margin: 0 }}>Isya</p>
              </div>
              <div style={{ textAlign: "right" }}>
                <p style={{ fontSize: 14, fontWeight: 700, color: c.primary, margin: 0 }}>19:08</p>
                <p style={{ fontSize: 8, color: c.textMuted, margin: 0 }}>in 2h 14m</p>
              </div>
            </div>

            <p style={{ fontSize: 7, color: c.textMuted, margin: 0, position: "absolute", bottom: 6, right: 10, opacity: 0.5 }}>Hayya</p>
          </div>

          <div style={{ display: "flex", flexDirection: "column", justifyContent: "center" }}>
            <p style={{ fontSize: 13, fontWeight: 600, color: c.text, margin: "0 0 4px" }}>Small (2×2)</p>
            <p style={{ fontSize: 11, color: c.textSoft, margin: "0 0 2px" }}>My Prayers</p>
            <p style={{ fontSize: 10, color: c.textMuted, margin: 0 }}>Free tier</p>
            <p style={{ fontSize: 10, color: c.textMuted, margin: "6px 0 0", lineHeight: 1.4 }}>
              Prayer dots + streak<br />+ next prayer + countdown<br />+ active prayer ring
            </p>
          </div>
        </div>

        {/* ===== MEDIUM WIDGET (4×2) — Together ===== */}
        <div>
          <div style={{
            width: 343, height: 170, borderRadius: 22,
            background: c.bg, padding: "14px 16px",
            display: "flex", flexDirection: "column", justifyContent: "space-between",
            boxShadow: mode === "dark" ? "0 2px 12px rgba(0,0,0,0.3)" : "0 2px 12px rgba(0,0,0,0.06)",
            position: "relative",
          }}>
            {/* Header with summary */}
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
              <p style={{ fontSize: 13, fontWeight: 700, color: c.text, margin: 0 }}>Together</p>
              <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
                <span style={{ fontSize: 10 }}>🤲</span>
                <span style={{ fontSize: 11, fontWeight: 600, color: c.accent }}>{togetherCount} together today</span>
              </div>
            </div>

            {/* My row — no labels, just dots */}
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <p style={{ fontSize: 11, fontWeight: 600, color: c.text, margin: 0, width: 44 }}>You</p>
              <div style={{ display: "flex", gap: 10, flex: 1 }}>
                {myPrayers.map((status, i) => (
                  <div key={i} style={{ position: "relative" }}>
                    <Dot status={status} isActive={i === activePrayerIdx} size={26} c={c} />
                    {prayedTogether[i] && status === "done" && partnerPrayers[i] === "done" && (
                      <PrayedTogetherBadge size={14} c={c} />
                    )}
                  </div>
                ))}
              </div>
              <span style={{ fontSize: 10, color: c.accent }}>🔥 6</span>
            </div>

            {/* Partner row — softer color, no opacity */}
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <p style={{ fontSize: 11, fontWeight: 500, color: c.textSoft, margin: 0, width: 44 }}>Aisha</p>
              <div style={{ display: "flex", gap: 10, flex: 1 }}>
                {partnerPrayers.map((status, i) => (
                  <div key={i} style={{ position: "relative" }}>
                    <Dot status={status} isActive={i === activePrayerIdx} size={26} partner c={c} />
                  </div>
                ))}
              </div>
              <span style={{ fontSize: 10, color: c.textSoft }}>🔥 4</span>
            </div>

            {/* You & Aisha narrative */}
            <p style={{ fontSize: 10, color: c.textSoft, margin: 0, textAlign: "center" }}>
              You & Aisha · praying together on Hayya
            </p>

            <p style={{ fontSize: 7, color: c.textMuted, margin: 0, position: "absolute", bottom: 6, right: 12, opacity: 0.5 }}>Hayya</p>
          </div>

          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "6px 4px 0" }}>
            <div>
              <span style={{ fontSize: 11, fontWeight: 600, color: c.text }}>Medium (4×2)</span>
              <span style={{ fontSize: 10, color: c.textSoft, marginLeft: 6 }}>Together</span>
            </div>
            <span style={{ fontSize: 10, color: c.accent, fontWeight: 500 }}>Premium</span>
          </div>
        </div>

        {/* ===== LARGE WIDGET (4×4) — Today ===== */}
        <div>
          <div style={{
            width: 343, height: 350, borderRadius: 22,
            background: c.bg, padding: "14px 16px",
            display: "flex", flexDirection: "column",
            boxShadow: mode === "dark" ? "0 2px 12px rgba(0,0,0,0.3)" : "0 2px 12px rgba(0,0,0,0.06)",
            position: "relative",
          }}>
            {/* Header */}
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
              <p style={{ fontSize: 13, fontWeight: 700, color: c.text, margin: 0 }}>Today</p>
              <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
                <span style={{ fontSize: 9 }}>🤲</span>
                <span style={{ fontSize: 10, fontWeight: 600, color: c.accent }}>{togetherCount} together</span>
              </div>
            </div>

            {/* Together section */}
            <div style={{
              background: c.bgSoft, borderRadius: 14, padding: "10px 12px", marginBottom: 8,
            }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 6 }}>
                <p style={{ fontSize: 10, fontWeight: 600, color: c.text, margin: 0, width: 36 }}>You</p>
                <div style={{ display: "flex", gap: 7, flex: 1 }}>
                  {myPrayers.map((status, i) => (
                    <div key={i} style={{ position: "relative" }}>
                      <Dot status={status} isActive={i === activePrayerIdx} size={22} c={c} />
                      {prayedTogether[i] && status === "done" && partnerPrayers[i] === "done" && (
                        <PrayedTogetherBadge size={12} c={c} />
                      )}
                    </div>
                  ))}
                </div>
                <span style={{ fontSize: 9, color: c.accent }}>🔥 6</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <p style={{ fontSize: 10, fontWeight: 500, color: c.textSoft, margin: 0, width: 36 }}>Aisha</p>
                <div style={{ display: "flex", gap: 7, flex: 1 }}>
                  {partnerPrayers.map((status, i) => (
                    <div key={i}>
                      <Dot status={status} isActive={i === activePrayerIdx} size={22} partner c={c} />
                    </div>
                  ))}
                </div>
                <span style={{ fontSize: 9, color: c.textSoft }}>🔥 4</span>
              </div>
            </div>

            {/* Days protected */}
            <div style={{
              display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
              padding: "6px 0", marginBottom: 6,
            }}>
              <span style={{ fontSize: 12, fontWeight: 700, color: c.primary }}>4/7</span>
              <span style={{ fontSize: 10, color: c.textSoft }}>days protected this week</span>
            </div>

            {/* Next Prayer Card */}
            <div style={{
              background: c.primaryLight, borderRadius: 14, padding: "12px 14px",
              marginBottom: 8, display: "flex", alignItems: "center", justifyContent: "space-between",
            }}>
              <div>
                <p style={{ fontSize: 9, color: c.textSoft, margin: "0 0 2px" }}>Next prayer</p>
                <p style={{ fontSize: 18, fontWeight: 700, color: c.text, margin: 0 }}>Isya</p>
                <p style={{ fontSize: 10, color: c.textSoft, margin: "1px 0 0", fontFamily: "'Noto Naskh Arabic',serif" }}>العشاء</p>
              </div>
              <div style={{ textAlign: "right" }}>
                <p style={{ fontSize: 22, fontWeight: 700, color: c.primary, margin: 0 }}>19:08</p>
                <p style={{ fontSize: 10, color: c.textSoft, margin: "1px 0 0" }}>in 2h 14m</p>
              </div>
            </div>

            {/* Spiritual message */}
            <div style={{
              background: c.accentLight, borderRadius: 12, padding: "10px 14px",
              textAlign: "center", flex: 1, display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <p style={{ fontSize: 11, color: c.accent, margin: 0, lineHeight: 1.5, fontStyle: "italic" }}>
                "Whoever prays Isha in congregation,<br />it is as if they stood half the night."
              </p>
            </div>

            <p style={{ fontSize: 7, color: c.textMuted, margin: "4px 0 0", textAlign: "right", opacity: 0.5 }}>Hayya</p>
          </div>

          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "6px 4px 0" }}>
            <div>
              <span style={{ fontSize: 11, fontWeight: 600, color: c.text }}>Large (4×4)</span>
              <span style={{ fontSize: 10, color: c.textSoft, marginLeft: 6 }}>Today</span>
            </div>
            <span style={{ fontSize: 10, color: c.accent, fontWeight: 500 }}>Premium</span>
          </div>
        </div>

      </div>

      <p style={{ fontSize: 11, color: c.textMuted, marginTop: 14, textAlign: "center" }}>
        Toggle Light/Dark above • Small = free • Medium & Large = Premium<br />
        Gold ring = active prayer • 🤲 badge = prayed together • "Hayya" branding in corner
      </p>
    </div>
  );
}
