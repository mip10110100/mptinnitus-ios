//
//  ExerciseLaunchCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct ExerciseLaunchCard: View {
    let exercise: StaticExerciseItem
    let module: StaticModule

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            NavigationLink(value: AppRoute.exercise(exercise.exerciseId)) {
                HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                    Image(systemName: "square.and.pencil")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(MPTTheme.accentColor)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(displayDescription)
                            .font(.subheadline)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: MPTTheme.Spacing.small)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MPTTheme.secondaryText)
                }
            }
            .buttonStyle(.plain)

            Divider()

            MyPlanSaveToggle(descriptor: .exercise(exercise, module: module))
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var displayDescription: String {
        var text = exercise.description
        let replacements = [
            "Launches the later ": "Open ",
            "Launches the ": "Open ",
            "In this stage it remains a placeholder route without saved results.": "Use this as a practice tool when you want to return to it.",
            "In this stage it remains a navigation placeholder.": "Use this when you want a quick way to choose where to begin.",
            "No response is saved in this stage.": "Use this as a practice tool when you want to return to it.",
            "Reminder settings are future local preferences only. No reminders are scheduled in this MVP.": "Reminder scheduling is not available yet.",
            "Reminders are not implemented in this stage.": "Reminder scheduling is not available yet."
        ]

        for (target, replacement) in replacements {
            text = text.replacingOccurrences(of: target, with: replacement)
        }

        return text
    }
}
