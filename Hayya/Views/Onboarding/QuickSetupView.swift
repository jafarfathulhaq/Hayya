//
//  QuickSetupView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import Adhan

struct QuickSetupView: View {
    @Binding var locationGranted: Bool
    @Binding var notificationsGranted: Bool
    @Binding var selectedMethod: CalculationMethodType

    @State private var showMethodPicker = false

    private let prayerTimeService = PrayerTimeService.shared
    private let timeZone = TimeZone(identifier: "Asia/Jakarta")!

    private var prayerTimes: HayyaPrayerTimes? {
        prayerTimeService.getPrayerTimes(
            coordinates: Coordinates(latitude: -6.2088, longitude: 106.8456),
            date: Date(),
            method: selectedMethod
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 20)

                // Section 1: Location
                locationSection

                // Section 2: Prayer Times (unlocked after location)
                if locationGranted {
                    prayerTimesSection
                }

                // Section 3: Notifications
                if locationGranted {
                    notificationSection
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("1. YOUR LOCATION")

            if !locationGranted {
                Button {
                    // Phase 1: Simulate location granted (Jakarta default)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        locationGranted = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text("\u{1F4CD}")
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Allow Location Access")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: 0x5B8C6F))
                            Text("To find your nearest prayer times")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0x8E8E93))
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(hex: 0xE8F0EB))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: 0x5B8C6F), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                    Text("Jakarta, Indonesia")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: 0x2C2C2C))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: 0x7FC4A0))
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
            }
        }
    }

    // MARK: - Prayer Times

    private var prayerTimesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("2. PRAYER TIMES")

            VStack(spacing: 12) {
                // Method selection
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMethodPicker.toggle()
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedMethod.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: 0x2C2C2C))
                            Text("Recommended for your location")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0x8E8E93))
                        }
                        Spacer()
                        Image(systemName: showMethodPicker ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0x8E8E93))
                    }
                }
                .buttonStyle(.plain)

                // Method picker
                if showMethodPicker {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(CalculationMethodType.allCases) { method in
                                let isSelected = selectedMethod == method
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedMethod = method
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(method.rawValue)
                                                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                                .foregroundColor(Color(hex: 0x2C2C2C))
                                            Text(method.region)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color(hex: 0x8E8E93))
                                        }
                                        Spacer()
                                        Text("Fajr \(String(format: "%.0f", method.fajrAngle))° · Isha \(String(format: "%.0f", method.ishaAngle))°")
                                            .font(.system(size: 9))
                                            .foregroundColor(Color(hex: 0xB5B5BA))
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .background(isSelected ? Color(hex: 0xE8F0EB) : .clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 140)
                }

                // Today's times
                VStack(spacing: 8) {
                    Text("TODAY'S PRAYER TIMES")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color(hex: 0x5B8C6F))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    HStack {
                        ForEach(PrayerName.allCases) { prayer in
                            VStack(spacing: 2) {
                                Text(prayer.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: 0x2C2C2C))
                                Text(prayerTimeString(prayer))
                                    .font(.system(size: 9))
                                    .foregroundColor(Color(hex: 0x8E8E93))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }

                Text("Times are calculated for your location. You can change the method anytime in Settings.")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xB5B5BA))
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
        }
    }

    // MARK: - Notifications

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("3. NOTIFICATIONS")

            if !notificationsGranted {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        notificationsGranted = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text("\u{1F514}")
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Allow Notifications")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: 0x5B8C6F))
                            Text("So Hayya can remind you at prayer time")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0x8E8E93))
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(hex: 0xE8F0EB))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: 0x5B8C6F), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                    Text("Notifications enabled")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: 0x2C2C2C))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: 0x7FC4A0))
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
            }
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Color(hex: 0x8E8E93))
            .tracking(0.6)
    }

    private func prayerTimeString(_ prayer: PrayerName) -> String {
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
        f.timeZone = timeZone
        return f.string(from: d)
    }
}
