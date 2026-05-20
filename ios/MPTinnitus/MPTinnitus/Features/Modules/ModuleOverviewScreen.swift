//
//  ModuleOverviewScreen.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ModuleOverviewScreen: View {
    let module: StaticModule
    let library: StaticModuleLibrary
    @ObservedObject var audioController: AudioController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header

                if !module.visuals.isEmpty {
                    SectionHeader("Visual Tools", subtitle: "Open local visual helpers and simple interaction cards.")
                    ForEach(module.visuals) { visual in
                        VisualReferenceCard(visual: visual, module: module)
                    }
                }

                if !module.cards.isEmpty {
                    SectionHeader("Education Cards", subtitle: "Tap a card to expand the Stage 04 static content.")
                    ForEach(module.cards) { card in
                        ExpandableContentCard(card: card, module: module)
                    }
                }

                if !module.safetyScopes.isEmpty {
                    SectionHeader("Safety And Scope")
                    ForEach(module.safetyScopes) { safetyScope in
                        SafetyScopeCard(safetyScope: safetyScope)
                    }
                }

                if !module.audio.isEmpty {
                    SectionHeader("Audio", subtitle: "Play uses bundled local m4a files when present. Transcript starts collapsed.")
                    ForEach(module.audio) { audio in
                        AudioCard(audio: audio, module: module, audioController: audioController)
                    }
                }

                if !module.exercises.isEmpty {
                    SectionHeader("Exercise Placeholders", subtitle: "These routes are static placeholders until later stages.")
                    ForEach(module.exercises) { exercise in
                        ExerciseLaunchCard(exercise: exercise, module: module)
                    }
                }

                if !module.relatedModules.isEmpty {
                    SectionHeader("Continue")
                    relatedLinks
                }
            }
            .padding(MPTTheme.Spacing.screen)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: module.systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(module.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text(module.purpose)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if !module.overviewMarkdown.isEmpty {
                Text(module.overviewMarkdown)
                    .font(.subheadline)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            SourceIDDebugLabel("module", ids: [module.moduleId, module.screenId, module.route])
            SourceIDDebugLabel("screens", ids: module.sourceScreenIds)
            SourceIDDebugLabel("visuals", ids: module.visuals.map(\.visualId))

            MyPlanSaveToggle(descriptor: .module(module))
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var relatedLinks: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            ForEach(module.relatedModules) { link in
                if library.module(id: link.moduleId) != nil {
                    NavigationLink(value: AppRoute.module(link.moduleId)) {
                        HStack {
                            Text(link.title)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MPTTheme.secondaryText)
                        }
                        .padding(MPTTheme.Spacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(MPTTheme.surfaceBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
