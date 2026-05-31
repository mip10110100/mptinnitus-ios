//
//  TinnitusSoundProfile.swift
//  MPTinnitus
//
//  Created by Codex on 5/31/26.
//

import Foundation

enum TinnitusMatchConfidence: String, CaseIterable, Codable, Identifiable {
    case goodMatch = "good_match"
    case closeEnough = "close_enough"
    case notSure = "not_sure"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .goodMatch:
            "Good match"
        case .closeEnough:
            "Close enough"
        case .notSure:
            "Not sure"
        }
    }
}

enum TinnitusLaterality: String, CaseIterable, Codable, Identifiable {
    case left
    case right
    case both
    case notSure = "not_sure"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .left:
            "Left"
        case .right:
            "Right"
        case .both:
            "Both"
        case .notSure:
            "Not sure"
        }
    }
}

struct TinnitusSoundProfile: Codable, Equatable {
    let profileVersion: String
    var matchedFrequencyHz: Double
    var loudnessEstimate: Double?
    var matchConfidence: TinnitusMatchConfidence
    var laterality: TinnitusLaterality
    var createdAt: Date
    var updatedAt: Date

    static let currentProfileVersion = "1.0.0"
}
