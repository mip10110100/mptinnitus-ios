//
//  AppRoute.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import Foundation

enum AppRoute: Hashable, Identifiable {
    case aboutTinnitus
    case module(String)
    case exercise(String)
    case visual(String)
    case soundTherapyPlayer
    case tinnitusSoundEstimate
    case tinnitusCheckIn
    case safetyInformation
    case settings

    var id: String {
        routePath
    }

    var routePath: String {
        switch self {
        case .aboutTinnitus:
            "/about/overview"
        case .module(let moduleId):
            "/module/\(moduleId)"
        case .exercise(let exerciseId):
            "/placeholder/exercise/\(exerciseId)"
        case .visual(let visualId):
            "/visual/\(visualId)"
        case .soundTherapyPlayer:
            AppTab.soundAnnex.route
        case .tinnitusSoundEstimate:
            "/sound/tinnitus-sound-estimate"
        case .tinnitusCheckIn:
            "/check-in/tinnitus"
        case .safetyInformation:
            "/safety"
        case .settings:
            "/settings"
        }
    }

    var title: String {
        switch self {
        case .aboutTinnitus:
            "About Tinnitus"
        case .module:
            "Module"
        case .exercise:
            "Exercise"
        case .visual:
            "Visual Tool"
        case .soundTherapyPlayer:
            AppTab.soundAnnex.fullTitle
        case .tinnitusSoundEstimate:
            "Tinnitus sound estimate"
        case .tinnitusCheckIn:
            "Tinnitus Check-In"
        case .safetyInformation:
            "Safety Information"
        case .settings:
            "Settings"
        }
    }
}
