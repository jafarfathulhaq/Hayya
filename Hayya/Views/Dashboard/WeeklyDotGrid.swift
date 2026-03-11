//
//  WeeklyDotGrid.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct WeeklyDotGrid: View {
    let grid: [PrayerName: [PrayerStatus?]]
    let todayIndex: Int?  // 0–6, nil if showing last week
    let completions: [PrayerName: (done: Int, total: Int)]

    private let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let prayers = PrayerName.allCases

    var body: some View {
        VStack(spacing: 0) {
            // Day labels header
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 52)

                ForEach(0..<7, id: \.self) { index in
                    Text(dayLabels[index])
                        .font(.system(size: 9, weight: isToday(index) ? .bold : .medium))
                        .foregroundColor(isToday(index) ? Color(hex: 0x5B8C6F) : Color(hex: 0xB5B5BA))
                        .frame(maxWidth: .infinity)
                }

                Text("")
                    .frame(width: 28)
            }
            .padding(.bottom, 8)

            // Prayer rows
            ForEach(prayers) { prayer in
                prayerRow(prayer: prayer)
                    .padding(.bottom, prayer == .isya ? 0 : 8)
            }

            // Legend
            Divider()
                .padding(.top, 12)
                .padding(.bottom, 10)

            HStack(spacing: 12) {
                legendItem(color: Color(hex: 0x7FC4A0), label: "Done")
                legendItem(color: Color(hex: 0xE8878F), label: "Missed")
                legendItem(color: Color(hex: 0xE0B86B), label: "Qadha")
                legendDash(label: "Upcoming")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: 0xEBEBF0), lineWidth: 1)
        )
    }

    // MARK: - Prayer Row

    private func prayerRow(prayer: PrayerName) -> some View {
        let row = grid[prayer] ?? Array(repeating: nil, count: 7)
        let comp = completions[prayer] ?? (done: 0, total: 0)
        let isPerfect = comp.total > 0 && comp.done == comp.total

        return HStack(spacing: 0) {
            Text(prayer.rawValue)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: 0x8E8E93))
                .frame(width: 52, alignment: .leading)

            ForEach(0..<7, id: \.self) { dayIndex in
                dotCell(status: row[dayIndex], isToday: isToday(dayIndex))
                    .frame(maxWidth: .infinity)
            }

            Text("\(comp.done)/\(comp.total)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isPerfect ? Color(hex: 0x7FC4A0) : Color(hex: 0x8E8E93))
                .frame(width: 28, alignment: .trailing)
        }
    }

    // MARK: - Dot Cell

    private func dotCell(status: PrayerStatus?, isToday: Bool) -> some View {
        ZStack {
            if isToday {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: 0x5B8C6F).opacity(0.03))
            }

            if let status = status {
                ZStack {
                    Circle()
                        .fill(dotBackground(status))
                        .frame(width: 22, height: 22)

                    switch status {
                    case .done:
                        Circle()
                            .fill(Color(hex: 0x7FC4A0))
                            .frame(width: 8, height: 8)
                    case .missed:
                        Text("✕")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(hex: 0xE8878F))
                    case .qadha:
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(hex: 0xE0B86B))
                    default:
                        Circle()
                            .fill(Color(hex: 0xD1D1D6))
                            .frame(width: 6, height: 6)
                    }
                }
            } else {
                // Future/null
                Circle()
                    .stroke(Color(hex: 0xEBEBF0), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color(hex: 0xF5F5F7)))
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Helpers

    private func isToday(_ index: Int) -> Bool {
        todayIndex == index
    }

    private func dotBackground(_ status: PrayerStatus) -> Color {
        switch status {
        case .done: return Color(hex: 0xEEFAF3)
        case .missed: return Color(hex: 0xFFF0F1)
        case .qadha: return Color(hex: 0xFFF8EC)
        default: return Color(hex: 0xF5F5F7)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
    }

    private func legendDash(label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .stroke(Color(hex: 0xEBEBF0), style: StrokeStyle(lineWidth: 1, dash: [2, 1.5]))
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
    }
}
