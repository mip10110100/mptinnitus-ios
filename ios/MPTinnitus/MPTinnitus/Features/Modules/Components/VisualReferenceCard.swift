//
//  VisualReferenceCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct VisualReferenceCard: View {
    let visual: StaticVisualReference
    let module: StaticModule

    var body: some View {
        NavigationLink(value: AppRoute.visual(visual.visualId)) {
            HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                Image(systemName: iconName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(MPTTheme.accentColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(visual.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(visual.description)
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    SourceIDDebugLabel("visual", ids: [visual.visualId, visual.screenId, module.moduleId])
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

    private var iconName: String {
        switch visual.visualId {
        case "VIS-003":
            "slider.horizontal.3"
        case "VIS-009", "VIS-031":
            "lungs"
        case "VIS-013":
            "pause.circle"
        case "VIS-014":
            "thermometer.medium"
        case "VIS-001", "VIS-017", "VIS-023", "VIS-033", "VIS-034":
            "circle.hexagongrid"
        default:
            "rectangle.3.group"
        }
    }
}
