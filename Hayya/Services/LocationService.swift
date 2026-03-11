//
//  LocationService.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import CoreLocation
import MapKit

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    var currentLocation: CLLocation?
    var locationName: String = "Unknown"
    var countryCode: String = "ID"
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isLoading = false

    private let manager = CLLocationManager()

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = manager.authorizationStatus
    }

    // MARK: - Request

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        isLoading = true
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        reverseGeocode(location)
        writeToWidgetDefaults()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        // Fall back to default (Jakarta)
        locationName = "Jakarta, Indonesia"
        countryCode = "ID"
    }

    // MARK: - Geocoding

    private func reverseGeocode(_ location: CLLocation) {
        Task {
            let request = MKLocalSearch.Request()
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            request.resultTypes = .address

            do {
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                if let item = response.mapItems.first,
                   let representations = item.addressRepresentations {
                    let city = representations.cityName ?? "Unknown"
                    let region = representations.regionName ?? ""
                    self.locationName = region.isEmpty ? city : "\(city), \(region)"
                    self.countryCode = representations.region?.identifier ?? "ID"
                }
            } catch {
                self.locationName = "Jakarta, Indonesia"
                self.countryCode = "ID"
            }
            self.isLoading = false
        }
    }

    // MARK: - Widget Data

    func writeToWidgetDefaults() {
        guard let defaults = UserDefaults(suiteName: "group.com.jafarfh.hayya.shared") else { return }
        defaults.set(latitude, forKey: "widget_latitude")
        defaults.set(longitude, forKey: "widget_longitude")
        defaults.set(countryCode, forKey: "widget_countryCode")

        // Short location name for widget display
        let shortName = locationName.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? locationName
        defaults.set(shortName, forKey: "widget_locationName")
    }

    // MARK: - Computed

    var latitude: Double {
        currentLocation?.coordinate.latitude ?? -6.2088
    }

    var longitude: Double {
        currentLocation?.coordinate.longitude ?? 106.8456
    }

    var recommendedMethod: CalculationMethodType {
        PrayerTimeService.shared.recommendedMethod(forCountryCode: countryCode)
    }
}
