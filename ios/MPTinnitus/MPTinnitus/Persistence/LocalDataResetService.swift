//
//  LocalDataResetService.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation
import SwiftData

enum LocalDataResetScope: String, CaseIterable, Identifiable {
    case allLocalData
    case myPlanItems
    case exerciseEntries
    case threeLinesJournalEntries
    case soundPreferences
    case reminderSettings
    case userPreferences
    case safetyScopeFlags

    var id: String {
        rawValue
    }
}

@MainActor
struct LocalDataResetService {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func reset(_ scope: LocalDataResetScope) throws {
        switch scope {
        case .allLocalData:
            try deleteAll(MyPlanItemRecord.self)
            try deleteAll(ExerciseEntryRecord.self)
            try deleteAll(ThreeLinesJournalEntryRecord.self)
            try deleteAll(SoundPreferenceRecord.self)
            try deleteAll(ReminderSettingsRecord.self)
            try deleteAll(UserPreferenceRecord.self)
            try deleteAll(SafetyScopeAcknowledgementRecord.self)
            try deleteAll(LocalSchemaMetadataRecord.self)
        case .myPlanItems:
            try deleteAll(MyPlanItemRecord.self)
        case .exerciseEntries:
            try deleteAll(ExerciseEntryRecord.self)
        case .threeLinesJournalEntries:
            try deleteAll(ThreeLinesJournalEntryRecord.self)
        case .soundPreferences:
            try deleteAll(SoundPreferenceRecord.self)
        case .reminderSettings:
            try deleteAll(ReminderSettingsRecord.self)
        case .userPreferences:
            try deleteAll(UserPreferenceRecord.self)
        case .safetyScopeFlags:
            try deleteAll(SafetyScopeAcknowledgementRecord.self)
        }

        try modelContext.save()
    }

    private func deleteAll<T: PersistentModel>(_ modelType: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let records = try modelContext.fetch(descriptor)
        records.forEach(modelContext.delete)
    }
}
