//
//  IntensityBarsView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct IntensityBarsView: View {
    let level: Int          // 1–4
    let color: Color
    let size: BarSize

    enum BarSize {
        case small, medium

        var barWidth: CGFloat {
            switch self {
            case .small: return 3
            case .medium: return 4
            }
        }

        var gap: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 2.5
            }
        }

        var heights: [CGFloat] {
            switch self {
            case .small: return [6, 10, 14, 18]
            case .medium: return [8, 13, 18, 23]
            }
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: size.gap) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: size.barWidth / 2)
                    .fill(index < level ? color : Color(hex: 0xEBEBF0))
                    .frame(width: size.barWidth, height: size.heights[index])
            }
        }
        .frame(height: size.heights[3])
    }
}

// MARK: - Disruption Level Colors & Metadata

extension DisruptionLevel {
    var color: Color {
        switch self {
        case .gentle: return Color(hex: 0xA8C8D4)
        case .moderate: return Color(hex: 0x5B8C6F)
        case .urgent: return Color(hex: 0xD4A843)
        case .wakeUp: return Color(hex: 0xC47A5A)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .gentle: return Color(hex: 0xE4EEF2)
        case .moderate: return Color(hex: 0xE8F0EB)
        case .urgent: return Color(hex: 0xFFF6E3)
        case .wakeUp: return Color(hex: 0xFAEEE8)
        }
    }

    var barLevel: Int {
        switch self {
        case .gentle: return 1
        case .moderate: return 2
        case .urgent: return 3
        case .wakeUp: return 4
        }
    }

    var shortDescription: String {
        switch self {
        case .gentle: return "Silent push notification"
        case .moderate: return "Sound + vibration, once"
        case .urgent: return "Repeats until opened"
        case .wakeUp: return "Full alarm until dismissed"
        }
    }
}
