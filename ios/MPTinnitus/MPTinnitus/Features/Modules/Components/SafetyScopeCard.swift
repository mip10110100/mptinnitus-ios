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
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Label(safetyScope.title, systemImage: "cross.case")
                .font(.headline)
                .foregroundStyle(.primary)

            Text(safetyScope.bodyMarkdown)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            SourceIDDebugLabel("safety", ids: [safetyScope.safetyScopeId, safetyScope.screenId])
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
