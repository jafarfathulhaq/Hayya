//
//  PrayerTimeService.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import Adhan

// MARK: - Calculation Method Types (19 methods)

enum CalculationMethodType: String, CaseIterable, Identifiable {
    case kemenagRI = "Kemenag RI"
    case jakim = "JAKIM"
    case muis = "MUIS"
    case muslimWorldLeague = "MWL"
    case isna = "ISNA"
    case egyptian = "Egyptian"
    case ummAlQura = "Umm Al-Qura"
    case karachi = "Karachi"
    case dubai = "Dubai"
    case qatar = "Qatar"
    case kuwait = "Kuwait"
    case moonsighting = "Moonsighting Committee"
    case diyanet = "Diyanet"
    case tehran = "Tehran"
    case algeria = "Algeria"
    case tunisia = "Tunisia"
    case franceUOIF = "France UOIF"
    case russia = "Russia"
    case custom = "Custom"

    var id: String { rawValue }

    var region: String {
        switch self {
        case .kemenagRI: return "Indonesia"
        case .jakim: return "Malaysia"
        case .muis: return "Singapore"
        case .muslimWorldLeague: return "Europe, Global"
        case .isna: return "North America"
        case .egyptian: return "Africa, Middle East"
        case .ummAlQura: return "Saudi Arabia"
        case .karachi: return "Pakistan, India"
        case .dubai: return "UAE"
        case .qatar: return "Qatar"
        case .kuwait: return "Kuwait"
        case .moonsighting: return "North America (alt)"
        case .diyanet: return "Turkey"
        case .tehran: return "Iran"
        case .algeria: return "Algeria"
        case .tunisia: return "Tunisia"
        case .franceUOIF: return "France"
        case .russia: return "Russia"
        case .custom: return "Any"
        }
    }

    var fajrAngle: Double {
        switch self {
        case .kemenagRI: return 20.0
        case .jakim: return 20.0
        case .muis: return 20.0
        case .muslimWorldLeague: return 18.0
        case .isna: return 15.0
        case .egyptian: return 19.5
        case .ummAlQura: return 18.5
        case .karachi: return 18.0
        case .dubai: return 18.2
        case .qatar: return 18.0
        case .kuwait: return 18.0
        case .moonsighting: return 18.0
        case .diyanet: return 18.0
        case .tehran: return 17.7
        case .algeria: return 18.0
        case .tunisia: return 18.0
        case .franceUOIF: return 12.0
        case .russia: return 16.0
        case .custom: return 18.0
        }
    }

    var ishaAngle: Double {
        switch self {
        case .kemenagRI: return 18.0
        case .jakim: return 18.0
        case .muis: return 18.0
        case .muslimWorldLeague: return 17.0
        case .isna: return 15.0
        case .egyptian: return 17.5
        case .ummAlQura: return 0.0 // Uses 90-minute interval
        case .karachi: return 18.0
        case .dubai: return 18.2
        case .qatar: return 0.0 // Uses 90-minute interval
        case .kuwait: return 17.5
        case .moonsighting: return 18.0
        case .diyanet: return 17.0
        case .tehran: return 14.0
        case .algeria: return 17.0
        case .tunisia: return 18.0
        case .franceUOIF: return 12.0
        case .russia: return 14.5
        case .custom: return 18.0
        }
    }

    /// Whether this method uses a fixed minute interval for Isha instead of an angle
    var usesIshaInterval: Bool {
        switch self {
        case .ummAlQura, .qatar: return true
        default: return false
        }
    }

    var ishaInterval: Int {
        switch self {
        case .ummAlQura: return 90
        case .qatar: return 90
        default: return 0
        }
    }
}

// MARK: - Prayer Times Result

struct HayyaPrayerTimes {
    let subuh: Date
    let sunrise: Date
    let dzuhur: Date
    let ashar: Date
    let maghrib: Date
    let isya: Date
    let date: Date
    let method: CalculationMethodType

    /// All five obligatory prayers in order
    var allPrayers: [(name: String, time: Date)] {
        [
            ("Subuh", subuh),
            ("Dzuhur", dzuhur),
            ("Ashar", ashar),
            ("Maghrib", maghrib),
            ("Isya", isya)
        ]
    }
}

// MARK: - Prayer Time Service

final class PrayerTimeService {

    static let shared = PrayerTimeService()

    private init() {}

    // MARK: - Calculate Prayer Times

