//
//  PrayerMomentView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

enum MomentPhase {
    case moment
    case snoozed
    case checkedIn
}

struct PrayerMomentView: View {
    let prayer: PrayerName
    let azanTime: String
    let nextPrayer: PrayerName?
    let nextPrayerTime: String?

    @State private var phase: MomentPhase = .moment
    @State private var snoozesLeft = 3
    @State private var breathing = false

    private var theme: TemporalTheme { TemporalTheme.theme(for: prayer) }

    var body: some View {
        ZStack {
            // Background
            if prayer == .subuh {
                RadialGradient(
                    colors: [theme.backgroundGlow, theme.background],
                    center: .init(x: 0.5, y: 0.3),
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [theme.background, theme.backgroundGlow],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                Spacer()

                switch phase {
                case .moment:
                    momentContent
                case .snoozed:
                    snoozedContent
                case .checkedIn:
                    checkedInContent
                }

                Spacer()
            }
            .padding(.horizontal, 28)
        }
    }

    // MARK: - Moment

    private var momentContent: some View {
        VStack(spacing: 0) {
            // Emoji
            ZStack {
                if prayer == .subuh {
                    Circle()
                        .fill(theme.accent.opacity(breathing ? 0.3 : 0.1))
                        .frame(width: 80, height: 80)
                        .scaleEffect(breathing ? 1.15 : 1.0)
                }
                Text(theme.emoji)
                    .font(.system(size: prayer == .subuh ? 48 : 40))
                    .scaleEffect(prayer == .subuh ? (breathing ? 1.1 : 1.0) : 1.0)
            }
            .padding(.bottom, 16)

            // Label
            Text("It's time for")
                .font(.system(size: prayer == .subuh ? 14 : 12, weight: .medium))
                .foregroundColor(theme.textSoft)
                .textCase(.uppercase)
                .tracking(prayer == .subuh ? 1.5 : 1)
                .padding(.bottom, 4)

            // Prayer name
            Text(prayer.rawValue)
                .font(.system(size: prayer == .subuh ? 42 : 36, weight: .bold))
                .foregroundColor(theme.text)
                .padding(.bottom, 4)

            // Arabic
            Text(prayer.arabicName)
                .font(.custom("Noto Naskh Arabic", size: prayer == .subuh ? 22 : 18))
                .foregroundColor(theme.textSoft)
                .padding(.bottom, 6)

            // Azan time
            Text(azanTime)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(theme.accent)
                .padding(.bottom, prayer == .maghrib ? 12 : 24)

            // Maghrib urgency badge
            if prayer == .maghrib, let nextTime = nextPrayerTime {
                HStack(spacing: 4) {
                    Text("\u{26A1}")
                    Text("Short window — pray before Isya at \(nextTime)")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(theme.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(theme.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.accent.opacity(0.3), lineWidth: 1))
                .padding(.bottom, 20)
            }

            // Hadith
            hadithCard(text: hadithText, source: hadithSource)
                .padding(.bottom, prayer == .subuh ? 32 : 28)

            // Check-in button
            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    phase = .checkedIn
                }
            } label: {
                Text("Alhamdulillah, I've prayed \u{2713}")
                    .font(.system(size: prayer == .subuh ? 18 : 16, weight: .bold))
                    .foregroundColor(theme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, prayer == .subuh ? 18 : 16)
                    .background(theme.buttonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: theme.buttonGlow.opacity(0.4), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)

            // Snooze (Subuh) or Dashboard (others)
            if prayer == .subuh {
                if snoozesLeft > 0 {
                    Button {
                        snoozesLeft -= 1
                        withAnimation(.easeInOut(duration: 0.3)) {
                            phase = .snoozed
                        }
                    } label: {
                        Text("Snooze 5 min (\(snoozesLeft) left)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(theme.textSoft)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.textMuted, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("No more snoozes. Time to pray.")
                        .font(.system(size: 12))
                        .foregroundColor(theme.textMuted)
                }
            } else {
                Button {
                    // Navigate to dashboard
                } label: {
                    Text("Open dashboard instead")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.textSoft)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(theme.isDark ? theme.textMuted : Color(hex: 0xEBEBF0), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Snoozed

    private var snoozedContent: some View {
        VStack(spacing: 16) {
            Text("\u{1F634}")
                .font(.system(size: 40))

            Text("Snoozed")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(theme.textSoft)

            Text("Alarm returns in a moment...")
                .font(.system(size: 16))
                .foregroundColor(theme.accent)

            Text("Snooze \(3 - snoozesLeft) of 3")
                .font(.system(size: 13))
                .foregroundColor(theme.textMuted)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = .moment
                }
            }
        }
    }

    // MARK: - Checked In

    private var checkedInContent: some View {
        VStack(spacing: 0) {
            // Success circle
            ZStack {
                Circle()
                    .fill(theme.isDark ? Color(hex: 0x1A3328) : Color(hex: 0xEEFAF3))
                    .frame(width: 64, height: 64)
                    .shadow(color: theme.accent.opacity(0.3), radius: 15)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: 0x7FC4A0))
            }
            .padding(.bottom, 20)

            Text("Alhamdulillah")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(theme.text)
                .padding(.bottom, 4)

            Text("\(prayer.rawValue) completed")
                .font(.system(size: 15))
                .foregroundColor(theme.textSoft)
                .padding(.bottom, 20)

            // Spiritual message
            hadithCard(text: completionMessage, source: completionSource)
                .padding(.bottom, 20)

            // Next prayer info
            if let nextPrayer = nextPrayer, let nextTime = nextPrayerTime {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next prayer")
                            .font(.system(size: 11))
                            .foregroundColor(theme.textMuted)
                        Text(nextPrayer.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.text)
                    }
                    Spacer()
                    Text(nextTime)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(theme.accent)
                }
                .padding(14)
                .background(theme.isDark ? Color(hex: 0x1B2535) : Color(hex: 0xF5F5F7))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.bottom, 16)
            }

            // Closing message
            Text(closingMessage)
                .font(.system(size: 12))
                .foregroundColor(theme.textMuted)
        }
    }

