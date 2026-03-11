//
//  CalculationMethodPicker.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct CalculationMethodPicker: View {
    @Binding var selectedMethod: CalculationMethodType
    @Binding var customFajrAngle: Double
    @Binding var customIshaAngle: Double
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ScrollView {
                VStack(spacing: 3) {
                    ForEach(CalculationMethodType.allCases) { method in
                        methodRow(method)
                    }
                }
            }
            .frame(maxHeight: 200)

            // Custom angle inputs
            if selectedMethod == .custom {
                customAngleInputs
            }

            Text("Choose the method used by your local mosque for best accuracy")
                .font(.system(size: 10))
                .foregroundColor(Color(hex: 0xB5B5BA))
                .padding(.top, 4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .padding(.bottom, 8)
    }

    // MARK: - Method Row

    private func methodRow(_ method: CalculationMethodType) -> some View {
        let isSelected = method == selectedMethod

        return Button {
            selectedMethod = method
            if method != .custom {
                onDismiss?()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(method.rawValue)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? Color(hex: 0x5B8C6F) : Color(hex: 0x2C2C2C))
                    Text(method.region)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }

                Spacer()

                Text(angleLabel(for: method))
                    .font(.system(size: 9))
                    .foregroundColor(Color(hex: 0xB5B5BA))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: 0xE8F0EB) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color(hex: 0x5B8C6F) : Color(hex: 0xEBEBF0),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func angleLabel(for method: CalculationMethodType) -> String {
        if method == .custom { return "F:— I:—" }
        let fajr = String(format: "%.1f°", method.fajrAngle)
        let isha = method.usesIshaInterval ? "\(method.ishaInterval)m" : String(format: "%.1f°", method.ishaAngle)
        return "F:\(fajr) I:\(isha)"
    }

    // MARK: - Custom Angle Inputs

    private var customAngleInputs: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fajr angle (°)")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xB5B5BA))
                TextField("20", value: $customFajrAngle, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Isha angle (°)")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xB5B5BA))
                TextField("18", value: $customIshaAngle, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }
}
