//
//  LargePrayerWidgetView.swift
//  HayyaWidget
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import WidgetKit

struct LargePrayerWidgetView: View {
    let entry: PrayerEntry

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private var completedCount: Int {
        entry.prayerStatus.values.filter { $0 == "done" || $0 == "qadha" }.count
    }

    private static let spiritualMessages: [String] = [
        "\"Verily, in the remembrance of Allah do hearts find rest.\" — Ar-Ra'd 13:28",
        "\"And seek help through patience and prayer.\" — Al-Baqarah 2:45",
        "\"Allah does not burden a soul beyond that it can bear.\" — Al-Baqarah 2:286",
        "\"So verily, with hardship, there is relief.\" — Ash-Sharh 94:5",
        "\"And whoever puts their trust in Allah, He will be enough for them.\" — At-Talaq 65:3",
    ]

    private var todayMessage: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return Self.spiritualMessages[dayOfYear % Self.spiritualMessages.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                    Text(entry.locationName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }

                Spacer()

                Text("Hayya")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: 0x5B8C6F))
            }
            .padding(.bottom, 10)

            // Prayer dots row with check-in status
            HStack(spacing: 0) {
                ForEach(Array(entry.prayers.enumerated()), id: \.offset) { index, prayer in
                    prayerDotLarge(index: index, prayer: prayer)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 10)

            // Completed metric
            HStack(spacing: 6) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0x5B8C6F))
                Text("\(completedCount)/5 prayers completed today")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: 0x5B8C6F))
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0xE8F0EB))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.bottom, 10)

            // Next prayer card
            if let nextIdx = entry.nextPrayerIndex {
                let next = entry.prayers[nextIdx]
                nextPrayerCard(prayer: next)
                    .padding(.bottom, 10)
            }

            Spacer()

            // All 5 prayer times list
            VStack(spacing: 3) {
                ForEach(Array(entry.prayers.enumerated()), id: \.offset) { index, prayer in
                    prayerListRow(index: index, prayer: prayer)
                }
            }

            Spacer()

            // Spiritual message
            Text(todayMessage)
                .font(.system(size: 10).italic())
                .foregroundColor(Color(hex: 0x8E8E93))
                .lineSpacing(2)
                .lineLimit(2)
        }
    }

    // MARK: - Next Prayer Card

    private func nextPrayerCard(prayer: (name: String, time: Date, icon: String)) -> some View {
        HStack(spacing: 10) {
            Image(systemName: prayer.icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: 0x5B8C6F))

            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: 0x2C2C2C))
                Text(arabicName(for: prayer.name))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }

            Spacer()

            Text(timeFormatter.string(from: prayer.time))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: 0x5B8C6F))
        }
        .padding(10)
        .background(Color(hex: 0xE8F0EB).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Prayer Dot Large

    private func prayerDotLarge(index: Int, prayer: (name: String, time: Date, icon: String)) -> some View {
        let isNext = index == entry.nextPrayerIndex
        let status = entry.prayerStatus[prayer.name]
        let isCompleted = status == "done" || status == "qadha"
        let isQadha = status == "qadha"
        let isPast = entry.nextPrayerIndex == nil || index < (entry.nextPrayerIndex ?? 0)

        return VStack(spacing: 4) {
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(isQadha ? Color(hex: 0xFFF6E3) : Color(hex: 0xEEFAF3))
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(isQadha ? Color(hex: 0xE0B86B) : Color(hex: 0x7FC4A0))
                } else if isNext {
                    Circle()
                        .fill(Color(hex: 0xE8F0EB))
                        .frame(width: 22, height: 22)
                    Circle()
                        .fill(Color(hex: 0x5B8C6F))
                        .frame(width: 10, height: 10)
                } else if isPast {
                    Circle()
                        .fill(Color(hex: 0xFDE8EA))
                        .frame(width: 22, height: 22)
                    Circle()
                        .fill(Color(hex: 0xE8878F))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .stroke(Color(hex: 0xD1D1D6), lineWidth: 1)
                        .frame(width: 22, height: 22)
                    Circle()
                        .fill(Color(hex: 0xD1D1D6))
                        .frame(width: 5, height: 5)
                }
            }

            Text(prayer.name)
                .font(.system(size: 9, weight: isNext ? .bold : .medium))
                .foregroundColor(isNext ? Color(hex: 0x5B8C6F) : Color(hex: 0xB5B5BA))
        }
    }

    // MARK: - Prayer List Row

    private func prayerListRow(index: Int, prayer: (name: String, time: Date, icon: String)) -> some View {
        let isNext = index == entry.nextPrayerIndex
        let status = entry.prayerStatus[prayer.name]
        let isCompleted = status == "done" || status == "qadha"

        return HStack {
            Image(systemName: prayer.icon)
                .font(.system(size: 10))
                .foregroundColor(isCompleted ? Color(hex: 0x7FC4A0) : (isNext ? Color(hex: 0x5B8C6F) : Color(hex: 0xB5B5BA)))
                .frame(width: 16)

            Text(prayer.name)
                .font(.system(size: 11, weight: isNext ? .semibold : .regular))
                .foregroundColor(isCompleted ? Color(hex: 0x7FC4A0) : (isNext ? Color(hex: 0x2C2C2C) : Color(hex: 0x8E8E93)))

            Spacer()

            Text(timeFormatter.string(from: prayer.time))
                .font(.system(size: 11, weight: isNext ? .semibold : .regular, design: .rounded))
                .foregroundColor(isCompleted ? Color(hex: 0x7FC4A0) : (isNext ? Color(hex: 0x5B8C6F) : Color(hex: 0xB5B5BA)))

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0x7FC4A0))
            }
        }
    }

    // MARK: - Arabic Name

    private func arabicName(for name: String) -> String {
        switch name {
        case "Subuh": return "\u{0627}\u{0644}\u{0635}\u{0628}\u{062D}"
        case "Dzuhur": return "\u{0627}\u{0644}\u{0638}\u{0647}\u{0631}"
        case "Ashar": return "\u{0627}\u{0644}\u{0639}\u{0635}\u{0631}"
        case "Maghrib": return "\u{0627}\u{0644}\u{0645}\u{063A}\u{0631}\u{0628}"
        case "Isya": return "\u{0627}\u{0644}\u{0639}\u{0634}\u{0627}\u{0621}"
        default: return ""
        }
    }
}

// MARK: - Preview

#Preview(as: .systemLarge) {
    HayyaLargeWidget()
} timeline: {
    PrayerEntry(
        date: Date(),
        prayers: [
            ("Subuh", Calendar.current.date(bySettingHour: 4, minute: 38, second: 0, of: Date())!, "moon.haze.fill"),
            ("Dzuhur", Calendar.current.date(bySettingHour: 11, minute: 55, second: 0, of: Date())!, "sun.max.fill"),
            ("Ashar", Calendar.current.date(bySettingHour: 15, minute: 15, second: 0, of: Date())!, "sun.haze.fill"),
            ("Maghrib", Calendar.current.date(bySettingHour: 17, minute: 55, second: 0, of: Date())!, "sunset.fill"),
            ("Isya", Calendar.current.date(bySettingHour: 19, minute: 8, second: 0, of: Date())!, "moon.stars.fill"),
        ],
        nextPrayerIndex: 2,
        locationName: "Jakarta",
        prayerStatus: ["Subuh": "done", "Dzuhur": "done"]
    )
}
