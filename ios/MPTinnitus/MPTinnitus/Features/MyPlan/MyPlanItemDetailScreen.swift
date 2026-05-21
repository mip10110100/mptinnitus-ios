//
//  MyPlanItemDetailScreen.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftData
import SwiftUI

struct MyPlanItemDetailScreen: View {
    let item: MyPlanItemRecord
    let moduleLibrary: StaticModuleLibrary

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var errorMessage: String?

    private var sourceTypeLabel: String {
        MyPlanSourceType(rawValue: item.sourceType)?.displayName ?? item.sourceType
    }

    private var module: StaticModule? {
        moduleLibrary.module(id: item.moduleID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                sourceDetails
                sourceNavigation
                removeSection
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle("Saved Item")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "checkmark.square.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(item.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            if !item.summary.isEmpty {
                Text(item.summary)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("This saved item stays on this device. Removing it only removes the My Plan marker; it does not change module content.")
                .font(.footnote)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var sourceDetails: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Source")
            labeledText("Type", sourceTypeLabel)
            labeledText("Module", module?.title ?? "Module not available")
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var sourceNavigation: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Open Source")

            if item.sourceType == MyPlanSourceType.exercisePlaceholder.rawValue {
                NavigationLink(value: AppRoute.exercise(item.sourceID)) {
                    sourceLinkLabel("Open Exercise", systemImage: "square.and.pencil")
                }
                .buttonStyle(.plain)
            }

            if let module {
                NavigationLink(value: AppRoute.module(module.moduleId)) {
                    sourceLinkLabel("Open \(module.title)", systemImage: module.systemImage)
                }
                .buttonStyle(.plain)
            } else if item.sourceType != MyPlanSourceType.exercisePlaceholder.rawValue {
                Text("The original module is not available right now.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var removeSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Button(role: .destructive) {
                removeItem()
            } label: {
                Label("Remove from My Plan", systemImage: "trash")
            }
            .buttonStyle(.bordered)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func sourceLinkLabel(_ title: String, systemImage: String) -> some View {
        HStack(spacing: MPTTheme.Spacing.medium) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(MPTTheme.accentColor)
                .frame(width: 28)

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MPTTheme.secondaryText)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func labeledText(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MPTTheme.secondaryText)

            Text(value.isEmpty ? "Not specified." : value)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func removeItem() {
        errorMessage = nil

        do {
            try MyPlanLocalStore.archive(item, modelContext: modelContext)
            dismiss()
        } catch {
            errorMessage = "Could not remove this item."

            #if DEBUG
            print("[MPTinnitus][MyPlan] Remove failed for \(item.id): \(error.localizedDescription)")
            #endif
        }
    }
}
