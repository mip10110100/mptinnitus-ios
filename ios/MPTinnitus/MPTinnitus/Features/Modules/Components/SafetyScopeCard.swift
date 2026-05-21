//
//  SafetyScopeCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct SafetyScopeCard: View {
    let safetyScope: StaticSafetyScope

    var body: some View {
        DisclosureGroup {
            Text(safetyScope.bodyMarkdown)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, MPTTheme.Spacing.small)
        } label: {
            Label(safetyScope.title, systemImage: "cross.case")
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
