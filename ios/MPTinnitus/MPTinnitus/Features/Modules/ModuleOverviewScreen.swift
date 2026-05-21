import SwiftUI

struct ModuleOverviewScreen: View {
    let module: StaticModule
    let library: StaticModuleLibrary
    let exerciseDefinitionLibrary: ExerciseDefinitionLibrary
    @ObservedObject var audioController: AudioController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                moduleHeader

                learningSection

                if !implementedExercises.isEmpty {
                    practiceSection
                }

                if !module.relatedModules.isEmpty {
                    relatedModulesSection
                }

                if !module.safetyScopes.isEmpty {
                    ModuleSafetyScopeGroup(safetyScopes: module.safetyScopes)
                }
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground.ignoresSafeArea())
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var moduleHeader: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            HStack(alignment: .top, spacing: MPTTheme.Spacing.medium) {
                Image(systemName: module.systemImage)
                    .font(.title2)
                    .foregroundStyle(MPTTheme.accentColor)
                    .frame(width: 44, height: 44)
                    .background(MPTTheme.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 8) {
                    Text(module.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(module.purpose)
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                }
            }

            Text(module.overviewMarkdown)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if let overviewAudio {
                ModuleHeaderAudioControl(audio: overviewAudio, audioController: audioController)
            }
        }
        .padding(MPTTheme.Spacing.large)
        .background(MPTTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.35))
        )
    }

    private var learningSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                "Learn",
                subtitle: "Read the key ideas first, then use the practice tools when you want to try them."
            )

            ForEach(Array(module.cards.enumerated()), id: \.element.id) { index, card in
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    ExpandableContentCard(
                        card: card,
                        module: module,
                        initiallyExpanded: index < 3
                    )

                    ForEach(visualItems(for: card), id: \.visualId) { visual in
                        VisualReferenceCard(visual: visual, module: module)
                    }

                    ForEach(audioItems(for: card), id: \.audioId) { audio in
                        AudioCard(audio: audio, module: module, audioController: audioController)
                    }
                }
            }

            if !unmatchedVisualItems.isEmpty {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    SectionHeader(
                        "See This Idea",
                        subtitle: "These visuals support the ideas in this module."
                    )

                    ForEach(unmatchedVisualItems, id: \.visualId) { visual in
                        VisualReferenceCard(visual: visual, module: module)
                    }
                }
            }

            if !unmatchedAudioItems.isEmpty {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    SectionHeader(
                        "Additional Explanation",
                        subtitle: "Listen when you want a short spoken version of the topic."
                    )

                    ForEach(unmatchedAudioItems, id: \.audioId) { audio in
                        AudioCard(audio: audio, module: module, audioController: audioController)
                    }
                }
            }
        }
    }

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                "Practice",
                subtitle: "Choose an exercise or tool you may want to come back to."
            )

            ForEach(implementedExercises, id: \.exerciseId) { exercise in
                ExerciseLaunchCard(exercise: exercise, module: module)
            }
        }
    }

    private var implementedExercises: [StaticExerciseItem] {
        module.exercises.filter { exercise in
            exerciseDefinitionLibrary.definition(id: exercise.exerciseId) != nil
        }
    }

    private var relatedModulesSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                "Continue",
                subtitle: "Related sections that build on this topic."
            )

            ForEach(relatedModules, id: \.id) { related in
                ModuleCard(module: related)
            }
        }
    }

    private var overviewAudio: StaticAudioItem? {
        module.audio.first { audio in
            audio.screenIds.contains(module.screenId) && audio.type.localizedCaseInsensitiveContains("overview")
        } ?? module.audio.first { audio in
            audio.title == module.title
        } ?? module.audio.first { audio in
            audio.type.localizedCaseInsensitiveContains("overview")
        }
    }

    private var relatedModules: [StaticModule] {
        module.relatedModules.compactMap { link in
            library.modules.first { related in
                related.moduleId == link.moduleId
            }
        }
    }

    private func audioItems(for card: StaticContentCard) -> [StaticAudioItem] {
        module.audio.filter { audio in
            audio.audioId != overviewAudio?.audioId
                && (card.audioIds.contains(audio.audioId)
                    || audio.screenIds.contains(card.screenId)
                    || audio.screenIds.contains { screenDescriptor($0, matches: card.screenId) })
        }
    }

    private func visualItems(for card: StaticContentCard) -> [StaticVisualReference] {
        module.visuals.filter { visual in
            card.visualIds.contains(visual.visualId)
                || visual.screenId == card.screenId
                || screenDescriptor(visual.screenId, matches: card.screenId)
        }
    }

    private var unmatchedAudioItems: [StaticAudioItem] {
        let attachedIds = Set(module.cards.flatMap { card in
            audioItems(for: card).map(\.audioId)
        })

        return module.audio.filter { audio in
            audio.audioId != overviewAudio?.audioId && !attachedIds.contains(audio.audioId)
        }
    }

    private var unmatchedVisualItems: [StaticVisualReference] {
        let attachedIds = Set(module.cards.flatMap { card in
            visualItems(for: card).map(\.visualId)
        })

        return module.visuals.filter { visual in
            !attachedIds.contains(visual.visualId)
        }
    }

    private func screenDescriptor(_ descriptor: String, matches screenId: String) -> Bool {
        let normalizedDescriptor = descriptor
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: ";", with: " ")

        return normalizedDescriptor
            .split(whereSeparator: { $0.isWhitespace })
            .contains { String($0).trimmingCharacters(in: .punctuationCharacters) == screenId }
    }
}

private struct ModuleHeaderAudioControl: View {
    let audio: StaticAudioItem
    @ObservedObject var audioController: AudioController

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Listen")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(MPTTheme.secondaryText)

                    Text(audio.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                Spacer()

                Button {
                    if isCurrentAudio && audioController.isPlaying {
                        audioController.togglePlayPause()
                    } else {
                        audioController.play(audio: audio)
                    }
                } label: {
                    Label(isCurrentAudioPlaying ? "Pause" : "Play", systemImage: isCurrentAudioPlaying ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            TranscriptDisclosure(transcript: audio.transcript)
        }
        .padding(MPTTheme.Spacing.medium)
        .background(MPTTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.35))
        )
    }

    private var isCurrentAudioPlaying: Bool {
        isCurrentAudio && audioController.isPlaying
    }

    private var isCurrentAudio: Bool {
        audioController.currentAudioID == audio.audioId
    }
}

private struct ModuleSafetyScopeGroup: View {
    let safetyScopes: [StaticSafetyScope]
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                ForEach(safetyScopes, id: \.safetyScopeId) { safety in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(safety.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Text(safety.bodyMarkdown)
                            .font(.body)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.top, MPTTheme.Spacing.medium)
        } label: {
            HStack(spacing: MPTTheme.Spacing.medium) {
                Image(systemName: "exclamationmark.shield")
                    .foregroundStyle(MPTTheme.accentColor)
                Text("Safety and Scope")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
        .padding(MPTTheme.Spacing.large)
        .background(MPTTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.35))
        )
    }
}
