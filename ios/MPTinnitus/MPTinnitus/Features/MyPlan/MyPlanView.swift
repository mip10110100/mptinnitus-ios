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

    @Query private var myPlanItems: [MyPlanItemRecord]
    @Query private var journalEntries: [ThreeLinesJournalEntryRecord]

    init(moduleLibrary: StaticModuleLibrary = .empty) {
        self.moduleLibrary = moduleLibrary
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

                if activeItems.isEmpty {
                    emptyState
                } else {
                    savedItemsList
                }

                otherExercisesSection

                #if DEBUG
                localDataDebugPanel
                #endif
            }
            .padding(MPTTheme.Spacing.screen)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(AppTab.myPlan.fullTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: AppTab.myPlan.systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(AppTab.myPlan.fullTitle)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Save useful modules, education cards, audio cards, and exercise placeholders here. Items saved here stay on this device.")
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

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Label("No saved items yet", systemImage: "tray")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Use Add to My Plan on modules, education cards, audio cards, or exercise placeholders. Saved items are local to this device and can be removed later.")
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
            SectionHeader("Other Exercises", subtitle: "Exercise interactions are placeholders in this stage. You can save a placeholder to My Plan without saving responses.")

            if moduleLibrary.exerciseReferences.isEmpty {
                Text("No exercise placeholders are available from the bundled module manifest.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(MPTTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MPTTheme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(moduleLibrary.exerciseReferences) { reference in
                    ExerciseLaunchCard(exercise: reference.exercise, module: reference.module)
                }
            }
        }
    }

    #if DEBUG
    private var localDataDebugPanel: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Local Data Status")

            Text("Active My Plan items: \(activeItems.count)")
            Text("Archived My Plan items: \(myPlanItems.filter { $0.isArchived }.count)")
            Text("Active journal entries: \(journalEntries.filter { !$0.isArchived }.count)")
            Text("Storage: SwiftData local device store")
        }
        .font(.footnote.monospacedDigit())
        .foregroundStyle(MPTTheme.secondaryText)
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    #endif
}