    /// Calculate prayer times for a given location, date, and method.
    /// Defaults to Kemenag RI if no method is specified.
    func getPrayerTimes(
        coordinates: Coordinates,
        date: Date = Date(),
        method: CalculationMethodType = .kemenagRI,
        customFajrAngle: Double? = nil,
        customIshaAngle: Double? = nil
    ) -> HayyaPrayerTimes? {
        let cal = Calendar(identifier: .gregorian)
        let dateComponents = cal.dateComponents([.year, .month, .day], from: date)

        let params = calculationParameters(for: method, customFajrAngle: customFajrAngle, customIshaAngle: customIshaAngle)

        guard let prayerTimes = PrayerTimes(
            coordinates: coordinates,
            date: dateComponents,
            calculationParameters: params
        ) else {
            return nil
        }

        return HayyaPrayerTimes(
            subuh: prayerTimes.fajr,
            sunrise: prayerTimes.sunrise,
            dzuhur: prayerTimes.dhuhr,
            ashar: prayerTimes.asr,
            maghrib: prayerTimes.maghrib,
            isya: prayerTimes.isha,
            date: date,
            method: method
        )
    }

    // MARK: - Auto-detect Calculation Method

    /// Returns the recommended calculation method for a given country code (ISO 3166-1 alpha-2).
    func recommendedMethod(forCountryCode countryCode: String) -> CalculationMethodType {
        switch countryCode.uppercased() {
        case "ID":
            return .kemenagRI
        case "MY":
            return .jakim
        case "SG":
            return .muis
        case "US", "CA":
            return .isna
        case "SA":
            return .ummAlQura
        case "EG":
            return .egyptian
        case "PK", "IN", "BD", "AF":
            return .karachi
        case "AE":
            return .dubai
        case "QA":
            return .qatar
        case "KW":
            return .kuwait
        case "TR":
            return .diyanet
        case "IR":
            return .tehran
        case "DZ":
            return .algeria
        case "TN":
            return .tunisia
        case "FR":
            return .franceUOIF
        case "RU":
            return .russia
        case "GB", "DE", "NL", "BE", "IT", "ES", "PT", "AT", "CH",
             "SE", "NO", "DK", "FI", "PL", "CZ", "HU", "RO", "BG",
             "GR", "IE", "HR", "SK", "SI", "LT", "LV", "EE":
            return .muslimWorldLeague
        case "JO", "LB", "SY", "IQ", "YE", "OM", "BH", "LY", "SD",
             "MA", "MR":
            return .egyptian
        case "BN":
            return .muis
        default:
            return .muslimWorldLeague
        }
    }

    /// Auto-detect using the device's current region
    func recommendedMethodForCurrentRegion() -> CalculationMethodType {
        let countryCode = Locale.current.region?.identifier ?? "ID"
        return recommendedMethod(forCountryCode: countryCode)
    }

    // MARK: - Private Helpers

    private func calculationParameters(
        for method: CalculationMethodType,
        customFajrAngle: Double?,
        customIshaAngle: Double?
    ) -> CalculationParameters {
        var params: CalculationParameters

        // Map to Adhan-Swift built-in methods where available
        switch method {
        case .muslimWorldLeague:
            params = CalculationMethod.muslimWorldLeague.params
        case .isna:
            params = CalculationMethod.northAmerica.params
        case .egyptian:
            params = CalculationMethod.egyptian.params
        case .ummAlQura:
            params = CalculationMethod.ummAlQura.params
        case .karachi:
            params = CalculationMethod.karachi.params
        case .dubai:
            params = CalculationMethod.dubai.params
        case .qatar:
            params = CalculationMethod.qatar.params
        case .kuwait:
            params = CalculationMethod.kuwait.params
        case .moonsighting:
            params = CalculationMethod.moonsightingCommittee.params
        case .diyanet:
            params = CalculationMethod.turkey.params
        case .tehran:
            params = CalculationMethod.tehran.params
        case .muis:
            params = CalculationMethod.singapore.params

        // Methods without built-in Adhan-Swift presets — use custom angles
        case .kemenagRI:
            params = CalculationMethod.other.params
            params.fajrAngle = 20.0
            params.ishaAngle = 18.0

        case .jakim:
            params = CalculationMethod.other.params
            params.fajrAngle = 20.0
            params.ishaAngle = 18.0

        case .algeria:
            params = CalculationMethod.other.params
            params.fajrAngle = 18.0
            params.ishaAngle = 17.0

        case .tunisia:
            params = CalculationMethod.other.params
            params.fajrAngle = 18.0
            params.ishaAngle = 18.0

        case .franceUOIF:
            params = CalculationMethod.other.params
            params.fajrAngle = 12.0
            params.ishaAngle = 12.0

        case .russia:
            params = CalculationMethod.other.params
            params.fajrAngle = 16.0
            params.ishaAngle = 14.5

        case .custom:
            params = CalculationMethod.other.params
            params.fajrAngle = customFajrAngle ?? 18.0
            params.ishaAngle = customIshaAngle ?? 18.0
        }

        // Override angles for custom method
        if method == .custom {
            if let fajr = customFajrAngle { params.fajrAngle = fajr }
            if let isha = customIshaAngle { params.ishaAngle = isha }
        }

        return params
    }
}
