//
//  ExerciseFieldEditor.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ExerciseFieldEditor: View {
    let field: ExerciseFieldDefinition
    @Binding var text: String
    @Binding var checkbox: Bool
    let computedValue: String

    var body: some View {
        switch field.type {
        case .staticInfo:
            staticInfo
        case .checkbox:
            Toggle(field.label, isOn: $checkbox)
        case .computedText:
            computedText
        case .shortText:
            textInput(lineLimit: 1...2)
        case .longText, .optionalText:
            textInput(lineLimit: 3...6)
        }
    }

    private var staticInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(field.label)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(field.helperText)
                .font(.body)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var computedText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(field.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MPTTheme.secondaryText)

            Text(computedValue.isEmpty ? "The preview will appear as you type." : computedValue)
                .font(.body)
                .foregroundStyle(computedValue.isEmpty ? MPTTheme.secondaryText : .primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(MPTTheme.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private func textInput(lineLimit: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(field.label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MPTTheme.secondaryText)

                if field.isRequired {
                    Text("Required")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.red)
                }
            }

            TextField(field.prompt, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(lineLimit)

            if !field.helperText.isEmpty {
                Text(field.helperText)
                    .font(.caption)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
