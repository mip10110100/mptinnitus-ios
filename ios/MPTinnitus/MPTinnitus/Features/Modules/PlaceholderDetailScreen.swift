//
//  PlaceholderDetailScreen.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct PlaceholderDetailScreen: View {
    let exercise: StaticExerciseItem?
    let module: StaticModule?
    let exerciseId: String

    init(exercise: StaticExerciseItem?, module: StaticModule?, exerciseId: String) {
        self.exercise = exercise
        self.module = module
        self.exerciseId = exerciseId
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(MPTTheme.accentColor)

                    Text(exercise?.title ?? "Exercise Placeholder")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("This route is a Stage 04 static placeholder. The interactive exercise will be implemented in a later stage. No responses are saved here.")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(MPTTheme.Spacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MPTTheme.surfaceBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                if let exercise {
                    VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                        SectionHeader("Planned Exercise Shape")

                        labeledText("Inputs / actions", exercise.inputSummary)
                        labeledText("Default CTAs", exercise.defaultCTAs)
                        labeledText("My Plan behavior", exercise.addToMyPlanBehavior)
                        SourceIDDebugLabel("exercise", ids: [exercise.exerciseId, exercise.screenId, exercise.route])

                        if let module {
                            MyPlanSaveToggle(descriptor: .exercise(exercise, module: module))
                        }
                    }
                    .padding(MPTTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MPTTheme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    Text("Missing exercise manifest entry for \(exerciseId).")
                        .font(.body)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .padding(MPTTheme.Spacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(MPTTheme.surfaceBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(MPTTheme.Spacing.screen)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(exercise?.title ?? "Exercise")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func labeledText(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MPTTheme.secondaryText)

            Text(value.isEmpty ? "Not specified in Stage 04." : value)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
