//
//  AlarmTabView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import SwiftData
import Adhan

struct AlarmTabView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var alarmSettings: [PrayerName: AlarmSetting] = {
        var settings: [PrayerName: AlarmSetting] = [:]
        for prayer in PrayerName.allCases {
            settings[prayer] = AlarmSetting.defaultSetting(for: prayer)
        }
        return settings
    }()

    @State private var selectedPrayer: PrayerName?
    @State private var toastMessage: String?

    private let prayerTimeService = PrayerTimeService.shared
    private let locationService = LocationService.shared

    private var coordinates: Coordinates {
        Coordinates(latitude: locationService.latitude, longitude: locationService.longitude)
    }

    private var timeZone: TimeZone {
        TimeZone(identifier: "Asia/Jakarta") ?? .current
    }

    private var prayerTimes: HayyaPrayerTimes? {
        prayerTimeService.getPrayerTimes(coordinates: coordinates, date: Date(), method: locationService.recommendedMethod)
    }

    private func azanTime(for prayer: PrayerName) -> Date? {
        guard let times = prayerTimes else { return nil }
        switch prayer {
        case .subuh: return times.subuh
        case .dzuhur: return times.dzuhur
        case .ashar: return times.ashar
        case .maghrib: return times.maghrib
        case .isya: return times.isya
        }
    }

    private func formattedTime(_ date: Date, offset: Int = 0) -> String {
        let adjusted = Calendar.current.date(byAdding: .minute, value: offset, to: date) ?? date
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = timeZone
        return f.string(from: adjusted)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0xFDFBF7).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    overviewStrip
                    prayerList
                    footer
                }
                .padding(.bottom, 100)
            }

            // Toast
            if let msg = toastMessage {
                Text(msg)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color(hex: 0x5B8C6F))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color(hex: 0x5B8C6F).opacity(0.3), radius: 8, x: 0, y: 4)
                    .padding(.bottom, 74)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(item: $selectedPrayer) { prayer in
            AlarmEditorSheet(
                prayer: prayer,
                setting: Binding(
                    get: { alarmSettings[prayer] ?? AlarmSetting.defaultSetting(for: prayer) },
                    set: { newValue in
                        alarmSettings[prayer] = newValue
                        saveAlarmSetting(newValue, for: prayer)
                    }
                ),
                azanTimeString: azanTime(for: prayer).map { formattedTime($0) } ?? "--:--",
                onDismiss: { selectedPrayer = nil }
            )
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.visible)
        }
        .onAppear { loadAlarmSettings() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Alarms")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(hex: 0x2C2C2C))
            Text("Set each prayer's alarm, your way.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 10)
    }

    // MARK: - Overview Strip

    private var overviewStrip: some View {
        HStack {
            ForEach(PrayerName.allCases) { prayer in
                let setting = alarmSettings[prayer] ?? AlarmSetting.defaultSetting(for: prayer)
                let dl = setting.disruptionLevel

                Button {
                    selectedPrayer = prayer
                } label: {
                    VStack(spacing: 3) {
                        IntensityBarsView(level: dl.barLevel, color: dl.color, size: .small)

                        if let time = azanTime(for: prayer) {
                            Text(formattedTime(time, offset: setting.offsetMinutes))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: 0x2C2C2C))
                        }

                        Text(prayer.rawValue)
                            .font(.system(size: 9))
                            .foregroundColor(Color(hex: 0xB5B5BA))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Prayer List

    private var prayerList: some View {
        VStack(spacing: 8) {
            ForEach(PrayerName.allCases) { prayer in
                let setting = alarmSettings[prayer] ?? AlarmSetting.defaultSetting(for: prayer)
                let dl = setting.disruptionLevel

                Button {
                    selectedPrayer = prayer
                } label: {
                    HStack(spacing: 12) {
                        // Disruption icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(dl.backgroundColor)
                                .frame(width: 40, height: 40)
                            IntensityBarsView(level: dl.barLevel, color: dl.color, size: .small)
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

                            HStack(spacing: 6) {
                                if let time = azanTime(for: prayer) {
                                    Text(formattedTime(time, offset: setting.offsetMinutes))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(hex: 0x2C2C2C))
                                }

                                Text(summaryText(setting: setting, azanTime: azanTime(for: prayer)))
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: 0xB5B5BA))
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: 0xB5B5BA))
                    }
                    .padding(14)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }

    private func summaryText(setting: AlarmSetting, azanTime: Date?) -> String {
        let offsetText = setting.offsetMinutes == 0 ? "at azan" : (azanTime != nil ? "azan \(formattedTime(azanTime!))" : "")
        let snoozeText = setting.snoozeIntervalMinutes == 0 ? "Snooze off" : "Snooze \(setting.snoozeIntervalMinutes)m"
        return "\(offsetText) · \(setting.disruptionLevel.rawValue) · \(snoozeText)"
    }

    // MARK: - Persistence

    private func loadAlarmSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        guard let settings = try? modelContext.fetch(descriptor).first else { return }
        for prayer in PrayerName.allCases {
            alarmSettings[prayer] = settings.alarmSetting(for: prayer)
        }
    }

    private func saveAlarmSetting(_ setting: AlarmSetting, for prayer: PrayerName) {
        let descriptor = FetchDescriptor<UserSettings>()
        let settings: UserSettings
        if let existing = try? modelContext.fetch(descriptor).first {
            settings = existing
        } else {
            settings = UserSettings()
            modelContext.insert(settings)
        }
        settings.setAlarmSetting(setting, for: prayer)
        try? modelContext.save()
    }

    // MARK: - Footer

    private var footer: some View {
        Text("Changes saved automatically.\nAzan voice can be set in Settings → Sound.")
            .font(.system(size: 11))
            .foregroundColor(Color(hex: 0xB5B5BA))
            .multilineTextAlignment(.center)
            .padding(.top, 12)
    }
}

#Preview {
    AlarmTabView()
}
