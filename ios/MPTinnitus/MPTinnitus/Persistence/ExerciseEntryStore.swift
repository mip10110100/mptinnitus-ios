//
//  ExerciseEntryStore.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation
import SwiftData

@MainActor
enum ExerciseEntryStore {
    static func activeEntries(
        for exerciseId: String,
        in entries: [ExerciseEntryRecord]
    ) -> [ExerciseEntryRecord] {
        entries
            .filter { !$0.isArchived && $0.exerciseID == exerciseId }
            .sorted {
                if $0.createdAt == $1.createdAt {
                    return $0.updatedAt > $1.updatedAt
                }

                return $0.createdAt > $1.createdAt
            }
    }

    static func saveEntry(
        editing entry: ExerciseEntryRecord?,
        definition: ExerciseDefinition,
        fieldValues: [String: String],
        checkboxValues: [String: Bool],
        computedValues: [String: String],
        isAddedToMyPlan: Bool,
        myPlanItemID: UUID?,
        modelContext: ModelContext
    ) throws -> ExerciseEntryRecord {
        let now = Date()
        let payload = ExerciseEntryPayload(
            schemaVersion: "1.0.0",
            exerciseId: definition.exerciseId,
            moduleId: definition.moduleId,
            fieldValues: normalizedStrings(fieldValues),
            checkboxValues: checkboxValues,
            computedValues: normalizedStrings(computedValues)
        )
        let payloadJSON = (try? LocalJSONPayload.encode(payload)) ?? LocalJSONPayload.emptyObject
        let entryTitle = makeEntryTitle(
            definition: definition,
            fieldValues: payload.fieldValues,
            computedValues: payload.computedValues
        )

        let record = entry ?? ExerciseEntryRecord(
            exerciseID: definition.exerciseId,
            exerciseTitle: definition.title,
            moduleID: definition.moduleId
        )

        record.exerciseID = definition.exerciseId
        record.exerciseTitle = definition.title
        record.moduleID = definition.moduleId
        record.entryTitle = entryTitle
        record.payloadJSON = payloadJSON
        record.updatedAt = now
        record.isAddedToMyPlan = isAddedToMyPlan
        record.myPlanItemID = myPlanItemID
        record.isArchived = false

        if entry == nil {
            record.createdAt = now
            modelContext.insert(record)
        }

        try modelContext.save()
        return record
    }

    static func archive(_ entry: ExerciseEntryRecord, modelContext: ModelContext) throws {
        entry.isArchived = true
        entry.updatedAt = Date()
        try modelContext.save()
    }

    static func decodePayload(_ entry: ExerciseEntryRecord) -> ExerciseEntryPayload? {
        try? LocalJSONPayload.decode(ExerciseEntryPayload.self, from: entry.payloadJSON)
    }

    static func makeComputedValues(
        definition: ExerciseDefinition,
        fieldValues: [String: String]
    ) -> [String: String] {
        var computedValues: [String: String] = [:]

        for field in definition.fields where field.type == .computedText {
            computedValues[field.fieldId] = renderTemplate(field.helperText, fieldValues: fieldValues)
        }

        return computedValues
    }

    static func validate(
        definition: ExerciseDefinition,
        fieldValues: [String: String],
        checkboxValues: [String: Bool]
    ) -> String? {
        let values = normalizedStrings(fieldValues)
        let filledFieldIds = Set(values.filter { !$0.value.isEmpty }.map(\.key))
        let checkedFieldIds = Set(checkboxValues.filter { $0.value }.map(\.key))
        let activeFieldIds = filledFieldIds.union(checkedFieldIds)

        switch definition.saveRule.mode {
        case .anyOf:
            if definition.saveRule.fieldIds.contains(where: activeFieldIds.contains) {
                return nil
            }

            return "Add at least one note or checkmark before saving."
        case .allOf:
            let missingFieldLabels = definition.saveRule.fieldIds.compactMap { fieldId -> String? in
                guard !activeFieldIds.contains(fieldId) else {
                    return nil
                }

                return definition.fields.first { $0.fieldId == fieldId }?.label ?? fieldId
            }

            if missingFieldLabels.isEmpty {
                return nil
            }

            return "Complete: \(missingFieldLabels.joined(separator: ", "))."
        }
    }

    private static func normalizedStrings(_ values: [String: String]) -> [String: String] {
        values.mapValues { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private static func makeEntryTitle(
        definition: ExerciseDefinition,
        fieldValues: [String: String],
        computedValues: [String: String]
    ) -> String {
        for fieldId in definition.entryTitleFieldIds {
            let value = computedValues[fieldId] ?? fieldValues[fieldId] ?? ""
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

            if !trimmed.isEmpty {
                return String(trimmed.prefix(80))
            }
        }

        return definition.title
    }

    private static func renderTemplate(_ template: String, fieldValues: [String: String]) -> String {
        var rendered = template

        for (fieldId, value) in fieldValues {
            rendered = rendered.replacingOccurrences(
                of: "{\(fieldId)}",
                with: value.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        return rendered
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
