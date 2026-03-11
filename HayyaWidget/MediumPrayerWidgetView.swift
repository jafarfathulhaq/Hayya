//
//  MediumPrayerWidgetView.swift
//  HayyaWidget
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import WidgetKit

struct MediumPrayerWidgetView: View {
    let entry: PrayerEntry

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private var completedCount: Int {
        entry.prayerStatus.values.filter { $0 == "done" || $0 == "qadha" }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: Next prayer info
            VStack(alignment: .leading, spacing: 4) {
                // Header
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 7))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                    Text(entry.locationName)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }

                Spacer()

                if let nextIdx = entry.nextPrayerIndex {
                    let next = entry.prayers[nextIdx]
                    Image(systemName: next.icon)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                    Text(next.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: 0x2C2C2C))
                    Text(timeFormatter.string(from: next.time))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: 0x7FC4A0))
                    Text("All done")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: 0x7FC4A0))
                }

                Spacer()

                // Completed count
                Text("\(completedCount)/5 completed")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Divider
            Rectangle()
                .fill(Color(hex: 0xEBEBF0))
                .frame(width: 1)
                .padding(.vertical, 4)

            // Right: All 5 prayers list
            VStack(spacing: 4) {
                ForEach(Array(entry.prayers.enumerated()), id: \.offset) { index, prayer in
                    prayerRow(index: index, prayer: prayer)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Prayer Row

    private func prayerRow(index: Int, prayer: (name: String, time: Date, icon: String)) -> some View {
        let isNext = index == entry.nextPrayerIndex
        let status = entry.prayerStatus[prayer.name]
        let isCompleted = status == "done" || status == "qadha"
        let isQadha = status == "qadha"
        let isMissed = !isCompleted && (entry.nextPrayerIndex == nil || index < (entry.nextPrayerIndex ?? 0))

        return HStack(spacing: 6) {
            // Status indicator
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(isQadha ? Color(hex: 0xE0B86B) : Color(hex: 0x7FC4A0))
                        .frame(width: 12, height: 12)
                    Image(systemName: "checkmark")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundColor(.white)
                } else if isNext {
                    Circle()
                        .fill(Color(hex: 0x5B8C6F))
                        .frame(width: 12, height: 12)
                } else if isMissed {
                    Circle()
                        .fill(Color(hex: 0xE8878F))
                        .frame(width: 12, height: 12)
                } else {
                    Circle()
                        .stroke(Color(hex: 0xD1D1D6), lineWidth: 1)
                        .frame(width: 12, height: 12)
                }
            }

            Text(prayer.name)
                .font(.system(size: 11, weight: isNext ? .bold : .regular))
                .foregroundColor(isNext ? Color(hex: 0x2C2C2C) : Color(hex: 0x8E8E93))
                .lineLimit(1)

            Spacer()

            Text(timeFormatter.string(from: prayer.time))
                .font(.system(size: 10, weight: isNext ? .semibold : .regular, design: .rounded))
                .foregroundColor(isNext ? Color(hex: 0x5B8C6F) : Color(hex: 0xB5B5BA))
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background(isNext ? Color(hex: 0xE8F0EB).opacity(0.5) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    HayyaMediumWidget()
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
