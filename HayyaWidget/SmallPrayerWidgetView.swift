//
//  SmallPrayerWidgetView.swift
//  HayyaWidget
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import WidgetKit

struct SmallPrayerWidgetView: View {
    let entry: PrayerEntry

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: location + Hayya branding
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(hex: 0x5B8C6F))
                Text(entry.locationName)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: 0x8E8E93))
                Spacer()
                Text("Hayya")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(hex: 0x5B8C6F))
            }
            .padding(.bottom, 6)

            // Next prayer highlight
            if let nextIdx = entry.nextPrayerIndex {
                let next = entry.prayers[nextIdx]
                HStack(spacing: 6) {
                    Image(systemName: next.icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x5B8C6F))
                    VStack(alignment: .leading, spacing: 0) {
                        Text(next.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: 0x2C2C2C))
                        Text(timeFormatter.string(from: next.time))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: 0x5B8C6F))
                    }
                }
                .padding(.bottom, 8)
            } else {
                // All prayers passed
                let completedCount = entry.prayerStatus.values.filter { $0 == "done" || $0 == "qadha" }.count
                if completedCount == 5 {
                    Text("Alhamdulillah \u{2714}")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: 0x7FC4A0))
                        .padding(.bottom, 8)
                } else {
                    Text("All prayers done")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: 0x7FC4A0))
                        .padding(.bottom, 8)
                }
            }

            Spacer()

            // 5 prayer dots row
            HStack(spacing: 0) {
                ForEach(Array(entry.prayers.enumerated()), id: \.offset) { index, prayer in
                    prayerDot(index: index, prayer: prayer)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Prayer Dot

    private func prayerDot(index: Int, prayer: (name: String, time: Date, icon: String)) -> some View {
        let isNext = index == entry.nextPrayerIndex
        let status = entry.prayerStatus[prayer.name]
        let isCompleted = status == "done" || status == "qadha"
        let isQadha = status == "qadha"
        let isPast = entry.nextPrayerIndex == nil || index < (entry.nextPrayerIndex ?? 0)

        return VStack(spacing: 3) {
            ZStack {
                if isCompleted {
                    // Completed — green filled (amber if qadha)
                    Circle()
                        .fill(isQadha ? Color(hex: 0xFFF6E3) : Color(hex: 0xEEFAF3))
                        .frame(width: 18, height: 18)
                    Image(systemName: "checkmark")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(isQadha ? Color(hex: 0xE0B86B) : Color(hex: 0x7FC4A0))
                } else if isNext {
                    // Active/next prayer — highlighted ring
                    Circle()
                        .fill(Color(hex: 0xE8F0EB))
                        .frame(width: 18, height: 18)
                    Circle()
                        .fill(Color(hex: 0x5B8C6F))
                        .frame(width: 8, height: 8)
                } else if isPast {
                    // Past prayer without check-in — missed (soft pink)
                    Circle()
                        .fill(Color(hex: 0xFDE8EA))
                        .frame(width: 18, height: 18)
                    Circle()
                        .fill(Color(hex: 0xE8878F))
                        .frame(width: 5, height: 5)
                } else {
                    // Future prayer — dashed outline
                    Circle()
                        .stroke(Color(hex: 0xD1D1D6), lineWidth: 1)
                        .frame(width: 18, height: 18)
                    Circle()
                        .fill(Color(hex: 0xD1D1D6))
                        .frame(width: 4, height: 4)
                }
            }

            Text(String(prayer.name.prefix(1)))
                .font(.system(size: 8, weight: isNext ? .bold : .medium))
                .foregroundColor(isNext ? Color(hex: 0x5B8C6F) : Color(hex: 0xB5B5BA))
        }
    }
}

// MARK: - Color Hex (Widget-local, mirrors main app)

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    HayyaPrayerWidget()
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
