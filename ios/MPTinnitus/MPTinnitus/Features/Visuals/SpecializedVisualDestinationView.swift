//
//  SpecializedVisualDestinationView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct SpecializedVisualDestinationView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    var body: some View {
        switch visual.visualId {
        case "VIS-003":
            SoundTherapyThermometerView(visual: visual, module: module)
        case "VIS-009", "VIS-031":
            BreathingPacerVisualView(visual: visual, module: module)
        case "VIS-007", "VIS-032":
            TugOfWarVisualView(visual: visual, module: module)
        case "VIS-013":
            STOPQuickCardView(visual: visual, module: module)
        case "VIS-014":
            TIPPQuickCardView(visual: visual, module: module)
        case "VIS-005", "VIS-030":
            SoundSensitivityStepsView(visual: visual, module: module)
        case "VIS-001":
            StaticConceptVisualView(visual: visual, module: module, kind: .bodyMindLife)
        case "VIS-017", "VIS-033":
            StaticConceptVisualView(visual: visual, module: module, kind: .thoughtsFeelingsBehaviors)
        case "VIS-023", "VIS-034":
            StaticConceptVisualView(visual: visual, module: module, kind: .sleepTinnitusLoop)
        case "VIS-021":
            MVPStaticImageVisualView(visual: visual, module: module)
        default:
            GenericVisualPlaceholderView(visual: visual, module: module)
        }
    }
}

struct GenericVisualPlaceholderView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            VisualPlaceholderPanel(
                title: "\(visual.title) visual guide",
                systemImage: "photo",
                message: visual.description
            )

            Text("This visual uses a simple built-in guide for now.")
                .font(.body)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct VisualToolScaffold<Content: View>: View {
    let visual: StaticVisualReference
    let module: StaticModule
    private let content: Content

    init(
        visual: StaticVisualReference,
        module: StaticModule,
        @ViewBuilder content: () -> Content
    ) {
        self.visual = visual
        self.module = module
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                content
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(visual.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "rectangle.3.group")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(visual.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text(visual.description)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("This local visual helper is part of \(module.title). It does not save data.")
                .font(.subheadline)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            SourceIDDebugLabel("visual", ids: [visual.visualId, visual.screenId, module.moduleId])
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct VisualPlaceholderPanel: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))
                .overlay {
                    VStack(spacing: MPTTheme.Spacing.small) {
                        Image(systemName: systemImage)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(MPTTheme.accentColor)

                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(MPTTheme.Spacing.medium)
                }
                .frame(minHeight: 170)

            Text(message)
                .font(.body)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct VisualExerciseLink: View {
    let exerciseId: String
    let title: String

    var body: some View {
        NavigationLink(value: AppRoute.exercise(exerciseId)) {
            Label(title, systemImage: "square.and.pencil")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
    }
}

struct MVPStaticImageVisualView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            if let asset = MVPStaticVisualAsset.asset(for: visual.visualId) {
                MVPStaticVisualImageCard(
                    asset: asset,
                    caption: visual.description
                ) {
                    VisualPlaceholderPanel(
                        title: visual.title,
                        systemImage: "photo",
                        message: visual.description
                    )
                }
            } else {
                VisualPlaceholderPanel(
                    title: visual.title,
                    systemImage: "photo",
                    message: visual.description
                )
            }
        }
    }
}
