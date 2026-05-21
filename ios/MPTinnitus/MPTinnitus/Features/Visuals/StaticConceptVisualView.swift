//
//  StaticConceptVisualView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

enum StaticConceptVisualKind {
    case bodyMindLife
    case thoughtsFeelingsBehaviors
    case sleepTinnitusLoop
}

struct StaticConceptVisualView: View {
    let visual: StaticVisualReference
    let module: StaticModule
    let kind: StaticConceptVisualKind

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                VisualPlaceholderPanel(
                    title: placeholderTitle,
                    systemImage: systemImage,
                    message: placeholderMessage
                )

                conceptDiagram

                Text("This built-in diagram uses simple shapes and text. No external images or network loading are used.")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var conceptDiagram: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Text(diagramTitle)
                .font(.headline)

            switch kind {
            case .bodyMindLife:
                HStack(spacing: MPTTheme.Spacing.small) {
                    ConceptNode(title: "Body", detail: "Hearing, fatigue, stress physiology, sound sensitivity")
                    ConceptNode(title: "Mind", detail: "Attention, emotion, worry, meaning")
                    ConceptNode(title: "Life", detail: "Sleep, work, routines, relationships, activities")
                }
            case .thoughtsFeelingsBehaviors:
                VStack(spacing: MPTTheme.Spacing.small) {
                    ConceptNode(title: "Thoughts", detail: "What the mind predicts or explains")
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(MPTTheme.accentColor)
                    HStack(spacing: MPTTheme.Spacing.small) {
                        ConceptNode(title: "Feelings", detail: "Emotion and body arousal")
                        ConceptNode(title: "Behaviors", detail: "What you do next")
                    }
                    Text("Changing one part of the loop can create an off-ramp.")
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                }
            case .sleepTinnitusLoop:
                VStack(spacing: MPTTheme.Spacing.small) {
                    ConceptNode(title: "Tinnitus feels louder", detail: "Quiet, fatigue, and attention can make tinnitus more prominent.")
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(MPTTheme.accentColor)
                    ConceptNode(title: "Sleep gets harder", detail: "Pressure to sleep can increase alertness.")
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(MPTTheme.accentColor)
                    ConceptNode(title: "More fatigue and distress", detail: "The loop can feed itself, but small supports can interrupt it.")
                }
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var placeholderTitle: String {
        switch kind {
        case .bodyMindLife:
            "Body / Mind / Life visual guide"
        case .thoughtsFeelingsBehaviors:
            "Thoughts / Feelings / Behaviors visual guide"
        case .sleepTinnitusLoop:
            "Sleep-Tinnitus loop visual guide"
        }
    }

    private var placeholderMessage: String {
        switch kind {
        case .bodyMindLife:
            "This diagram shows the three-part view of tinnitus: body factors, mind factors, and daily-life context."
        case .thoughtsFeelingsBehaviors:
            "This diagram shows the thought, feeling, and behavior loop used in cognitive reframing."
        case .sleepTinnitusLoop:
            "This diagram shows the two-way relationship between tinnitus distress and sleep difficulty."
        }
    }

    private var diagramTitle: String {
        switch kind {
        case .bodyMindLife:
            "Three parts of the experience"
        case .thoughtsFeelingsBehaviors:
            "The loop"
        case .sleepTinnitusLoop:
            "A loop that can be interrupted"
        }
    }

    private var systemImage: String {
        switch kind {
        case .bodyMindLife:
            "circle.hexagongrid"
        case .thoughtsFeelingsBehaviors:
            "arrow.triangle.2.circlepath"
        case .sleepTinnitusLoop:
            "moon.zzz"
        }
    }
}

private struct ConceptNode: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(detail)
                .font(.caption)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
