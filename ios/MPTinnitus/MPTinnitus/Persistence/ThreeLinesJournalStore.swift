//
//  ThreeLinesJournalStore.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation
import SwiftData

@MainActor
enum ThreeLinesJournalStore {
    static func activeEntries(
        from entries: [ThreeLinesJournalEntryRecord]
    ) -> [ThreeLinesJournalEntryRecord] {
        entries
            .filter { !$0.isArchived }
            .sorted {
                if $0.entryDate == $1.entryDate {
                    return $0.updatedAt > $1.updatedAt
                }

                return $0.entryDate > $1.entryDate
            }
    }

    static func activeEntry(
        for date: Date,
        in entries: [ThreeLinesJournalEntryRecord],
        calendar: Calendar = .current
    ) -> ThreeLinesJournalEntryRecord? {
        activeEntries(for: date, in: entries, calendar: calendar).first
    }

    static func activeEntries(
        for date: Date,
        in entries: [ThreeLinesJournalEntryRecord],
        calendar: Calendar = .current
    ) -> [ThreeLinesJournalEntryRecord] {
        let day = calendar.startOfDay(for: date)

        return entries
            .filter { !$0.isArchived && calendar.isDate($0.entryDate, inSameDayAs: day) }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    static func saveEntry(
        for date: Date,
        soundTherapyText: String,
        emotionalRegulationText: String,
        mindfulnessText: String,
        soundTherapyCheckOnly: Bool,
        emotionalRegulationCheckOnly: Bool,
        mindfulnessCheckOnly: Bool,
        notes: String,
        existingEntries: [ThreeLinesJournalEntryRecord],
        modelContext: ModelContext,
        calendar: Calendar = .current
    ) throws -> ThreeLinesJournalEntryRecord {
        let now = Date()
        let day = calendar.startOfDay(for: date)
        let sameDayEntries = activeEntries(for: day, in: existingEntries, calendar: calendar)

        let entry = sameDayEntries.first ?? ThreeLinesJournalEntryRecord(entryDate: day)
        entry.entryDate = day
        entry.soundTherapyText = soundTherapyText.trimmedJournalText
        entry.emotionalRegulationText = emotionalRegulationText.trimmedJournalText
        entry.mindfulnessText = mindfulnessText.trimmedJournalText
        entry.soundTherapyCheckOnly = soundTherapyCheckOnly
        entry.emotionalRegulationCheckOnly = emotionalRegulationCheckOnly
        entry.mindfulnessCheckOnly = mindfulnessCheckOnly
        entry.notes = notes.trimmedJournalText
        entry.updatedAt = now
        entry.isArchived = false

        if sameDayEntries.isEmpty {
            entry.createdAt = now
            modelContext.insert(entry)
        }

        for duplicate in sameDayEntries.dropFirst() {
            duplicate.isArchived = true
            duplicate.updatedAt = now
        }

        try modelContext.save()
        return entry
    }

    static func archive(_ entry: ThreeLinesJournalEntryRecord, modelContext: ModelContext) throws {
        entry.isArchived = true
        entry.updatedAt = Date()
        try modelContext.save()
    }
}

private extension String {
    var trimmedJournalText: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
