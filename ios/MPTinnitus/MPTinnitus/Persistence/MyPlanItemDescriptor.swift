//
//  MyPlanItemDescriptor.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation

enum MyPlanSourceType: String, CaseIterable {
    case contentCard = "content_card"
    case exercisePlaceholder = "exercise_placeholder"
    case audioItem = "audio_item"
    case module = "module"
    case safetyScopeItem = "safety_scope_item"
    case visualReference = "visual_reference"

    var displayName: String {
        switch self {
        case .contentCard:
            "Education Card"
        case .exercisePlaceholder:
            "Practice Tool"
        case .audioItem:
            "Audio"
        case .module:
            "Module"
        case .safetyScopeItem:
            "Safety"
        case .visualReference:
            "Visual Reference"
        }
    }
}

struct MyPlanItemDescriptor: Equatable {
    let sourceType: MyPlanSourceType
    let sourceID: String
    let moduleID: String
    let title: String
    let summary: String
    let payloadJSON: String

    var id: String {
        "\(sourceType.rawValue):\(sourceID)"
    }
}

struct MyPlanSourcePayload: Codable, Equatable {
    let route: String?
    let screenID: String?
    let audioIDs: [String]
    let visualIDs: [String]
    let sourceNote: String?
}

extension MyPlanItemDescriptor {
    static func module(_ module: StaticModule) -> MyPlanItemDescriptor {
        MyPlanItemDescriptor(
            sourceType: .module,
            sourceID: module.moduleId,
            moduleID: module.moduleId,
            title: module.title,
            summary: module.purpose,
            payloadJSON: payloadJSON(
                route: module.route,
                screenID: module.screenId,
                audioIDs: module.audio.map(\.audioId),
                visualIDs: module.visuals.map(\.visualId),
                sourceNote: "Saved module overview."
            )
        )
    }

    static func contentCard(_ card: StaticContentCard, module: StaticModule) -> MyPlanItemDescriptor {
        MyPlanItemDescriptor(
            sourceType: .contentCard,
            sourceID: card.sectionId,
            moduleID: module.moduleId,
            title: card.title,
            summary: summary(from: card.bodyMarkdown),
            payloadJSON: payloadJSON(
                route: module.route,
                screenID: card.screenId,
                audioIDs: card.audioIds,
                visualIDs: card.visualIds,
                sourceNote: card.safetyNote.isEmpty ? nil : card.safetyNote
            )
        )
    }

    static func audioItem(_ audio: StaticAudioItem, module: StaticModule) -> MyPlanItemDescriptor {
        MyPlanItemDescriptor(
            sourceType: .audioItem,
            sourceID: audio.audioId,
            moduleID: module.moduleId,
            title: audio.title,
            summary: audio.type,
            payloadJSON: payloadJSON(
                route: module.route,
                screenID: audio.screenIds.first,
                audioIDs: [audio.audioId],
                visualIDs: [],
                sourceNote: "Transcript text remains available on the source audio card."
            )
        )
    }

    static func exercise(_ exercise: StaticExerciseItem, module: StaticModule) -> MyPlanItemDescriptor {
        MyPlanItemDescriptor(
            sourceType: .exercisePlaceholder,
            sourceID: exercise.exerciseId,
            moduleID: module.moduleId,
            title: exercise.title,
            summary: patientFacingExerciseSummary(exercise.description),
            payloadJSON: payloadJSON(
                route: exercise.route,
                screenID: exercise.screenId,
                audioIDs: [],
                visualIDs: [],
                sourceNote: exercise.addToMyPlanBehavior
            )
        )
    }

    private static func payloadJSON(
        route: String?,
        screenID: String?,
        audioIDs: [String],
        visualIDs: [String],
        sourceNote: String?
    ) -> String {
        let payload = MyPlanSourcePayload(
            route: route,
            screenID: screenID,
            audioIDs: audioIDs,
            visualIDs: visualIDs,
            sourceNote: sourceNote
        )

        return (try? LocalJSONPayload.encode(payload)) ?? LocalJSONPayload.emptyObject
    }

    private static func summary(from markdown: String, maxLength: Int = 180) -> String {
        let normalized = markdown
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalized.count > maxLength else {
            return normalized
        }

        return String(normalized.prefix(maxLength)).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
    }

    private static func patientFacingExerciseSummary(_ description: String) -> String {
        var text = description
        let replacements = [
            "Launches the later ": "Open ",
            "Launches the ": "Open ",
            "In this stage it remains a placeholder route without saved results.": "Use this as a practice tool when you want to return to it.",
            "In this stage it remains a navigation placeholder.": "Use this when you want a quick way to choose where to begin.",
            "No response is saved in this stage.": "Use this as a practice tool when you want to return to it.",
            "Reminder settings are future local preferences only. No reminders are scheduled in this MVP.": "Reminder scheduling is not available yet.",
            "Reminders are not implemented in this stage.": "Reminder scheduling is not available yet."
        ]

        for (target, replacement) in replacements {
            text = text.replacingOccurrences(of: target, with: replacement)
        }

        return text
    }
}
