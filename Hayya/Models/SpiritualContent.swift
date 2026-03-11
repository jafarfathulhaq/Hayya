//
//  SpiritualContent.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation

struct SpiritualMessage: Codable {
    let message: String
    let source: String
}

struct SpiritualContentData: Codable {
    let checkInMessages: [String: [SpiritualMessage]]
    let qadhaMessages: [SpiritualMessage]
    let celebrationMessages: [SpiritualMessage]
    let streakMessages: [SpiritualMessage]
    let encouragement: EncouragementData

    struct EncouragementData: Codable {
        let comeback: [String]
        let progress: [String]
    }
}

final class SpiritualContent {
    static let shared = SpiritualContent()

    private let data: SpiritualContentData?

    private init() {
        guard let url = Bundle.main.url(forResource: "SpiritualContent", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url) else {
            data = nil
            return
        }
        data = try? JSONDecoder().decode(SpiritualContentData.self, from: jsonData)
    }

    // MARK: - Check-In Messages

    func checkInMessage(for prayer: PrayerName) -> SpiritualMessage? {
        data?.checkInMessages[prayer.rawValue.lowercased()]?.randomElement()
    }

    // MARK: - Qadha

    func qadhaMessage() -> SpiritualMessage? {
        data?.qadhaMessages.randomElement()
    }

    // MARK: - Celebration (5/5)

    func celebrationMessage() -> SpiritualMessage? {
        data?.celebrationMessages.randomElement()
    }

    // MARK: - Streak

    func streakMessage() -> SpiritualMessage? {
        data?.streakMessages.randomElement()
    }

    // MARK: - Encouragement

    func comebackMessage() -> String? {
        data?.encouragement.comeback.randomElement()
    }

    func progressMessage() -> String? {
        data?.encouragement.progress.randomElement()
    }
}
