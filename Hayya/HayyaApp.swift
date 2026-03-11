//
//  HayyaApp.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/10/26.
//

import SwiftUI
import SwiftData
import Adhan

@main
struct HayyaApp: App {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PrayerRecord.self,
            UserSettings.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        NotificationService.shared.registerCategories()
    }

    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                ContentView()
                    .onAppear {
                        scheduleDailyNotifications()
                        LocationService.shared.writeToWidgetDefaults()
                    }
                    .task {
                        // Refresh critical alert status + CloudKit user ID on launch
                        await NotificationService.shared.refreshCriticalAlertStatus()
                        await CloudKitService.shared.fetchCurrentUserID()
                        await CloudKitService.shared.processOfflineQueue()
                    }
            } else {
                OnboardingFlow(isOnboardingComplete: $isOnboardingComplete)
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func scheduleDailyNotifications() {
        let location = LocationService.shared
        let coordinates = Coordinates(latitude: location.latitude, longitude: location.longitude)

        // Load alarm settings from UserSettings if available
        var alarmSettings: [PrayerName: AlarmSetting] = [:]
        let descriptor = FetchDescriptor<UserSettings>()
        if let settings = try? sharedModelContainer.mainContext.fetch(descriptor).first {
            for prayer in PrayerName.allCases {
                alarmSettings[prayer] = settings.alarmSetting(for: prayer)
            }
        } else {
            for prayer in PrayerName.allCases {
                alarmSettings[prayer] = AlarmSetting.defaultSetting(for: prayer)
            }
        }

        NotificationService.shared.scheduleAllPrayers(
            coordinates: coordinates,
            date: Date(),
            method: location.recommendedMethod,
            alarmSettings: alarmSettings
        )
    }
}
