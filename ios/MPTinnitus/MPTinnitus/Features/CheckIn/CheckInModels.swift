//
//  CheckInModels.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Foundation

enum CheckInSessionSource: String, Codable, Equatable {
    case onboarding
    case myPlan = "my_plan"
    case reminder
    case settings
}

enum CheckInDomain: String, Codable, CaseIterable, Identifiable {
    case attentionIntrusiveness = "attention_intrusiveness"
    case soundQuiet = "sound_quiet"
    case sleep
    case emotionalDistress = "emotional_distress"
    case cognitiveLoop = "cognitive_loop"
    case dailyFunction = "daily_function"
    case supportValidation = "support_validation"
    case confidenceSelfCompassion = "confidence_self_compassion"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .attentionIntrusiveness:
            "Attention"
        case .soundQuiet:
            "Sound and quiet"
        case .sleep:
            "Sleep"
        case .emotionalDistress:
            "Distress"
        case .cognitiveLoop:
            "Thought loops"
        case .dailyFunction:
            "Daily life"
        case .supportValidation:
            "Support"
        case .confidenceSelfCompassion:
            "Confidence"
        }
    }
}

struct CheckInQuestionDocument: Codable, Equatable {
    let schemaVersion: String
    let timeWindow: String
    let scale: [CheckInScaleOption]
    let items: [CheckInQuestion]
}

struct CheckInScaleOption: Codable, Equatable, Identifiable {
    let value: Int?
    let label: String

    var id: String {
        value.map(String.init) ?? "na"
    }
}

struct CheckInQuestion: Codable, Identifiable, Equatable {
    let id: String
    let prompt: String
    let domain: CheckInDomain
    let isReverseScored: Bool
    let recommendedModuleIds: [String]
    let reasonText: String
}

struct CheckInResponse: Codable, Identifiable, Equatable {
    let questionId: String
    let value: Int?
    let scoringValue: Double?

    var id: String {
        questionId
    }
}

struct CheckInDomainScore: Codable, Identifiable, Equatable {
    let domain: CheckInDomain
    let average: Double?
    let responseCount: Int

    var id: String {
        domain.rawValue
    }
}

struct ModuleRecommendation: Codable, Identifiable, Equatable {
    let moduleId: String
    let title: String
    let reasonText: String
    let isBaseline: Bool

    var id: String {
        moduleId
    }
}

struct CheckInSession: Codable, Identifiable, Equatable {
    let sessionId: UUID
    let schemaVersion: String
    let createdAt: Date
    let completedAt: Date
    let source: CheckInSessionSource
    let responses: [CheckInResponse]
    let domainScores: [CheckInDomainScore]
    let recommendations: [ModuleRecommendation]
    let appVersion: String?
    let appBuild: String?
    let itemVersion: String

    var id: UUID {
        sessionId
    }
}

struct CheckInReminderPreference: Codable, Equatable {
    let schemaVersion: String
    var isEnabled: Bool
    var weekday: Int
    var hour: Int
    var minute: Int
    var updatedAt: Date

    static let defaultDisabled = CheckInReminderPreference(
        schemaVersion: "checkin_reminder_preference_v1",
        isEnabled: false,
        weekday: 2,
        hour: 9,
        minute: 0,
        updatedAt: Date()
    )
}

struct CheckInSessionDocument: Codable, Equatable {
    let schemaVersion: String
    var sessions: [CheckInSession]
}

enum CheckInScaleSelection: Hashable {
    case notApplicable
    case value(Int)

    var responseValue: Int? {
        switch self {
        case .notApplicable:
            nil
        case .value(let value):
            value
        }
    }
}
