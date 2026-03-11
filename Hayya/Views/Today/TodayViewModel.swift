//
//  TodayViewModel.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import SwiftUI
import SwiftData
import Adhan

@Observable
final class TodayViewModel {
    // MARK: - State

    var prayerStates: [PrayerState] = []
    var toastMessage: ToastMessage?
    var showCelebration: Bool = false
    var currentStreak: Int = 0
    var recoveryDays: Int = 0

    // MARK: - Dependencies

    private let prayerTimeService = PrayerTimeService.shared
    private let spiritualContent = SpiritualContent.shared
    private let coordinates: Coordinates
    private let method: CalculationMethodType
    private let timeZone: TimeZone
    private var modelContext: ModelContext?

    // MARK: - Init

    init(
        coordinates: Coordinates = Coordinates(latitude: -6.2088, longitude: 106.8456),
        method: CalculationMethodType = .kemenagRI,
        timeZone: TimeZone = TimeZone(identifier: "Asia/Jakarta")!
    ) {
        self.coordinates = coordinates
        self.method = method
        self.timeZone = timeZone
        loadTodayPrayers()
    }

    /// Call after view appears with the environment model context
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        restoreFromRecords()
        loadStreak()
    }

    private func loadStreak() {
        guard let context = modelContext else { return }
        let info = StreakService.shared.currentStreak(from: context)
        currentStreak = info.currentStreak
        recoveryDays = info.recoveryDaysInStreak
    }

    // MARK: - Load Today's Prayers

    func loadTodayPrayers() {
        guard let times = prayerTimeService.getPrayerTimes(
            coordinates: coordinates,
            date: Date(),
            method: method
        ) else { return }

        let now = Date()

        let prayerTimes: [(PrayerName, Date)] = [
            (.subuh, times.subuh),
            (.dzuhur, times.dzuhur),
            (.ashar, times.ashar),
            (.maghrib, times.maghrib),
            (.isya, times.isya),
        ]

        var states: [PrayerState] = []

        for (index, entry) in prayerTimes.enumerated() {
            let (prayer, azanTime) = entry

            let windowEnd: Date
            if index + 1 < prayerTimes.count {
                windowEnd = prayerTimes[index + 1].1
            } else {
                if let tomorrowTimes = prayerTimeService.getPrayerTimes(
                    coordinates: coordinates,
                    date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                    method: method
                ) {
                    windowEnd = tomorrowTimes.subuh
                } else {
                    windowEnd = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
                }
            }

            let status: PrayerStatus
            if now < azanTime {
                status = .upcoming
            } else if now < windowEnd {
                status = .active
            } else {
                status = .missed
            }

            states.append(PrayerState(
                prayer: prayer,
                azanTime: azanTime,
                windowEnd: windowEnd,
                status: status
            ))
        }

        self.prayerStates = states
    }

    // MARK: - Restore from SwiftData

    private func restoreFromRecords() {
        guard let context = modelContext else { return }

        let todayStart = Calendar.current.startOfDay(for: Date())
        let tomorrowStart = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!

        let descriptor = FetchDescriptor<PrayerRecord>(
            predicate: #Predicate { record in
                record.date >= todayStart && record.date < tomorrowStart
            }
        )

        guard let records = try? context.fetch(descriptor) else { return }

        for record in records {
            if let index = prayerStates.firstIndex(where: { $0.prayer == record.prayer }) {
                if record.status == .done || record.status == .qadha {
                    prayerStates[index].status = record.status
                    prayerStates[index].checkedInAt = record.checkedInAt
                    prayerStates[index].tags = record.tags
                }
            }
        }
    }

    // MARK: - Check In

    func checkIn(prayer: PrayerName) {
        guard let index = prayerStates.firstIndex(where: { $0.prayer == prayer }) else { return }
        guard prayerStates[index].status == .active else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            prayerStates[index].status = .done
            prayerStates[index].checkedInAt = Date()
        }

        // Persist to SwiftData
        persistRecord(prayer: prayer, status: .done, azanTime: prayerStates[index].azanTime)

        showToast(for: prayer)
        checkMilestone()
    }

    // MARK: - Qadha

    func recoverAsQadha(prayer: PrayerName) {
        guard let index = prayerStates.firstIndex(where: { $0.prayer == prayer }) else { return }
        guard prayerStates[index].status == .missed else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            prayerStates[index].status = .qadha
            prayerStates[index].checkedInAt = Date()
        }

        persistRecord(prayer: prayer, status: .qadha, azanTime: prayerStates[index].azanTime)

        showQadhaToast(for: prayer)
        checkMilestone()
    }

    // MARK: - Persistence

    private func persistRecord(prayer: PrayerName, status: PrayerStatus, azanTime: Date) {
        guard let context = modelContext else { return }

        let todayStart = Calendar.current.startOfDay(for: Date())
        let tomorrowStart = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!

        // Check if record already exists for this prayer today
        let prayerRaw = prayer.rawValue
        let descriptor = FetchDescriptor<PrayerRecord>(
            predicate: #Predicate { record in
                record.date >= todayStart && record.date < tomorrowStart
            }
        )

        if let existing = (try? context.fetch(descriptor))?.first(where: { $0.prayer.rawValue == prayerRaw }) {
            // Update existing record
            existing.status = status
            existing.checkedInAt = Date()
        } else {
            // Create new record
            let record = PrayerRecord(
                prayer: prayer,
                date: todayStart,
                azanTime: azanTime,
                status: status,
                checkedInAt: Date()
            )
            context.insert(record)
        }

        try? context.save()
    }

    // MARK: - Milestone

    private func checkMilestone() {
        let completedCount = prayerStates.filter { $0.status == .done || $0.status == .qadha }.count
        if completedCount == 5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                    self.showCelebration = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        self.showCelebration = false
                    }
                }
            }
        }
    }

    // MARK: - Stats

    var completedToday: Int {
        prayerStates.filter { $0.status == .done || $0.status == .qadha }.count
    }

    var formattedTime: (_ date: Date) -> String {
        { [timeZone] date in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.timeZone = timeZone
            return formatter.string(from: date)
        }
    }

    // MARK: - Toast

    private func showToast(for prayer: PrayerName) {
        let message: String
        if let spiritual = spiritualContent.checkInMessage(for: prayer) {
            message = spiritual.message
        } else {
            message = "Alhamdulillah. Prayer completed."
        }
        withAnimation(.easeOut(duration: 0.35)) {
            toastMessage = ToastMessage(prayer: prayer, message: message)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation(.easeIn(duration: 0.35)) {
                self?.toastMessage = nil
            }
        }
    }

    private func showQadhaToast(for prayer: PrayerName) {
        let message: String
        if let spiritual = spiritualContent.qadhaMessage() {
            message = spiritual.message
        } else {
            message = "Every step back to prayer is a victory. Alhamdulillah."
        }
        withAnimation(.easeOut(duration: 0.35)) {
            toastMessage = ToastMessage(prayer: prayer, message: message)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation(.easeIn(duration: 0.35)) {
                self?.toastMessage = nil
            }
        }
    }
}

// MARK: - Supporting Types

struct PrayerState: Identifiable {
    let id = UUID()
    let prayer: PrayerName
    let azanTime: Date
    let windowEnd: Date
    var status: PrayerStatus
    var checkedInAt: Date?
    var tags: [PrayerTag] = []

    var isCompleted: Bool {
        status == .done || status == .qadha
    }
}

struct ToastMessage: Equatable {
    let id = UUID()
    let prayer: PrayerName
    let message: String

    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
    }
}
