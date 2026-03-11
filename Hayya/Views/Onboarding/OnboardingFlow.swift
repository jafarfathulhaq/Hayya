//
//  OnboardingFlow.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import Adhan

struct OnboardingFlow: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentScreen = 0
    @State private var isTransitioning = false

    // Quick setup state
    @State private var locationGranted = false
    @State private var notificationsGranted = false
    @State private var selectedMethod: CalculationMethodType = .kemenagRI

    // Smart alarm state — uses next upcoming prayer, not a hardcoded prayer
    @State private var alarmSetting = AlarmSetting.defaultSetting(for: .dzuhur)
    @State private var alarmConfirmed = false

    // Companion state
    @State private var selectedInviteType: String?

    private let totalScreens = 6

    var body: some View {
        ZStack {
            Color(hex: 0xFDFBF7).ignoresSafeArea()

            VStack(spacing: 0) {
                // Content
                Group {
                    switch currentScreen {
                    case 0: WelcomeScreen()
                    case 1: EmpathyScreen()
                    case 2: QuickSetupView(
                        locationGranted: $locationGranted,
                        notificationsGranted: $notificationsGranted,
                        selectedMethod: $selectedMethod
                    )
                    case 3: SmartAlarmScreen(
                        setting: $alarmSetting,
                        confirmed: $alarmConfirmed
                    )
                    case 4: DashboardPreviewScreen()
                    case 5: CompanionInviteScreen(
                        selectedType: $selectedInviteType,
                        onSkip: { completeOnboarding() }
                    )
                    default: EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)

                // Navigation
                navigationControls
            }
        }
    }

    // MARK: - Navigation Controls

    private var navigationControls: some View {
        HStack {
            // Back
            Button {
                goBack()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(currentScreen == 0 ? Color(hex: 0xD1D1D6) : Color(hex: 0x2C2C2C))
                    .frame(width: 40, height: 40)
            }
            .disabled(currentScreen == 0)

            Spacer()

            // Dots
            HStack(spacing: 6) {
                ForEach(0..<totalScreens, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index == currentScreen ? Color(hex: 0x5B8C6F) : Color(hex: 0xD1D1D6))
                        .frame(width: index == currentScreen ? 24 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: currentScreen)
                }
            }

            Spacer()

            // Next/Done
            Button {
                if currentScreen == totalScreens - 1 {
                    completeOnboarding()
                } else {
                    goNext()
                }
            } label: {
                Image(systemName: currentScreen == totalScreens - 1 ? "checkmark" : "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(canAdvance ? Color(hex: 0x5B8C6F) : Color(hex: 0xD1D1D6))
                    .clipShape(Circle())
            }
            .disabled(!canAdvance)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    private var canAdvance: Bool {
        switch currentScreen {
        case 2: return locationGranted && notificationsGranted
        case 3: return alarmConfirmed
        default: return true
        }
    }

    private func goNext() {
        guard !isTransitioning, currentScreen < totalScreens - 1 else { return }
        isTransitioning = true
        withAnimation(.easeInOut(duration: 0.25)) {
            currentScreen += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isTransitioning = false
        }
    }

    private func goBack() {
        guard !isTransitioning, currentScreen > 0 else { return }
        isTransitioning = true
        withAnimation(.easeInOut(duration: 0.25)) {
            currentScreen -= 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isTransitioning = false
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isOnboardingComplete = true
        }
    }
}

// MARK: - Screen 1: Welcome

struct WelcomeScreen: View {
    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showTagline = false
    @State private var showSub = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x5B8C6F), Color(hex: 0xA8CBB7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                Text("\u{263D}")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .scaleEffect(showLogo ? 1.0 : 0.8)
            .opacity(showLogo ? 1 : 0)
            .padding(.bottom, 24)

            Text("Hayya")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(Color(hex: 0x5B8C6F))
                .tracking(-1)
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 8)
                .padding(.bottom, 8)

            Text("A gentle companion\nfor your prayers.")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: 0x2C2C2C))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(showTagline ? 1 : 0)
                .offset(y: showTagline ? 0 : 8)
                .padding(.bottom, 12)

            Text("For the days you pray on time,\nand the days you're trying to come back.")
                .font(.system(size: 15).italic())
                .foregroundColor(Color(hex: 0x8E8E93))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(showSub ? 1 : 0)
                .offset(y: showSub ? 0 : 8)
                .padding(.bottom, 20)

            // Decorative dots
            HStack(spacing: 8) {
                ForEach([UInt(0xA8C8D4), 0x5B8C6F, 0xD4A843, 0xC47A5A, 0x7FC4A0], id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex).opacity(0.7))
                        .frame(width: 10, height: 10)
                }
            }
            .opacity(showSub ? 1 : 0)

            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                showLogo = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                showTitle = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                showTagline = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.45)) {
                showSub = true
            }
        }
    }
}

