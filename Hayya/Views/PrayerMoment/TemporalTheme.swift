//
//  TemporalTheme.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct TemporalTheme {
    let prayer: PrayerName
    let background: Color
    let backgroundGlow: Color
    let text: Color
    let textSoft: Color
    let textMuted: Color
    let accent: Color
    let accentSoft: Color
    let hadithBackground: Color
    let hadithBorder: Color
    let hadithText: Color
    let buttonGradient: LinearGradient
    let buttonText: Color
    let buttonGlow: Color
    let emoji: String
    let label: String
    let isDark: Bool

    static func theme(for prayer: PrayerName) -> TemporalTheme {
        switch prayer {
        case .subuh: return subuh
        case .dzuhur: return dzuhur
        case .ashar: return ashar
        case .maghrib: return maghrib
        case .isya: return isya
        }
    }

    // MARK: - Subuh (Pre-dawn)

    static let subuh = TemporalTheme(
        prayer: .subuh,
        background: Color(hex: 0x0D1B2A),
        backgroundGlow: Color(hex: 0x1B2D45),
        text: Color(hex: 0xE8E4DC),
        textSoft: Color(hex: 0x8B9BB4),
        textMuted: Color(hex: 0x4A5568),
        accent: Color(hex: 0x7EAFC4),
        accentSoft: Color(hex: 0x3D5A73),
        hadithBackground: Color(hex: 0x3D3220),
        hadithBorder: Color(hex: 0xD4A843).opacity(0.13),
        hadithText: Color(hex: 0xD4A843),
        buttonGradient: LinearGradient(
            colors: [Color(hex: 0x7FC4A0), Color(hex: 0x7EAFC4)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        buttonText: Color(hex: 0x0D1B2A),
        buttonGlow: Color(hex: 0x7FC4A0).opacity(0.19),
        emoji: "🌙",
        label: "Pre-dawn",
        isDark: true
    )

    // MARK: - Dzuhur (Midday)

    static let dzuhur = TemporalTheme(
        prayer: .dzuhur,
        background: Color(hex: 0xFDFBF7),
        backgroundGlow: Color(hex: 0xF7F3EC),
        text: Color(hex: 0x2C2C2C),
        textSoft: Color(hex: 0x8E8E93),
        textMuted: Color(hex: 0xB5B5BA),
        accent: Color(hex: 0x5B8C6F),
        accentSoft: Color(hex: 0xE8F0EB),
        hadithBackground: Color(hex: 0xE8F0EB),
        hadithBorder: Color(hex: 0x5B8C6F).opacity(0.13),
        hadithText: Color(hex: 0x5B8C6F),
        buttonGradient: LinearGradient(
            colors: [Color(hex: 0x5B8C6F), Color(hex: 0x7FC4A0)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        buttonText: .white,
        buttonGlow: Color(hex: 0x5B8C6F).opacity(0.13),
        emoji: "☀️",
        label: "Midday",
        isDark: false
    )

    // MARK: - Ashar (Afternoon)

    static let ashar = TemporalTheme(
        prayer: .ashar,
        background: Color(hex: 0xFAF7F2),
        backgroundGlow: Color(hex: 0xF2EFE8),
        text: Color(hex: 0x2C2C2C),
        textSoft: Color(hex: 0x8E8E93),
        textMuted: Color(hex: 0xB5B5BA),
        accent: Color(hex: 0x8B7D5E),
        accentSoft: Color(hex: 0xF0EBDF),
        hadithBackground: Color(hex: 0xF0EBDF),
        hadithBorder: Color(hex: 0x8B7D5E).opacity(0.13),
        hadithText: Color(hex: 0x8B7D5E),
        buttonGradient: LinearGradient(
            colors: [Color(hex: 0x5B8C6F), Color(hex: 0x8B9E7D)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        buttonText: .white,
        buttonGlow: Color(hex: 0x5B8C6F).opacity(0.13),
        emoji: "🌤️",
        label: "Afternoon",
        isDark: false
    )

    // MARK: - Maghrib (Sunset)

    static let maghrib = TemporalTheme(
        prayer: .maghrib,
        background: Color(hex: 0xFFF8F0),
        backgroundGlow: Color(hex: 0xF8EDE0),
        text: Color(hex: 0x2C2C2C),
        textSoft: Color(hex: 0x8E8E93),
        textMuted: Color(hex: 0xB5B5BA),
        accent: Color(hex: 0xD4A843),
        accentSoft: Color(hex: 0xFFF6E3),
        hadithBackground: Color(hex: 0xFFF6E3),
        hadithBorder: Color(hex: 0xD4A843).opacity(0.19),
        hadithText: Color(hex: 0xD4A843),
        buttonGradient: LinearGradient(
            colors: [Color(hex: 0xD4A843), Color(hex: 0xE0C06A)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        buttonText: .white,
        buttonGlow: Color(hex: 0xD4A843).opacity(0.13),
        emoji: "🌅",
        label: "Sunset",
        isDark: false
    )

    // MARK: - Isya (Night)

    static let isya = TemporalTheme(
        prayer: .isya,
        background: Color(hex: 0x1A1F2E),
        backgroundGlow: Color(hex: 0x252B3D),
        text: Color(hex: 0xE0DCD4),
        textSoft: Color(hex: 0x8B9BB4),
        textMuted: Color(hex: 0x4A5568),
        accent: Color(hex: 0x8B9BB4),
        accentSoft: Color(hex: 0x2A3045),
        hadithBackground: Color(hex: 0x2A3045),
        hadithBorder: Color(hex: 0x8B9BB4).opacity(0.19),
        hadithText: Color(hex: 0xA8B8D0),
        buttonGradient: LinearGradient(
            colors: [Color(hex: 0x5B8C6F), Color(hex: 0x7EAFC4)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        buttonText: Color(hex: 0x1A1F2E),
        buttonGlow: Color(hex: 0x5B8C6F).opacity(0.13),
        emoji: "🌃",
        label: "Night",
        isDark: true
    )
}

// MARK: - Color Hex Extension

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
