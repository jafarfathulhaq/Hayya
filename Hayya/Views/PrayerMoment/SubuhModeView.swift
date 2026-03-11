//
//  SubuhModeView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct SubuhModeView: View {
    let azanTime: String
    let onDismiss: () -> Void
    let onCheckIn: () -> Void

    @State private var breathing = false
    @State private var snoozesLeft = 3
    @State private var isSnoozed = false
    @State private var showContent = false

    private let theme = TemporalTheme.theme(for: .subuh)

    var body: some View {
        ZStack {
            // Dark navy background with breathing glow
            Color(hex: 0x0D1B2A).ignoresSafeArea()

            // Radial glow
            RadialGradient(
                colors: [
                    Color(hex: 0x1B2D45).opacity(breathing ? 0.8 : 0.4),
                    Color(hex: 0x0D1B2A).opacity(0)
                ],
                center: .init(x: 0.5, y: 0.35),
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathing)

            VStack(spacing: 0) {
                Spacer()

                if isSnoozed {
                    snoozedContent
                } else {
                    alarmContent
                }

                Spacer()
            }
            .padding(.horizontal, 32)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            breathing = true
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }

    // MARK: - Alarm Content

    private var alarmContent: some View {
        VStack(spacing: 0) {
            // Moon with breathing glow
            ZStack {
                Circle()
                    .fill(Color(hex: 0x7EAFC4).opacity(breathing ? 0.25 : 0.08))
                    .frame(width: 100, height: 100)
                    .scaleEffect(breathing ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathing)

                Text("\u{1F319}")
                    .font(.system(size: 52))
                    .scaleEffect(breathing ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathing)
            }
            .padding(.bottom, 24)

            // Time
            Text(azanTime)
                .font(.system(size: 52, weight: .bold))
                .foregroundColor(Color(hex: 0xE8E4DC))
                .tracking(-1)
                .padding(.bottom, 4)

            Text("IT'S TIME FOR")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: 0x8B9BB4))
                .tracking(1.5)
                .padding(.bottom, 4)

            Text("Subuh")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(Color(hex: 0xE8E4DC))
                .padding(.bottom, 4)

            Text(PrayerName.subuh.arabicName)
                .font(.custom("Noto Naskh Arabic", size: 22))
                .foregroundColor(Color(hex: 0x8B9BB4))
                .padding(.bottom, 32)

            // Hadith
            VStack(alignment: .leading, spacing: 6) {
                Text("Whoever prays the dawn prayer in congregation, it is as if he had prayed the whole night.")
                    .font(.system(size: 14).italic())
                    .foregroundColor(Color(hex: 0xD4A843))
                    .lineSpacing(6)
                Text("Sahih Muslim")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0x4A5568))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x3D3220))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: 0x5A4632), lineWidth: 1))
            .padding(.bottom, 36)

            // Check-in button
            Button {
                onCheckIn()
            } label: {
                Text("Alhamdulillah, I've prayed \u{2713}")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: 0x0D1B2A))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0x7FC4A0), Color(hex: 0x7EAFC4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color(hex: 0x7EAFC4).opacity(0.4), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)

            // Snooze
            if snoozesLeft > 0 {
                Button {
                    snoozesLeft -= 1
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSnoozed = true
                    }
                    // Return after snooze
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSnoozed = false
                        }
                    }
                } label: {
                    Text("Snooze 5 min (\(snoozesLeft) left)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: 0x8B9BB4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: 0x4A5568), lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else {
                Text("No more snoozes. Time to pray.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x4A5568))
            }
        }
    }

    // MARK: - Snoozed

    private var snoozedContent: some View {
        VStack(spacing: 16) {
            Text("\u{1F634}")
                .font(.system(size: 40))

            Text("Snoozed")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(hex: 0x8B9BB4))

            Text("Alarm returns in a moment...")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: 0x7EAFC4))

            Text("Snooze \(3 - snoozesLeft) of 3")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: 0x4A5568))
        }
    }
}

#Preview {
    SubuhModeView(
        azanTime: "04:40",
        onDismiss: {},
        onCheckIn: {}
    )
}
