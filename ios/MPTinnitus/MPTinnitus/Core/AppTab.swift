//
//  AppTab.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case library
    case soundAnnex = "sound_annex"
    case mindfulnessAnnex = "mindfulness_annex"
    case myPlan = "my_plan"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .library:
            "Library"
        case .soundAnnex:
            "Sound"
        case .mindfulnessAnnex:
            "Mindfulness"
        case .myPlan:
            "My Plan"
        }
    }

    var fullTitle: String {
        switch self {
        case .library:
            "Library / Table of Contents"
        case .soundAnnex:
            "Sound Therapy Player"
        case .mindfulnessAnnex:
            "Mindfulness Practice"
        case .myPlan:
            "My Plan"
        }
    }

    var route: String {
        switch self {
        case .library:
            "/library"
        case .soundAnnex:
            "/annex/sound"
        case .mindfulnessAnnex:
            "/annex/mindfulness"
        case .myPlan:
            "/my-plan"
        }
    }

    var systemImage: String {
        switch self {
        case .library:
            "list.bullet.rectangle"
        case .soundAnnex:
            "speaker.wave.2"
        case .mindfulnessAnnex:
            "leaf"
        case .myPlan:
            "checkmark.circle"
        }
    }
}
