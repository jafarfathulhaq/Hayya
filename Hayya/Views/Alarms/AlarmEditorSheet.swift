//
//  AlarmEditorSheet.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct AlarmEditorSheet: View {
    let prayer: PrayerName
    @Binding var setting: AlarmSetting
    let azanTimeString: String
    let onDismiss: () -> Void

    @State private var showApplyToOthers = false
    @State private var applySelection: Set<PrayerName> = []

    private var alarmTimeString: String {
        guard azanTimeString != "--:--" else { return "--:--" }
        let parts = azanTimeString.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else { return azanTimeString }
        var total = hour * 60 + minute + setting.offsetMinutes
        if total < 0 { total += 1440 }
        total = total % 1440
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    private var isShortWindow: Bool {
        prayer == .subuh || prayer == .maghrib
    }

    private var snoozeOptions: [Int] {
        isShortWindow ? [0, 5, 10, 15] : [0, 5, 15, 30]
    }

    private var offsetOptions: [Int] {
        prayer == .subuh ? [-15, -10, -5, 0, 5] : [-5, 0, 5, 10, 15]
    }

    private let sounds = ["Default chime", "Soft bell", "Gentle pulse", "Morning birds"]

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(hex: 0xD1D1D6))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)

            // Header
            sheetHeader

            ScrollView {
                VStack(spacing: 16) {
                    disruptionLevelSection
                    snoozeSection
                    offsetSection
                    soundSection
                    headsUpSection
                    if prayer == .subuh {
                        subuhModeSection
                    }
                    applyToOthersSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: 0xFDFBF7))
    }

    // MARK: - Header

    private var sheetHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(setting.disruptionLevel.backgroundColor)
                    .frame(width: 36, height: 36)
                IntensityBarsView(level: setting.disruptionLevel.barLevel, color: setting.disruptionLevel.color, size: .small)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(prayer.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: 0x2C2C2C))
                    Text(prayer.arabicName)
                        .font(.custom("Noto Naskh Arabic", size: 14))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                Text("Azan at \(azanTimeString) · Alarm at \(alarmTimeString)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .frame(width: 28, height: 28)
                    .background(Color(hex: 0xF5F5F7))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Disruption Level

    private var disruptionLevelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Disruption Level")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(DisruptionLevel.allCases) { level in
                    let isSelected = setting.disruptionLevel == level

                    Button {
                        setting.disruptionLevel = level
                    } label: {
                        VStack(spacing: 6) {
                            IntensityBarsView(level: level.barLevel, color: isSelected ? level.color : Color(hex: 0xD1D1D6), size: .medium)
                                .frame(height: 23)

                            Text(level.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(isSelected ? level.color : Color(hex: 0x8E8E93))

                            Text(level.shortDescription)
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: 0xB5B5BA))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? level.backgroundColor : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? level.color.opacity(0.5) : Color(hex: 0xEBEBF0), lineWidth: isSelected ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Snooze

    private var snoozeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Snooze Interval")

            HStack(spacing: 6) {
                ForEach(snoozeOptions, id: \.self) { minutes in
                    chipButton(
                        label: minutes == 0 ? "Off" : "\(minutes)m",
                        isSelected: setting.snoozeIntervalMinutes == minutes,
                        color: setting.disruptionLevel.color
                    ) {
                        setting.snoozeIntervalMinutes = minutes
                        if minutes == 0 { setting.maxSnoozeCount = 1 }
                    }
                }
            }

            if setting.snoozeIntervalMinutes > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Repeat count")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: 0x8E8E93))

                    HStack(spacing: 6) {
                        ForEach([1, 2, 3], id: \.self) { count in
                            chipButton(
                                label: "\(count)x",
                                isSelected: setting.maxSnoozeCount == count,
                                color: setting.disruptionLevel.color
                            ) {
                                setting.maxSnoozeCount = count
                            }
                        }
                        Spacer()
                    }

                    let totalWindow = setting.snoozeIntervalMinutes * setting.maxSnoozeCount
                    Text("One tap at alarm time. Total window: \(totalWindow) min")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Offset from Azan

    private var offsetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Offset from Azan")

            HStack(spacing: 6) {
                ForEach(offsetOptions, id: \.self) { minutes in
                    chipButton(
                        label: offsetLabel(minutes),
                        isSelected: setting.offsetMinutes == minutes,
                        color: setting.disruptionLevel.color
                    ) {
                        setting.offsetMinutes = minutes
                    }
                }
            }

            HStack(spacing: 4) {
                Text(offsetDescription)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0x8E8E93))
                Spacer()
                Text("Alarm at \(alarmTimeString)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(setting.disruptionLevel.color)
            }
            .padding(.top, 2)
        }
    }

    private func offsetLabel(_ minutes: Int) -> String {
        if minutes == 0 { return "0" }
        return minutes > 0 ? "+\(minutes)" : "\(minutes)"
    }

    private var offsetDescription: String {
        if setting.offsetMinutes == 0 {
            return "At azan time"
        } else if setting.offsetMinutes > 0 {
            return "\(setting.offsetMinutes) min after azan"
        } else {
            return "\(abs(setting.offsetMinutes)) min before azan"
        }
    }

    // MARK: - Sound

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Sound")

            FlowLayout(spacing: 6) {
                ForEach(sounds, id: \.self) { sound in
                    let isSelected = setting.soundName == sound
                    Button {
                        setting.soundName = sound
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 8))
                            Text(sound)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(isSelected ? setting.disruptionLevel.color : Color(hex: 0x8E8E93))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? setting.disruptionLevel.backgroundColor : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? setting.disruptionLevel.color.opacity(0.4) : Color(hex: 0xEBEBF0), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Heads-up

    private var headsUpSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Heads-up Before Azan")

            HStack(spacing: 6) {
                ForEach([0, 15, 30, 60], id: \.self) { minutes in
                    chipButton(
                        label: minutes == 0 ? "Off" : "\(minutes)m",
                        isSelected: setting.headsUpMinutes == minutes,
                        color: setting.disruptionLevel.color
                    ) {
                        setting.headsUpMinutes = minutes
                    }
                }
            }
        }
    }

    // MARK: - Subuh Mode

    private var subuhModeSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: 0x0D1B2A).opacity(0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: 0x0D1B2A))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Subuh Mode")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: 0x2C2C2C))
                Text("Full-screen wake-up experience")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }

            Spacer()

            Toggle("", isOn: $setting.isSubuhModeEnabled)
                .labelsHidden()
                .tint(Color(hex: 0x5B8C6F))
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
    }

    // MARK: - Apply to Others

    private var applyToOthersSection: some View {
        VStack(spacing: 0) {
            if !showApplyToOthers {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showApplyToOthers = true
                        applySelection = []
                    }
                } label: {
                    HStack {
                        Text("Use this setup for other prayers")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: 0x5B8C6F))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0x5B8C6F))
                    }
                    .padding(14)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: 10) {
                    ForEach(PrayerName.allCases.filter { $0 != prayer }) { p in
                        Button {
                            if applySelection.contains(p) {
                                applySelection.remove(p)
                            } else {
                                applySelection.insert(p)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: applySelection.contains(p) ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 18))
                                    .foregroundColor(applySelection.contains(p) ? Color(hex: 0x5B8C6F) : Color(hex: 0xD1D1D6))

                                Text(p.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: 0x2C2C2C))

                                Text(p.arabicName)
                                    .font(.custom("Noto Naskh Arabic", size: 12))
                                    .foregroundColor(Color(hex: 0xB5B5BA))

                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 10) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showApplyToOthers = false
                            }
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: 0x8E8E93))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: 0xF5F5F7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        if !applySelection.isEmpty {
                            Button {
                                // Apply will be handled by parent via callback
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showApplyToOthers = false
                                }
                            } label: {
                                Text("Apply to \(applySelection.count)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: 0x5B8C6F))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }

                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
            }
        }
    }

    // MARK: - Reusable Components

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(hex: 0x8E8E93))
            .textCase(.uppercase)
    }

    private func chipButton(label: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? color : Color(hex: 0x8E8E93))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? color.opacity(0.1) : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? color.opacity(0.4) : Color(hex: 0xEBEBF0), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout (for sound chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
