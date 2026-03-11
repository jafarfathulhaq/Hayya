//
//  CloudKitService.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import Foundation
import CloudKit

// MARK: - CKRecord Type Names

enum CloudRecordType {
    static let sharedPrayerStatus = "SharedPrayerStatus"
    static let companionConnection = "CompanionConnection"
    static let reminderEvent = "ReminderEvent"
}

// MARK: - Connection Status

enum CompanionStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case disconnected = "disconnected"
}

enum RelationshipType: String, Codable {
    case spouse = "spouse"
    case family = "family"
    case friend = "friend"
}

// MARK: - Cloud Models

struct SharedPrayerStatusRecord {
    let userID: String
    let date: Date
    let prayerName: String
    let status: String          // "done", "qadha", "missed"
    let checkInTime: Date?
    let isHidden: Bool          // User can hide individual prayers

    var ckRecord: CKRecord {
        let record = CKRecord(recordType: CloudRecordType.sharedPrayerStatus)
        record["userID"] = userID
        record["date"] = date
        record["prayerName"] = prayerName
        record["status"] = status
        record["checkInTime"] = checkInTime
        record["isHidden"] = isHidden ? 1 : 0
        return record
    }

    init(from record: CKRecord) {
        self.userID = record["userID"] as? String ?? ""
        self.date = record["date"] as? Date ?? Date()
        self.prayerName = record["prayerName"] as? String ?? ""
        self.status = record["status"] as? String ?? ""
        self.checkInTime = record["checkInTime"] as? Date
        self.isHidden = (record["isHidden"] as? Int ?? 0) == 1
    }

    init(userID: String, date: Date, prayerName: String, status: String, checkInTime: Date?, isHidden: Bool = false) {
        self.userID = userID
        self.date = date
        self.prayerName = prayerName
        self.status = status
        self.checkInTime = checkInTime
        self.isHidden = isHidden
    }
}

struct CompanionConnectionRecord {
    let fromUser: String
    let toUser: String
    let relationshipType: RelationshipType
    let status: CompanionStatus
    let createdAt: Date
    let connectionToken: String      // Deep link token for invite

    var ckRecord: CKRecord {
        let record = CKRecord(recordType: CloudRecordType.companionConnection)
        record["fromUser"] = fromUser
        record["toUser"] = toUser
        record["relationshipType"] = relationshipType.rawValue
        record["status"] = status.rawValue
        record["createdAt"] = createdAt
        record["connectionToken"] = connectionToken
        return record
    }

    init(from record: CKRecord) {
        self.fromUser = record["fromUser"] as? String ?? ""
        self.toUser = record["toUser"] as? String ?? ""
        self.relationshipType = RelationshipType(rawValue: record["relationshipType"] as? String ?? "") ?? .friend
        self.status = CompanionStatus(rawValue: record["status"] as? String ?? "") ?? .pending
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.connectionToken = record["connectionToken"] as? String ?? ""
    }

    init(fromUser: String, toUser: String, relationshipType: RelationshipType, status: CompanionStatus = .pending, connectionToken: String) {
        self.fromUser = fromUser
        self.toUser = toUser
        self.relationshipType = relationshipType
        self.status = status
        self.createdAt = Date()
        self.connectionToken = connectionToken
    }
}

struct ReminderEventRecord {
    let fromUser: String
    let toUser: String
    let prayerName: String
    let date: Date
    let sentAt: Date

    var ckRecord: CKRecord {
        let record = CKRecord(recordType: CloudRecordType.reminderEvent)
        record["fromUser"] = fromUser
        record["toUser"] = toUser
        record["prayerName"] = prayerName
        record["date"] = date
        record["sentAt"] = sentAt
        return record
    }

    init(from record: CKRecord) {
        self.fromUser = record["fromUser"] as? String ?? ""
        self.toUser = record["toUser"] as? String ?? ""
        self.prayerName = record["prayerName"] as? String ?? ""
        self.date = record["date"] as? Date ?? Date()
        self.sentAt = record["sentAt"] as? Date ?? Date()
    }

    init(fromUser: String, toUser: String, prayerName: String) {
        self.fromUser = fromUser
        self.toUser = toUser
        self.prayerName = prayerName
        self.date = Calendar.current.startOfDay(for: Date())
        self.sentAt = Date()
    }
}

