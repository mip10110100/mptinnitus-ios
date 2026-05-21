//
//  RootShellView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct RootShellView: View {
    @AppStorage("mptinnitus.firstLaunchDecision")
    private var firstLaunchDecisionRaw = FirstLaunchDecision.pending.rawValue

    @StateObject private var audioController = AudioController()
    @State private var selectedTab: AppTab = .library
    @State private var libraryPath: [AppRoute] = []
    @State private var soundPath: [AppRoute] = []
    @State private var mindfulnessPath: [AppRoute] = []
    @State private var myPlanPath: [AppRoute] = []
    @State private var isShowingWelcome = false
    @State private var welcomePresentedThisSession = false

    private let manifestSnapshot: ManifestSnapshot
    private let moduleLibrary: StaticModuleLibrary
    private let exerciseDefinitionLibrary: ExerciseDefinitionLibrary

    init(
        manifestSnapshot: ManifestSnapshot = ManifestLoader().loadSnapshot(),
        moduleLibrary: StaticModuleLibrary = StaticModuleLibraryLoader().loadLibrary(),
        exerciseDefinitionLibrary: ExerciseDefinitionLibrary = ExerciseDefinitionLoader().loadLibrary()
    ) {
        self.manifestSnapshot = manifestSnapshot
        self.moduleLibrary = moduleLibrary
        self.exerciseDefinitionLibrary = exerciseDefinitionLibrary
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            tabContent(for: .library, path: $libraryPath) {
                LibraryView(
                    moduleLibrary: moduleLibrary,
                    manifestSnapshot: manifestSnapshot
                )
            }

            tabContent(for: .soundAnnex, path: $soundPath) {
                SoundTherapyAnnexView(moduleLibrary: moduleLibrary)
            }

            tabContent(for: .mindfulnessAnnex, path: $mindfulnessPath) {
                MindfulnessAnnexView(
                    moduleLibrary: moduleLibrary,
                    audioController: audioController
                )
            }

            tabContent(for: .myPlan, path: $myPlanPath) {
                MyPlanView(
                    moduleLibrary: moduleLibrary,
                    exerciseDefinitionLibrary: exerciseDefinitionLibrary
                )
            }
        }
        .tint(MPTTheme.accentColor)
        .onAppear(perform: presentWelcomeIfNeeded)
        .sheet(isPresented: $isShowingWelcome) {
            FirstLaunchWelcomeView(
                startWithAboutTinnitus: startWithAboutTinnitus,
                exploreFirst: exploreFirst,
                remindMeLater: remindMeLater
            )
        }
    }

    private func tabContent<Content: View>(
        for tab: AppTab,
        path: Binding<[AppRoute]>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack(path: path) {
            content()
                .navigationDestination(for: AppRoute.self) { route in
                    AppRouteDestinationView(
                        route: route,
                        moduleLibrary: moduleLibrary,
                        exerciseDefinitionLibrary: exerciseDefinitionLibrary,
                        audioController: audioController
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            path.wrappedValue.append(.settings)
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel("Settings")
                    }
                }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AudioMiniPlayerPlaceholderView(audioController: audioController)
                .padding(.horizontal, MPTTheme.Spacing.screen)
                .padding(.vertical, MPTTheme.Spacing.small)
                .background(.regularMaterial)
        }
        .tabItem {
            Label(tab.title, systemImage: tab.systemImage)
        }
        .tag(tab)
    }

    private func presentWelcomeIfNeeded() {
        guard !welcomePresentedThisSession else {
            return
        }

        let decision = FirstLaunchDecision(rawValue: firstLaunchDecisionRaw) ?? .pending
        guard decision == .pending || decision == .remindLater else {
            return
        }

        welcomePresentedThisSession = true
        isShowingWelcome = true
    }

    private func startWithAboutTinnitus() {
        firstLaunchDecisionRaw = FirstLaunchDecision.startedAboutTinnitus.rawValue
        isShowingWelcome = false
        selectedTab = .library
        libraryPath = [.aboutTinnitus]
    }

    private func exploreFirst() {
        firstLaunchDecisionRaw = FirstLaunchDecision.exploreFirst.rawValue
        isShowingWelcome = false
    }

    private func remindMeLater() {
        firstLaunchDecisionRaw = FirstLaunchDecision.remindLater.rawValue
        isShowingWelcome = false
    }
}

#Preview {
    RootShellView()
}