// MARK: - Screen 2: Empathy

struct EmpathyScreen: View {
    @State private var showCards = [false, false, false]
    @State private var showMessage = false

    private let struggles = [
        ("I keep missing Subuh...", Color(hex: 0xF8F0E8)),
        ("I do well for a week, then fall off.", Color(hex: 0xE8F0EB)),
        ("I want to be better, but I keep starting over.", Color(hex: 0xE4EEF2))
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)

                Text("YOU'RE NOT ALONE IN THIS")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: 0x5B8C6F))
                    .tracking(2)

                // Struggle cards
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        Text("\"\(struggles[index].0)\"")
                            .font(.system(size: 15).italic())
                            .foregroundColor(Color(hex: 0x2C2C2C))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 18)
                            .frame(maxWidth: 300)
                            .background(struggles[index].1)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .opacity(showCards[index] ? 1 : 0)
                            .offset(x: showCards[index] ? 0 : -16)
                    }
                }

                // Main message
                VStack(spacing: 10) {
                    Text("Every Muslim has felt this.")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(hex: 0x2C2C2C))

                    Text("Hayya doesn't judge you for missing a prayer. It helps you come back — every time.")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: 0x8E8E93))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("Just start with the next prayer.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                        .padding(.top, 4)
                }
                .opacity(showMessage ? 1 : 0)
                .offset(y: showMessage ? 0 : 8)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(.easeOut(duration: 0.4).delay(Double(i) * 0.15 + 0.1)) {
                    showCards[i] = true
                }
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                showMessage = true
            }
        }
    }
}

// MARK: - Screen 5: Dashboard Preview

struct DashboardPreviewScreen: View {
    @State private var cardAppeared = [false, false, false, false, false]
    @State private var showFooter = false

    private let prayerTimeService = PrayerTimeService.shared

    private var prayerTimes: HayyaPrayerTimes? {
        let location = LocationService.shared
        return prayerTimeService.getPrayerTimes(
            coordinates: .init(latitude: location.latitude, longitude: location.longitude),
            date: Date(),
            method: location.recommendedMethod
        )
    }

    private func timeString(for prayer: PrayerName) -> String {
        guard let times = prayerTimes else { return "--:--" }
        let date: Date? = {
            switch prayer {
            case .subuh: return times.subuh
            case .dzuhur: return times.dzuhur
            case .ashar: return times.ashar
            case .maghrib: return times.maghrib
            case .isya: return times.isya
            }
        }()
        guard let d = date else { return "--:--" }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = .current
        return f.string(from: d)
    }

    private func status(for index: Int) -> PrayerStatus {
        // Simulate: first 2 done, 3rd active, rest upcoming
        if index < 2 { return .done }
        if index == 2 { return .active }
        return .upcoming
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 20)

