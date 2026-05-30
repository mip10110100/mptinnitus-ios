//
//  MindfulnessAnnexView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct MindfulnessAnnexView: View {
    let moduleLibrary: StaticModuleLibrary
    @ObservedObject var audioController: AudioController

    private let guidedMindfulnessAudioOrder = [
        "mindfulness.long_bodyscan",
        "mindfulness.acceptance_present_moment",
        "mindfulness.body_scan",
        "mindfulness.mindful_listening",
        "mindfulness.sound_therapy_mindful",
        "mindfulness.three_two_one",
        "mindfulness.name_it",
        "mindfulness.one_breath",
        "mindfulness.open_hands",
        "mindfulness.sound_shifting",
        "mindfulness.body_anchor",
        "mindfulness.breathing_space"
    ]

    private let sleepMindfulnessAudioOrder = [
        "mindfulness.long_sleep",
        "mindfulness.settling_sleep"
    ]

    private var mindfulnessModule: StaticModule? {
        moduleLibrary.module(id: "mindfulness")
    }

    var body: some View {
        if let module = mindfulnessModule {
            annexContent(module: module)
        } else {
            PlaceholderScreenView(
                title: AppTab.mindfulnessAnnex.fullTitle,
                subtitle: "The bundled module manifest is missing the Mindfulness module.",
                systemImage: AppTab.mindfulnessAnnex.systemImage
            )
        }
    }

    private func annexContent(module: StaticModule) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                practiceNotPerfectCard
                practiceSection(module: module)
                audioPracticeSection()
                helpSection
                learnSection

                #if DEBUG
                debugPanel(module: module)
                #endif
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

            Text("Brief practices for attention flexibility, grounding, and listening. Use what is useful and stop or switch when a practice is not a fit.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var practiceNotPerfectCard: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Label("Practice, don't perfect", systemImage: "leaf")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Mindfulness is attention flexibility. It does not require silence, forced relaxation, or staring at tinnitus. One breath can count as practice.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Sound therapy can make practice more accessible. If mindfulness feels too intense, shorten the practice, add comfortable sound, use grounding, or switch to distress tolerance. If you save a practice to My Plan, that marker stays on this device.")
                .font(.footnote)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func practiceSection(module: StaticModule) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Practice Options", subtitle: "Open a short exercise, visual pacer, or support tool. Saving is optional.")

            exercisePracticeCard(
                module: module,
                exerciseId: "I-011",
                title: "Deep Breath Check-In",
                subtitle: "Use one breath as a brief present-moment reset.",
                systemImage: "wind"
            )

            MindfulnessPracticeCard(
                title: "Breathing Pacer",
                subtitle: "Follow a simple inhale, hold, and exhale visual guide. Adjust or stop if the pace does not fit.",
                systemImage: "circle.dashed",
                route: .visual("VIS-009"),
                myPlanDescriptor: nil,
                footer: "Visual breathing guide"
            )

            exercisePracticeCard(
                module: module,
                exerciseId: "I-012",
                title: "3-2-1 Senses",
                subtitle: "Widen attention beyond tinnitus with quick sensory noticing.",
                systemImage: "hand.point.up.left"
            )

            exercisePracticeCard(
                module: module,
                exerciseId: "I-013",
                title: "Mindful Listening",
                subtitle: "Practice hearing tinnitus as one sound among many during an everyday activity.",
                systemImage: "ear"
            )

            exercisePracticeCard(
                module: module,
                exerciseId: "I-014",
                title: "Sound Shifting",
                subtitle: "Move attention between tinnitus, external sound, the body, and the room.",
                systemImage: "arrow.left.arrow.right"
            )

            MindfulnessPracticeCard(
                title: "When Mindfulness Feels Hard",
                subtitle: "Shorten the practice, add comfortable sound, use grounding, or switch to a distress tolerance tool.",
                systemImage: "lifepreserver",
                route: .module("distress_tolerance"),
                myPlanDescriptor: nil,
                footer: "Audio guidance is available below."
            )
        }
    }

    private func exercisePracticeCard(
        module: StaticModule,
        exerciseId: String,
        title: String,
        subtitle: String,
        systemImage: String
    ) -> some View {
        let exercise = module.exercises.first { $0.exerciseId == exerciseId }
        return MindfulnessPracticeCard(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            route: .exercise(exerciseId),
            myPlanDescriptor: exercise.map { MyPlanItemDescriptor.exercise($0, module: module) },
            footer: exercise == nil ? "This exercise is not available right now." : "Practice tool"
        )
    }

    private func audioPracticeSection() -> some View {
        let guidedAudioItems = audioReferences(for: guidedMindfulnessAudioOrder)
        let sleepAudioItems = audioReferences(for: sleepMindfulnessAudioOrder)

        return VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Guided Mindfulness Practices", subtitle: "These guided practices can be used on their own or alongside skills from the program. They are single-play recordings, not continuous sound therapy loops.")

            if guidedAudioItems.isEmpty {
                Text("No guided mindfulness recordings are available right now.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(MPTTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MPTTheme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(guidedAudioItems) { reference in
                    AudioCard(
                        audio: reference.audio,
                        module: reference.module,
                        audioController: audioController
                    )
                }
            }

            if !sleepAudioItems.isEmpty {
                SectionHeader("Sleep-Oriented Guided Practices", subtitle: "Use these as single-play wind-down supports when they fit the moment.")
                    .padding(.top, MPTTheme.Spacing.medium)

                ForEach(sleepAudioItems) { reference in
                    AudioCard(
                        audio: reference.audio,
                        module: reference.module,
                        audioController: audioController
                    )
                }
            }
        }
    }

    private var helpSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("If Practice Feels Too Intense", subtitle: "Mindfulness is optional and adjustable.")

            relatedLink(
                title: "Open Distress Tolerance",
                subtitle: "Use STOP, TIPP, temperature, or grounding when cooling the moment down is the better next step.",
                systemImage: "hand.raised",
                route: .module("distress_tolerance")
            )

            relatedLink(
                title: "Open Sound Therapy",
                subtitle: "Comfortable sound can make attention practice more accessible.",
                systemImage: "speaker.wave.2",
                route: .module("sound_therapy")
            )
        }
    }

    private var learnSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Learn", subtitle: "Review the education connected to these practices.")

            relatedLink(
                title: "Mindfulness education module",
                subtitle: "Review mindfulness as attention flexibility, not forced silence.",
                systemImage: "book",
                route: .module("mindfulness")
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

    #if DEBUG
    private func debugPanel(module: StaticModule) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Mindfulness Annex Debug")
            Text("Practice exercises: I-011, I-012, I-013, I-014")
            Text("Breathing visual: VIS-009")
            Text("Guided mindfulness audio cards: \(audioReferences(for: guidedMindfulnessAudioOrder).count)")
            Text("Sleep-oriented audio cards: \(audioReferences(for: sleepMindfulnessAudioOrder).count)")
        }
        .font(.footnote.monospacedDigit())
        .foregroundStyle(MPTTheme.secondaryText)
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    #endif
}

private struct MindfulnessAudioReference: Identifiable {
    let audio: StaticAudioItem
    let module: StaticModule

    var id: String {
        audio.audioId
    }
}
