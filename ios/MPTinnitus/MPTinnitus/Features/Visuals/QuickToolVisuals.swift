//
//  QuickToolVisuals.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct TugOfWarVisualView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                VisualPlaceholderPanel(
                    title: "Tug-of-War image placeholder",
                    systemImage: "figure.strengthtraining.traditional",
                    message: "A final tug-of-war image can replace this placeholder later without changing saved data."
                )

                VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                    Text("Dropping the rope does not mean tinnitus wins. It means you stop spending this moment on a fight that is not helping.")
                        .font(.title3.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("From there, your hands are free for a useful next action: sound support, a breath, a request for help, or one step back into life.")
                        .font(.body)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(MPTTheme.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MPTTheme.surfaceBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VisualExerciseLink(
                    exerciseId: "I-008",
                    title: "Open Tug-of-War Reflection"
                )
            }
        }
    }
}

struct STOPQuickCardView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    @State private var selectedIndex = 0

    private let steps = [
        QuickStep(title: "Stop", detail: "Pause before reacting. Let there be a small gap before the next action."),
        QuickStep(title: "Take a breath / take a step back", detail: "Use one breath or one physical step back to create room."),
        QuickStep(title: "Observe", detail: "Notice body, thoughts, emotions, urges, and what is happening around you."),
        QuickStep(title: "Proceed mindfully", detail: "Choose one next action that fits the moment and your values.")
    ]

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                StepThroughCard(
                    title: "STOP Quick Card",
                    steps: steps,
                    selectedIndex: $selectedIndex
                )

                Text("This is a quick visual tool, not crisis care. If you are unsafe, seek immediate help.")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                VisualExerciseLink(
                    exerciseId: "I-016",
                    title: "Open STOP Practice"
                )
            }
        }
    }
}

struct TIPPQuickCardView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    @State private var selectedIndex = 0

    private let steps = [
        QuickStep(title: "Temperature", detail: "Use safe temperature input to help shift body arousal. The goal is noticeable sensation, not pain."),
        QuickStep(title: "Intense movement when appropriate", detail: "Use movement only when it is safe for your body and situation."),
        QuickStep(title: "Paced breathing", detail: "Try a steady breathing rhythm that feels safe and workable."),
        QuickStep(title: "Paired muscle relaxation", detail: "Gently tense and release muscles if that is appropriate for your body.")
    ]

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                StepThroughCard(
                    title: "TIPP Quick Card",
                    steps: steps,
                    selectedIndex: $selectedIndex
                )

                Text("Use safe, appropriate options for your body and situation. The goal is not pain or injury.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                VisualExerciseLink(
                    exerciseId: "I-018",
                    title: "Open TIPP Practice"
                )
            }
        }
    }
}

struct SoundSensitivityStepsView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    private let steps = [
        "Choose music you enjoy.",
        "Use speakers, not headphones, unless otherwise guided by a clinician.",
        "Start with volume all the way down.",
        "Slowly raise volume until you begin to notice sensitivity.",
        "Turn it down slightly below that point.",
        "Listen for 10-15 minutes if comfortable.",
        "Track only nonjudgmentally if tracking at all."
    ]

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        NumberedStepRow(number: index + 1, text: step)
                    }
                }
                .padding(MPTTheme.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MPTTheme.surfaceBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text("Do not push into painful sound. The goal is comfortable, controlled sound below the sensitivity point.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                VisualExerciseLink(
                    exerciseId: "I-006",
                    title: "Open Enjoyable Music Speaker Exercise"
                )
            }
        }
    }
}

private struct QuickStep: Identifiable {
    let title: String
    let detail: String

    var id: String {
        title
    }
}

private struct StepThroughCard: View {
    let title: String
    let steps: [QuickStep]
    @Binding var selectedIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Text(title)
                .font(.headline)

            HStack(spacing: MPTTheme.Spacing.small) {
                ForEach(steps.indices, id: \.self) { index in
                    Button {
                        selectedIndex = index
                    } label: {
                        Text(String(steps[index].title.prefix(1)))
                            .font(.headline)
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(index == selectedIndex ? MPTTheme.accentColor : .secondary)
                    .accessibilityLabel(steps[index].title)
                }
            }

            VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                Text(steps[selectedIndex].title)
                    .font(.title3.weight(.semibold))

                Text(steps[selectedIndex].detail)
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(MPTTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct NumberedStepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: MPTTheme.Spacing.medium) {
            Text("\(number)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(MPTTheme.accentColor)
                .clipShape(Circle())

            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}
