//
//  SettingsTabView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import Adhan

struct SettingsTabView: View {
    @State private var location = "Jakarta, Indonesia"
    @State private var calcMethod: CalculationMethodType = .kemenagRI
    @State private var madhab = "Shafi'i"
    @State private var appearance = "system"
    @State private var customFajrAngle: Double = 20.0
    @State private var customIshaAngle: Double = 18.0
    @State private var trackQuality = false
    @State private var notifEnabled = true
    @State private var criticalAlerts = true

    @State private var showCalcPicker = false
    @State private var showMadhabPicker = false
    @State private var showAdvanced = false
    @State private var prayerAdjustments: [PrayerName: Int] = [
        .subuh: 0, .dzuhur: 0, .ashar: 0, .maghrib: 0, .isya: 0
    ]

    private let prayerTimeService = PrayerTimeService.shared
    private let jakartaCoords = Coordinates(latitude: -6.2088, longitude: 106.8456)

    private var todayTimes: HayyaPrayerTimes? {
        prayerTimeService.getPrayerTimes(
            coordinates: jakartaCoords,
            date: Date(),
            method: calcMethod,
            customFajrAngle: calcMethod == .custom ? customFajrAngle : nil,
            customIshaAngle: calcMethod == .custom ? customIshaAngle : nil
        )
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = TimeZone(identifier: "Asia/Jakarta")!
        return f
    }

