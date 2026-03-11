//
//  SpiritualToastView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct SpiritualToastView: View {
    let toast: ToastMessage

    var body: some View {
        HStack(spacing: 12) {
            // Status circle
            ZStack {
                Circle()
                    .fill(Color(hex: 0xEEFAF3))
                    .frame(width: 20, height: 20)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: 0x7FC4A0))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(toast.prayer.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: 0x5B8C6F))

                Text(toast.message)
                    .font(.system(size: 12).italic())
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 0.5)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .allowsHitTesting(false)
    }
}

// MARK: - Celebration Overlay (5/5 milestone)

struct CelebrationOverlay: View {
    @State private var isVisible = false

    var body: some View {
        ZStack {
            Color(hex: 0xFDFBF7).opacity(0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("🤲")
                    .font(.system(size: 52))
                    .padding(.bottom, 12)

                Text("Alhamdulillah")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: 0x5B8C6F))
                    .padding(.bottom, 4)

                Text("All 5 prayers completed")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: 0x2C2C2C))
                    .padding(.bottom, 20)

                Text("Whoever prays the five daily prayers, Allah will prepare for him light, proof, and salvation on the Day of Resurrection.")
                    .font(.system(size: 13).italic())
                    .foregroundColor(Color(hex: 0xB5B5BA))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 6)

                Text("Musnad Ahmad")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0xB5B5BA))
                    .padding(.bottom, 20)

                // 5 dots
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { _ in
                        Circle()
                            .fill(Color(hex: 0x7FC4A0))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .scaleEffect(isVisible ? 1.0 : 0.9)
            .opacity(isVisible ? 1.0 : 0.0)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                isVisible = true
            }
        }
    }
}