                // Date + location
                VStack(spacing: 4) {
                    Text(dateString)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0x8E8E93))

                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                        Text(LocationService.shared.locationName)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .padding(.bottom, 16)

                // Prayer cards
                VStack(spacing: 10) {
                    ForEach(Array(PrayerName.allCases.enumerated()), id: \.element) { index, prayer in
                        let st = status(for: index)
                        previewCard(prayer: prayer, status: st, time: timeString(for: prayer), isActive: st == .active)
                            .opacity(cardAppeared[index] ? 1 : 0)
                            .offset(y: cardAppeared[index] ? 0 : 8)
                    }
                }
                .padding(.horizontal, 14)

                // Footer
                VStack(spacing: 6) {
                    Text("Your prayers are ready.")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: 0x2C2C2C))
                    Text("Hayya will remind you at each prayer time.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }
                .opacity(showFooter ? 1 : 0)
                .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            for i in 0..<5 {
                withAnimation(.easeOut(duration: 0.4).delay(Double(i) * 0.08)) {
                    cardAppeared[i] = true
                }
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                showFooter = true
            }
        }
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        f.timeZone = .current
        return f.string(from: Date())
    }

    private func previewCard(prayer: PrayerName, status: PrayerStatus, time: String, isActive: Bool) -> some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(statusBackground(status))
                    .frame(width: 36, height: 36)

                switch status {
                case .done:
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: 0x7FC4A0))
                case .active:
                    Circle()
                        .fill(Color(hex: 0x5B8C6F))
                        .frame(width: 10, height: 10)
                default:
                    Circle()
                        .fill(Color(hex: 0xD1D1D6))
                        .frame(width: 8, height: 8)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(prayer.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: 0x2C2C2C))
                    Text(prayer.arabicName)
                        .font(.custom("Noto Naskh Arabic", size: 13))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                Text(time)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }

            Spacer()

            if isActive {
                Text("Check In")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: 0x5B8C6F))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isActive ? Color(hex: 0x5B8C6F) : Color(hex: 0xEBEBF0), lineWidth: isActive ? 1.5 : 1)
        )
    }

    private func statusBackground(_ status: PrayerStatus) -> Color {
        switch status {
        case .done: return Color(hex: 0xEEFAF3)
        case .active: return Color(hex: 0xE8F0EB)
        default: return Color(hex: 0xF5F5F7)
        }
    }
}

// MARK: - Screen 6: Companion Invite

struct CompanionInviteScreen: View {
    @Binding var selectedType: String?
    let onSkip: () -> Void

    @State private var showQuote = false
    @State private var showContent = false

    private let types: [(label: String, emoji: String)] = [
        ("My spouse", "\u{1F491}"),
        ("Family", "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"),
        ("Friend", "\u{1F91D}")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 20)

                // Hadith quote
                VStack(alignment: .leading, spacing: 8) {
                    Text("The prayer in congregation is twenty-seven times better than the prayer offered alone.")
                        .font(.system(size: 14).italic())
                        .foregroundColor(Color(hex: 0x5B8C6F))
                        .lineSpacing(4)
                    Text("Sahih Bukhari & Muslim")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: 0xE8F0EB))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .opacity(showQuote ? 1 : 0)

                // Content
                VStack(spacing: 12) {
                    Text("Share this journey?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(hex: 0x2C2C2C))

                    Text("Invite someone you trust to pray alongside you. See each other's progress. Remind each other gently.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x8E8E93))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    // Type buttons
                    VStack(spacing: 8) {
                        ForEach(types, id: \.label) { type in
                            Button {
                                selectedType = type.label
                            } label: {
                                HStack {
                                    Text(type.emoji)
                                        .font(.system(size: 20))
                                    Text(type.label)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: 0x2C2C2C))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: 0xB5B5BA))
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(selectedType == type.label ? Color(hex: 0xE8F0EB) : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedType == type.label ? Color(hex: 0x5B8C6F) : Color(hex: 0xEBEBF0), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)

                    // Invite button — disabled until type selected, functional from Together tab
                    Button {
                        // Companion invite is handled from the Together tab after onboarding
                        onSkip()
                    } label: {
                        Text("Invite a companion")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(selectedType != nil ? Color(hex: 0x5B8C6F) : Color(hex: 0xD1D1D6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedType == nil)
                    .padding(.top, 4)

                    // Skip
                    Button {
                        onSkip()
                    } label: {
                        Text("Skip — I'll do this later")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: 0x8E8E93))
                    }
                    .buttonStyle(.plain)

                    Text("You can always invite someone from the Together tab.")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 8)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { showQuote = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) { showContent = true }
        }
    }
}
