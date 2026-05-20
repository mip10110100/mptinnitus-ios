//
//  ExerciseDefinitionModels.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation

struct ExerciseDefinitionDocument: Codable, Equatable {
    let schemaVersion: String
    let sourceFiles: [String]
    let definitions: [ExerciseDefinition]
}

struct ExerciseDefinitionLibrary: Equatable {
    let schemaVersion: String
    let sourceFiles: [String]
    let definitions: [ExerciseDefinition]
    let issues: [ExerciseDefinitionIssue]

    static let empty = ExerciseDefinitionLibrary(
        schemaVersion: "0.0.0",
        sourceFiles: [],
        definitions: [],
        issues: []
    )

    func definition(id exerciseId: String) -> ExerciseDefinition? {
        definitions.first { $0.exerciseId == exerciseId }
    }
}

struct ExerciseDefinitionIssue: Identifiable, Equatable {
    enum Severity: String {
        case warning
        case error
    }

    let severity: Severity
    let message: String

    var id: String {
        "\(severity.rawValue)-\(message)"
    }
}

struct ExerciseDefinition: Codable, Identifiable, Equatable {
    let exerciseId: String
    let screenId: String
    let moduleId: String
    let title: String
    let purpose: String
    let instructions: String
    let entryTitleFieldIds: [String]
    let saveRule: ExerciseSaveRule
    let fields: [ExerciseFieldDefinition]

    var id: String {
        exerciseId
    }
}

struct ExerciseSaveRule: Codable, Equatable {
    enum Mode: String, Codable {
        case anyOf
        case allOf
    }

    let mode: Mode
    let fieldIds: [String]
}

struct ExerciseFieldDefinition: Codable, Identifiable, Equatable {
    enum FieldType: String, Codable {
        case shortText
        case longText
        case optionalText
        case staticInfo
        case checkbox
        case computedText
    }

    let fieldId: String
    let type: FieldType
    let label: String
    let prompt: String
    let helperText: String
    let isRequired: Bool

    var id: String {
        fieldId
    }
}

struct ExerciseEntryPayload: Codable, Equatable {
    let schemaVersion: String
    let exerciseId: String
    let moduleId: String
    let fieldValues: [String: String]
    let checkboxValues: [String: Bool]
    let computedValues: [String: String]
}
