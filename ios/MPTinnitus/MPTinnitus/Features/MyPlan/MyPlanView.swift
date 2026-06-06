//
//  MyPlanView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftData
import SwiftUI

struct MyPlanView: View {
    let moduleLibrary: StaticModuleLibrary
    let exerciseDefinitionLibrary: ExerciseDefinitionLibrary

    @Query private var myPlanItems: [MyPlanItemRecord]
    @Query private var journalEntries: [ThreeLinesJournalEntryRecord]
    @StateObject private var checkInStore = CheckInStore()

    init(
        moduleLibrary: StaticModuleLibrary = .empty,
        exerciseDefinitionLibrary: ExerciseDefinitionLibrary = .empty
    ) {
        self.moduleLibrary = moduleLibrary
        self.exerciseDefinitionLibrary = exerciseDefinitionLibrary
    }

    private var activeItems: [MyPlanItemRecord] {
        myPlanItems
            .filter { !$0.isArchived }
            .sorted {
                if $0.sortOrder == $1.sortOrder {
                    return $0.createdAt > $1.createdAt
                }

                return $0.sortOrder > $1.sortOrder
            }
    }

    private var groupedItems: [(label: String, items: [MyPlanItemRecord])] {
        let groups = Dictionary(grouping: activeItems) { item in
            MyPlanSourceType(rawValue: item.sourceType)?.displayName ?? "Saved Item"
        }

        return groups.keys.sorted().map { key in
            (label: key, items: groups[key] ?? [])
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                threeLinesJournalSection
                checkInStartingPlanSection

                if activeItems.isEmpty {
                    emptyState
                } else {
                    savedItemsList
                }

                otherExercisesSection
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(AppTab.myPlan.fullTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkInStore.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: AppTab.myPlan.systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(AppTab.myPlan.fullTitle)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Save exercises and practice tools you want to revisit. Items saved here stay on this device.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var threeLinesJournalSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Three Lines Journal", subtitle: "ST = Sound Therapy, E = Emotional Regulation, M = Mindfulness.")

            NavigationLink {
                ThreeLinesJournalView(moduleLibrary: moduleLibrary)
            } label: {
                HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                    Image(systemName: "checklist")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(MPTTheme.accentColor)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Open Three Lines Journal")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("A short, nonjudgmental daily check-in. A few words, a checkmark, or not today can be enough.")
                            .font(.subheadline)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Entries stay on this device.")
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
            .buttonStyle(.plain)
        }
    }

    private var checkInStartingPlanSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Tinnitus Check-In", subtitle: "A private check-in for choosing a starting plan.")

            if let latestSession = checkInStore.latestSession {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    Text("Your starting plan")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("Use this as a starting point. You can change your plan anytime.")
                        .font(.body)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(latestSession.recommendations) { recommendation in
                        NavigationLink(value: AppRoute.module(recommendation.moduleId)) {
                            checkInRecommendationRow(recommendation)
                        }
                        .buttonStyle(.plain)
                    }

                    let trendMessages = CheckInScoring.trendMessages(
                        latest: latestSession,
                        previous: checkInStore.previousSession
                    )
                    if !trendMessages.isEmpty {
                        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                            Text("Compared with last time")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)

                            ForEach(trendMessages, id: \.self) { message in
                                Label(message, systemImage: "arrow.triangle.2.circlepath")
                                    .font(.subheadline)
                                    .foregroundStyle(MPTTheme.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    } else {
                        Text("You have completed \(checkInStore.sessions.count) check-in\(checkInStore.sessions.count == 1 ? "" : "s").")
                            .font(.subheadline)
                            .foregroundStyle(MPTTheme.secondaryText)
                    }

                    NavigationLink(value: AppRoute.tinnitusCheckIn) {
                        Label("Retake Tinnitus Check-In", systemImage: "checklist")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Text("Your check-in answers are stored on this device.")
                        .font(.caption)
                        .foregroundStyle(MPTTheme.secondaryText)
                }
                .padding(MPTTheme.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MPTTheme.surfaceBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
                    Text("No check-in yet")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("Take a short check-in if you want a private starting plan based on how tinnitus is affecting you right now.")
                        .font(.body)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    NavigationLink(value: AppRoute.tinnitusCheckIn) {
                        Label("Start Tinnitus Check-In", systemImage: "checklist")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Text("This is not a diagnostic test or a standardized clinical measure.")
                        .font(.caption)
                        .foregroundStyle(MPTTheme.secondaryText)
                }
                .padding(MPTTheme.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MPTTheme.surfaceBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private func checkInRecommendationRow(_ recommendation: ModuleRecommendation) -> some View {
        HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: moduleLibrary.module(id: recommendation.moduleId)?.systemImage ?? "list.bullet.rectangle")
                .font(.title3.weight(.semibold))
                .foregroundStyle(MPTTheme.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(recommendation.reasonText)
                    .font(.subheadline)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MPTTheme.secondaryText)
        }
        .padding(MPTTheme.Spacing.small)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Label("No saved items yet", systemImage: "tray")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Use Add to My Plan on exercises and practice tools. Saved items are local to this device and can be removed whenever needed.")
                .font(.body)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var savedItemsList: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
            ForEach(groupedItems, id: \.label) { group in
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                    SectionHeader(group.label)

                    ForEach(group.items, id: \.id) { item in
                        NavigationLink {
                            MyPlanItemDetailScreen(item: item, moduleLibrary: moduleLibrary)
                        } label: {
                            MyPlanSavedItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var otherExercisesSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Other Exercises", subtitle: "Browse practice tools from across the Library.")

            if implementedExerciseReferences.isEmpty {
                Text("No exercise practice tools are available from the bundled module library.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(MPTTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MPTTheme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(implementedExerciseReferences) { reference in
                    ExerciseLaunchCard(exercise: reference.exercise, module: reference.module)
                }
            }
        }
    }

    private var implementedExerciseReferences: [StaticExerciseReference] {
        moduleLibrary.exerciseReferences.filter { reference in
            exerciseDefinitionLibrary.definition(id: reference.exercise.exerciseId) != nil
        }
    }
}
