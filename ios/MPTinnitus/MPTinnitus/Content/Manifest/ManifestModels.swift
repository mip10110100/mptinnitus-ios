//
//  ManifestModels.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import Foundation

struct RouteManifestDocument: Codable, Equatable {
    let schemaVersion: String
    let routes: [RouteItem]
}

struct ScreenManifestDocument: Codable, Equatable {
    let schemaVersion: String
    let screens: [ScreenManifest]
}

struct ContentSectionDocument: Codable, Equatable {
    let schemaVersion: String
    let sections: [ContentSection]
}

struct AudioManifestDocument: Codable, Equatable {
    let schemaVersion: String
    let audio: [AudioManifestItem]
}

struct VisualManifestDocument: Codable, Equatable {
    let schemaVersion: String
    let visuals: [VisualManifestItem]
}

struct SafetyScopeDocument: Codable, Equatable {
    let schemaVersion: String
    let safetyScopes: [SafetyScopeItem]
}

struct AssetPlaceholderDocument: Codable, Equatable {
    let schemaVersion: String
    let soundSamples: [SoundSamplePlaceholder]
    let visualPlaceholders: [VisualPlaceholderItem]
}

struct ScreenManifest: Codable, Identifiable, Equatable {
    let screenId: String
    let route: String
    let moduleId: String
    let title: String
    let role: String
    let layout: String?
    let sections: [String]
    let audioIds: [String]
    let visualIds: [String]
    let interactionIds: [String]
    let primaryCtas: [String]
    let localDataKeys: [String]
    let safetyScopeId: String?
    let nextRoutes: [String]

    var id: String {
        screenId
    }
}

struct ContentSection: Codable, Identifiable, Equatable {
    let sectionId: String
    let screenId: String
    let title: String
    let bodyMarkdown: String
    let expandable: Bool
    let audioId: String?
    let transcriptCollapsed: Bool

    var id: String {
        sectionId
    }
}

struct AudioManifestItem: Codable, Identifiable, Equatable {
    let audioId: String
    let moduleId: String
    let topic: String
    let type: String
    let assetPath: String
    let transcript: String
    let embeddedForMVP: Bool
    let playbackContext: String

    var id: String {
        audioId
    }
}

struct VisualManifestItem: Codable, Identifiable, Equatable {
    let visualId: String
    let type: String
    let title: String
    let status: String
    let placeholderAllowed: Bool
    let acceptanceCriteria: [String]

    var id: String {
        visualId
    }
}

struct RouteItem: Codable, Identifiable, Equatable {
    let screenId: String
    let route: String
    let module: String
    let title: String
    let role: String

    var id: String {
        route
    }
}

struct SafetyScopeItem: Codable, Identifiable, Equatable {
    let safetyScopeId: String
    let title: String
    let bodyMarkdown: String
    let appliesToRoutes: [String]

    var id: String {
        safetyScopeId
    }
}

struct SoundSamplePlaceholder: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let assetPath: String
    let status: String
}

struct VisualPlaceholderItem: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let status: String
}
