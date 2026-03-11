//
//  NotificationService.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import UserNotifications
import Adhan

final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let prayerTimeService = PrayerTimeService.shared

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule All Prayers

    /// Schedules notifications for all prayers for a given date.
    /// Call this daily (e.g., on app launch or at midnight) to refresh.
    func scheduleAllPrayers(
        coordinates: Coordinates,
        date: Date,
        method: CalculationMethodType,
        alarmSettings: [PrayerName: AlarmSetting]
    ) {
        // Remove existing prayer notifications first
        removeAllPrayerNotifications()

        guard let times = prayerTimeService.getPrayerTimes(coordinates: coordinates, date: date, method: method) else { return }

        for prayer in PrayerName.allCases {
            let setting = alarmSettings[prayer] ?? AlarmSetting.defaultSetting(for: prayer)
            let azanTime = prayerTime(prayer, from: times)

            schedulePrayerAlarm(prayer: prayer, azanTime: azanTime, setting: setting)

            // Heads-up notification
            if setting.headsUpMinutes > 0 {
                scheduleHeadsUp(prayer: prayer, azanTime: azanTime, minutes: setting.headsUpMinutes)
            }
        }
    }

    // MARK: - Individual Prayer Alarm

    private func schedulePrayerAlarm(prayer: PrayerName, azanTime: Date, setting: AlarmSetting) {
        let alarmTime = Calendar.current.date(byAdding: .minute, value: setting.offsetMinutes, to: azanTime) ?? azanTime

        // Only schedule if in the future
        guard alarmTime > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(prayer.rawValue) \u{2022} \(setting.disruptionLevel.rawValue)"
        content.body = notificationBody(for: prayer, setting: setting)
        content.categoryIdentifier = "PRAYER_ALARM"
        content.userInfo = [
            "prayer": prayer.rawValue,
            "disruptionLevel": setting.disruptionLevel.rawValue
        ]

        // Sound based on disruption level
        switch setting.disruptionLevel {
        case .gentle:
            // Silent push — no sound
            content.sound = nil
        case .moderate:
            content.sound = .default
        case .urgent:
            content.sound = UNNotificationSound.defaultCritical
            content.interruptionLevel = .timeSensitive
        case .wakeUp:
            content.sound = UNNotificationSound.defaultCritical
            content.interruptionLevel = .critical
        }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alarmTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "prayer_\(prayer.rawValue)_alarm",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Heads-Up

    private func scheduleHeadsUp(prayer: PrayerName, azanTime: Date, minutes: Int) {
        let headsUpTime = Calendar.current.date(byAdding: .minute, value: -minutes, to: azanTime) ?? azanTime

        guard headsUpTime > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(prayer.rawValue) in \(minutes) minutes"
        content.body = "Get ready for \(prayer.rawValue) prayer."
        content.sound = .default
        content.categoryIdentifier = "PRAYER_HEADSUP"
        content.userInfo = ["prayer": prayer.rawValue]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: headsUpTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "prayer_\(prayer.rawValue)_headsup",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Snooze

    func scheduleSnooze(prayer: PrayerName, minutes: Int, snoozeNumber: Int) {
        let content = UNMutableNotificationContent()
        content.title = "\(prayer.rawValue) — Time to pray"
        content.body = "Your snooze is up. It's still time for \(prayer.rawValue)."
        content.sound = UNNotificationSound.defaultCritical
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "PRAYER_SNOOZE"
        content.userInfo = [
            "prayer": prayer.rawValue,
            "snoozeNumber": snoozeNumber
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(minutes * 60), repeats: false)

        let request = UNNotificationRequest(
            identifier: "prayer_\(prayer.rawValue)_snooze_\(snoozeNumber)",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Remove

    func removeAllPrayerNotifications() {
        let identifiers = PrayerName.allCases.flatMap { prayer -> [String] in
            [
                "prayer_\(prayer.rawValue)_alarm",
                "prayer_\(prayer.rawValue)_headsup",
                "prayer_\(prayer.rawValue)_snooze_1",
                "prayer_\(prayer.rawValue)_snooze_2",
                "prayer_\(prayer.rawValue)_snooze_3"
            ]
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removePrayerNotification(prayer: PrayerName) {
        let identifiers = [
            "prayer_\(prayer.rawValue)_alarm",
            "prayer_\(prayer.rawValue)_headsup"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Notification Categories

    func registerCategories() {
        let checkInAction = UNNotificationAction(
            identifier: "CHECK_IN",
            title: "Alhamdulillah, I've prayed",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 5 min",
            options: []
        )

        let alarmCategory = UNNotificationCategory(
            identifier: "PRAYER_ALARM",
            actions: [checkInAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let headsUpCategory = UNNotificationCategory(
            identifier: "PRAYER_HEADSUP",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let snoozeCategory = UNNotificationCategory(
            identifier: "PRAYER_SNOOZE",
            actions: [checkInAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        center.setNotificationCategories([alarmCategory, headsUpCategory, snoozeCategory])
    }

    // MARK: - Helpers

    private func prayerTime(_ prayer: PrayerName, from times: HayyaPrayerTimes) -> Date {
        switch prayer {
        case .subuh: return times.subuh
        case .dzuhur: return times.dzuhur
        case .ashar: return times.ashar
        case .maghrib: return times.maghrib
        case .isya: return times.isya
        }
    }

    private func notificationBody(for prayer: PrayerName, setting: AlarmSetting) -> String {
        switch prayer {
        case .subuh:
            return "Rise for Subuh. You are about to be under Allah's protection for the day."
        case .dzuhur:
            return "It's Dzuhur time. Take a moment to connect with Allah."
        case .ashar:
            return "Ashar is calling. Don't let it pass by."
        case .maghrib:
            return "Maghrib is now. The window is short — pray soon."
        case .isya:
            return "Isya time. Close your day beautifully with prayer."
        }
    }
}
