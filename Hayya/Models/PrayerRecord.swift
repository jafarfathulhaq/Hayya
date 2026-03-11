//
//  PrayerRecord.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import SwiftData

// MARK: - Prayer Name

enum PrayerName: String, Codable, CaseIterable, Identifiable {
    case subuh = "Subuh"
    case dzuhur = "Dzuhur"
    case ashar = "Ashar"
    case maghrib = "Maghrib"
    case isya = "Isya"

    var id: String { rawValue }

    var arabicName: String {
        switch self {
        case .subuh: return "الصبح"
        case .dzuhur: return "الظهر"
        case .ashar: return "العصر"
        case .maghrib: return "المغرب"
        case .isya: return "العشاء"
        }
    }

    var icon: String {
        switch self {
        case .subuh: return "moon.haze.fill"
        case .dzuhur: return "sun.max.fill"
        case .ashar: return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isya: return "moon.stars.fill"
        }
    }

    /// Order index for sorting (0–4)
    var order: Int {
        switch self {
        case .subuh: return 0
        case .dzuhur: return 1
        case .ashar: return 2
        case .maghrib: return 3
        case .isya: return 4
        }
    }

    /// Whether this prayer has a short window (affects snooze options)
    var hasShortWindow: Bool {
        switch self {
        case .subuh, .maghrib: return true
        default: return false
        }
    }
}

// MARK: - Prayer Status

enum PrayerStatus: String, Codable {
    case upcoming   // Before azan time
    case active     // Prayer window open
    case done       // Completed on time
    case missed     // Window passed without check-in
    case qadha      // Recovered via qadha
}

// MARK: - Prayer Detail Tags

enum PrayerTag: String, Codable, CaseIterable {
    case jamaahMosque = "jamaah_mosque"
    case jamaahHome = "jamaah_home"
    case prayedEarly = "prayed_early"

    var displayName: String {
        switch self {
        case .jamaahMosque: return "Jamaah (Mosque)"
        case .jamaahHome: return "Jamaah (Home)"
        case .prayedEarly: return "Prayed Early"
        }
    }
}

// MARK: - Prayer Record (SwiftData)

@Model
final class PrayerRecord {
    var id: UUID
    var prayer: PrayerName
    var date: Date          // Calendar date (normalized to midnight)
    var azanTime: Date      // Computed azan time for this prayer on this date
    var status: PrayerStatus
    var checkedInAt: Date?  // When the user tapped "Check In"
    var tags: [PrayerTag]

    init(
        prayer: PrayerName,
        date: Date,
        azanTime: Date,
        status: PrayerStatus = .upcoming,
        checkedInAt: Date? = nil,
        tags: [PrayerTag] = []
    ) {
        self.id = UUID()
        self.prayer = prayer
        self.date = date
        self.azanTime = azanTime
        self.status = status
        self.checkedInAt = checkedInAt
        self.tags = tags
    }

    /// Check in this prayer as done
    func checkIn(tags: [PrayerTag] = []) {
        self.status = .done
        self.checkedInAt = Date()
        self.tags = tags
    }

    /// Recover this prayer via qadha
    func recoverAsQadha() {
        self.status = .qadha
        self.checkedInAt = Date()
    }

    /// Mark as missed (called when prayer window closes)
    func markMissed() {
        self.status = .missed
    }

    /// Whether this prayer counts as completed (done or qadha)
    var isCompleted: Bool {
        status == .done || status == .qadha
    }

    /// Whether this prayer was recovered (not on time)
    var isRecovered: Bool {
        status == .qadha
    }
}

// MARK: - Day Summary (Computed Helper)

struct DaySummary {
    let date: Date
    let records: [PrayerRecord]

    var completedCount: Int {
        records.filter(\.isCompleted).count
    }

    var recoveredCount: Int {
        records.filter(\.isRecovered).count
    }

    /// A protected day = all 5 prayers completed (on time or via qadha)
    var isProtected: Bool {
        completedCount == 5
    }

    /// A perfect day = 5/5 on time with no qadha
    var isPerfect: Bool {
        completedCount == 5 && recoveredCount == 0
    }

    /// A streak day = at least 4/5 prayers completed
    var isStreakDay: Bool {
        completedCount >= 4
    }
}
