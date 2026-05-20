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
        case .safetyInformation:
            "Safety Information"
        case .settings:
            "Settings"
        }
    }
}
