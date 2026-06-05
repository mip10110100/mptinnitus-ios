//
//  ThreeLinesJournalReminderManager.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class ThreeLinesJournalReminderManager: ObservableObject {
    static let reminderIdentifier = "three_lines_journal_daily_reminder"

    @Published private(set) var preference: ThreeLinesJournalReminderPreference = .defaultDisabled
    @Published private(set) var errorMessage: String?

    private let fileManager: FileManager
    private let notificationCenter: UNUserNotificationCenter

    init(
        fileManager: FileManager = .default,
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.fileManager = fileManager
        self.notificationCenter = notificationCenter
        load()
    }

    func load() {
        preference = ThreeLinesJournalReminderStore.load(fileManager: fileManager)
        errorMessage = nil
    }

    func refreshPermissionStatus() async {
        let status = (await notificationCenter.notificationSettings()).authorizationStatus
        var nextPreference = preference
        nextPreference.permissionLastKnownStatus = status.storageValue
        preference = nextPreference

        if fileManager.fileExists(atPath: ThreeLinesJournalReminderStore.fileURL(fileManager: fileManager).path) {
            try? ThreeLinesJournalReminderStore.save(nextPreference, fileManager: fileManager)
        }
    }

    func setEnabled(_ isEnabled: Bool) async {
        if isEnabled {
            await enableReminder()
        } else {
            disableReminder()
        }
    }

    func setReminderTime(_ date: Date) async {
        var nextPreference = preference
        nextPreference.updateTime(from: date)

        do {
            if nextPreference.isEnabled {
                let status = (await notificationCenter.notificationSettings()).authorizationStatus
                guard status.allowsLocalReminder else {
                    nextPreference.isEnabled = false
                    nextPreference.permissionLastKnownStatus = status.storageValue
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
                    try ThreeLinesJournalReminderStore.save(nextPreference, fileManager: fileManager)
                    preference = nextPreference
                    errorMessage = nil
                    return
                }

                try await scheduleDailyReminder(preference: nextPreference)
                nextPreference.permissionLastKnownStatus = status.storageValue
            }

            try ThreeLinesJournalReminderStore.save(nextPreference, fileManager: fileManager)
            preference = nextPreference
            errorMessage = nil
        } catch {
            errorMessage = "Could not update the journal reminder time."

            #if DEBUG
            print("[MPTinnitus][ThreeLinesJournalReminder] Time update failed: \(error.localizedDescription)")
            #endif
        }
    }

    static func resetReminderPreference(fileManager: FileManager = .default) throws {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
        try ThreeLinesJournalReminderStore.deletePreference(fileManager: fileManager)
    }

    private func enableReminder() async {
        do {
            let currentStatus = (await notificationCenter.notificationSettings()).authorizationStatus
            let status: UNAuthorizationStatus

            if currentStatus == .notDetermined {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
                status = granted
                    ? (await notificationCenter.notificationSettings()).authorizationStatus
                    : .denied
            } else {
                status = currentStatus
            }

            var nextPreference = preference
            nextPreference.permissionLastKnownStatus = status.storageValue
            nextPreference.updatedAt = Date()

            guard status.allowsLocalReminder else {
                nextPreference.isEnabled = false
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
                try ThreeLinesJournalReminderStore.save(nextPreference, fileManager: fileManager)
                preference = nextPreference
                errorMessage = nil
                return
            }

            nextPreference.isEnabled = true
            try await scheduleDailyReminder(preference: nextPreference)
            try ThreeLinesJournalReminderStore.save(nextPreference, fileManager: fileManager)
            preference = nextPreference
            errorMessage = nil
        } catch {
            errorMessage = "Could not turn on the journal reminder."

            #if DEBUG
            print("[MPTinnitus][ThreeLinesJournalReminder] Enable failed: \(error.localizedDescription)")
            #endif
        }
    }

    private func disableReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
        var nextPreference = preference
        nextPreference.isEnabled = false
        nextPreference.updatedAt = Date()

        do {
            try ThreeLinesJournalReminderStore.save(nextPreference, fileManager: fileManager)
            preference = nextPreference
            errorMessage = nil
        } catch {
            errorMessage = "Could not turn off the journal reminder."

            #if DEBUG
            print("[MPTinnitus][ThreeLinesJournalReminder] Disable failed: \(error.localizedDescription)")
            #endif
        }
    }

    private func scheduleDailyReminder(
        preference: ThreeLinesJournalReminderPreference
    ) async throws {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Three Lines Journal"
        content.body = "Take a minute for Three Lines Journal."

        var dateComponents = DateComponents()
        dateComponents.hour = preference.hour
        dateComponents.minute = preference.minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: Self.reminderIdentifier,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }
}

private extension UNAuthorizationStatus {
    var storageValue: String {
        switch self {
        case .notDetermined:
            "not_determined"
        case .denied:
            "denied"
        case .authorized:
            "authorized"
        case .provisional:
            "provisional"
        case .ephemeral:
            "ephemeral"
        @unknown default:
            "unknown"
        }
    }

    var allowsLocalReminder: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            true
        case .notDetermined, .denied:
            false
        @unknown default:
            false
        }
    }
}
