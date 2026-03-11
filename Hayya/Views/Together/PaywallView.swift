//
//  PaywallView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Binding var isPresented: Bool
    @State private var selectedProduct: HayyaProduct = .annual
    @State private var isPurchasing = false

    private let subscription = SubscriptionService.shared

    // Legal page URLs — required by Apple for subscription paywalls
    private let privacyPolicyURL = URL(string: "https://jafarfh.com/Hayya/privacy-policy.html")!
    private let termsOfServiceURL = URL(string: "https://jafarfh.com/Hayya/terms-of-service.html")!

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            // Paywall card
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: 0xB5B5BA))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Header
                VStack(spacing: 8) {
                    Text("\u{1F932}")  // 🤲
                        .font(.system(size: 40))

                    Text("Hayya Premium")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: 0x2C2C2C))

                    Text("Support each other's prayer journey")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x8E8E93))
                }
                .padding(.bottom, 20)

                // Features
                VStack(alignment: .leading, spacing: 10) {
                    featureRow(icon: "person.2.fill", text: "Prayer Companion — invite someone to pray together")
                    featureRow(icon: "rectangle.3.group.fill", text: "Medium & Large widgets with prayer dashboard")
                    featureRow(icon: "speaker.wave.3.fill", text: "Custom alarm sounds and azan voices")
                    featureRow(icon: "bell.badge.fill", text: "Advanced companion reminders")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // Price options
                VStack(spacing: 8) {
                    ForEach(HayyaProduct.allCases, id: \.rawValue) { product in
                        priceOption(product: product)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Purchase button
                Button {
                    Task {
                        isPurchasing = true
                        // Find the matching StoreKit product
                        if let storeProduct = subscription.products.first(where: { $0.id == selectedProduct.rawValue }) {
                            let success = await subscription.purchase(storeProduct)
                            if success {
                                isPresented = false
                            }
                        }
                        isPurchasing = false
                    }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue with \(selectedProduct.displayName)")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color(hex: 0x5B8C6F))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(isPurchasing)
                .padding(.horizontal, 20)

                // Restore + terms + privacy
                VStack(spacing: 6) {
                    Button("Restore Purchases") {
                        Task { await subscription.restorePurchases() }
                    }
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0x8E8E93))

                    HStack(spacing: 4) {
                        Link("Terms of Service", destination: termsOfServiceURL)
                        Text("\u{00B7}")
                            .foregroundColor(Color(hex: 0xB5B5BA))
                        Link("Privacy Policy", destination: privacyPolicyURL)
                    }
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xB5B5BA))

                    Text("Subscriptions auto-renew unless cancelled 24h before the period ends. Manage in Settings > Apple ID.")
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: 0xB5B5BA))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .background(Color(hex: 0xFDFBF7))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.15), radius: 20)
            .padding(.horizontal, 16)
        }
        .task {
            await subscription.loadProducts()
        }
    }

    // MARK: - Feature Row

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0x5B8C6F))
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: 0x2C2C2C))
                .lineSpacing(2)
        }
    }

    // MARK: - Price Option

    private func priceOption(product: HayyaProduct) -> some View {
        let isSelected = selectedProduct == product

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedProduct = product
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: 0x2C2C2C))

                        if let savings = product.savings {
                            Text(savings)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: 0xD4A843))
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                Text(product.price)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: 0x5B8C6F))
            }
            .padding(14)
            .background(isSelected ? Color(hex: 0xE8F0EB) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: 0x5B8C6F) : Color(hex: 0xEBEBF0), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView(isPresented: .constant(true))
}
