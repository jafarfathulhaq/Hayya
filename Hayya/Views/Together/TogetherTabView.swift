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
    @State private var reminderSent = false
    @State private var showPaywall = false

    private let cloudKit = CloudKitService.shared

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

        var relationship: RelationshipType {
            switch self {
            case .spouse: return .spouse
            case .family: return .family
            case .friend: return .friend
            }
        }
    }

    var body: some View {
        ZStack {
            Color(hex: 0xFDFBF7).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header

                    if cloudKit.isConnected {
                        // Connected state
                        connectedContent
                    } else {
                        // Invite state (Phase 1 style)
                        inviteContent
                    }
                }
                .padding(.bottom, 100)
            }

            // Paywall overlay
            if showPaywall {
                PaywallView(isPresented: $showPaywall)
            }
        }
        .task {
            await cloudKit.fetchCurrentUserID()
            if cloudKit.isConnected {
                await cloudKit.fetchPartnerStatus()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Together")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(hex: 0x2C2C2C))
            Text(cloudKit.isConnected
                ? "Praying alongside your companion."
                : "Share your prayer journey with someone you trust.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xB5B5BA))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 16)
    }

    // MARK: - Connected Content

    private var connectedContent: some View {
        VStack(spacing: 14) {
            // Partner profile card
            partnerProfileCard

            // Prayed Together moments
            prayedTogetherSection

            // Reminder button (current active prayer only)
            reminderButton

            // Today's prayer dots comparison
            todayDotComparison

            privacyNote
        }
    }

    // MARK: - Partner Profile Card

    private var partnerProfileCard: some View {
        VStack(spacing: 12) {
            // Avatar pair
            HStack(spacing: 16) {
                // You
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0xE8F0EB), Color(hex: 0xFFF6E3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        Text("\u{1F60A}")  // 😊
                            .font(.system(size: 24))
                    }
                    Text("You")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }

                // Heart
                Text("\u{2764}\u{FE0F}")  // ❤️
                    .font(.system(size: 20))

                // Partner
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0xFFF6E3), Color(hex: 0xE8F0EB)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        Text("\u{1F60A}")  // 😊
                            .font(.system(size: 24))
                    }
                    Text("Partner")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }
            }

            if let companion = cloudKit.companion {
                let dateFormatter: DateFormatter = {
                    let f = DateFormatter()
                    f.dateFormat = "MMM d, yyyy"
                    return f
                }()
                Text("Praying together since \(dateFormatter.string(from: companion.createdAt))")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x8E8E93))
            }

            // Partner's 5 prayer dots
            partnerPrayerDots
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Partner Prayer Dots

    private var partnerPrayerDots: some View {
        let prayers = ["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"]

        return HStack(spacing: 0) {
            ForEach(prayers, id: \.self) { prayer in
                let partnerStatus = cloudKit.partnerPrayerStatus[prayer]
                let isDone = partnerStatus?.status == "done" || partnerStatus?.status == "qadha"

                VStack(spacing: 3) {
                    ZStack {
                        if isDone {
                            Circle()
                                .fill(Color(hex: 0xEEFAF3))
                                .frame(width: 20, height: 20)
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Color(hex: 0x7FC4A0))
                        } else {
                            Circle()
                                .stroke(Color(hex: 0xD1D1D6), lineWidth: 1)
                                .frame(width: 20, height: 20)
                            Circle()
                                .fill(Color(hex: 0xD1D1D6))
                                .frame(width: 5, height: 5)
                        }
                    }

                    Text(String(prayer.prefix(1)))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Prayed Together Section

    private var prayedTogetherSection: some View {
        let prayedTogetherPrayers = ["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"]
            .filter { cloudKit.checkPrayedTogether(prayer: $0) }

        return Group {
            if !prayedTogetherPrayers.isEmpty {
                VStack(spacing: 8) {
                    Text("\u{1F932}")  // 🤲
                        .font(.system(size: 32))

                    Text("Prayed Together")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: 0xD4A843))

                    ForEach(prayedTogetherPrayers, id: \.self) { prayer in
                        Text(prayer)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: 0x8E8E93))
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xFFF6E3), Color(hex: 0xFDFBF7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: 0xD4A843).opacity(0.3), lineWidth: 1.5))
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Reminder Button

    private var reminderButton: some View {
        Group {
            if cloudKit.isConnected {
                Button {
                    Task {
                        let currentPrayer = "Dzuhur" // TODO: Get actual current active prayer
                        let sent = await cloudKit.sendReminder(prayer: currentPrayer)
                        if sent {
                            withAnimation { reminderSent = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation { reminderSent = false }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: reminderSent ? "checkmark.circle.fill" : "bell.fill")
                            .font(.system(size: 14))
                        Text(reminderSent ? "Reminder sent" : "Send gentle reminder")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(reminderSent ? Color(hex: 0x7FC4A0) : Color(hex: 0x5B8C6F))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(reminderSent)
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Today Dot Comparison

    private var todayDotComparison: some View {
        let prayers = ["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"]
        let defaults = UserDefaults(suiteName: "group.com.jafarfh.hayya.shared") ?? UserDefaults.standard
        let myStatus = defaults.dictionary(forKey: "widget_prayerStatus") as? [String: String] ?? [:]

        return VStack(spacing: 8) {
            Text("Today's Prayers")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: 0x2C2C2C))

            // You row
            HStack(spacing: 0) {
                Text("You")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .frame(width: 40, alignment: .leading)

                ForEach(prayers, id: \.self) { prayer in
                    let done = myStatus[prayer] == "done" || myStatus[prayer] == "qadha"
                    Circle()
                        .fill(done ? Color(hex: 0x7FC4A0) : Color(hex: 0xD1D1D6).opacity(0.5))
                        .frame(width: 14, height: 14)
                        .frame(maxWidth: .infinity)
                }
            }

            // Partner row
            HStack(spacing: 0) {
                Text("Partner")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: 0x8E8E93))
                    .frame(width: 40, alignment: .leading)

                ForEach(prayers, id: \.self) { prayer in
                    let partnerStatus = cloudKit.partnerPrayerStatus[prayer]
                    let done = partnerStatus?.status == "done" || partnerStatus?.status == "qadha"
                    Circle()
                        .fill(done ? Color(hex: 0x9DC4AD) : Color(hex: 0xD1D1D6).opacity(0.5))
                        .frame(width: 14, height: 14)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: 0xEBEBF0), lineWidth: 1))
        .padding(.horizontal, 16)
    }

    // MARK: - Invite Content (Empty State)

    private var inviteContent: some View {
        VStack(spacing: 0) {
            hadithCard
            prayedTogetherPreview
            invitationSection
            socialProofCard
            privacyNote
        }
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
                Button {
                    // Check premium status
                    if SubscriptionService.shared.isPremium {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedInviteType = .spouse
                        }
                    } else {
                        showPaywall = true
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

                whatsAppPreview
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    // MARK: - WhatsApp Preview

    private var whatsAppPreview: some View {
        VStack(spacing: 10) {
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

            // Send button
            Button {
                shareInviteLink()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 12))
                    Text("Share invite link")
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

    // MARK: - Share Invite Link

    private func shareInviteLink() {
        Task {
            guard let selectedType = selectedInviteType else { return }
            if let token = await cloudKit.createInvite(relationshipType: selectedType.relationship) {
                let url = "https://hayya.app/invite/\(token)"
                let message = "Assalamu'alaikum! I'm using Hayya to help me keep up with my prayers. Would you like to join me as my prayer companion? \u{1F932}\n\n\(url)"

                let activityVC = UIActivityViewController(
                    activityItems: [message],
                    applicationActivities: nil
                )

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
            }
        }
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
