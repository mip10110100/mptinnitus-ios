//
//  LibraryView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct LibraryView: View {
    let moduleLibrary: StaticModuleLibrary
    let manifestSnapshot: ManifestSnapshot

    init(
        moduleLibrary: StaticModuleLibrary = .empty,
        manifestSnapshot: ManifestSnapshot = .empty
    ) {
        self.moduleLibrary = moduleLibrary
        self.manifestSnapshot = manifestSnapshot
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header

                if moduleLibrary.modules.isEmpty {
                    missingLibraryPlaceholder
                } else {
                    SectionHeader("Modules", subtitle: "Locked MVP module list from the Stage 04 source workbook.")
                    ModuleList(modules: moduleLibrary.modules)
                }

                #if DEBUG
                debugPanels
                #endif
            }
            .padding(MPTTheme.Spacing.screen)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(AppTab.library.fullTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: AppTab.library.systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(AppTab.library.fullTitle)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Browse static educational module overviews, audio transcript placeholders, and exercise placeholder routes.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var missingLibraryPlaceholder: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Text("Module library unavailable")
                .font(.headline)

            Text("module_library_v1.json is missing or malformed. The Stage 03 shell remains available while the development manifest is repaired.")
                .font(.body)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    #if DEBUG
    private var debugPanels: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                SectionHeader("Static Module Library")

                Text("Modules: \(moduleLibrary.modules.count)")
                Text("Cards: \(moduleLibrary.modules.reduce(0) { $0 + $1.cards.count })")
                Text("Audio: \(moduleLibrary.modules.reduce(0) { $0 + $1.audio.count })")
                Text("Exercises: \(moduleLibrary.modules.reduce(0) { $0 + $1.exercises.count })")

                ForEach(moduleLibrary.issues) { issue in
                    Label(issue.message, systemImage: issue.severity == .error ? "xmark.octagon" : "exclamationmark.triangle")
                        .font(.footnote)
                        .foregroundStyle(issue.severity == .error ? .red : .orange)
                }
            }
            .font(.footnote.monospacedDigit())
            .foregroundStyle(MPTTheme.secondaryText)
            .padding(MPTTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            ManifestDebugStatusView(snapshot: manifestSnapshot)
        }
    }
    #endif
}

#Preview {
    NavigationStack {
        LibraryView()
    }
}
