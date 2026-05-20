//
//  ThreeLinesJournalLineEditor.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ThreeLinesJournalLineEditor: View {
    let abbreviation: String
    let title: String
    let prompt: String
    @Binding var text: String
    @Binding var isCheckOnly: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            HStack(alignment: .firstTextBaseline, spacing: MPTTheme.Spacing.small) {
                Text(abbreviation)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MPTTheme.accentColor)
                    .frame(width: 32, alignment: .leading)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: isCheckOnly ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCheckOnly ? MPTTheme.accentColor : MPTTheme.secondaryText)
                    .accessibilityHidden(true)
            }

            Toggle("Checkmark only", isOn: $isCheckOnly)
                .font(.subheadline)

            TextField(prompt, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
        }
    }
}