// MARK: - Offline Queue Entry

struct OfflineQueueEntry: Codable {
    let id: UUID
    let type: String            // "checkIn", "reminder", "connect"
    let payload: [String: String]
    let createdAt: Date
}

// MARK: - CloudKit Service

@Observable
final class CloudKitService {
    static let shared = CloudKitService()

    var currentUserID: String?
    var companion: CompanionConnectionRecord?
    var partnerPrayerStatus: [String: SharedPrayerStatusRecord] = [:]  // prayerName → status
    var isConnected: Bool { companion?.status == .accepted }
    var isSyncing = false
    var lastSyncError: String?

    private let container = CKContainer(identifier: "iCloud.com.jafarfh.Hayya")
    private let privateDB: CKDatabase
    private let sharedDB: CKDatabase

    /// Offline queue for resilience
    private var offlineQueue: [OfflineQueueEntry] = []
    private let offlineQueueKey = "cloudkit_offline_queue"

    private init() {
        privateDB = container.privateCloudDatabase
        sharedDB = container.sharedCloudDatabase
        loadOfflineQueue()
    }

    // MARK: - User Identity

    func fetchCurrentUserID() async {
        do {
            let userID = try await container.userRecordID()
            self.currentUserID = userID.recordName
        } catch {
            lastSyncError = "Could not fetch user ID: \(error.localizedDescription)"
        }
    }

    // MARK: - Share Prayer Status

    /// Sync a prayer check-in to CloudKit for companion visibility.
    /// Only shares today's data — never historical records.
    func sharePrayerStatus(prayer: String, status: String, checkInTime: Date?) async {
        guard let userID = currentUserID else {
            // Queue offline
            queueOffline(type: "checkIn", payload: [
                "prayer": prayer,
                "status": status,
                "checkInTime": checkInTime?.timeIntervalSince1970.description ?? ""
            ])
            return
        }

        let todayStart = Calendar.current.startOfDay(for: Date())
        let record = SharedPrayerStatusRecord(
            userID: userID,
            date: todayStart,
            prayerName: prayer,
            status: status,
            checkInTime: checkInTime
        )

        do {
            isSyncing = true
            try await privateDB.save(record.ckRecord)
            isSyncing = false
        } catch {
            isSyncing = false
            lastSyncError = error.localizedDescription
            // Queue for retry
            queueOffline(type: "checkIn", payload: [
                "prayer": prayer,
                "status": status,
                "checkInTime": checkInTime?.timeIntervalSince1970.description ?? ""
            ])
        }
    }

    // MARK: - Fetch Partner Status

    /// Fetch companion's prayer status for today only.
    /// Returns status for all 5 prayers (if shared).
    func fetchPartnerStatus() async {
        guard let companion = companion,
              companion.status == .accepted else { return }

        let partnerID = companion.fromUser == currentUserID ? companion.toUser : companion.fromUser
        let todayStart = Calendar.current.startOfDay(for: Date())

        let predicate = NSPredicate(format: "userID == %@ AND date >= %@", partnerID, todayStart as NSDate)
        let query = CKQuery(recordType: CloudRecordType.sharedPrayerStatus, predicate: predicate)

        do {
            isSyncing = true
            let (results, _) = try await privateDB.records(matching: query)
            var statusMap: [String: SharedPrayerStatusRecord] = [:]
            for (_, result) in results {
                if let record = try? result.get() {
                    let status = SharedPrayerStatusRecord(from: record)
                    if !status.isHidden {
                        statusMap[status.prayerName] = status
                    }
                }
            }
            self.partnerPrayerStatus = statusMap
            isSyncing = false
        } catch {
            isSyncing = false
            lastSyncError = error.localizedDescription
        }
    }

    // MARK: - Connection Management

    /// Generate a connection invite token and create a pending connection record.
    func createInvite(relationshipType: RelationshipType) async -> String? {
        guard let userID = currentUserID else { return nil }

        let token = UUID().uuidString
        let connection = CompanionConnectionRecord(
            fromUser: userID,
            toUser: "",
            relationshipType: relationshipType,
            connectionToken: token
        )

        do {
            try await privateDB.save(connection.ckRecord)
            return token
        } catch {
            lastSyncError = error.localizedDescription
            return nil
        }
    }

