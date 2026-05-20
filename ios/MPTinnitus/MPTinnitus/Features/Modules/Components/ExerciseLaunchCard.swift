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

                        Text(exercise.description)
                            .font(.subheadline)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        SourceIDDebugLabel("exercise", ids: [exercise.exerciseId, exercise.screenId])
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
}
