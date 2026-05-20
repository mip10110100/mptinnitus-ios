//
//  ExerciseDefinitionLoader.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation

struct ExerciseDefinitionLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    func loadLibrary() -> ExerciseDefinitionLibrary {
        guard let url = bundle.url(forResource: "exercise_definitions_v1", withExtension: "json") else {
            return ExerciseDefinitionLibrary(
                schemaVersion: "0.0.0",
                sourceFiles: [],
                definitions: [],
                issues: [
                    ExerciseDefinitionIssue(
                        severity: .warning,
                        message: "exercise_definitions_v1.json is missing from the app bundle."
                    )
                ]
            )
        }

        do {
            let data = try Data(contentsOf: url)
            let document = try decoder.decode(ExerciseDefinitionDocument.self, from: data)
            return ExerciseDefinitionLibrary(
                schemaVersion: document.schemaVersion,
                sourceFiles: document.sourceFiles,
                definitions: document.definitions,
                issues: validate(document.definitions)
            )
        } catch {
            return ExerciseDefinitionLibrary(
                schemaVersion: "0.0.0",
                sourceFiles: [],
                definitions: [],
                issues: [
                    ExerciseDefinitionIssue(
                        severity: .error,
                        message: "exercise_definitions_v1.json could not be decoded: \(error.localizedDescription)"
                    )
                ]
            )
        }
    }

    private func validate(_ definitions: [ExerciseDefinition]) -> [ExerciseDefinitionIssue] {
        var issues: [ExerciseDefinitionIssue] = []
        var exerciseIds = Set<String>()

        for definition in definitions {
            if !exerciseIds.insert(definition.exerciseId).inserted {
                issues.append(
                    ExerciseDefinitionIssue(
                        severity: .warning,
                        message: "Duplicate exercise definition ID \(definition.exerciseId)."
                    )
                )
            }

            let fieldIds = Set(definition.fields.map(\.fieldId))
            for requiredFieldId in definition.saveRule.fieldIds where !fieldIds.contains(requiredFieldId) {
                issues.append(
                    ExerciseDefinitionIssue(
                        severity: .warning,
                        message: "\(definition.exerciseId) save rule references missing field \(requiredFieldId)."
                    )
                )
            }
        }

        #if DEBUG
        print(
            "[MPTinnitus][ExerciseDefinitions] Loaded definitions=\(definitions.count), issues=\(issues.count)"
        )
        #endif

        return issues
    }
}
