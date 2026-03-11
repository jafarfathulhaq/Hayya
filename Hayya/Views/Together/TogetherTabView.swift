//
//  TogetherTabView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI

struct TogetherTabView: View {
    @State private var selectedInviteType: InviteType?
    @State private var showWhatsAppPreview = false

    enum InviteType: String, CaseIterable, Identifiable {
        case spouse = "My spouse"
        case family = "Family"
        case friend = "Friend"

        var id: String { rawValue }

        var emoji: String {
            switch self {
            case .spouse: return "\u{1F491}"  // 💑
            case .family: return "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"  // 👨‍👩‍👧
            case .friend: return "\u{1F91D}"  // 🤝
            }
        }
    }

    var body: some View {
        ZStack {
            Color(hex: 0xFDFBF7).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    hadithCard
                    prayedTogetherPreview
                    invitationSection
                    socialProofCard
                    privacyNote
                }
                .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Together")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(hex: 0x2C2C2C))
            Text("Share your prayer journey with someone you trust.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 16)
    }

    // MARK: - Hadith Card

    private var hadithCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The prayer in congregation is twenty-seven times better than the prayer offered alone.")
                .font(.system(size: 14).italic())
                .foregroundColor(Color(hex: 0x5B8C6F))
                .lineSpacing(4)

            Text("Sahih Bukhari & Muslim")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: 0xB5B5BA))

            Text("Invite someone when you're ready")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x5B8C6F))
                .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xE8F0EB))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    // MARK: - Prayed Together Preview

    private var prayedTogetherPreview: some View {
        VStack(spacing: 12) {
            Text("\u{1F932}")  // 🤲
                .font(.system(size: 36))
                .opacity(0.4)

            Text("Prayed Together")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: 0xD4A843).opacity(0.5))

            Text("Maghrib")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0xB5B5BA))

            // Avatar pair
            HStack(spacing: 0) {
                // You
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xE8F0EB), Color(hex: 0xFFF6E3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    Text("\u{1F60A}")  // 😊
                        .font(.system(size: 16))
                }

                Text("\u{2764}\u{FE0F}")  // ❤️
                    .font(.system(size: 16))
                    .padding(.horizontal, 8)

                // Partner placeholder
                ZStack {
                    Circle()
                        .stroke(Color(hex: 0xEBEBF0), lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                    Text("?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
            }

            Text("You & ...")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
    }

    // MARK: - Invitation Section

    private var invitationSection: some View {
        VStack(spacing: 12) {
            Text("Share this moment with someone you love.")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: 0x2C2C2C))
                .multilineTextAlignment(.center)

            Text("Invite someone you trust to share your prayer journey with you.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0x8E8E93))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if selectedInviteType == nil {
                // Invite button
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        // Show invite options — just reveal them inline
                        selectedInviteType = .spouse
                    }
                } label: {
                    Text("Invite someone")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(hex: 0x5B8C6F))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }

            if selectedInviteType != nil {
                // Who to invite
                VStack(spacing: 8) {
                    Text("Who would you like to invite?")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: 0x2C2C2C))

                    HStack(spacing: 8) {
                        ForEach(InviteType.allCases) { type in
                            let isSelected = selectedInviteType == type
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedInviteType = type
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(type.emoji)
                                        .font(.system(size: 20))
                                    Text(type.rawValue)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(isSelected ? Color(hex: 0x5B8C6F) : Color(hex: 0x8E8E93))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isSelected ? Color(hex: 0xE8F0EB) : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(isSelected ? Color(hex: 0x5B8C6F) : Color(hex: 0xEBEBF0), lineWidth: isSelected ? 2 : 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // WhatsApp preview
                whatsAppPreview
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - WhatsApp Preview

    private var whatsAppPreview: some View {
        VStack(spacing: 10) {
            // Message bubble
            VStack(alignment: .leading, spacing: 6) {
                Text("Assalamu'alaikum! I'm using Hayya to help me keep up with my prayers. Would you like to join me as my prayer companion? We can support each other's prayer journey. \u{1F932}")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: 0x2C2C2C))
                    .lineSpacing(3)

                Text("Download Hayya: hayya.app/invite")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x5B8C6F))
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))

            // Send button (Phase 2 - disabled for now)
            Button {
                // Phase 2: will open WhatsApp share sheet
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 12))
                    Text("Send via WhatsApp")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: 0x25D366))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color(hex: 0xF0FFF0))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: 0x25D366).opacity(0.3), lineWidth: 1.5)
        )
        .padding(.top, 4)
    }

    // MARK: - Social Proof

    private var socialProofCard: some View {
        HStack(spacing: 8) {
            Text("\u{1F932}")  // 🤲
                .font(.system(size: 14))
            Text("Couples who pray together on Hayya check in more consistently than solo users.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0x5B8C6F))
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xE8F0EB))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    // MARK: - Privacy Note

    private var privacyNote: some View {
        VStack(spacing: 4) {
            Text("Only today's status is shared. No historical data.")
                .font(.system(size: 10))
                .foregroundColor(Color(hex: 0xB5B5BA))
            Text("You can pause sharing or disconnect anytime in Settings.")
                .font(.system(size: 10))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
    }
}

#Preview {
    TogetherTabView()
}
