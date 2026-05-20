//
//  ExerciseEntryRow.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ExerciseEntryRow: View {
    let entry: ExerciseEntryRecord
    let definition: ExerciseDefinition
    let editAction: () -> Void
    let archiveAction: () -> Void

    private var payload: ExerciseEntryPayload? {
        ExerciseEntryStore.decodePayload(entry)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.entryTitle.isEmpty ? entry.exerciseTitle : entry.entryTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer()

                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(MPTTheme.secondaryText)
            }

            if let payload {
                entrySummary(payload)
            } else {
                Text("Saved payload could not be decoded.")
                    .font(.subheadline)
                    .foregroundStyle(MPTTheme.secondaryText)
            }

            HStack(spacing: MPTTheme.Spacing.small) {
                Button {
                    editAction()
                } label: {
                    Label("Open / Edit", systemImage: "pencil")
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

    private func entrySummary(_ payload: ExerciseEntryPayload) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(summaryFields(payload), id: \.label) { item in
                HStack(alignment: .firstTextBaseline, spacing: MPTTheme.Spacing.small) {
                    Text(item.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MPTTheme.secondaryText)
                        .frame(width: 96, alignment: .leading)

                    Text(item.value)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
            }
        }
    }

    private func summaryFields(_ payload: ExerciseEntryPayload) -> [(label: String, value: String)] {
        var rows: [(String, String)] = []

        for field in definition.fields where field.type != .staticInfo {
            let value = payload.computedValues[field.fieldId]
                ?? payload.fieldValues[field.fieldId]
                ?? (payload.checkboxValues[field.fieldId] == true ? "Checked" : "")
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

            if !trimmed.isEmpty {
                rows.append((field.label, trimmed))
            }

            if rows.count == 3 {
                break
            }
        }

        if rows.isEmpty {
            rows.append(("Entry", "Saved"))
        }

        return rows
    }
}
