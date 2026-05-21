//
//  ModuleCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ModuleCard: View {
    let module: StaticModule

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            NavigationLink(value: AppRoute.module(module.moduleId)) {
                HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                    Image(systemName: module.systemImage)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(MPTTheme.accentColor)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(module.title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(module.purpose)
                            .font(.subheadline)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .lineLimit(3)
                    }

                    Spacer(minLength: MPTTheme.Spacing.small)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MPTTheme.secondaryText)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
