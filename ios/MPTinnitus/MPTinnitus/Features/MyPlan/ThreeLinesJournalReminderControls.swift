//
//  ThreeLinesJournalReminderControls.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import SwiftUI

struct ThreeLinesJournalReminderControls: View {
    @ObservedObject var manager: ThreeLinesJournalReminderManager
    @State private var isUpdating = false

    private var statusText: String {
        if manager.preference.isPermissionDenied {
            return "Notifications are not allowed. You can update this in iOS Settings."
        }

        if manager.preference.isEnabled {
            return "Reminder set for \(manager.preference.formattedTime)."
        }

        return "Reminders are off."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                Text("Daily reminder")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Get a daily reminder to write three quick lines. You can turn this off anytime.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Toggle(
                isOn: Binding(
                    get: { manager.preference.isEnabled },
                    set: { newValue in
                        updateEnabled(newValue)
                    }
                )
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily reminder")
                        .font(.subheadline.weight(.semibold))

                    Text("Would you like a daily reminder for Three Lines Journal? This can help you pause for a short reflection. You can turn reminders off anytime.")
                        .font(.caption)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .toggleStyle(.switch)
            .disabled(isUpdating)

            if manager.preference.isEnabled {
                DatePicker(
                    "Reminder time",
                    selection: Binding(
                        get: { manager.preference.reminderDate },
                        set: { newDate in
                            updateTime(newDate)
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
            }

            Label(statusText, systemImage: manager.preference.isEnabled ? "bell" : "bell.slash")
                .font(.footnote)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            if isUpdating {
                Label("Updating journal reminder…", systemImage: "clock")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
            }

            if let errorMessage = manager.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task {
            manager.load()
            await manager.refreshPermissionStatus()
        }
    }

    private func updateEnabled(_ isEnabled: Bool) {
        isUpdating = true
        Task {
            await manager.setEnabled(isEnabled)
            isUpdating = false
        }
    }

    private func updateTime(_ date: Date) {
        isUpdating = true
        Task {
            await manager.setReminderTime(date)
            isUpdating = false
        }
    }
}
