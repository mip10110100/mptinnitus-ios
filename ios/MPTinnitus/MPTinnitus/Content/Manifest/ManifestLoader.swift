//
//  ManifestLoader.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import Foundation

struct ManifestSnapshot: Equatable {
    let routes: [RouteItem]
    let screens: [ScreenManifest]
    let sections: [ContentSection]
    let audioItems: [AudioManifestItem]
    let visualItems: [VisualManifestItem]
    let safetyScopes: [SafetyScopeItem]
    let soundSamplePlaceholders: [SoundSamplePlaceholder]
    let visualPlaceholders: [VisualPlaceholderItem]
    let issues: [ManifestIssue]

    static let empty = ManifestSnapshot(
        routes: [],
        screens: [],
        sections: [],
        audioItems: [],
        visualItems: [],
        safetyScopes: [],
        soundSamplePlaceholders: [],
        visualPlaceholders: [],
        issues: []
    )
}

struct ManifestIssue: Identifiable, Equatable {
    enum Severity: String {
        case warning
        case error
    }

    let severity: Severity
    let source: String
    let message: String

    var id: String {
        "\(severity.rawValue)-\(source)-\(message)"
    }
}

struct ManifestDebugCounts: Equatable {
    let routes: Int
    let screens: Int
    let sections: Int
    let audioItems: Int
    let visualItems: Int
    let safetyScopes: Int
    let soundSamplePlaceholders: Int
    let visualPlaceholders: Int
    let issues: Int
}

extension ManifestSnapshot {
    var debugCounts: ManifestDebugCounts {
        ManifestDebugCounts(
            routes: routes.count,
            screens: screens.count,
            sections: sections.count,
            audioItems: audioItems.count,
            visualItems: visualItems.count,
            safetyScopes: safetyScopes.count,
            soundSamplePlaceholders: soundSamplePlaceholders.count,
            visualPlaceholders: visualPlaceholders.count,
            issues: issues.count
        )
    }
}

struct ManifestLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    func loadSnapshot() -> ManifestSnapshot {
        var issues: [ManifestIssue] = []

        let routeDocument: RouteManifestDocument? = load(
            RouteManifestDocument.self,
            resourceName: "route_manifest_seed_v1",
            issues: &issues
        )
        let screenDocument: ScreenManifestDocument? = load(
            ScreenManifestDocument.self,
            resourceName: "screen_manifest_seed_v1",
            issues: &issues
        )
        let sectionDocument: ContentSectionDocument? = load(
            ContentSectionDocument.self,
            resourceName: "content_sections_seed_v1",
            issues: &issues
        )
        let audioDocument: AudioManifestDocument? = load(
            AudioManifestDocument.self,
            resourceName: "audio_manifest_seed_v1",
            issues: &issues
        )
        let visualDocument: VisualManifestDocument? = load(
            VisualManifestDocument.self,
            resourceName: "visual_manifest_seed_v1",
            issues: &issues
        )
        let safetyDocument: SafetyScopeDocument? = load(
            SafetyScopeDocument.self,
            resourceName: "safety_scope_seed_v1",
            issues: &issues
        )
        let assetDocument: AssetPlaceholderDocument? = load(
            AssetPlaceholderDocument.self,
            resourceName: "asset_placeholders_v1",
            issues: &issues
        )

        let loaded = ManifestSnapshot(
            routes: routeDocument?.routes ?? [],
            screens: screenDocument?.screens ?? [],
            sections: sectionDocument?.sections ?? [],
            audioItems: audioDocument?.audio ?? [],
            visualItems: visualDocument?.visuals ?? [],
            safetyScopes: safetyDocument?.safetyScopes ?? [],
            soundSamplePlaceholders: assetDocument?.soundSamples ?? [],
            visualPlaceholders: assetDocument?.visualPlaceholders ?? [],
            issues: issues
        )

        let validationIssues = ManifestValidator.validate(loaded)
        let snapshot = ManifestSnapshot(
            routes: loaded.routes,
            screens: loaded.screens,
            sections: loaded.sections,
            audioItems: loaded.audioItems,
            visualItems: loaded.visualItems,
            safetyScopes: loaded.safetyScopes,
            soundSamplePlaceholders: loaded.soundSamplePlaceholders,
            visualPlaceholders: loaded.visualPlaceholders,
            issues: loaded.issues + validationIssues
        )

        #if DEBUG
        ManifestDebugLogger.log(snapshot)
        #endif

        return snapshot
    }

    private func load<T: Decodable>(
        _ type: T.Type,
        resourceName: String,
        issues: inout [ManifestIssue]
    ) -> T? {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            issues.append(
                ManifestIssue(
                    severity: .warning,
                    source: "\(resourceName).json",
                    message: "Manifest is missing from the app bundle."
                )
            )
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(type, from: data)
        } catch {
            issues.append(
                ManifestIssue(
                    severity: .error,
                    source: "\(resourceName).json",
                    message: "Manifest could not be decoded: \(error.localizedDescription)"
                )
            )
            return nil
        }
    }
}
