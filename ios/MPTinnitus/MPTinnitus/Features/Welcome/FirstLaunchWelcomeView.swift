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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                    VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                        Image(systemName: "ear.and.waveform")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(MPTTheme.accentColor)

                        Text("Welcome to MPTinnitus")
                            .font(.title2.weight(.semibold))

                        Text("Choose a starting point for this local-only educational companion.")
                            .font(.body)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(MPTTheme.Spacing.large)
                    .background(MPTTheme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

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
                .padding(MPTTheme.Spacing.screen)
            }
            .background(MPTTheme.screenBackground)
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled()
    }
}

#Preview {
    FirstLaunchWelcomeView(
        startWithAboutTinnitus: {},
        exploreFirst: {},
        remindMeLater: {}
    )
}
