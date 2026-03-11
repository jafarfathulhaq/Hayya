//
//  PrayerCardView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct PrayerCardView: View {
    let state: PrayerState
    let formattedTime: (Date) -> String
    var onCheckIn: () -> Void
    var onQadha: () -> Void

    @State private var justChecked = false

    // MARK: - Colors per status

    private var cardBackground: Color {
        switch state.status {
        case .active: return .white.opacity(0.95)
        case .missed: return Color(hex: 0xFFF0F1).opacity(0.6)
        default: return .white.opacity(0.8)
        }
    }

    private var borderColor: Color {
        switch state.status {
        case .active: return Color(hex: 0x5B8C6F)
        case .missed: return Color(hex: 0xE8878F).opacity(0.25)
        default: return Color(hex: 0xEBEBF0).opacity(0.8)
        }
    }

    private var borderWidth: CGFloat {
        switch state.status {
        case .active: return 2
        case .missed: return 1.5
        default: return 1
        }
    }

    private var statusColor: Color {
        switch state.status {
        case .done: return Color(hex: 0x7FC4A0)
        case .active: return Color(hex: 0x5B8C6F)
        case .missed: return Color(hex: 0xE8878F)
        case .qadha: return Color(hex: 0xE0B86B)
        case .upcoming: return Color(hex: 0xD1D1D6)
        }
    }

    private var statusBackground: Color {
        switch state.status {
        case .done: return Color(hex: 0x7FC4A0).opacity(0.15)
        case .active: return Color(hex: 0x5B8C6F).opacity(0.1)
        case .missed: return Color(hex: 0xE8878F).opacity(0.12)
        case .qadha: return Color(hex: 0xE0B86B).opacity(0.15)
        case .upcoming: return Color(hex: 0xD1D1D6).opacity(0.15)
        }
    }

    private var statusIcon: String {
        switch state.status {
        case .done: return "checkmark"
        case .active: return "circle.fill"
        case .missed: return "xmark"
        case .qadha: return "arrow.uturn.backward"
        case .upcoming: return "circle"
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 14) {
            statusCircle
            prayerInfo
            Spacer()
            actionArea
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .shadow(
            color: state.status == .active
                ? Color(hex: 0x5B8C6F).opacity(0.1)
                : .black.opacity(0.02),
            radius: state.status == .active ? 10 : 2,
            x: 0,
            y: state.status == .active ? 4 : 1
        )
        .shadow(
            color: justChecked ? Color(hex: 0x7FC4A0).opacity(0.19) : .clear,
            radius: justChecked ? 12 : 0
        )
        .scaleEffect(justChecked ? 0.98 : 1.0)
        .animation(.easeOut(duration: 0.35), value: justChecked)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: state.status)
    }

    // MARK: - Status Circle

    private var statusCircle: some View {
        ZStack {
            Circle()
                .fill(statusBackground)
                .frame(width: 46, height: 46)

            Image(systemName: statusIcon)
                .font(.system(size: state.status == .done ? 20 : 16, weight: .semibold))
                .foregroundColor(statusColor)
        }
        .scaleEffect(justChecked ? 1.15 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: justChecked)
    }

    // MARK: - Prayer Info

    private var prayerInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(state.prayer.rawValue)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: 0x2C2C2C))

            Text(state.prayer.arabicName)
                .font(.custom("Noto Naskh Arabic", size: 14))
                .foregroundColor(Color(hex: 0xB5B5BA))

            Text(formattedTime(state.azanTime))
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x8E8E93))
                .padding(.top, 1)

            if state.status == .qadha {
                qadhaBadge
            }
        }
    }

    private var qadhaBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 9, weight: .semibold))
            Text("Recovered")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(Color(hex: 0xE0B86B))
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(Color(hex: 0xFFF8EC))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.top, 4)
    }

    // MARK: - Action Area

    @ViewBuilder
    private var actionArea: some View {
        switch state.status {
        case .active:
            Button {
                justChecked = true
                onCheckIn()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    justChecked = false
                }
            } label: {
                Text("Check In")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color(hex: 0x5B8C6F))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(ScaleButtonStyle())

        case .missed:
            Button {
                onQadha()
            } label: {
                Text("Qadha")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: 0xE0B86B))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(ScaleButtonStyle())

        case .done:
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: 0x7FC4A0))

        case .qadha:
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: 0xE0B86B))

        case .upcoming:
            EmptyView()
        }
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
