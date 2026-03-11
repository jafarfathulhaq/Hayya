//
//  SubscriptionService.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import StoreKit

// MARK: - Product IDs

enum HayyaProduct: String, CaseIterable {
    case monthly = "com.jafarfh.Hayya.premium.monthly"
    case annual = "com.jafarfh.Hayya.premium.annual"
    case lifetime = "com.jafarfh.Hayya.premium.lifetime"

    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        case .lifetime: return "Lifetime"
        }
    }

    var price: String {
        switch self {
        case .monthly: return "$1.99/mo"
        case .annual: return "$14.99/yr"
        case .lifetime: return "$39.99"
        }
    }

    var savings: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "Save 37%"
        case .lifetime: return "Best value"
        }
    }
}

// MARK: - Subscription Service

@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    var isPremium: Bool = false
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading: Bool = false
    var errorMessage: String?

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task { await checkCurrentEntitlements() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        do {
            let productIDs = HayyaProduct.allCases.map(\.rawValue)
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        } catch {
            errorMessage = "Could not load products: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                isPremium = true
                await transaction.finish()
                isLoading = false
                return true

            case .userCancelled:
                isLoading = false
                return false

            case .pending:
                isLoading = false
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await checkCurrentEntitlements()
        } catch {
            errorMessage = "Could not restore purchases: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Check Entitlements

    func checkCurrentEntitlements() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            purchased.insert(transaction.productID)
        }

        purchasedProductIDs = purchased
        isPremium = !purchased.isEmpty
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                guard let transaction = try? self.checkVerified(result) else { continue }

                self.purchasedProductIDs.insert(transaction.productID)
                self.isPremium = true
                await transaction.finish()
            }
        }
    }

    // MARK: - Verify

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Premium Features

    /// Check if a specific feature is available.
    var canUseCompanion: Bool { isPremium }
    var canUseMediumWidget: Bool { isPremium }
    var canUseLargeWidget: Bool { isPremium }
    var canUseCustomSounds: Bool { isPremium }
}

// MARK: - Store Error

enum StoreError: Error, LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed."
        }
    }
}
