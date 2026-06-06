//
//  FirstLaunchWelcomeView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct FirstLaunchWelcomeView: View {
    let startWithAboutTinnitus: () -> Void
    let exploreFirst: () -> Void
    let remindMeLater: () -> Void

    @State private var step: WelcomeStep = .bodyMindLife

    private let moduleLibrary = StaticModuleLibraryLoader().loadLibrary()

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .bodyMindLife:
                    welcomeScroll {
                        bodyMindLifeStep
                    }
                case .checkInOffer:
                    welcomeScroll {
                        checkInOfferStep
                    }
                case .checkIn:
                    TinnitusCheckInView(
                        source: .onboarding,
                        moduleLibrary: moduleLibrary,
                        showsIntro: false,
                        onComplete: { step = .startChoices },
                        onSkip: { step = .startChoices }
                    )
                case .startChoices:
                    welcomeScroll {
                        startChoicesStep
                    }
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled()
    }

    private func welcomeScroll<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView {
            content()
                .padding(MPTTheme.Spacing.screen)
        }
        .background(MPTTheme.screenBackground)
    }

    private var bodyMindLifeStep: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
            welcomeHeader(
                title: "Welcome to MPTinnitus",
                subtitle: "Tinnitus is shaped by the body, the mind, and daily life, not sound alone."
            )

            VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                Text("The ringing, buzzing, or hissing is real, and it can be distressing. It can also be affected by stress, attention, sleep, emotions, sound, and daily routines.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("This app starts with that bigger picture so you can choose a practical first step.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .welcomeCard()

            Button {
                step = .checkInOffer
            } label: {
                Label("Continue", systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var checkInOfferStep: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
            welcomeHeader(
                title: "Optional Tinnitus Check-In",
                subtitle: "Answer a few questions now, or skip and come back later."
            )

            VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                Text("Before you begin, you can answer a few questions about how tinnitus is affecting you right now. This helps build your starting plan. Your answers are for personal tracking and app recommendations only. This is not a diagnosis or a standardized clinical score. You can skip this and come back later.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Your check-in answers are stored on this device.")
                    .font(.subheadline)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .welcomeCard()

            VStack(spacing: MPTTheme.Spacing.medium) {
                Button {
                    step = .checkIn
                } label: {
                    Label("Start Check-In", systemImage: "checklist")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    step = .startChoices
                } label: {
                    Label("Skip for Now", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                NavigationLink {
                    SafetyInformationView()
                } label: {
                    Label("Safety Information", systemImage: "cross.case")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var startChoicesStep: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
            welcomeHeader(
                title: "Choose a Starting Point",
                subtitle: "You can start with the big-picture tinnitus overview or explore the app first."
            )

            VStack(spacing: MPTTheme.Spacing.medium) {
                Button(action: startWithAboutTinnitus) {
                    Label("Start with About Tinnitus", systemImage: "ear")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: exploreFirst) {
                    Label("Explore First", systemImage: "square.grid.2x2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(action: remindMeLater) {
                    Label("Remind Me Later", systemImage: "clock")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                NavigationLink {
                    SafetyInformationView()
                } label: {
                    Label("Safety Information", systemImage: "cross.case")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func welcomeHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "ear.and.waveform")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(title)
                .font(.title2.weight(.semibold))

            Text(subtitle)
                .font(.body)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .welcomeCard()
    }
}

private enum WelcomeStep {
    case bodyMindLife
    case checkInOffer
    case checkIn
    case startChoices
}

private extension View {
    func welcomeCard() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(MPTTheme.Spacing.large)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    FirstLaunchWelcomeView(
        startWithAboutTinnitus: {},
        exploreFirst: {},
        remindMeLater: {}
    )
}