    /// Accept a connection invite by token.
    func acceptInvite(token: String) async -> Bool {
        guard let userID = currentUserID else { return false }

        let predicate = NSPredicate(format: "connectionToken == %@", token)
        let query = CKQuery(recordType: CloudRecordType.companionConnection, predicate: predicate)

        do {
            let (results, _) = try await privateDB.records(matching: query)
            guard let (_, result) = results.first,
                  let record = try? result.get() else { return false }

            record["toUser"] = userID
            record["status"] = CompanionStatus.accepted.rawValue

            try await privateDB.save(record)
            self.companion = CompanionConnectionRecord(from: record)
            return true
        } catch {
            lastSyncError = error.localizedDescription
            return false
        }
    }

    /// Disconnect from companion.
    func disconnect() async {
        // Mark connection as disconnected
        companion = nil
        partnerPrayerStatus = [:]
    }

    // MARK: - Reminders

    /// Send a reminder to companion for the current active prayer.
    /// System-generated copy only — no custom text allowed.
    func sendReminder(prayer: String) async -> Bool {
        guard let userID = currentUserID,
              let companion = companion,
              companion.status == .accepted else { return false }

        let partnerID = companion.fromUser == userID ? companion.toUser : companion.fromUser
        let reminder = ReminderEventRecord(
            fromUser: userID,
            toUser: partnerID,
            prayerName: prayer
        )

        do {
            try await privateDB.save(reminder.ckRecord)
            return true
        } catch {
            lastSyncError = error.localizedDescription
            return false
        }
    }

    /// Check if both users checked in within 10 minutes for "Prayed Together" detection.
    func checkPrayedTogether(prayer: String) -> Bool {
        guard let partnerStatus = partnerPrayerStatus[prayer],
              let partnerTime = partnerStatus.checkInTime else { return false }

        // Check if user also checked in for this prayer
        let defaults = UserDefaults(suiteName: "group.com.jafarfh.hayya.shared") ?? UserDefaults.standard
        guard let statusDict = defaults.dictionary(forKey: "widget_prayerStatus") as? [String: String],
              statusDict[prayer] == "done" || statusDict[prayer] == "qadha" else { return false }

        // For simplicity, if partner checked in within last 10 minutes of now, count it
        let tenMinutes: TimeInterval = 600
        return abs(partnerTime.timeIntervalSinceNow) < tenMinutes
    }

    // MARK: - Subscriptions

    /// Subscribe to partner status changes for real-time updates.
    func subscribeToPartnerUpdates() async {
        guard companion?.status == .accepted else { return }

        let subscription = CKQuerySubscription(
            recordType: CloudRecordType.sharedPrayerStatus,
            predicate: NSPredicate(value: true),
            subscriptionID: "partner-status-updates",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )

        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true  // Silent push
        subscription.notificationInfo = info

        do {
            try await privateDB.save(subscription)
        } catch {
            lastSyncError = error.localizedDescription
        }
    }

    // MARK: - Offline Queue

    /// Queue an operation for retry when connectivity returns.
    private func queueOffline(type: String, payload: [String: String]) {
        let entry = OfflineQueueEntry(
            id: UUID(),
            type: type,
            payload: payload,
            createdAt: Date()
        )
        offlineQueue.append(entry)
        saveOfflineQueue()
    }

    /// Process all queued operations.
    func processOfflineQueue() async {
        let queue = offlineQueue
        offlineQueue = []
        saveOfflineQueue()

        for entry in queue {
            switch entry.type {
            case "checkIn":
                let prayer = entry.payload["prayer"] ?? ""
                let status = entry.payload["status"] ?? ""
                let timeStr = entry.payload["checkInTime"] ?? ""
                let checkInTime = Double(timeStr).map { Date(timeIntervalSince1970: $0) }
                await sharePrayerStatus(prayer: prayer, status: status, checkInTime: checkInTime)
            default:
                break
            }
        }
    }

    private func loadOfflineQueue() {
        guard let data = UserDefaults.standard.data(forKey: offlineQueueKey),
              let queue = try? JSONDecoder().decode([OfflineQueueEntry].self, from: data) else { return }
        offlineQueue = queue
    }

    private func saveOfflineQueue() {
        guard let data = try? JSONEncoder().encode(offlineQueue) else { return }
        UserDefaults.standard.set(data, forKey: offlineQueueKey)
    }
}
