//
//  StaticModuleModels.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation

struct StaticModuleLibraryDocument: Codable, Equatable {
    let schemaVersion: String
    let sourceFiles: [String]
    let modules: [StaticModule]
}

struct StaticModuleLibrary: Equatable {
    let schemaVersion: String
    let sourceFiles: [String]
    let modules: [StaticModule]
    let issues: [StaticModuleLibraryIssue]

    static let empty = StaticModuleLibrary(
        schemaVersion: "0.0.0",
        sourceFiles: [],
        modules: [],
        issues: []
    )

    func module(id moduleId: String) -> StaticModule? {
        modules.first { $0.moduleId == moduleId }
    }

    func exercise(id exerciseId: String) -> StaticExerciseItem? {
        modules
            .flatMap(\.exercises)
            .first { $0.exerciseId == exerciseId }
    }

    func module(containingExercise exerciseId: String) -> StaticModule? {
        modules.first { module in
            module.exercises.contains { $0.exerciseId == exerciseId }
        }
    }

    func visual(id visualId: String) -> StaticVisualReference? {
        modules
            .flatMap(\.visuals)
            .first { $0.visualId == visualId }
    }

    func module(containingVisual visualId: String) -> StaticModule? {
        modules.first { module in
            module.visuals.contains { $0.visualId == visualId }
        }
    }

    var exerciseReferences: [StaticExerciseReference] {
        modules.flatMap { module in
            module.exercises.map { exercise in
                StaticExerciseReference(module: module, exercise: exercise)
            }
        }
    }
}

struct StaticModuleLibraryIssue: Identifiable, Equatable {
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

struct StaticExerciseReference: Identifiable, Equatable {
    let module: StaticModule
    let exercise: StaticExerciseItem

    var id: String {
        "\(module.moduleId)-\(exercise.exerciseId)"
    }
}

struct StaticModule: Codable, Identifiable, Equatable {
    static let aboutTinnitusModuleId = "about_tinnitus"

    let moduleId: String
    let screenId: String
    let route: String
    let title: String
    let systemImage: String
    let purpose: String
    let overviewMarkdown: String
    let sourceScreenIds: [String]
    let cards: [StaticContentCard]
    let audio: [StaticAudioItem]
    let exercises: [StaticExerciseItem]
    let safetyScopes: [StaticSafetyScope]
    let visuals: [StaticVisualReference]
    let relatedModules: [StaticModuleLink]

    var id: String {
        moduleId
    }
}

struct StaticContentCard: Codable, Identifiable, Equatable {
    let sectionId: String
    let screenId: String
    let title: String
    let bodyMarkdown: String
    let isExpandable: Bool
    let audioIds: [String]
    let visualIds: [String]
    let safetyNote: String

    var id: String {
        sectionId
    }
}

struct StaticAudioItem: Codable, Identifiable, Equatable {
    let audioId: String
    let sourceId: String
    let screenIds: [String]
    let title: String
    let type: String
    let assetPath: String
    let transcript: String
    let playbackContext: String

    var id: String {
        audioId
    }
}

struct StaticExerciseItem: Codable, Identifiable, Equatable {
    let exerciseId: String
    let screenId: String
    let title: String
    let description: String
    let inputSummary: String
    let defaultCTAs: String
    let route: String
    let addToMyPlanBehavior: String

    var id: String {
        exerciseId
    }
}

struct StaticSafetyScope: Codable, Identifiable, Equatable {
    let safetyScopeId: String
    let screenId: String
    let title: String
    let bodyMarkdown: String

    var id: String {
        safetyScopeId
    }
}

struct StaticVisualReference: Codable, Identifiable, Equatable {
    let visualId: String
    let screenId: String
    let title: String
    let status: String
    let description: String

    var id: String {
        visualId
    }
}

struct StaticModuleLink: Codable, Identifiable, Equatable {
    let moduleId: String
    let title: String

    var id: String {
        moduleId
    }
}
