//
//  MyPlanSavedItemRow.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct MyPlanSavedItemRow: View {
    let item: MyPlanItemRecord

    private var sourceTypeLabel: String {
        MyPlanSourceType(rawValue: item.sourceType)?.displayName ?? item.sourceType
    }

    var body: some View {
        HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "checkmark.square.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(MPTTheme.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if !item.summary.isEmpty {
                    Text(item.summary)
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .lineLimit(3)
                }

                Text("\(sourceTypeLabel) | \(item.moduleID)")
                    .font(.caption)
                    .foregroundStyle(MPTTheme.secondaryText)
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
}
