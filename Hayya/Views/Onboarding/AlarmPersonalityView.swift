//
//  AlarmPersonalityView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import Adhan

struct SmartAlarmScreen: View {
    @Binding var setting: AlarmSetting
    @Binding var confirmed: Bool

    private let prayer: PrayerName = .ashar
    private let prayerTimeService = PrayerTimeService.shared
    private let timeZone = TimeZone(identifier: "Asia/Jakarta")!

    private var prayerTimes: HayyaPrayerTimes? {
        prayerTimeService.getPrayerTimes(
            coordinates: Coordinates(latitude: -6.2088, longitude: 106.8456),
            date: Date(),
            method: .kemenagRI
        )
    }

    private var azanTimeString: String {
        guard let times = prayerTimes else { return "--:--" }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = timeZone
        return f.string(from: times.ashar)
    }

    private var alarmTimeString: String {
        guard let times = prayerTimes else { return "--:--" }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = timeZone
        let adjusted = Calendar.current.date(byAdding: .minute, value: setting.offsetMinutes, to: times.ashar) ?? times.ashar
        return f.string(from: adjusted)
    }

    private let snoozeOptions = [0, 5, 15, 30]
    private let offsetOptions = [-5, 0, 5, 10, 15]
    private let sounds = ["Default chime", "Soft bell", "Gentle pulse", "Morning birds"]

    var body: some View {
        if confirmed {
            successView
        } else {
            editorView
        }
    }

    // MARK: - Editor

    private var editorView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text("SET UP YOUR FIRST ALARM")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                        .tracking(1)

                    Text("Ashar \u{00B7} \(azanTimeString)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: 0x2C2C2C))

                    Text("Your next prayer. Configure it, then we'll set the rest.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }
                .padding(.top, 16)
                .padding(.bottom, 16)

                // Editor card
                VStack(spacing: 16) {
                    // Drag handle visual
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0xD1D1D6))
                        .frame(width: 36, height: 4)
                        .padding(.bottom, 8)

                    disruptionSection
                    snoozeSection
                    offsetSection
                    soundSection

                    // Confirm
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            confirmed = true
                        }
                    } label: {
                        Text("Set Ashar alarm \u{2192}")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: 0x5B8C6F))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    Text("We'll set smart defaults for the other 4 prayers.")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .padding(16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
                .padding(.horizontal, 14)
            }
        }
    }

    // MARK: - Disruption Level

    private var disruptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HOW SHOULD HAYYA REMIND YOU?")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: 0x8E8E93))
                .tracking(0.5)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(DisruptionLevel.allCases) { level in
                    let isSelected = setting.disruptionLevel == level
                    Button {
                        setting.disruptionLevel = level
                    } label: {
                        VStack(spacing: 5) {
                            IntensityBarsView(
                                level: level.barLevel,
                                color: isSelected ? level.color : Color(hex: 0xD1D1D6),
                                size: .small
                            )
                            .frame(height: 18)

                            Text(level.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isSelected ? level.color : Color(hex: 0x8E8E93))

                            Text(level.shortDescription)
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: 0xB5B5BA))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? level.backgroundColor : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? level.color.opacity(0.5) : Color(hex: 0xEBEBF0), lineWidth: isSelected ? 2 : 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Snooze

    private var snoozeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SNOOZE INTERVAL")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: 0x8E8E93))
                .tracking(0.5)

            HStack(spacing: 6) {
                ForEach(snoozeOptions, id: \.self) { minutes in
                    chipButton(
                        label: minutes == 0 ? "Off" : "\(minutes) min",
                        isSelected: setting.snoozeIntervalMinutes == minutes
                    ) {
                        setting.snoozeIntervalMinutes = minutes
                        if minutes == 0 { setting.maxSnoozeCount = 1 }
                    }
                }
            }

            if setting.snoozeIntervalMinutes > 0 {
                HStack(spacing: 6) {
                    Text("Repeat:")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: 0x8E8E93))
                    ForEach([1, 2, 3], id: \.self) { count in
                        chipButton(label: "\(count)x", isSelected: setting.maxSnoozeCount == count) {
                            setting.maxSnoozeCount = count
                        }
                    }
                    Spacer()
                }

                let total = setting.snoozeIntervalMinutes * setting.maxSnoozeCount
                Text("One tap at alarm time. Window: \(total) min")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xB5B5BA))
            }
        }
    }

    // MARK: - Offset

    private var offsetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OFFSET FROM AZAN")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: 0x8E8E93))
                .tracking(0.5)

            HStack(spacing: 6) {
                ForEach(offsetOptions, id: \.self) { minutes in
                    chipButton(
                        label: minutes == 0 ? "0" : (minutes > 0 ? "+\(minutes)" : "\(minutes)"),
                        isSelected: setting.offsetMinutes == minutes
                    ) {
                        setting.offsetMinutes = minutes
                    }
                }
            }

            HStack {
                Text(offsetDescription)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0x8E8E93))
                Spacer()
                Text("Alarm at \(alarmTimeString)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: 0x5B8C6F))
            }
        }
    }

    private var offsetDescription: String {
        if setting.offsetMinutes == 0 { return "At azan time" }
        if setting.offsetMinutes > 0 { return "\(setting.offsetMinutes) min after azan" }
        return "\(abs(setting.offsetMinutes)) min before azan"
    }

    // MARK: - Sound

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SOUND")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: 0x8E8E93))
                .tracking(0.5)

            FlowLayout(spacing: 6) {
                ForEach(sounds, id: \.self) { sound in
                    let isSelected = setting.soundName == sound
                    Button {
                        setting.soundName = sound
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 8))
                            Text(sound)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(isSelected ? setting.disruptionLevel.color : Color(hex: 0x8E8E93))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? setting.disruptionLevel.backgroundColor : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? setting.disruptionLevel.color.opacity(0.4) : Color(hex: 0xEBEBF0), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Success

    private var successView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 40)

                // Checkmark
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xE8F0EB))
                        .frame(width: 56, height: 56)
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                }

                Text("Your alarms are ready")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: 0x2C2C2C))

                Text("We've set smart defaults for your other 4 prayers based on your Ashar setup. Customize anytime.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Profile card
                VStack(alignment: .leading, spacing: 10) {
                    Text("YOUR ALARM PROFILE")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                        .tracking(0.5)

                    ForEach(PrayerName.allCases) { p in
                        let level = alarmLevel(for: p)
                        HStack(spacing: 10) {
                            IntensityBarsView(level: level.barLevel, color: level.color, size: .small)
                                .frame(width: 20)
                            Text(p.rawValue)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: 0x2C2C2C))
                            Text(level.rawValue)
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0x8E8E93))
                            Spacer()
                            if p == .ashar {
                                Text("you set this")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(Color(hex: 0x5B8C6F))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color(hex: 0xE8F0EB))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(hex: 0xE8F0EB))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text("Subuh is always Wake-Up. Maghrib is always Urgent.\nShort prayer windows need stronger reminders.")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xB5B5BA))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    private func alarmLevel(for prayer: PrayerName) -> DisruptionLevel {
        switch prayer {
        case .subuh: return .wakeUp
        case .maghrib: return .urgent
        case .ashar: return setting.disruptionLevel
        default: return setting.disruptionLevel
        }
    }

    // MARK: - Chip Button

    private func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? setting.disruptionLevel.color : Color(hex: 0x8E8E93))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(isSelected ? setting.disruptionLevel.color.opacity(0.1) : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? setting.disruptionLevel.color.opacity(0.4) : Color(hex: 0xEBEBF0), lineWidth: isSelected ? 2 : 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}