    // MARK: - Hadith Card

    private func hadithCard(text: String, source: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(.system(size: 14).italic())
                .foregroundColor(theme.hadithText)
                .lineSpacing(6)
            Text(source)
                .font(.system(size: 10))
                .foregroundColor(theme.textMuted)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.hadithBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.hadithBorder, lineWidth: 1))
    }

    // MARK: - Content

    private var hadithText: String {
        switch prayer {
        case .subuh: return "Whoever prays the dawn prayer in congregation, it is as if he had prayed the whole night."
        case .dzuhur: return "The most beloved of deeds to Allah are those that are most consistent, even if they are small."
        case .ashar: return "Whoever misses the Asr prayer, it is as if he lost his family and his wealth."
        case .maghrib: return "Hasten to break the fast, for that is one of the practices of the people of goodness."
        case .isya: return "Whoever prays Isha in congregation, it is as if he stood for half the night."
        }
    }

    private var hadithSource: String {
        switch prayer {
        case .subuh: return "Sahih Muslim"
        case .dzuhur: return "Sahih Bukhari & Muslim"
        case .ashar: return "Sahih Bukhari"
        case .maghrib: return "Musnad Ahmad"
        case .isya: return "Sahih Muslim"
        }
    }

    private var completionMessage: String {
        switch prayer {
        case .subuh: return "You are now under Allah's protection for the rest of the day."
        case .isya: return "Rest well. You finished the day in prayer."
        default: return "Whoever guards his prayers, they will be light, proof, and salvation on the Day of Resurrection."
        }
    }

    private var completionSource: String {
        switch prayer {
        case .subuh: return "Sahih Muslim"
        case .isya: return "Sunan An-Nasa'i"
        default: return "Musnad Ahmad"
        }
    }

    private var closingMessage: String {
        switch prayer {
        case .subuh: return "Go back to sleep. Hayya will remind you for Dzuhur. \u{1F319}"
        case .isya: return "Sleep well. Hayya will wake you for Subuh. \u{1F319}"
        default: return "Hayya will remind you when it's time."
        }
    }
}

#Preview("Subuh") {
    PrayerMomentView(prayer: .subuh, azanTime: "04:40", nextPrayer: .dzuhur, nextPrayerTime: "12:03")
}

#Preview("Dzuhur") {
    PrayerMomentView(prayer: .dzuhur, azanTime: "12:03", nextPrayer: .ashar, nextPrayerTime: "15:08")
}

#Preview("Maghrib") {
    PrayerMomentView(prayer: .maghrib, azanTime: "18:08", nextPrayer: .isya, nextPrayerTime: "19:17")
}
