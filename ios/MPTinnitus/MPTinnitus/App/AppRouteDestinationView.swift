//
//  AppRouteDestinationView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct AppRouteDestinationView: View {
    let route: AppRoute
    let moduleLibrary: StaticModuleLibrary
    let exerciseDefinitionLibrary: ExerciseDefinitionLibrary
    @ObservedObject var audioController: AudioController
    @ObservedObject var soundSampleController: SoundSampleController

    var body: some View {
        switch route {
        case .aboutTinnitus:
            moduleOverview(moduleId: StaticModule.aboutTinnitusModuleId)
        case .module(let moduleId):
            moduleOverview(moduleId: moduleId)
        case .exercise(let exerciseId):
            exerciseDestination(exerciseId: exerciseId)
        case .visual(let visualId):
            visualDestination(visualId: visualId)
        case .soundTherapyPlayer:
            SoundTherapyAnnexView(
                moduleLibrary: moduleLibrary,
                sampleController: soundSampleController
            )
        case .tinnitusSoundEstimate:
            TinnitusSoundEstimateView(sampleController: soundSampleController)
        case .tinnitusCheckIn:
            TinnitusCheckInView(
                source: .myPlan,
                moduleLibrary: moduleLibrary
            )
        case .safetyInformation:
            SafetyInformationView()
        case .settings:
            SettingsPlaceholderView()
        }
    }

    @ViewBuilder
    private func moduleOverview(moduleId: String) -> some View {
        if let module = moduleLibrary.module(id: moduleId) {
            ModuleOverviewScreen(
                module: module,
                library: moduleLibrary,
                exerciseDefinitionLibrary: exerciseDefinitionLibrary,
                audioController: audioController
            )
        } else {
            PlaceholderScreenView(
                title: "Module Unavailable",
                subtitle: "This module is not available right now.",
                systemImage: "exclamationmark.triangle"
            )
        }
    }

    @ViewBuilder
    private func exerciseDestination(exerciseId: String) -> some View {
        let exercise = moduleLibrary.exercise(id: exerciseId)
        let module = moduleLibrary.module(containingExercise: exerciseId)

        if let definition = exerciseDefinitionLibrary.definition(id: exerciseId),
           let exercise,
           let module {
            ExerciseEntryScreen(
                definition: definition,
                exercise: exercise,
                module: module
            )
        } else {
            PlaceholderDetailScreen(
                exercise: exercise,
                module: module,
                exerciseId: exerciseId
            )
        }
    }

    @ViewBuilder
    private func visualDestination(visualId: String) -> some View {
        let visual = moduleLibrary.visual(id: visualId)
        let module = moduleLibrary.module(containingVisual: visualId)

        if let visual, let module {
            SpecializedVisualDestinationView(
                visual: visual,
                module: module
            )
        } else {
            PlaceholderScreenView(
                title: "Visual Tool Unavailable",
                subtitle: "This visual tool is not available right now.",
                systemImage: "exclamationmark.triangle"
            )
        }
    }
}
