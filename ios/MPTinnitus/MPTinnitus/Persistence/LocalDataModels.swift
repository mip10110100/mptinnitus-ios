//
//  LocalDataModels.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation
import SwiftData

enum MPTinnitusLocalSchema {
    static let schemaVersion = 1
    static let appContentVersion = "v10"

    static let models: [any PersistentModel.Type] = [
        LocalSchemaMetadataRecord.self,
        UserPreferenceRecord.self,
        MyPlanItemRecord.self,
        ExerciseEntryRecord.self,
        ThreeLinesJournalEntryRecord.self,
        SoundPreferenceRecord.self,
        ReminderSettingsRecord.self,
        SafetyScopeAcknowledgementRecord.self
    ]
}

@Model
final class LocalSchemaMetadataRecord {
    @Attribute(.unique) var id: UUID
    var schemaVersion: Int
    var appContentVersion: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        schemaVersion: Int = MPTinnitusLocalSchema.schemaVersion,
        appContentVersion: String = MPTinnitusLocalSchema.appContentVersion,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.appContentVersion = appContentVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class UserPreferenceRecord {
    @Attribute(.unique) var id: UUID
    var key: String
    var valueString: String?
    var valueJSON: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        key: String,
        valueString: String? = nil,
        valueJSON: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.key = key
        self.valueString = valueString
        self.valueJSON = valueJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class MyPlanItemRecord {
    @Attribute(.unique) var id: UUID
    var sourceType: String
    var sourceID: String
    var moduleID: String
    var title: String
    var summary: String
    var payloadJSON: String
    var createdAt: Date
    var updatedAt: Date
    var sortOrder: Double
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        sourceType: String,
        sourceID: String,
        moduleID: String,
        title: String,
        summary: String = "",
        payloadJSON: String = LocalJSONPayload.emptyObject,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sortOrder: Double = 0,
        isArchived: Bool = false
    ) {
        self.id = id
        self.sourceType = sourceType
        self.sourceID = sourceID
        self.moduleID = moduleID
        self.title = title
        self.summary = summary
        self.payloadJSON = payloadJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sortOrder = sortOrder
        self.isArchived = isArchived
    }
}

@Model
final class ExerciseEntryRecord {
    @Attribute(.unique) var id: UUID
    var exerciseID: String
    var exerciseTitle: String
    var moduleID: String
    var entryTitle: String
    var payloadJSON: String
    var createdAt: Date
    var updatedAt: Date
    var isAddedToMyPlan: Bool
    var myPlanItemID: UUID?
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        exerciseID: String,
        exerciseTitle: String,
        moduleID: String,
        entryTitle: String = "",
        payloadJSON: String = LocalJSONPayload.emptyObject,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isAddedToMyPlan: Bool = false,
        myPlanItemID: UUID? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseTitle = exerciseTitle
        self.moduleID = moduleID
        self.entryTitle = entryTitle
        self.payloadJSON = payloadJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isAddedToMyPlan = isAddedToMyPlan
        self.myPlanItemID = myPlanItemID
        self.isArchived = isArchived
    }
}

@Model
final class ThreeLinesJournalEntryRecord {
    @Attribute(.unique) var id: UUID
    var entryDate: Date
    var soundTherapyText: String
    var emotionalRegulationText: String
    var mindfulnessText: String
    var soundTherapyCheckOnly: Bool
    var emotionalRegulationCheckOnly: Bool
    var mindfulnessCheckOnly: Bool
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        entryDate: Date = Date(),
        soundTherapyText: String = "",
        emotionalRegulationText: String = "",
        mindfulnessText: String = "",
        soundTherapyCheckOnly: Bool = false,
        emotionalRegulationCheckOnly: Bool = false,
        mindfulnessCheckOnly: Bool = false,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.entryDate = entryDate
        self.soundTherapyText = soundTherapyText
        self.emotionalRegulationText = emotionalRegulationText
        self.mindfulnessText = mindfulnessText
        self.soundTherapyCheckOnly = soundTherapyCheckOnly
        self.emotionalRegulationCheckOnly = emotionalRegulationCheckOnly
        self.mindfulnessCheckOnly = mindfulnessCheckOnly
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }
}

@Model
final class SoundPreferenceRecord {
    @Attribute(.unique) var id: UUID
    var soundID: String
    var soundTitle: String
    var soundCategory: String
    var preferredVolumeNote: String
    var contextNote: String
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        soundID: String,
        soundTitle: String,
        soundCategory: String,
        preferredVolumeNote: String = "",
        contextNote: String = "",
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.soundID = soundID
        self.soundTitle = soundTitle
        self.soundCategory = soundCategory
        self.preferredVolumeNote = preferredVolumeNote
        self.contextNote = contextNote
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }
}

@Model
final class ReminderSettingsRecord {
    @Attribute(.unique) var id: UUID
    var reminderType: String
    var isEnabled: Bool
    var hour: Int?
    var minute: Int?
    var repeatRule: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        reminderType: String,
        isEnabled: Bool = false,
        hour: Int? = nil,
        minute: Int? = nil,
        repeatRule: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.reminderType = reminderType
        self.isEnabled = isEnabled
        self.hour = hour
        self.minute = minute
        self.repeatRule = repeatRule
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class SafetyScopeAcknowledgementRecord {
    @Attribute(.unique) var id: UUID
    var scopeKey: String
    var screenID: String
    var hasSeen: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        scopeKey: String,
        screenID: String = "",
        hasSeen: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.scopeKey = scopeKey
        self.screenID = screenID
        self.hasSeen = hasSeen
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
