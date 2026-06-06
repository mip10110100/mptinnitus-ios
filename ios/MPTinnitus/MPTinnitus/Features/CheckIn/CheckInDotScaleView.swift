//
//  CheckInDotScaleView.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import SwiftUI

struct CheckInDotScaleView: View {
    @Binding var selection: CheckInScaleSelection?

    private let valueLabels: [(value: Int, label: String)] = [
        (0, "Not at all"),
        (1, "A little"),
        (2, "Mild"),
        (3, "Moderate"),
        (4, "Strong"),
        (5, "Very strong")
    ]

    private var selectedLabel: String {
        switch selection {
        case .notApplicable:
            "N/A"
        case .value(let value):
            "\(value) \(valueLabels.first { $0.value == value }?.label ?? "")"
        case nil:
            "Choose one option, or choose N/A."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            HStack(alignment: .center, spacing: MPTTheme.Spacing.small) {
                Button {
                    selection = .notApplicable
                } label: {
                    Text("N/A")
                        .font(.caption.weight(.semibold))
                        .frame(width: 44, height: 36)
                        .background(isSelected(.notApplicable) ? MPTTheme.accentColor.opacity(0.18) : Color(.tertiarySystemGroupedBackground))
                        .foregroundStyle(isSelected(.notApplicable) ? MPTTheme.accentColor : .primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Not applicable")
                .accessibilityHint("Stores this response as N/A, not zero.")

                ForEach(valueLabels, id: \.value) { option in
                    Button {
                        selection = .value(option.value)
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(isSelected(.value(option.value)) ? MPTTheme.accentColor : Color.clear)
                                .overlay(
                                    Circle()
                                        .stroke(MPTTheme.accentColor, lineWidth: 2)
                                )
                                .frame(width: 26, height: 26)

                            Text("\(option.value)")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(MPTTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(option.value), \(option.label)")
                }
            }

            Text(selectedLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            scaleLegend
        }
    }

    private var scaleLegend: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: MPTTheme.Spacing.small) {
                legendText("N/A")
                ForEach(valueLabels, id: \.value) { option in
                    legendText("\(option.value) \(option.label)")
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                legendText("N/A")
                ForEach(valueLabels, id: \.value) { option in
                    legendText("\(option.value) \(option.label)")
                }
            }
        }
    }

    private func legendText(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(MPTTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func isSelected(_ option: CheckInScaleSelection) -> Bool {
        selection == option
    }
}
