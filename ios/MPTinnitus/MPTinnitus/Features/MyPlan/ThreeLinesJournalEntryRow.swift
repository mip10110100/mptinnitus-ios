//
//  ThreeLinesJournalEntryRow.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ThreeLinesJournalEntryRow: View {
    let entry: ThreeLinesJournalEntryRecord
    let editAction: () -> Void
    let archiveAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.entryDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("Updated \(entry.updatedAt.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(MPTTheme.secondaryText)
            }

            journalLine("ST", text: entry.soundTherapyText, checkOnly: entry.soundTherapyCheckOnly)
            journalLine("E", text: entry.emotionalRegulationText, checkOnly: entry.emotionalRegulationCheckOnly)
            journalLine("M", text: entry.mindfulnessText, checkOnly: entry.mindfulnessCheckOnly)

            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.subheadline)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: MPTTheme.Spacing.small) {
                Button {
                    editAction()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    archiveAction()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func journalLine(_ label: String, text: String, checkOnly: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: MPTTheme.Spacing.small) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MPTTheme.accentColor)
                .frame(width: 24, alignment: .leading)

            Text(displayText(text: text, checkOnly: checkOnly))
                .font(.subheadline)
                .foregroundStyle(text.isEmpty && !checkOnly ? MPTTheme.secondaryText : .primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func displayText(text: String, checkOnly: Bool) -> String {
        if checkOnly && text.isEmpty {
            return "Checkmark"
        }

        if text.isEmpty {
            return "Blank"
        }

        if checkOnly {
            return "Checkmark - \(text)"
        }

        return text
    }
}
