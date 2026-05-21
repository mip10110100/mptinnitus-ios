//
//  ExerciseEntryScreen.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftData
import SwiftUI

struct ExerciseEntryScreen: View {
    let definition: ExerciseDefinition
    let exercise: StaticExerciseItem
    let module: StaticModule

    @Environment(\.modelContext) private var modelContext
    @Query private var exerciseEntries: [ExerciseEntryRecord]
    @Query private var myPlanItems: [MyPlanItemRecord]

    @State private var fieldValues: [String: String] = [:]
    @State private var checkboxValues: [String: Bool] = [:]
    @State private var editingEntry: ExerciseEntryRecord?
    @State private var entryPendingArchive: ExerciseEntryRecord?
    @State private var isShowingArchiveConfirmation = false
    @State private var statusMessage: String?
    @State private var errorMessage: String?

    private var activeEntries: [ExerciseEntryRecord] {
        ExerciseEntryStore.activeEntries(for: definition.exerciseId, in: exerciseEntries)
    }

    private var computedValues: [String: String] {
        ExerciseEntryStore.makeComputedValues(
            definition: definition,
            fieldValues: fieldValues
        )
    }

    private var exerciseMyPlanDescriptor: MyPlanItemDescriptor {
        .exercise(exercise, module: module)
    }

    private var activeMyPlanItem: MyPlanItemRecord? {
        MyPlanLocalStore.activeItem(in: myPlanItems, matching: exerciseMyPlanDescriptor)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                formSection
                saveSection
                pastEntriesSection
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(definition.title)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete this exercise entry?",
            isPresented: $isShowingArchiveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Entry", role: .destructive) {
                archivePendingEntry()
            }

            Button("Cancel", role: .cancel) {
                entryPendingArchive = nil
            }
        } message: {
            Text("This removes the saved response from this device. It does not change the exercise or My Plan item.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(definition.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text(definition.purpose)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(definition.instructions)
                .font(.subheadline)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            SourceIDDebugLabel("exercise", ids: [definition.exerciseId, definition.screenId, module.moduleId])
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                editingEntry == nil ? "New Entry" : "Editing Entry",
                subtitle: editingEntry == nil ? "Unsaved text is not kept if you leave this screen." : "Save updates this selected entry. Start New Entry to repeat the exercise."
            )

            ForEach(definition.fields) { field in
                ExerciseFieldEditor(
                    field: field,
                    text: textBinding(for: field.fieldId),
                    checkbox: checkboxBinding(for: field.fieldId),
                    computedValue: computedValues[field.fieldId] ?? ""
                )
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var saveSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader("Save")

            MyPlanSaveToggle(descriptor: exerciseMyPlanDescriptor)

            Text("Add this exercise to My Plan saves the exercise itself, not the written response.")
                .font(.footnote)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: MPTTheme.Spacing.small) {
                Button {
                    saveEntry()
                } label: {
                    Label("Save Entry", systemImage: "tray.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)

                if editingEntry != nil {
                    Button {
                        startNewEntry()
                    } label: {
                        Label("Start New Entry", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                }
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var pastEntriesSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Past Entries", subtitle: "Review, edit, repeat, or delete local entries for this exercise.")

            if activeEntries.isEmpty {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                    Label("No saved entries yet", systemImage: "tray")
                        .font(.headline)

                    Text("Save an entry above. Entries stay local to this device.")
                        .font(.body)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(MPTTheme.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MPTTheme.surfaceBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(activeEntries, id: \.id) { entry in
                    ExerciseEntryRow(
                        entry: entry,
                        definition: definition,
                        editAction: {
                            loadEntry(entry)
                        },
                        archiveAction: {
                            entryPendingArchive = entry
                            isShowingArchiveConfirmation = true
                        }
                    )
                }
            }
        }
    }

    private func textBinding(for fieldId: String) -> Binding<String> {
        Binding(
            get: { fieldValues[fieldId, default: ""] },
            set: { fieldValues[fieldId] = $0 }
        )
    }

    private func checkboxBinding(for fieldId: String) -> Binding<Bool> {
        Binding(
            get: { checkboxValues[fieldId, default: false] },
            set: { checkboxValues[fieldId] = $0 }
        )
    }

    private func saveEntry() {
        statusMessage = nil
        errorMessage = nil

        if let validationMessage = ExerciseEntryStore.validate(
            definition: definition,
            fieldValues: fieldValues,
            checkboxValues: checkboxValues
        ) {
            errorMessage = validationMessage
            return
        }

        do {
            let entry = try ExerciseEntryStore.saveEntry(
                editing: editingEntry,
                definition: definition,
                fieldValues: fieldValues,
                checkboxValues: checkboxValues,
                computedValues: computedValues,
                isAddedToMyPlan: activeMyPlanItem != nil,
                myPlanItemID: activeMyPlanItem?.id,
                modelContext: modelContext
            )

            editingEntry = entry
            statusMessage = "Saved locally on this device."
        } catch {
            errorMessage = "Could not save this exercise entry."

            #if DEBUG
            print("[MPTinnitus][ExerciseEntry] Save failed for \(definition.exerciseId): \(error.localizedDescription)")
            #endif
        }
    }

    private func loadEntry(_ entry: ExerciseEntryRecord) {
        guard let payload = ExerciseEntryStore.decodePayload(entry) else {
            errorMessage = "Could not open this saved entry."
            return
        }

        editingEntry = entry
        fieldValues = payload.fieldValues
        checkboxValues = payload.checkboxValues
        statusMessage = "Editing a saved entry."
        errorMessage = nil
    }

    private func startNewEntry() {
        editingEntry = nil
        fieldValues = [:]
        checkboxValues = [:]
        statusMessage = "Ready for a new entry."
        errorMessage = nil
    }

    private func archivePendingEntry() {
        guard let entry = entryPendingArchive else {
            return
        }

        do {
            try ExerciseEntryStore.archive(entry, modelContext: modelContext)
            if editingEntry?.id == entry.id {
                startNewEntry()
            }
            entryPendingArchive = nil
            statusMessage = "Entry deleted locally."
        } catch {
            errorMessage = "Could not delete this exercise entry."

            #if DEBUG
            print("[MPTinnitus][ExerciseEntry] Delete failed for \(entry.id): \(error.localizedDescription)")
            #endif
        }
    }
}
