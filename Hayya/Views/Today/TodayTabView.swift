//
//  TodayTabView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct TodayTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodayViewModel()

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        f.timeZone = TimeZone(identifier: "Asia/Jakarta")!
        return f
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: 0xFDFBF7),
                    Color(hex: 0xF9F6F0),
                    Color(hex: 0xFDFBF7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Main content
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    prayerCards
                }
                .padding(.bottom, 100) // Space for tab bar
            }

            // Spiritual toast
            if let toast = viewModel.toastMessage {
                SpiritualToastView(toast: toast)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
            }

            // 5/5 celebration overlay
            if viewModel.showCelebration {
                CelebrationOverlay()
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dateFormatter.string(from: Date()))
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0x8E8E93))

                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                        Text("Jakarta")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color(hex: 0xB5B5BA))
                }

                Spacer()

                // Streak badge
                if viewModel.currentStreak > 0 || viewModel.completedToday > 0 {
                    streakBadge
                }
            }

            // Stats line
            Text("Today: \(viewModel.completedToday)/5")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: 0xB5B5BA))
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
        .padding(.horizontal, 18)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private var streakBadge: some View {
        HStack(spacing: 2) {
            Text("🔥")
                .font(.system(size: 13))
            Text("\(viewModel.currentStreak)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: 0xD4A843))
            if viewModel.recoveryDays > 0 {
                Text("+\(viewModel.recoveryDays)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: 0xD4A843))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(hex: 0xFFF6E3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Prayer Cards

    private var prayerCards: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.prayerStates) { state in
                PrayerCardView(
                    state: state,
                    formattedTime: viewModel.formattedTime,
                    onCheckIn: { viewModel.checkIn(prayer: state.prayer) },
                    onQadha: { viewModel.recoverAsQadha(prayer: state.prayer) }
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
    }
}

#Preview {
    TodayTabView()
}
