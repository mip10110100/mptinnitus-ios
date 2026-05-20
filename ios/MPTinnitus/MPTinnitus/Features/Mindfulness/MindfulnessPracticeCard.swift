//
//  MindfulnessPracticeCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct MindfulnessPracticeCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let route: AppRoute?
    let myPlanDescriptor: MyPlanItemDescriptor?
    let footer: String?

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            if let route {
                NavigationLink(value: route) {
                    cardContent(showsChevron: true)
                }
                .buttonStyle(.plain)
            } else {
                cardContent(showsChevron: false)
            }

            if let myPlanDescriptor {
                Divider()
                MyPlanSaveToggle(descriptor: myPlanDescriptor)
            }

            if let footer {
                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func cardContent(showsChevron: Bool) -> some View {
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

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MPTTheme.secondaryText)
            }
        }
    }
}
