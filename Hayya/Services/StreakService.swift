//
//  StreakService.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import SwiftData

// MARK: - Weekly Stats

struct WeeklyStats {
    let weekStart: Date
    let grid: [PrayerName: [PrayerStatus?]]   // 5 prayers × 7 days
    let daysProtected: Int                      // All 5 done/qadha
    let recoveryDays: Int                       // Days user came back after missing
    let totalPrayers: Int                       // Completed out of 35
    let qadhaCount: Int
    let prayerCompletions: [PrayerName: (done: Int, total: Int)]
    let strongestPrayer: PrayerName
    let focusArea: PrayerName                   // "Focus area" not "weakest"
}

// MARK: - Streak Info

struct StreakInfo {
    let currentStreak: Int
    let recoveryDaysInStreak: Int
    let displayText: String                     // e.g., "6 +2"
}

// MARK: - Streak Service

final class StreakService {
    static let shared = StreakService()
    private init() {}

    // MARK: - Compute Weekly Stats from Grid Data

    func computeWeeklyStats(
        grid: [PrayerName: [PrayerStatus?]],
        weekStart: Date
    ) -> WeeklyStats {
        let prayers = PrayerName.allCases

        // Count totals
        var totalPrayers = 0
        var qadhaCount = 0
        var completions: [PrayerName: (done: Int, total: Int)] = [:]

        for prayer in prayers {
            let row = grid[prayer] ?? Array(repeating: nil, count: 7)
            let doneCount = row.compactMap { $0 }.filter { $0 == .done || $0 == .qadha }.count
            let totalCount = row.compactMap { $0 }.count
            let qadha = row.compactMap { $0 }.filter { $0 == .qadha }.count
            completions[prayer] = (done: doneCount, total: totalCount)
            totalPrayers += doneCount
            qadhaCount += qadha
        }

        // Days protected: all 5 prayers completed
        var daysProtected = 0
        for dayIndex in 0..<7 {
            let dayStatuses = prayers.compactMap { grid[$0]?[dayIndex] }
            if dayStatuses.count == 5 && dayStatuses.allSatisfy({ $0 == .done || $0 == .qadha }) {
                daysProtected += 1
            }
        }

        // Recovery days: day after a missed day where user prayed at least once
        var recoveryDays = 0
        for dayIndex in 1..<7 {
            let prevDay = prayers.compactMap { grid[$0]?[dayIndex - 1] }
            let thisDay = prayers.compactMap { grid[$0]?[dayIndex] }
            let prevHadMiss = prevDay.contains(.missed)
            let prevComplete = prevDay.count == 5
            let thisDoneCount = thisDay.filter { $0 == .done || $0 == .qadha }.count
            if prevComplete && prevHadMiss && thisDoneCount > 0 && !thisDay.isEmpty {
                recoveryDays += 1
            }
        }

        // Strongest and focus area
        let sorted = completions.sorted { a, b in
            if a.value.total == 0 { return false }
            if b.value.total == 0 { return true }
            return a.value.done > b.value.done
        }
        let strongest = sorted.first?.key ?? .dzuhur
        let focusArea = sorted.last?.key ?? .subuh

        return WeeklyStats(
            weekStart: weekStart,
            grid: grid,
            daysProtected: daysProtected,
            recoveryDays: recoveryDays,
            totalPrayers: totalPrayers,
            qadhaCount: qadhaCount,
            prayerCompletions: completions,
            strongestPrayer: strongest,
            focusArea: focusArea
        )
    }

    // MARK: - Compute Streak

    /// Computes the current streak from an array of DaySummary (most recent first).
    func computeStreak(from days: [DaySummary]) -> StreakInfo {
        var streak = 0
        var recoveries = 0

        for day in days {
            if day.isStreakDay {
                streak += 1
                if day.recoveredCount > 0 {
                    recoveries += 1
                }
            } else {
                break // Streak pauses
            }
        }

        let display = recoveries > 0 ? "\(streak) +\(recoveries)" : "\(streak)"
        return StreakInfo(
            currentStreak: streak,
            recoveryDaysInStreak: recoveries,
            displayText: display
        )
    }

    // MARK: - Build Grid from SwiftData

    /// Returns the Monday-start date of the week containing `date`.
    func weekStart(for date: Date) -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) // 1=Sun, 2=Mon
        let daysFromMonday = (weekday + 5) % 7
        return cal.startOfDay(for: cal.date(byAdding: .day, value: -daysFromMonday, to: date)!)
    }

    /// Builds a 5×7 grid from PrayerRecords for the week starting at `start`.
    func buildGrid(from records: [PrayerRecord], weekStart start: Date) -> [PrayerName: [PrayerStatus?]] {
        let cal = Calendar.current
        var grid: [PrayerName: [PrayerStatus?]] = [:]
        let today = cal.startOfDay(for: Date())

        for prayer in PrayerName.allCases {
            var row: [PrayerStatus?] = Array(repeating: nil, count: 7)
            for dayIndex in 0..<7 {
                let dayDate = cal.date(byAdding: .day, value: dayIndex, to: start)!
                let dayStart = cal.startOfDay(for: dayDate)

                // Only fill past/today, leave future as nil
                if dayStart > today { continue }

                // Find record for this prayer on this day
                if let record = records.first(where: {
                    $0.prayer == prayer && cal.isDate($0.date, inSameDayAs: dayDate)
                }) {
                    row[dayIndex] = record.status
                } else if dayStart < today {
                    // Past day with no record = missed
                    row[dayIndex] = .missed
                } else {
                    // Today, no record yet = upcoming/active (don't mark missed yet)
                    row[dayIndex] = nil
                }
            }
            grid[prayer] = row
        }

        return grid
    }

    /// Fetches records for a week and computes stats.
    func weeklyStats(from context: ModelContext, for date: Date) -> WeeklyStats {
        let start = weekStart(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start)!

        let descriptor = FetchDescriptor<PrayerRecord>(
            predicate: #Predicate { record in
                record.date >= start && record.date < end
            }
        )

        let records = (try? context.fetch(descriptor)) ?? []
        let grid = buildGrid(from: records, weekStart: start)
        return computeWeeklyStats(grid: grid, weekStart: start)
    }

    /// Computes the current streak from SwiftData records.
    func currentStreak(from context: ModelContext) -> StreakInfo {
        let today = Calendar.current.startOfDay(for: Date())
        var days: [DaySummary] = []

        for i in 0..<30 {
            let dayDate = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: dayDate)!

            let descriptor = FetchDescriptor<PrayerRecord>(
                predicate: #Predicate { record in
                    record.date >= dayDate && record.date < nextDate
                }
            )

            let records = (try? context.fetch(descriptor)) ?? []
            if records.isEmpty && i > 0 { break } // No data before this
            days.append(DaySummary(date: dayDate, records: records))
        }

        return computeStreak(from: days)
    }

    /// Total lifetime prayers completed.
    func lifetimePrayers(from context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<PrayerRecord>()
        let records = (try? context.fetch(descriptor)) ?? []
        return records.filter { $0.status == .done || $0.status == .qadha }.count
    }

}
