//
//  PrayerTimeTestView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import Adhan

struct PrayerTimeTestView: View {
    private let service = PrayerTimeService.shared

    // Jakarta coordinates
    private let jakartaCoordinates = Coordinates(latitude: -6.2088, longitude: 106.8456)
    private let jakartaTimezone = TimeZone(identifier: "Asia/Jakarta")!

    @State private var selectedMethod: CalculationMethodType = .kemenagRI
    @State private var prayerTimes: HayyaPrayerTimes?

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = jakartaTimezone
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        formatter.timeZone = jakartaTimezone
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                dateSection
                prayerTimesCard
                methodPicker
                infoCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color("BackgroundCream"))
        .onAppear { calculateTimes() }
        .onChange(of: selectedMethod) { _, _ in calculateTimes() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("Hayya")
                .font(.custom("DMSans-Bold", size: 28))
                .foregroundColor(Color("PrimaryGreen"))
            Text("Prayer Time Service Test")
                .font(.custom("DMSans-Regular", size: 15))
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Date

    private var dateSection: some View {
        VStack(spacing: 2) {
            Text(dateFormatter.string(from: Date()))
                .font(.custom("DMSans-Medium", size: 16))
                .foregroundColor(.primary)
            Text("Jakarta, Indonesia (-6.2088, 106.8456)")
                .font(.custom("DMSans-Regular", size: 13))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Prayer Times Card

    private var prayerTimesCard: some View {
        VStack(spacing: 0) {
            if let times = prayerTimes {
                prayerRow(name: "Subuh", time: times.subuh, icon: "moon.haze.fill", isLast: false)
                Divider().padding(.horizontal, 16)
                sunriseRow(time: times.sunrise)
                Divider().padding(.horizontal, 16)
                prayerRow(name: "Dzuhur", time: times.dzuhur, icon: "sun.max.fill", isLast: false)
                Divider().padding(.horizontal, 16)
                prayerRow(name: "Ashar", time: times.ashar, icon: "sun.haze.fill", isLast: false)
                Divider().padding(.horizontal, 16)
                prayerRow(name: "Maghrib", time: times.maghrib, icon: "sunset.fill", isLast: false)
                Divider().padding(.horizontal, 16)
                prayerRow(name: "Isya", time: times.isya, icon: "moon.stars.fill", isLast: true)
            } else {
                Text("Unable to calculate prayer times")
                    .font(.custom("DMSans-Regular", size: 15))
                    .foregroundColor(.secondary)
                    .padding(24)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func prayerRow(name: String, time: Date, icon: String, isLast: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color("PrimaryGreen"))
                .frame(width: 28)

            Text(name)
                .font(.custom("DMSans-Medium", size: 17))
                .foregroundColor(.primary)

            Spacer()

            Text(timeFormatter.string(from: time))
                .font(.custom("DMSans-SemiBold", size: 20))
                .foregroundColor(.primary)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func sunriseRow(time: Date) -> some View {
        HStack {
            Image(systemName: "sunrise.fill")
                .font(.system(size: 18))
                .foregroundColor(Color("AccentGold"))
                .frame(width: 28)

            Text("Sunrise")
                .font(.custom("DMSans-Regular", size: 15))
                .foregroundColor(.secondary)

            Spacer()

            Text(timeFormatter.string(from: time))
                .font(.custom("DMSans-Regular", size: 17))
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    // MARK: - Method Picker

    private var methodPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calculation Method")
                .font(.custom("DMSans-SemiBold", size: 15))
                .foregroundColor(.secondary)

            Menu {
                ForEach(CalculationMethodType.allCases) { method in
                    Button {
                        selectedMethod = method
                    } label: {
                        HStack {
                            Text("\(method.rawValue) — \(method.region)")
                            if method == selectedMethod {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedMethod.rawValue)
                            .font(.custom("DMSans-Medium", size: 16))
                            .foregroundColor(.primary)
                        Text(selectedMethod.region)
                            .font(.custom("DMSans-Regular", size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Method Details")
                .font(.custom("DMSans-SemiBold", size: 15))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                infoRow(label: "Fajr Angle", value: String(format: "%.1f°", selectedMethod.fajrAngle))
                if selectedMethod.usesIshaInterval {
                    infoRow(label: "Isha", value: "\(selectedMethod.ishaInterval) min after Maghrib")
                } else {
                    infoRow(label: "Isha Angle", value: String(format: "%.1f°", selectedMethod.ishaAngle))
                }
                infoRow(label: "Device Region", value: Locale.current.region?.identifier ?? "Unknown")
                infoRow(label: "Auto-detected", value: service.recommendedMethodForCurrentRegion().rawValue)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.custom("DMSans-Regular", size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.custom("DMSans-Medium", size: 14))
                .foregroundColor(.primary)
        }
    }

    // MARK: - Logic

    private func calculateTimes() {
        prayerTimes = service.getPrayerTimes(
            coordinates: jakartaCoordinates,
            date: Date(),
            method: selectedMethod
        )
    }
}

#Preview {
    PrayerTimeTestView()
}
