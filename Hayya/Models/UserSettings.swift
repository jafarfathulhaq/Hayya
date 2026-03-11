//
//  UserSettings.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import SwiftData

// MARK: - Disruption Level

enum DisruptionLevel: String, Codable, CaseIterable, Identifiable {
    case gentle = "Gentle"
    case moderate = "Moderate"
    case urgent = "Urgent"
    case wakeUp = "Wake-Up"

    var id: String { rawValue }

    var order: Int {
        switch self {
        case .gentle: return 0
        case .moderate: return 1
        case .urgent: return 2
        case .wakeUp: return 3
        }
    }
}

// MARK: - Alarm Setting (per prayer)

struct AlarmSetting: Equatable {
    var disruptionLevel: DisruptionLevel
    var offsetMinutes: Int              // Minutes from azan (-15 to +15), 0 = at azan
    var soundName: String               // e.g., "Default chime"
    var snoozeIntervalMinutes: Int      // 0, 5, 10, 15, 30
    var maxSnoozeCount: Int             // 1, 2, or 3
    var headsUpMinutes: Int             // Pre-alarm: 0, 15, 30, 60
    var isSubuhModeEnabled: Bool        // Only relevant for Subuh

    /// Default alarm setting for a given prayer
    static func defaultSetting(for prayer: PrayerName) -> AlarmSetting {
        switch prayer {
        case .subuh:
            return AlarmSetting(
                disruptionLevel: .wakeUp,
                offsetMinutes: 0,
                soundName: "Default chime",
                snoozeIntervalMinutes: 5,
                maxSnoozeCount: 3,
                headsUpMinutes: 30,
                isSubuhModeEnabled: true
            )
        case .dzuhur:
            return AlarmSetting(
                disruptionLevel: .gentle,
                offsetMinutes: 0,
                soundName: "Default chime",
                snoozeIntervalMinutes: 15,
                maxSnoozeCount: 2,
                headsUpMinutes: 0,
                isSubuhModeEnabled: false
            )
        case .ashar:
            return AlarmSetting(
                disruptionLevel: .gentle,
                offsetMinutes: 0,
                soundName: "Default chime",
                snoozeIntervalMinutes: 15,
                maxSnoozeCount: 2,
                headsUpMinutes: 0,
                isSubuhModeEnabled: false
            )
        case .maghrib:
            return AlarmSetting(
                disruptionLevel: .urgent,
                offsetMinutes: 0,
                soundName: "Default chime",
                snoozeIntervalMinutes: 5,
                maxSnoozeCount: 2,
                headsUpMinutes: 15,
                isSubuhModeEnabled: false
            )
        case .isya:
            return AlarmSetting(
                disruptionLevel: .moderate,
                offsetMinutes: 0,
                soundName: "Default chime",
                snoozeIntervalMinutes: 15,
                maxSnoozeCount: 2,
                headsUpMinutes: 0,
                isSubuhModeEnabled: false
            )
        }
    }
}

extension AlarmSetting: Codable {
    private enum CodingKeys: String, CodingKey {
        case disruptionLevel, offsetMinutes, soundName, snoozeIntervalMinutes, maxSnoozeCount, headsUpMinutes, isSubuhModeEnabled
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        disruptionLevel = try container.decode(DisruptionLevel.self, forKey: .disruptionLevel)
        offsetMinutes = try container.decode(Int.self, forKey: .offsetMinutes)
        soundName = try container.decode(String.self, forKey: .soundName)
        snoozeIntervalMinutes = try container.decode(Int.self, forKey: .snoozeIntervalMinutes)
        maxSnoozeCount = try container.decode(Int.self, forKey: .maxSnoozeCount)
        headsUpMinutes = try container.decode(Int.self, forKey: .headsUpMinutes)
        isSubuhModeEnabled = try container.decode(Bool.self, forKey: .isSubuhModeEnabled)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(disruptionLevel, forKey: .disruptionLevel)
        try container.encode(offsetMinutes, forKey: .offsetMinutes)
        try container.encode(soundName, forKey: .soundName)
        try container.encode(snoozeIntervalMinutes, forKey: .snoozeIntervalMinutes)
        try container.encode(maxSnoozeCount, forKey: .maxSnoozeCount)
        try container.encode(headsUpMinutes, forKey: .headsUpMinutes)
        try container.encode(isSubuhModeEnabled, forKey: .isSubuhModeEnabled)
    }
}

// MARK: - User Settings (SwiftData)

@Model
final class UserSettings {
    var id: UUID

    // Location
    var latitude: Double
    var longitude: Double
    var locationName: String        // e.g., "Jakarta, Indonesia"
    var countryCode: String         // ISO 3166-1 alpha-2

    // Prayer calculation
    var calculationMethodRaw: String    // CalculationMethodType.rawValue
    var customFajrAngle: Double?
    var customIshaAngle: Double?

    // Alarm settings (stored as JSON-encoded per prayer)
    var alarmSubuh: AlarmSetting
    var alarmDzuhur: AlarmSetting
    var alarmAshar: AlarmSetting
    var alarmMaghrib: AlarmSetting
    var alarmIsya: AlarmSetting

    // Global sound preference
    var azanVoice: String           // Global azan voice identifier

    // Onboarding
    var isOnboardingComplete: Bool
    var dateOnboarded: Date?

    // Permissions
    var allowsNotifications: Bool
    var allowsLocation: Bool

    // Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed Properties

    var calculationMethod: CalculationMethodType {
        get { CalculationMethodType(rawValue: calculationMethodRaw) ?? .kemenagRI }
        set { calculationMethodRaw = newValue.rawValue }
    }

    // MARK: - Alarm Setting Access

    func alarmSetting(for prayer: PrayerName) -> AlarmSetting {
        switch prayer {
        case .subuh: return alarmSubuh
        case .dzuhur: return alarmDzuhur
        case .ashar: return alarmAshar
        case .maghrib: return alarmMaghrib
        case .isya: return alarmIsya
        }
    }

    func setAlarmSetting(_ setting: AlarmSetting, for prayer: PrayerName) {
        switch prayer {
        case .subuh: alarmSubuh = setting
        case .dzuhur: alarmDzuhur = setting
        case .ashar: alarmAshar = setting
        case .maghrib: alarmMaghrib = setting
        case .isya: alarmIsya = setting
        }
        updatedAt = Date()
    }

    // MARK: - Init

    init(
        latitude: Double = -6.2088,
        longitude: Double = 106.8456,
        locationName: String = "Jakarta, Indonesia",
        countryCode: String = "ID"
    ) {
        self.id = UUID()
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.countryCode = countryCode
        self.calculationMethodRaw = CalculationMethodType.kemenagRI.rawValue
        self.customFajrAngle = nil
        self.customIshaAngle = nil

        // Default alarm settings per CLAUDE.md
        self.alarmSubuh = AlarmSetting.defaultSetting(for: .subuh)
        self.alarmDzuhur = AlarmSetting.defaultSetting(for: .dzuhur)
        self.alarmAshar = AlarmSetting.defaultSetting(for: .ashar)
        self.alarmMaghrib = AlarmSetting.defaultSetting(for: .maghrib)
        self.alarmIsya = AlarmSetting.defaultSetting(for: .isya)

        self.azanVoice = "default"
        self.isOnboardingComplete = false
        self.dateOnboarded = nil
        self.allowsNotifications = false
        self.allowsLocation = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
