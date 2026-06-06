//
//  CheckInReminderManager.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class CheckInReminderManager: ObservableObject {
    static let reminderIdentifier = "mptinnitus.weekly_checkin_reminder"

    @Published private(set) var preference: CheckInReminderPreference = .defaultDisabled
    @Published private(set) var errorMessage: String?

    private let fileManager: FileManager
    private let fileURL: URL
    private let notificationCenter: UNUserNotificationCenter

    init(
        fileManager: FileManager = .default,
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.fileManager = fileManager
        self.notificationCenter = notificationCenter
        fileURL = Self.makeFileURL(fileManager: fileManager)
        load()
    }

    func load() {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            preference = .defaultDisabled
            errorMessage = nil
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            preference = try decoder.decode(CheckInReminderPreference.self, from: data)
            errorMessage = nil
        } catch {
            preference = .defaultDisabled
            errorMessage = "Could not load check-in reminder settings."

            #if DEBUG
            print("[MPTinnitus][CheckInReminderManager] Load failed: \(error.localizedDescription)")
            #endif
        }
    }

    func setEnabled(_ isEnabled: Bool) async {
        if isEnabled {
            await enableWeeklyReminder()
        } else {
            disableReminder()
        }
    }

    func enableWeeklyReminder() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
            guard granted else {
                errorMessage = "Reminder permission was not granted."
                return
            }

            var nextPreference = preference
            nextPreference.isEnabled = true
            nextPreference.updatedAt = Date()
            scheduleWeeklyReminder(preference: nextPreference)
            try save(nextPreference)
            preference = nextPreference
            errorMessage = nil
        } catch {
            errorMessage = "Could not turn on the check-in reminder."

            #if DEBUG
            print("[MPTinnitus][CheckInReminderManager] Permission failed: \(error.localizedDescription)")
            #endif
        }
    }

    func disableReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
        var nextPreference = preference
        nextPreference.isEnabled = false
        nextPreference.updatedAt = Date()

        do {
            try save(nextPreference)
            preference = nextPreference
            errorMessage = nil
        } catch {
            errorMessage = "Could not turn off the check-in reminder."

            #if DEBUG
            print("[MPTinnitus][CheckInReminderManager] Disable failed: \(error.localizedDescription)")
            #endif
        }
    }

    static func resetReminderPreference(fileManager: FileManager = .default) throws {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
        let url = makeFileURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        try fileManager.removeItem(at: url)
    }

    private func scheduleWeeklyReminder(preference: CheckInReminderPreference) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Tinnitus Check-In"
        content.body = "Time for a quick tinnitus check-in. See what’s changed this week."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = preference.weekday
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

        notificationCenter.add(request) { error in
            #if DEBUG
            if let error {
                print("[MPTinnitus][CheckInReminderManager] Schedule failed: \(error.localizedDescription)")
            }
            #endif
        }
    }

    private func save(_ preference: CheckInReminderPreference) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(preference)
        try data.write(to: fileURL, options: [.atomic])
    }

    private static func makeFileURL(fileManager: FileManager) -> URL {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        return baseURL
            .appendingPathComponent("MPTinnitus", isDirectory: true)
            .appendingPathComponent("checkin_reminder_preference_v1.json")
    }
}
