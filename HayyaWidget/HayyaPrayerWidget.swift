//
//  HayyaPrayerWidget.swift
//  HayyaWidget
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import WidgetKit
import SwiftUI
import Adhan

// MARK: - Timeline Entry

struct PrayerEntry: TimelineEntry {
    let date: Date
    let prayers: [(name: String, time: Date, icon: String)]
    let nextPrayerIndex: Int?  // Index into prayers array, nil if all passed
    let locationName: String
}

// MARK: - Timeline Provider

struct PrayerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
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
            locationName: "Jakarta"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(makeEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let now = Date()
        let entry = makeEntry(for: now)

        // Schedule refresh at each prayer time and at midnight
        var refreshDates: [Date] = []
        for prayer in entry.prayers {
            if prayer.time > now {
                refreshDates.append(prayer.time)
            }
        }

        // Also refresh at midnight for the next day
        let calendar = Calendar.current
        if let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: now)!) {
            refreshDates.append(midnight)
        }

        // If no future prayers, refresh at midnight
        let nextRefresh = refreshDates.min() ?? calendar.date(byAdding: .hour, value: 1, to: now)!

        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    // MARK: - Build Entry

    private func makeEntry(for date: Date) -> PrayerEntry {
        let location = loadLocation()
        let coords = Coordinates(latitude: location.latitude, longitude: location.longitude)

        let method = WidgetDataProvider.recommendedMethod(forCountryCode: location.countryCode)
        let params = WidgetDataProvider.calculationParameters(for: method)

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        guard let prayerTimes = PrayerTimes(
            coordinates: coords,
            date: dateComponents,
            calculationParameters: params
        ) else {
            return PrayerEntry(date: date, prayers: [], nextPrayerIndex: nil, locationName: location.name)
        }

        let prayers: [(name: String, time: Date, icon: String)] = [
            ("Subuh", prayerTimes.fajr, "moon.haze.fill"),
            ("Dzuhur", prayerTimes.dhuhr, "sun.max.fill"),
            ("Ashar", prayerTimes.asr, "sun.haze.fill"),
            ("Maghrib", prayerTimes.maghrib, "sunset.fill"),
            ("Isya", prayerTimes.isha, "moon.stars.fill"),
        ]

        // Find next upcoming prayer
        var nextIndex: Int? = nil
        for (i, prayer) in prayers.enumerated() {
            if prayer.time > date {
                nextIndex = i
                break
            }
        }

        return PrayerEntry(
            date: date,
            prayers: prayers,
            nextPrayerIndex: nextIndex,
            locationName: location.name
        )
    }

    private func loadLocation() -> (latitude: Double, longitude: Double, countryCode: String, name: String) {
        let defaults = UserDefaults(suiteName: "group.com.jafarfh.hayya.shared") ?? UserDefaults.standard

        let lat = defaults.double(forKey: "widget_latitude")
        let lon = defaults.double(forKey: "widget_longitude")
        let code = defaults.string(forKey: "widget_countryCode") ?? "ID"
        let name = defaults.string(forKey: "widget_locationName") ?? "Jakarta"

        // Use defaults if no stored location
        if lat == 0 && lon == 0 {
            return (-6.2088, 106.8456, "ID", "Jakarta")
        }

        return (lat, lon, code, name)
    }
}

// MARK: - Widget Definition

struct HayyaPrayerWidget: Widget {
    let kind = "HayyaPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            SmallPrayerWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: 0xFDFBF7)
                }
        }
        .configurationDisplayName("Prayer Times")
        .description("Today's prayer times at a glance.")
        .supportedFamilies([.systemSmall])
    }
}
