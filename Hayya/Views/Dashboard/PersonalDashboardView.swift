//
//  PersonalDashboardView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import SwiftData

struct PersonalDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    private let streakService = StreakService.shared

    @State private var selectedWeek: WeekSelection = .thisWeek
    @State private var showMoreInsights = false
    @State private var thisWeekStats: WeeklyStats?
    @State private var lastWeekStats: WeeklyStats?
    @State private var lifetimePrayers: Int = 0

    private var currentStats: WeeklyStats? {
        selectedWeek == .thisWeek ? thisWeekStats : lastWeekStats
    }

    private var diff: Int {
        (thisWeekStats?.totalPrayers ?? 0) - (lastWeekStats?.totalPrayers ?? 0)
    }

    // Jamaah tracking data (populated when jamaah tagging is active)
    private let jamaahCount = 0
    private let jamaahMosque = 0
    private let jamaahHome = 0
    private let earlyCount = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xFDFBF7), Color(hex: 0xF9F6F0), Color(hex: 0xFDFBF7)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    if currentStats != nil {
                        heroMetric
                        weekToggle
                        dotGrid
                        statsRow
                        encouragement
                        insightsCard
                        if jamaahCount > 0 || earlyCount > 0 {
                            moreInsightsToggle
                            if showMoreInsights { jamaahCard }
                        }
                        duaFooter
                        privacyNote
                    } else {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading your journey...")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: 0x8E8E93))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 4)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Your Journey")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { loadStats() }
    }

    private func loadStats() {
        thisWeekStats = streakService.weeklyStats(from: modelContext, for: Date())
        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        lastWeekStats = streakService.weeklyStats(from: modelContext, for: lastWeekDate)
        lifetimePrayers = streakService.lifetimePrayers(from: modelContext)
    }

    // MARK: - Hero Metric

    private var heroMetric: some View {
        let tw = thisWeekStats!
        return VStack(spacing: 6) {
            Text("Days protected this week")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: 0x5B8C6F))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(tw.daysProtected)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(hex: 0x5B8C6F))
                Text("/7")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: 0xA8CBB7))
            }

            Text(heroMessage)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x8E8E93))

            if tw.recoveryDays > 0 {
                Divider()
                    .padding(.top, 6)

                HStack(spacing: 6) {
                    Text("↩ \(tw.recoveryDays)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: 0xE0B86B))
                    Text(tw.recoveryDays == 1
                         ? "day you came back after missing"
                         : "days you came back after missing")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0xE8F0EB))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var heroMessage: String {
        let p = thisWeekStats?.daysProtected ?? 0
        if p == 7 { return "Every single day. MasyaAllah." }
        if p >= 5 { return "Strong week. Keep protecting your prayers." }
        if p >= 3 { return "You can still protect tomorrow." }
        return "Every new day is a chance to protect your prayers."
    }

    // MARK: - Week Toggle

    private var weekToggle: some View {
        HStack(spacing: 6) {
            ForEach(WeekSelection.allCases) { week in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedWeek = week
                    }
                } label: {
                    Text(week.label)
                        .font(.system(size: 12, weight: selectedWeek == week ? .semibold : .regular))
                        .foregroundColor(selectedWeek == week ? Color(hex: 0x5B8C6F) : Color(hex: 0x8E8E93))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedWeek == week ? Color(hex: 0xE8F0EB) : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedWeek == week ? Color(hex: 0x5B8C6F) : Color(hex: 0xEBEBF0),
                                    lineWidth: selectedWeek == week ? 1.5 : 1
                                )
                        )
                }
            }
        }
    }

    // MARK: - Dot Grid

    private var dotGrid: some View {
        let stats = currentStats!
        return WeeklyDotGrid(
            grid: stats.grid,
            todayIndex: selectedWeek == .thisWeek ? todayDayIndex : nil,
            completions: stats.prayerCompletions
        )
    }

    private var todayDayIndex: Int {
        // 0 = Monday, 6 = Sunday
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Calendar weekday: 1 = Sunday, 2 = Monday, ...
        return weekday == 1 ? 6 : weekday - 2
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        let stats = currentStats!
        return HStack(spacing: 10) {
            statCard(
                title: "Prayers",
                value: "\(stats.totalPrayers)",
                subtitle: "of 35",
                valueColor: Color(hex: 0x5B8C6F)
            )
            statCard(
                title: "Protected",
                value: "\(stats.daysProtected)",
                subtitle: "of 7 days",
                valueColor: Color(hex: 0xD4A843)
            )
            statCard(
                title: "vs last week",
                value: trendValue,
                subtitle: trendLabel,
                valueColor: trendColor
            )
        }
    }

    private var trendValue: String {
        if abs(diff) <= 1 { return "≈" }
        return diff > 0 ? "+\(diff)" : "\(diff)"
    }

    private var trendLabel: String {
        if abs(diff) <= 1 { return "about the same" }
        return diff > 0 ? "prayers more" : "prayers fewer"
    }

    private var trendColor: Color {
        if abs(diff) <= 1 { return Color(hex: 0x8E8E93) }
        return diff > 0 ? Color(hex: 0x7FC4A0) : Color(hex: 0xE8878F)
    }

    private func statCard(title: String, value: String, subtitle: String, valueColor: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: 0x8E8E93))
                .padding(.bottom, 2)
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(valueColor)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: 0xEBEBF0), lineWidth: 1)
        )
    }

    // MARK: - Encouragement

    private var encouragement: some View {
        VStack(spacing: 2) {
            Text(encouragementMain)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: 0x5B8C6F))
            Text(encouragementSub)
                .font(.system(size: 12).italic())
                .foregroundColor(Color(hex: 0x5B8C6F))
        }
        .multilineTextAlignment(.center)
        .lineSpacing(4)
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0xE8F0EB))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var encouragementMain: String {
        guard let tw = thisWeekStats else { return "" }
        if tw.totalPrayers < 15 {
            return "Even one sincere prayer matters."
        } else if tw.recoveryDays > 0 && tw.daysProtected < 5 {
            return "You fell, and you came back \(tw.recoveryDays) \(tw.recoveryDays == 1 ? "time" : "times") this week."
        } else if diff > 1 {
            return "You protected \(tw.daysProtected) days this week."
        } else if abs(diff) <= 1 {
            return "Steady and consistent. That's istiqamah."
        } else {
            return "A lighter week. That's okay."
        }
    }

    private var encouragementSub: String {
        guard let tw = thisWeekStats else { return "" }
        if tw.totalPrayers < 15 {
            return "Every new prayer is a fresh start."
        } else if tw.recoveryDays > 0 && tw.daysProtected < 5 {
            return "Returning after a lapse is itself an act of devotion."
        } else if diff > 1 {
            return "Keep going. Consistency is beloved to Allah."
        } else if abs(diff) <= 1 {
            return "The most beloved deeds are those done consistently."
        } else {
            return "You can still protect tomorrow."
        }
    }

    // MARK: - Insights Card

    private var insightsCard: some View {
        let stats = currentStats!
        return VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: 0x2C2C2C))

            HStack(spacing: 10) {
                insightPill(
                    title: "Strongest",
                    titleColor: Color(hex: 0x7FC4A0),
                    prayer: stats.strongestPrayer,
                    completion: stats.prayerCompletions[stats.strongestPrayer] ?? (0, 0),
                    background: Color(hex: 0xEEFAF3)
                )
                insightPill(
                    title: "Focus area",
                    titleColor: Color(hex: 0xE8878F),
                    prayer: stats.focusArea,
                    completion: stats.prayerCompletions[stats.focusArea] ?? (0, 0),
                    background: Color(hex: 0xFFF0F1)
                )
            }

            if stats.qadhaCount > 0 {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: 0xFFF8EC))
                            .frame(width: 24, height: 24)
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: 0xE0B86B))
                    }
                    HStack(spacing: 4) {
                        Text("\(stats.qadhaCount) prayer\(stats.qadhaCount > 1 ? "s" : "")")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: 0xE0B86B))
                        Text("recovered via qadha")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0x8E8E93))
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: 0xEBEBF0), lineWidth: 1)
        )
    }

    private func insightPill(title: String, titleColor: Color, prayer: PrayerName, completion: (done: Int, total: Int), background: Color) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(titleColor)
                .padding(.bottom, 2)
            Text(prayer.rawValue)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(hex: 0x2C2C2C))
            Text("\(completion.done)/\(completion.total) this week")
                .font(.system(size: 10))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - More Insights Toggle

    private var moreInsightsToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showMoreInsights.toggle()
            }
        } label: {
            HStack(spacing: 5) {
                Text(showMoreInsights ? "Less insights" : "More insights")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: 0xB5B5BA))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xB5B5BA))
                    .rotationEffect(.degrees(showMoreInsights ? 180 : 0))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Jamaah Card

    private var jamaahCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Jamaah this month")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: 0x2C2C2C))

            HStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text("\(jamaahCount)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: 0xD4A843))
                    Text("total jamaah")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color(hex: 0xEBEBF0))
                    .frame(width: 1, height: 30)

                VStack(spacing: 2) {
                    Text("🕌 \(jamaahMosque)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: 0x8E8E93))
                    Text("at mosque")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color(hex: 0xEBEBF0))
                    .frame(width: 1, height: 30)

                VStack(spacing: 2) {
                    Text("🏠 \(jamaahHome)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: 0x8E8E93))
                    Text("at home")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .frame(maxWidth: .infinity)
            }

            Divider()

            HStack(spacing: 6) {
                Text("⏰")
                    .font(.system(size: 12))
                HStack(spacing: 4) {
                    Text("\(earlyCount) prayers")
                        .font(.system(size: 12, weight: .semibold))
                    Text("prayed early this month")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: 0xEBEBF0), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Du'a Footer

    private var duaFooter: some View {
        VStack(spacing: 4) {
            Text("\(lifetimePrayers) prayers protected since joining Hayya")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: 0xD4A843))
            Text("May every prayer be accepted. Ameen.")
                .font(.system(size: 12).italic())
                .foregroundColor(Color(hex: 0xD4A843))
        }
        .multilineTextAlignment(.center)
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0xFFF6E3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Privacy Note

    private var privacyNote: some View {
        Text("This is your **private reflection**. No one else sees this data.")
            .font(.system(size: 10))
            .foregroundColor(Color(hex: 0xB5B5BA))
            .multilineTextAlignment(.center)
            .padding(.top, 2)
    }
}

// MARK: - Week Selection

enum WeekSelection: String, CaseIterable, Identifiable {
    case thisWeek = "this"
    case lastWeek = "last"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .thisWeek: return "This week"
        case .lastWeek: return "Last week"
        }
    }
}

#Preview {
    NavigationStack {
        PersonalDashboardView()
    }
}
