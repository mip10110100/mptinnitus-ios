//
//  CheckInRecommendationEngine.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Foundation

enum CheckInRecommendationEngine {
    static let baselineModuleIDs = [
        "about_tinnitus",
        "sound_therapy",
        "acceptance_and_change"
    ]

    static func recommendations(
        domainScores: [CheckInDomainScore],
        library: StaticModuleLibrary
    ) -> [ModuleRecommendation] {
        var recommendations = baselineRecommendations(library: library)
        var addedModuleIDs = Set(recommendations.map(\.moduleId))
        let scoresByDomain = Dictionary(uniqueKeysWithValues: domainScores.map { ($0.domain, $0.average) })

        func addPersonalized(_ moduleId: String, reason: String) {
            guard recommendations.filter({ !$0.isBaseline }).count < 3,
                  !addedModuleIDs.contains(moduleId),
                  let module = library.module(id: moduleId) else {
                return
            }

            recommendations.append(
                ModuleRecommendation(
                    moduleId: module.moduleId,
                    title: module.title,
                    reasonText: reason,
                    isBaseline: false
                )
            )
            addedModuleIDs.insert(moduleId)
        }

        if score(scoresByDomain[.sleep]) >= 3 {
            addPersonalized("sleep", reason: "You mentioned that tinnitus is affecting sleep.")
        }

        if score(scoresByDomain[.soundQuiet]) >= 3 {
            addPersonalized("sound_therapy", reason: "You mentioned difficulty with quiet, sound, or avoidance.")
            addPersonalized("distress_tolerance", reason: "You mentioned difficulty with quiet, sound, or avoidance.")
        }

        if score(scoresByDomain[.attentionIntrusiveness]) >= 3 {
            addPersonalized("mindfulness", reason: "You mentioned that tinnitus is pulling attention.")
        }

        if score(scoresByDomain[.cognitiveLoop]) >= 3 {
            addPersonalized("cognitive_reframing", reason: "You mentioned getting stuck in monitoring or problem-solving loops.")
        }

        if score(scoresByDomain[.emotionalDistress]) >= 3 {
            addPersonalized("distress_tolerance", reason: "You mentioned strong emotional reactions.")
            addPersonalized("confidence_communication", reason: "You mentioned strong emotional reactions.")
        }

        if score(scoresByDomain[.dailyFunction]) >= 3 {
            addPersonalized("acceptance_and_change", reason: "You mentioned tinnitus getting in the way of daily life.")
            addPersonalized("cognitive_reframing", reason: "You mentioned tinnitus getting in the way of daily life.")
        }

        if score(scoresByDomain[.supportValidation]) >= 3 {
            addPersonalized("confidence_communication", reason: "You mentioned feeling alone, misunderstood, or unsure how to explain tinnitus.")
        }

        if score(scoresByDomain[.confidenceSelfCompassion]) >= 3 {
            addPersonalized("my_plan", reason: "You mentioned wanting more confidence in how to respond.")
            addPersonalized("confidence_communication", reason: "You mentioned wanting more confidence in how to respond.")
        }

        return recommendations
    }

    static func baselineRecommendations(library: StaticModuleLibrary) -> [ModuleRecommendation] {
        baselineModuleIDs.compactMap { moduleId in
            guard let module = library.module(id: moduleId) else {
                return nil
            }

            let reason: String
            switch moduleId {
            case "about_tinnitus":
                reason = "Start with the body, mind, and life model."
            case "sound_therapy":
                reason = "Explore comfortable sound as a support tool."
            case "acceptance_and_change":
                reason = "Learn how acceptance and useful change can work together."
            default:
                reason = "Use this as a starting point."
            }

            return ModuleRecommendation(
                moduleId: module.moduleId,
                title: module.title,
                reasonText: reason,
                isBaseline: true
            )
        }
    }

    private static func score(_ score: Double??) -> Double {
        guard let score, let value = score else {
            return 0
        }

        return value
    }
}