    var body: some View {
        ZStack {
            Color(hex: 0xFDFBF7).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 2) {
                    header
                    prayerSection
                    prayerTimePreview
                    advancedSection
                    notificationSection
                    featuresSection
                    appearanceSection
                    supportSection
                    dataSection
                    versionFooter
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: 0x2C2C2C))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }

    // MARK: - Prayer Section

    private var prayerSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Prayer")
            groupCard {
                settingsRow(icon: "📍", label: "Location", value: location)
                dividerLine
                settingsRow(icon: "🧭", label: "Calculation Method", value: calcMethod.rawValue) {
                    withAnimation(.easeInOut(duration: 0.2)) { showCalcPicker.toggle() }
                }
                if showCalcPicker {
                    CalculationMethodPicker(
                        selectedMethod: $calcMethod,
                        customFajrAngle: $customFajrAngle,
                        customIshaAngle: $customIshaAngle,
                        onDismiss: { withAnimation { showCalcPicker = false } }
                    )
                }
                dividerLine
                settingsRow(icon: "📖", label: "Asr Calculation", value: madhab) {
                    withAnimation(.easeInOut(duration: 0.2)) { showMadhabPicker.toggle() }
                }
                if showMadhabPicker {
                    madhabPicker
                }
            }
        }
    }

    private var madhabPicker: some View {
        VStack(spacing: 4) {
            ForEach(["Shafi'i", "Hanafi"], id: \.self) { option in
                Button {
                    madhab = option
                    withAnimation { showMadhabPicker = false }
                } label: {
                    HStack {
                        Text(option)
                            .font(.system(size: 13, weight: madhab == option ? .semibold : .regular))
                            .foregroundColor(madhab == option ? Color(hex: 0x5B8C6F) : Color(hex: 0x2C2C2C))
                        Spacer()
                        if madhab == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: 0x5B8C6F))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(madhab == option ? Color(hex: 0xE8F0EB) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                madhab == option ? Color(hex: 0x5B8C6F) : Color(hex: 0xEBEBF0),
                                lineWidth: madhab == option ? 1.5 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            Text(madhab == "Hanafi" ? "Asr when shadow = 2× object height" : "Asr when shadow = 1× object height (default)")
                .font(.system(size: 10))
                .foregroundColor(Color(hex: 0xB5B5BA))
                .padding(.top, 2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .padding(.bottom, 8)
    }

    // MARK: - Prayer Time Preview

    private var prayerTimePreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TODAY'S TIMES · \(calcMethod.rawValue)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: 0x5B8C6F))

            if let times = todayTimes {
                HStack {
                    ForEach(times.allPrayers, id: \.name) { prayer in
                        VStack(spacing: 1) {
                            Text(timeFormatter.string(from: prayer.time))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: 0x2C2C2C))
                            Text(prayer.name)
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: 0x8E8E93))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(hex: 0xE8F0EB))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.vertical, 6)
    }

    // MARK: - Advanced Section

    private var advancedSection: some View {
        groupCard {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showAdvanced.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Text("⚙️")
                        .font(.system(size: 16))
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Advanced Calculation")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: 0x2C2C2C))
                        Text("High latitude, manual adjustments")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xB5B5BA))
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                        .rotationEffect(.degrees(showAdvanced ? 180 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if showAdvanced {
                VStack(alignment: .leading, spacing: 14) {
                    // Manual adjustments
                    Text("MANUAL TIME ADJUSTMENTS")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                    Text("Fine-tune ±minutes per prayer to match your mosque")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xB5B5BA))

                    ForEach(PrayerName.allCases) { prayer in
                        adjustmentRow(prayer: prayer)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
    }

    private func adjustmentRow(prayer: PrayerName) -> some View {
        let value = prayerAdjustments[prayer] ?? 0
        return HStack(spacing: 8) {
            Text(prayer.rawValue)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: 0x8E8E93))
                .frame(width: 50, alignment: .leading)

            Button {
                prayerAdjustments[prayer] = value - 1
            } label: {
                Text("−")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .frame(width: 28, height: 28)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Text(value == 0 ? "0" : (value > 0 ? "+\(value)" : "\(value)"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(value == 0 ? Color(hex: 0xB5B5BA) : Color(hex: 0x5B8C6F))
                .frame(width: 36)
                .multilineTextAlignment(.center)

            Button {
                prayerAdjustments[prayer] = value + 1
            } label: {
                Text("+")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .frame(width: 28, height: 28)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Text("min")
                .font(.system(size: 10))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Notifications")
            groupCard {
                HStack(spacing: 10) {
                    Text("🔔").font(.system(size: 16)).frame(width: 24)
                    Text("Notifications")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: 0x2C2C2C))
                    Spacer()
                    statusBadge(ok: notifEnabled, label: notifEnabled ? "Enabled" : "Disabled")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                dividerLine

                HStack(spacing: 10) {
                    Text("🚨").font(.system(size: 16)).frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Critical Alerts")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: 0x2C2C2C))
                        Text("Required for Wake-Up alarms")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xB5B5BA))
                    }
                    Spacer()
                    statusBadge(ok: criticalAlerts, label: criticalAlerts ? "Granted" : "Not granted")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                dividerLine

                settingsRow(icon: "⏰", label: "Alarm Settings", subtitle: "Disruption levels, sounds, offsets", chevron: true)
            }
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Features")
            groupCard {
                HStack(spacing: 10) {
                    Text("🏷️").font(.system(size: 16)).frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Track Prayer Quality")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: 0x2C2C2C))
                        Text("Jamaah, prayed early tags after check-in")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xB5B5BA))
                    }
                    Spacer()
                    Toggle("", isOn: $trackQuality)
                        .tint(Color(hex: 0x5B8C6F))
                        .labelsHidden()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Appearance")
            groupCard {
                HStack(spacing: 6) {
                    ForEach([
                        ("light", "Light", "☀️"),
                        ("dark", "Dark", "🌙"),
                        ("system", "System", "📱"),
                    ], id: \.0) { id, label, icon in
                        Button {
                            appearance = id
                        } label: {
                            VStack(spacing: 3) {
                                Text(icon)
                                    .font(.system(size: 18))
                                Text(label)
                                    .font(.system(size: 11, weight: appearance == id ? .semibold : .regular))
                                    .foregroundColor(appearance == id ? Color(hex: 0x5B8C6F) : Color(hex: 0x8E8E93))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(appearance == id ? Color(hex: 0xE8F0EB) : .white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        appearance == id ? Color(hex: 0x5B8C6F) : Color(hex: 0xEBEBF0),
                                        lineWidth: appearance == id ? 2 : 1.5
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Support")
            groupCard {
                settingsRow(icon: "❓", label: "Help & FAQ", chevron: true)
                dividerLine
                settingsRow(icon: "💬", label: "Send Feedback", chevron: true)
                dividerLine
                settingsRow(icon: "⭐", label: "Rate Hayya", chevron: true)
                dividerLine
                settingsRow(icon: "📋", label: "Privacy Policy", chevron: true)
                dividerLine
                settingsRow(icon: "📄", label: "Terms of Service", chevron: true)
            }
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Data")
            groupCard {
                settingsRow(icon: "📊", label: "Export Prayer History", subtitle: "Download as CSV", chevron: true)
                dividerLine
                settingsRow(icon: "🗑️", label: "Reset All Data", subtitle: "Cannot be undone", labelColor: Color(hex: 0xE25C5C), chevron: true)
            }
        }
    }

    // MARK: - Version Footer

    private var versionFooter: some View {
        VStack(spacing: 2) {
            Text("Hayya v1.0.0 (build 1)")
            Text("Made with 🤲 for the ummah")
        }
        .font(.system(size: 11))
        .foregroundColor(Color(hex: 0xB5B5BA))
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Reusable Components

    private func sectionHeader(_ label: String) -> some View {
        Text(label.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(hex: 0xB5B5BA))
            .tracking(0.6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 16)
            .padding(.bottom, 6)
    }

    private func groupCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: 0xEBEBF0), lineWidth: 1)
        )
    }

    private func settingsRow(
        icon: String,
        label: String,
        value: String? = nil,
        subtitle: String? = nil,
        labelColor: Color = Color(hex: 0x2C2C2C),
        chevron: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 10) {
                Text(icon)
                    .font(.system(size: 16))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(labelColor)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xB5B5BA))
                    }
                }

                Spacer()

                if let value {
                    Text(value)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }

                if chevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private var dividerLine: some View {
        Divider()
            .padding(.leading, 48)
    }

    private func statusBadge(ok: Bool, label: String) -> some View {
        HStack(spacing: 3) {
            Text(ok ? "✓" : "✕")
            Text(label)
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(ok ? Color(hex: 0x7FC4A0) : Color(hex: 0xE8878F))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(ok ? Color(hex: 0xEEFAF3) : Color(hex: 0xFFF0F1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    SettingsTabView()
}
