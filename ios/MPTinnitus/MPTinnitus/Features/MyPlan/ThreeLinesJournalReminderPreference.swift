//
//  ThreeLinesJournalReminderPreference.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Foundation

struct ThreeLinesJournalReminderPreference: Codable, Equatable {
    let schemaVersion: String
    var isEnabled: Bool
    var hour: Int
    var minute: Int
    var updatedAt: Date
    var permissionLastKnownStatus: String?

    static let defaultDisabled = ThreeLinesJournalReminderPreference(
        schemaVersion: "three_lines_journal_reminder_v1",
        isEnabled: false,
        hour: 20,
        minute: 0,
        updatedAt: Date(),
        permissionLastKnownStatus: nil
    )

    var reminderDate: Date {
        var components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: reminderDate)
    }

    var isPermissionDenied: Bool {
        permissionLastKnownStatus == "denied"
    }

    mutating func updateTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        hour = components.hour ?? 20
        minute = components.minute ?? 0
        updatedAt = Date()
    }
}
