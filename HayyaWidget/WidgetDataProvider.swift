//
//  WidgetDataProvider.swift
//  HayyaWidget
//
//  Created by Jafar Fathul Haq on 3/11/26.
//
//  Lightweight helpers for prayer time calculation in the widget.
//  Mirrors PrayerTimeService logic without depending on the main app target.
//

import Foundation
import Adhan

enum WidgetDataProvider {

    // MARK: - Recommended Method by Country

    static func recommendedMethod(forCountryCode countryCode: String) -> WidgetCalculationMethod {
        switch countryCode.uppercased() {
        case "ID": return .kemenagRI
        case "MY": return .jakim
        case "SG": return .muis
        case "US", "CA": return .isna
        case "SA": return .ummAlQura
        case "EG": return .egyptian
        case "PK", "IN", "BD", "AF": return .karachi
        case "AE": return .dubai
        case "QA": return .qatar
        case "KW": return .kuwait
        case "TR": return .diyanet
        case "IR": return .tehran
        default: return .muslimWorldLeague
        }
    }

    // MARK: - Calculation Parameters

    static func calculationParameters(for method: WidgetCalculationMethod) -> CalculationParameters {
        var params: CalculationParameters

        switch method {
        case .kemenagRI:
            params = CalculationMethod.other.params
            params.fajrAngle = 20.0
            params.ishaAngle = 18.0
        case .jakim:
            params = CalculationMethod.other.params
            params.fajrAngle = 20.0
            params.ishaAngle = 18.0
        case .muis:
            params = CalculationMethod.singapore.params
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
        case .diyanet:
            params = CalculationMethod.turkey.params
        case .tehran:
            params = CalculationMethod.tehran.params
        }

        return params
    }
}

// MARK: - Widget Calculation Method

/// Lightweight enum for widget — subset of main app's CalculationMethodType.
enum WidgetCalculationMethod: String {
    case kemenagRI, jakim, muis, muslimWorldLeague, isna, egyptian
    case ummAlQura, karachi, dubai, qatar, kuwait, diyanet, tehran
}
