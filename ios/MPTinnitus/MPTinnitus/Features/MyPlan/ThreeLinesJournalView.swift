//
//  ThreeLinesJournalView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftData
import SwiftUI

struct ThreeLinesJournalView: View {
    let moduleLibrary: StaticModuleLibrary

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var journalEntries: [ThreeLinesJournalEntryRecord]

    @State private var selectedDate = Date()
    @State private var soundTherapyText = ""
    @State private var emotionalRegulationText = ""
    @State private var mindfulnessText = ""
    @State private var notes = ""
    @State private var soundTherapyCheckOnly = false
    @State private var emotionalRegulationCheckOnly = false
    @State private var mindfulnessCheckOnly = false
    @State private var statusMessage: String?
    @State private var errorMessage: String?
    @State private var entryPendingArchive: ThreeLinesJournalEntryRecord?
    @State private var isShowingArchiveConfirmation = false

    private var activeEntries: [ThreeLinesJournalEntryRecord] {
        ThreeLinesJournalStore.activeEntries(from: journalEntries)
    }

    private var selectedDateEntry: ThreeLinesJournalEntryRecord? {
        ThreeLinesJournalStore.activeEntry(for: selectedDate, in: journalEntries)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                helpCard
                entryForm
                pastEntriesSection
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle("Three Lines Journal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadEntry(for: selectedDate)
        }
        .onChange(of: selectedDate) { _, newDate in
            loadEntry(for: newDate)
        }
        .confirmationDialog(
            "Delete this journal entry?",
            isPresented: $isShowingArchiveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Journal Entry", role: .destructive) {
                archivePendingEntry()
            }

            Button("Cancel", role: .cancel) {
                entryPendingArchive = nil
            }
        } message: {
            Text("This removes the entry from the past-entry list on this device. It does not affect My Plan items or app content.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "checklist")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text("Three Lines Journal")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("A short daily check-in for Sound Therapy, Emotional Regulation, and Mindfulness. Entries stay on this device.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var helpCard: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                Text("The Three Lines Journal is meant to keep practice manageable. ST stands for Sound Therapy, E stands for Emotional Regulation, and M stands for Mindfulness. The goal is not to write a long journal entry or prove progress. A few words, a checkmark, or \"not today\" can be enough.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("If one line is blank for several days, that may show low-hanging fruit rather than failure. If you are unsure how to use it, start with the Sound Therapy and Mindfulness sections. The emotional regulation line is built from tools throughout the app, especially Acceptance and Change, Distress Tolerance, Cognitive Reframing, and Confidence and Communication.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Keep this brief and practical. Do not use the journal as a crisis record, medical diagnosis log, or severity score.")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                supportLinks
            }
            .padding(.top, MPTTheme.Spacing.small)
        } label: {
            Label("How to use ST / E / M", systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var supportLinks: some View {
        HStack(spacing: MPTTheme.Spacing.small) {
            NavigationLink(value: AppRoute.module("sound_therapy")) {
                Label("Sound Therapy", systemImage: "speaker.wave.2")
            }
            .buttonStyle(.bordered)

            NavigationLink(value: AppRoute.module("mindfulness")) {
                Label("Mindfulness", systemImage: "leaf")
            }
            .buttonStyle(.bordered)
        }
    }

    private var entryForm: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader(
                selectedDateEntry == nil ? "New Entry" : "Edit Entry",
                subtitle: selectedDateEntry == nil ? "One short check-in for the selected date." : "An active entry already exists for this date."
            )

            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)

            ThreeLinesJournalLineEditor(
                abbreviation: "ST",
                title: "Sound Therapy",
                prompt: "A few words, a checkmark, or not today.",
                text: $soundTherapyText,
                isCheckOnly: $soundTherapyCheckOnly
            )

            ThreeLinesJournalLineEditor(
                abbreviation: "E",
                title: "Emotional Regulation",
                prompt: "A skill, a moment, or not today.",
                text: $emotionalRegulationText,
                isCheckOnly: $emotionalRegulationCheckOnly
            )

            ThreeLinesJournalLineEditor(
                abbreviation: "M",
                title: "Mindfulness",
                prompt: "A practice, a pause, or not today.",
                text: $mindfulnessText,
                isCheckOnly: $mindfulnessCheckOnly
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Optional note")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MPTTheme.secondaryText)

                TextField("Optional short note", text: $notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
            }

            Button {
                saveEntry()
            } label: {
                Label("Save Entry", systemImage: "tray.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)

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
            SectionHeader("Past Entries", subtitle: "Review, edit, or delete local journal entries.")

            if activeEntries.isEmpty {
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                    Label("No journal entries yet", systemImage: "calendar")
                        .font(.headline)

                    Text("Save a few words or checkmarks above. The past-entry list will stay local to this device.")
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
                    ThreeLinesJournalEntryRow(
                        entry: entry,
                        editAction: {
                            selectedDate = entry.entryDate
                            loadEntry(for: entry.entryDate)
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

    private func loadEntry(for date: Date) {
        let entry = ThreeLinesJournalStore.activeEntry(for: date, in: journalEntries)
        soundTherapyText = entry?.soundTherapyText ?? ""
        emotionalRegulationText = entry?.emotionalRegulationText ?? ""
        mindfulnessText = entry?.mindfulnessText ?? ""
        soundTherapyCheckOnly = entry?.soundTherapyCheckOnly ?? false
        emotionalRegulationCheckOnly = entry?.emotionalRegulationCheckOnly ?? false
        mindfulnessCheckOnly = entry?.mindfulnessCheckOnly ?? false
        notes = entry?.notes ?? ""
        statusMessage = nil
        errorMessage = nil
    }

    private func saveEntry() {
        statusMessage = nil
        errorMessage = nil

        do {
            let entry = try ThreeLinesJournalStore.saveEntry(
                for: selectedDate,
                soundTherapyText: soundTherapyText,
                emotionalRegulationText: emotionalRegulationText,
                mindfulnessText: mindfulnessText,
                soundTherapyCheckOnly: soundTherapyCheckOnly,
                emotionalRegulationCheckOnly: emotionalRegulationCheckOnly,
                mindfulnessCheckOnly: mindfulnessCheckOnly,
                notes: notes,
                existingEntries: journalEntries,
                modelContext: modelContext
            )
            selectedDate = entry.entryDate
            statusMessage = "Saved locally on this device."
            loadEntry(for: entry.entryDate)
        } catch {
            errorMessage = "Could not save this journal entry."

            #if DEBUG
            print("[MPTinnitus][ThreeLinesJournal] Save failed: \(error.localizedDescription)")
            #endif
        }
    }

    private func archivePendingEntry() {
        guard let entry = entryPendingArchive else {
            return
        }

        do {
            try ThreeLinesJournalStore.archive(entry, modelContext: modelContext)
            entryPendingArchive = nil
            loadEntry(for: selectedDate)
            statusMessage = "Journal entry deleted locally."
        } catch {
            errorMessage = "Could not delete this journal entry."

            #if DEBUG
            print("[MPTinnitus][ThreeLinesJournal] Delete failed: \(error.localizedDescription)")
            #endif
        }
    }
}
