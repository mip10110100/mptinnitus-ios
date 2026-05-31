//
//  MindfulnessAnnexView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct MindfulnessAnnexView: View {
    let moduleLibrary: StaticModuleLibrary
    let exerciseDefinitionLibrary: ExerciseDefinitionLibrary
    @ObservedObject var audioController: AudioController

    @State private var expandedPracticeSections: Set<MindfulnessPracticeSectionID> = []

    private let reflectionExerciseIDs = [
        "I-011",
        "I-012",
        "I-013",
        "I-014"
    ]

    private let shortGuidedPracticeAudioOrder = [
        "mindfulness.one_breath",
        "mindfulness.name_it",
        "mindfulness.three_two_one",
        "mindfulness.sound_therapy_mindful"
    ]

    private let mediumGuidedPracticeAudioOrder = [
        "mindfulness.breathing_space",
        "mindfulness.body_anchor",
        "mindfulness.sound_shifting",
        "mindfulness.open_hands",
        "mindfulness.mindful_listening",
        "mindfulness.acceptance_present_moment",
        "mindfulness.body_scan"
    ]

    private let longGuidedPracticeAudioOrder = [
        "mindfulness.long_bodyscan"
    ]

    private let sleepGuidedPracticeAudioOrder = [
        "mindfulness.settling_sleep",
        "mindfulness.long_sleep"
    ]

    private var mindfulnessModule: StaticModule? {
        moduleLibrary.module(id: "mindfulness")
    }

    var body: some View {
        if let module = mindfulnessModule {
            practiceContent(module: module)
        } else {
            PlaceholderScreenView(
                title: AppTab.mindfulnessAnnex.fullTitle,
                subtitle: "The bundled module manifest is missing the Mindfulness module.",
                systemImage: AppTab.mindfulnessAnnex.systemImage
            )
        }
    }

    private func practiceContent(module: StaticModule) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                practiceSections(module: module)
                supportAndLearnSection
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(AppTab.mindfulnessAnnex.fullTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: AppTab.mindfulnessAnnex.systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(AppTab.mindfulnessAnnex.fullTitle)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Choose a guided practice or breathing rhythm. Mindfulness is attention flexibility, and one breath can count as practice.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func practiceSections(module: StaticModule) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            practiceDisclosure(
                id: .short,
                title: "Short Guided Practices"
            ) {
                audioCards(for: shortGuidedPracticeAudioOrder)
            }

            practiceDisclosure(
                id: .medium,
                title: "Medium Guided Practices"
            ) {
                audioCards(for: mediumGuidedPracticeAudioOrder)
            }

            practiceDisclosure(
                id: .long,
                title: "Long Guided Practices"
            ) {
                audioCards(for: longGuidedPracticeAudioOrder)
            }

            practiceDisclosure(
                id: .sleep,
                title: "Sleep-Oriented Practices"
            ) {
                audioCards(for: sleepGuidedPracticeAudioOrder)
            }

            practiceDisclosure(
                id: .breathing,
                title: "Breathing Pacer"
            ) {
                breathingPacerOptions(module: module)
            }

            practiceDisclosure(
                id: .reflection,
                title: "Reflection Exercises"
            ) {
                reflectionExerciseCards(module: module)
            }
        }
    }

    private func practiceDisclosure<Content: View>(
        id: MindfulnessPracticeSectionID,
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        DisclosureGroup(isExpanded: expansionBinding(for: id)) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                content()
            }
            .padding(.top, MPTTheme.Spacing.small)
        } label: {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func expansionBinding(for id: MindfulnessPracticeSectionID) -> Binding<Bool> {
        Binding {
            expandedPracticeSections.contains(id)
        } set: { isExpanded in
            if isExpanded {
                expandedPracticeSections.insert(id)
            } else {
                expandedPracticeSections.remove(id)
            }
        }
    }

    private func audioCards(for audioIDs: [String]) -> some View {
        let audioItems = audioReferences(for: audioIDs)

        return Group {
            if audioItems.isEmpty {
                Text("No guided recordings are available right now.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(audioItems) { reference in
                    AudioCard(
                        audio: mindfulnessPracticeDisplayAudio(reference.audio),
                        module: reference.module,
                        audioController: audioController,
                        showsContextLabel: false
                    )
                }
            }
        }
    }

    private func mindfulnessPracticeDisplayAudio(_ audio: StaticAudioItem) -> StaticAudioItem {
        StaticAudioItem(
            audioId: audio.audioId,
            sourceId: audio.sourceId,
            screenIds: audio.screenIds,
            title: mindfulnessPracticeDisplayTitle(for: audio.audioId) ?? audio.title,
            type: audio.type,
            assetPath: audio.assetPath,
            transcript: audio.transcript,
            playbackContext: audio.playbackContext
        )
    }

    private func mindfulnessPracticeDisplayTitle(for audioId: String) -> String? {
        switch audioId {
        case "mindfulness.one_breath":
            "One Breath Reset"
        case "mindfulness.name_it":
            "Name It and Widen"
        case "mindfulness.three_two_one":
            "3-2-1 Senses Mini"
        case "mindfulness.sound_therapy_mindful":
            "Sound Therapy Mindful Start"
        case "mindfulness.breathing_space":
            "Breathing Space"
        case "mindfulness.body_anchor":
            "Body Anchor and Room Sounds"
        case "mindfulness.sound_shifting":
            "Sound Shifting"
        case "mindfulness.open_hands":
            "Open Hands Grounding"
        case "mindfulness.mindful_listening":
            "Mindful Listening with Tinnitus and External Sound"
        case "mindfulness.acceptance_present_moment":
            "Acceptance in the Present Moment"
        case "mindfulness.body_scan":
            "Medium Length Body-Scan"
        case "mindfulness.long_bodyscan":
            "Full Body Scan"
        case "mindfulness.settling_sleep":
            "Settling Without Forcing Sleep"
        case "mindfulness.long_sleep":
            "Evening Body and Sound Wind-Down"
        default:
            nil
        }
    }

    private func breathingPacerOptions(module: StaticModule) -> some View {
        let visual = moduleLibrary.visual(id: "VIS-009")
        let visualModule = moduleLibrary.module(containingVisual: "VIS-009") ?? module

        return Group {
            if let visual {
                ForEach(BreathingPacerPattern.mindfulnessPracticeOptions) { pattern in
                    NavigationLink {
                        BreathingPacerVisualView(
                            visual: visual,
                            module: visualModule,
                            pattern: pattern
                        )
                    } label: {
                        HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                            Image(systemName: "circle.dashed")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(MPTTheme.accentColor)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(pattern.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(pattern.description)
                                    .font(.subheadline)
                                    .foregroundStyle(MPTTheme.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: MPTTheme.Spacing.small)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MPTTheme.secondaryText)
                        }
                        .padding(MPTTheme.Spacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                Text("Return to natural breathing or stop the practice if you feel uncomfortable, dizzy, short of breath, or more anxious.")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Breathing Pacer is not available right now.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
            }
        }
    }

    private func reflectionExerciseCards(module: StaticModule) -> some View {
        let exercises = reflectionExercises(module: module)

        return Group {
            if exercises.isEmpty {
                Text("Reflection exercises are not available right now.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(exercises, id: \.exerciseId) { exercise in
                    ExerciseLaunchCard(exercise: exercise, module: module)
                }
            }
        }
    }

    private func reflectionExercises(module: StaticModule) -> [StaticExerciseItem] {
        reflectionExerciseIDs.compactMap { exerciseId in
            guard exerciseDefinitionLibrary.definition(id: exerciseId) != nil else {
                return nil
            }

            return module.exercises.first { $0.exerciseId == exerciseId }
        }
    }

    private var supportAndLearnSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Learn and Support", subtitle: "Use education or another tool when practice needs adjustment.")

            relatedLink(
                title: "If Practice Feels Too Intense",
                subtitle: "Shorten the practice, add comfortable sound, use grounding, or switch to a distress tolerance tool.",
                systemImage: "lifepreserver",
                route: .module("distress_tolerance")
            )

            relatedLink(
                title: "Mindfulness education module",
                subtitle: "Review mindfulness as attention flexibility, not forced silence.",
                systemImage: "book",
                route: .module("mindfulness")
            )

            relatedLink(
                title: "Open Sound Therapy",
                subtitle: "Comfortable sound can make attention practice more accessible.",
                systemImage: "speaker.wave.2",
                route: .module("sound_therapy")
            )

            relatedLink(
                title: "Acceptance and Change",
                subtitle: "Use acceptance, both-and thinking, and values as a bridge into mindfulness.",
                systemImage: "arrow.triangle.branch",
                route: .module("acceptance_and_change")
            )
        }
    }

    private func relatedLink(
        title: String,
        subtitle: String,
        systemImage: String,
        route: AppRoute
    ) -> some View {
        NavigationLink(value: route) {
            HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(MPTTheme.accentColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: MPTTheme.Spacing.small)

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

    private func audioReferences(for audioIDs: [String]) -> [MindfulnessAudioReference] {
        audioIDs.compactMap { audioID in
            for module in moduleLibrary.modules {
                if let audio = module.audio.first(where: { $0.audioId == audioID }) {
                    return MindfulnessAudioReference(audio: audio, module: module)
                }
            }

            return nil
        }
    }
}

private enum MindfulnessPracticeSectionID: Hashable {
    case short
    case medium
    case long
    case sleep
    case breathing
    case reflection
}

private struct MindfulnessAudioReference: Identifiable {
    let audio: StaticAudioItem
    let module: StaticModule

    var id: String {
        audio.audioId
    }
}
