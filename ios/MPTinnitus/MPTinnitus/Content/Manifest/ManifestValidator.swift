//
//  ManifestValidator.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import Foundation

enum ManifestValidator {
    static func validate(_ snapshot: ManifestSnapshot) -> [ManifestIssue] {
        var issues: [ManifestIssue] = []

        appendDuplicateIssues(
            values: snapshot.routes.map(\.route),
            source: "route_manifest_seed_v1.json",
            label: "route",
            to: &issues
        )
        appendDuplicateIssues(
            values: snapshot.routes.map(\.screenId),
            source: "route_manifest_seed_v1.json",
            label: "screenId",
            to: &issues
        )
        appendDuplicateIssues(
            values: snapshot.screens.map(\.screenId),
            source: "screen_manifest_seed_v1.json",
            label: "screenId",
            to: &issues
        )
        appendDuplicateIssues(
            values: snapshot.sections.map(\.sectionId),
            source: "content_sections_seed_v1.json",
            label: "sectionId",
            to: &issues
        )
        appendDuplicateIssues(
            values: snapshot.audioItems.map(\.audioId),
            source: "audio_manifest_seed_v1.json",
            label: "audioId",
            to: &issues
        )
        appendDuplicateIssues(
            values: snapshot.visualItems.map(\.visualId),
            source: "visual_manifest_seed_v1.json",
            label: "visualId",
            to: &issues
        )
        appendDuplicateIssues(
            values: snapshot.safetyScopes.map(\.safetyScopeId),
            source: "safety_scope_seed_v1.json",
            label: "safetyScopeId",
            to: &issues
        )

        let routes = Set(snapshot.routes.map(\.route))
        let screenIds = Set(snapshot.screens.map(\.screenId))
        let sectionIds = Set(snapshot.sections.map(\.sectionId))
        let audioIds = Set(snapshot.audioItems.map(\.audioId))
        let visualIds = Set(snapshot.visualItems.map(\.visualId))
            .union(snapshot.visualPlaceholders.map(\.id))
        let safetyScopeIds = Set(snapshot.safetyScopes.map(\.safetyScopeId))

        for screen in snapshot.screens {
            if !routes.contains(screen.route) {
                issues.append(
                    ManifestIssue(
                        severity: .warning,
                        source: screen.screenId,
                        message: "Screen route '\(screen.route)' is missing from route manifest."
                    )
                )
            }

            for sectionId in screen.sections where !sectionIds.contains(sectionId) {
                issues.append(
                    ManifestIssue(
                        severity: .warning,
                        source: screen.screenId,
                        message: "Referenced section ID '\(sectionId)' is missing."
                    )
                )
            }

            for audioId in screen.audioIds where !audioIds.contains(audioId) {
                issues.append(
                    ManifestIssue(
                        severity: .warning,
                        source: screen.screenId,
                        message: "Referenced audio ID '\(audioId)' is missing."
                    )
                )
            }

            for visualId in screen.visualIds where !visualIds.contains(visualId) {
                issues.append(
                    ManifestIssue(
                        severity: .warning,
                        source: screen.screenId,
                        message: "Referenced visual ID '\(visualId)' is missing."
                    )
                )
            }

            for route in screen.nextRoutes where !routes.contains(route) {
                issues.append(
                    ManifestIssue(
                        severity: .warning,
                        source: screen.screenId,
                        message: "Referenced next route '\(route)' is missing."
                    )
                )
            }

            if let safetyScopeId = screen.safetyScopeId,
               !safetyScopeIds.contains(safetyScopeId) {
                issues.append(
                    ManifestIssue(
                        severity: .warning,
                        source: screen.screenId,
                        message: "Referenced safety scope ID '\(safetyScopeId)' is missing."
                    )
                )
            }
        }

        for section in snapshot.sections {
            if !screenIds.contains(section.screenId) {
                issues.append(
                    ManifestIssue(
                        severity: .warning,
                        source: section.sectionId,
                        message: "Section screen ID '\(section.screenId)' is missing from screen manifest."
                    )
                )
            }

            if let audioId = section.audioId,
               !audioIds.contains(audioId) {
                issues.append(
                    ManifestIssue(
                        severity: .warning,
                        source: section.sectionId,
                        message: "Section audio ID '\(audioId)' is missing."
                    )
                )
            }
        }

        for audioItem in snapshot.audioItems where audioItem.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(
                ManifestIssue(
                    severity: .warning,
                    source: audioItem.audioId,
                    message: "Audio manifest item is missing transcript text."
                )
            )
        }

        return issues
    }

    private static func appendDuplicateIssues(
        values: [String],
        source: String,
        label: String,
        to issues: inout [ManifestIssue]
    ) {
        let counts = Dictionary(grouping: values, by: { $0 }).mapValues(\.count)

        for (value, count) in counts where count > 1 {
            issues.append(
                ManifestIssue(
                    severity: .warning,
                    source: source,
                    message: "Duplicate \(label) '\(value)' appears \(count) times."
                )
            )
        }
    }
}
