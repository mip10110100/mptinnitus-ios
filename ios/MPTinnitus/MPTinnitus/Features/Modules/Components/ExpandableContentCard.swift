//
//  ExpandableContentCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ExpandableContentCard: View {
    let card: StaticContentCard
    let module: StaticModule

    @State private var isExpanded = false

    var body: some View {
        Group {
            if card.isExpandable {
                DisclosureGroup(isExpanded: $isExpanded) {
                    content
                        .padding(.top, MPTTheme.Spacing.small)
                } label: {
                    titleLabel
                }
            } else {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    titleLabel
                    content
                }
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var titleLabel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.title)
                .font(.headline)
                .foregroundStyle(.primary)

            SourceIDDebugLabel("section", ids: [card.sectionId, card.screenId])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Text(card.bodyMarkdown)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            SourceIDDebugLabel("audio", ids: card.audioIds)
            SourceIDDebugLabel("visual", ids: card.visualIds)

            MyPlanSaveToggle(descriptor: .contentCard(card, module: module))
        }
    }
}
