//
//  SettingsPlaceholderView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftData
import SwiftUI

struct SettingsPlaceholderView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("mptinnitus.firstLaunchDecision")
    private var firstLaunchDecisionRaw = FirstLaunchDecision.pending.rawValue
    @AppStorage("mptinnitus.transcriptsExpandedByDefault")
    private var transcriptsExpandedByDefault = false
    @AppStorage(AudioPreferenceKeys.automaticallyPlayNextEducationSection)
    private var automaticallyPlayNextEducationSection = false

    @Query private var myPlanItems: [MyPlanItemRecord]
    @Query private var exerciseEntries: [ExerciseEntryRecord]
    @Query private var journalEntries: [ThreeLinesJournalEntryRecord]
    @Query private var soundPreferences: [SoundPreferenceRecord]
    @Query private var reminderSettings: [ReminderSettingsRecord]
    @Query private var userPreferences: [UserPreferenceRecord]
    @Query private var safetyFlags: [SafetyScopeAcknowledgementRecord]
    @Query private var schemaRecords: [LocalSchemaMetadataRecord]

    @State private var pendingResetAction: SettingsResetAction?
    @State private var statusMessage: String?
    @State private var errorMessage: String?
    @State private var hasTinnitusSoundEstimate = TinnitusSoundProfileStore.savedProfileExists()

    private var isShowingResetConfirmation: Binding<Bool> {
        Binding(
            get: { pendingResetAction != nil },
            set: { isPresented in
                if !isPresented {
                    pendingResetAction = nil
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                aboutSection
                privacySection
                safetySection
                audioTranscriptSection
                welcomeSection
                localDataSection
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(AppRoute.settings.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: refreshTinnitusSoundEstimateStatus)
        .confirmationDialog(
            pendingResetAction?.confirmationTitle ?? "Confirm local reset",
            isPresented: isShowingResetConfirmation,
            titleVisibility: .visible
        ) {
            if let pendingResetAction {
                Button(pendingResetAction.destructiveButtonTitle, role: .destructive) {
                    performReset(pendingResetAction)
                }
            }

            Button("Cancel", role: .cancel) {
                pendingResetAction = nil
            }
        } message: {
            Text(pendingResetAction?.confirmationMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "gearshape")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text("Settings")
                .font(.title2.weight(.semibold))

            Text("Manage local privacy, safety information, display preferences, and on-device data controls.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .settingsCardPadding()
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("About This App")
            settingsText("MPTinnitus is an educational and informational tinnitus companion. It is not medical advice, diagnosis, treatment, therapy, crisis care, or a replacement for audiology, ENT, primary care, mental health care, sleep medicine, emergency care, or other appropriate care.")

            NavigationLink(value: AppRoute.aboutTinnitus) {
                settingsLinkLabel("Open About Tinnitus", systemImage: "ear")
            }
            .buttonStyle(.plain)
        }
        .settingsCardPadding()
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Privacy / Local-Only Data")
            settingsText("Preferences, entries, My Plan items, journal entries, exercise responses, sound favorites, and settings stay on this device.")
            settingsText("The MVP does not require an account and does not automatically transmit data. There is no clinician dashboard, cloud sync, remote monitoring, or analytics.")
        }
        .settingsCardPadding()
    }

    private var safetySection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Safety and Scope")
            settingsText("If you feel unsafe or are in a mental health crisis, do not rely on this app. Seek immediate support through emergency services, crisis resources, or a qualified professional.")

            NavigationLink(value: AppRoute.safetyInformation) {
                settingsLinkLabel("Safety Information", systemImage: "cross.case")
            }
            .buttonStyle(.plain)
        }
        .settingsCardPadding()
    }

    private var audioTranscriptSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Audio and Transcripts")
            Toggle(isOn: $transcriptsExpandedByDefault) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Show transcripts expanded by default")
                        .font(.headline)

                    Text("Default remains collapsed unless you turn this on. This changes transcript display only, not audio playback.")
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .toggleStyle(.switch)

            Toggle(isOn: $automaticallyPlayNextEducationSection) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Automatically play next education section")
                        .font(.headline)

                    Text("Default is off. When this is off, each section stops and waits for you to choose the next one.")
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .toggleStyle(.switch)
        }
        .settingsCardPadding()
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Welcome Prompt")
            settingsText("Resetting the welcome prompt only changes the first-launch preference. It does not delete saved entries or settings.")

            resetButton(.welcomePrompt)
        }
        .settingsCardPadding()
    }

    private var localDataSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            SectionHeader("Local Data Controls", subtitle: "These actions affect only data stored on this device. Each action asks for confirmation.")

            resetRow(
                title: "Clear My Plan",
                subtitle: "\(myPlanItems.count) saved My Plan record\(myPlanItems.count == 1 ? "" : "s")",
                action: .myPlanItems
            )

            resetRow(
                title: "Delete exercise entries",
                subtitle: "\(exerciseEntries.count) exercise entr\(exerciseEntries.count == 1 ? "y" : "ies")",
                action: .exerciseEntries
            )

            resetRow(
                title: "Delete Three Lines Journal entries",
                subtitle: "\(journalEntries.count) journal entr\(journalEntries.count == 1 ? "y" : "ies")",
                action: .threeLinesJournalEntries
            )

            resetRow(
                title: "Clear sound favorites/preferences",
                subtitle: "\(soundPreferences.count) sound preference record\(soundPreferences.count == 1 ? "" : "s")",
                action: .soundPreferences
            )

            resetRow(
                title: "Clear tinnitus sound estimate",
                subtitle: hasTinnitusSoundEstimate ? "1 saved local estimate" : "No estimate saved yet",
                action: .tinnitusSoundEstimate
            )

            resetRow(
                title: "Clear reminder settings",
                subtitle: "\(reminderSettings.count) local reminder setting record\(reminderSettings.count == 1 ? "" : "s"). No reminders are scheduled in this stage.",
                action: .reminderSettings
            )

            resetRow(
                title: "Clear safety acknowledgements",
                subtitle: "\(safetyFlags.count) safety/scope flag\(safetyFlags.count == 1 ? "" : "s")",
                action: .safetyScopeFlags
            )

            Divider()

            resetRow(
                title: "Reset all local app data",
                subtitle: "Deletes local records, clears the saved sound estimate, and resets welcome/audio/transcript preferences. Bundled education content stays installed.",
                action: .allLocalData
            )

            if let statusMessage {
                Label(statusMessage, systemImage: "checkmark.circle")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .settingsCardPadding()
    }

    private func resetRow(title: String, subtitle: String, action: SettingsResetAction) -> some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            HStack(alignment: .top, spacing: MPTTheme.Spacing.medium) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: MPTTheme.Spacing.small)

                resetButton(action)
            }
        }
    }

    private func resetButton(_ action: SettingsResetAction) -> some View {
        Button(role: action.isDestructive ? .destructive : nil) {
            pendingResetAction = action
        } label: {
            Label(action.buttonTitle, systemImage: action.systemImage)
        }
        .buttonStyle(.bordered)
    }

    private func settingsText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func settingsLinkLabel(_ title: String, systemImage: String) -> some View {
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
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func performReset(_ action: SettingsResetAction) {
        statusMessage = nil
        errorMessage = nil

        do {
            switch action {
            case .welcomePrompt:
                resetWelcomePrompt()
            case .allLocalData:
                try LocalDataResetService(modelContext: modelContext).reset(.allLocalData)
                try TinnitusSoundProfileStore.deleteSavedProfile()
                resetWelcomePrompt()
                transcriptsExpandedByDefault = false
                automaticallyPlayNextEducationSection = false
            default:
                if action == .tinnitusSoundEstimate {
                    try TinnitusSoundProfileStore.deleteSavedProfile()
                } else if let scope = action.resetScope {
                    try LocalDataResetService(modelContext: modelContext).reset(scope)
                }
            }

            statusMessage = action.successMessage
            refreshTinnitusSoundEstimateStatus()
        } catch {
            errorMessage = "Could not complete this local reset."

            #if DEBUG
            print("[MPTinnitus][Settings] Local reset failed for \(action.rawValue): \(error.localizedDescription)")
            #endif
        }

        pendingResetAction = nil
    }

    private func resetWelcomePrompt() {
        firstLaunchDecisionRaw = FirstLaunchDecision.pending.rawValue
    }

    private func refreshTinnitusSoundEstimateStatus() {
        hasTinnitusSoundEstimate = TinnitusSoundProfileStore.savedProfileExists()
    }
}

private enum SettingsResetAction: String {
    case myPlanItems
    case exerciseEntries
    case threeLinesJournalEntries
    case soundPreferences
    case tinnitusSoundEstimate
    case reminderSettings
    case safetyScopeFlags
    case allLocalData
    case welcomePrompt

    var resetScope: LocalDataResetScope? {
        switch self {
        case .myPlanItems:
            .myPlanItems
        case .exerciseEntries:
            .exerciseEntries
        case .threeLinesJournalEntries:
            .threeLinesJournalEntries
        case .soundPreferences:
            .soundPreferences
        case .tinnitusSoundEstimate:
            nil
        case .reminderSettings:
            .reminderSettings
        case .safetyScopeFlags:
            .safetyScopeFlags
        case .allLocalData:
            .allLocalData
        case .welcomePrompt:
            nil
        }
    }

    var isDestructive: Bool {
        self != .welcomePrompt
    }

    var buttonTitle: String {
        switch self {
        case .welcomePrompt:
            "Show Again"
        default:
            "Reset"
        }
    }

    var systemImage: String {
        switch self {
        case .welcomePrompt:
            "arrow.counterclockwise"
        default:
            "trash"
        }
    }

    var confirmationTitle: String {
        switch self {
        case .myPlanItems:
            "Clear My Plan?"
        case .exerciseEntries:
            "Delete exercise entries?"
        case .threeLinesJournalEntries:
            "Delete Three Lines Journal entries?"
        case .soundPreferences:
            "Clear sound favorites and preferences?"
        case .tinnitusSoundEstimate:
            "Clear tinnitus sound estimate?"
        case .reminderSettings:
            "Clear reminder settings?"
        case .safetyScopeFlags:
            "Clear safety acknowledgements?"
        case .allLocalData:
            "Reset all local app data?"
        case .welcomePrompt:
            "Show welcome prompt again?"
        }
    }

    var confirmationMessage: String {
        switch self {
        case .myPlanItems:
            "This clears saved My Plan markers from this device. Module content and exercise entries remain."
        case .exerciseEntries:
            "This deletes saved exercise responses from this device. My Plan markers and other settings remain."
        case .threeLinesJournalEntries:
            "This deletes all Three Lines Journal entries from this device."
        case .soundPreferences:
            "This clears saved sound favorites and preference records from this device."
        case .tinnitusSoundEstimate:
            "This clears the saved local tinnitus pitch and loudness estimate. Other sound preferences remain."
        case .reminderSettings:
            "This clears local reminder setting records. This stage does not schedule notifications."
        case .safetyScopeFlags:
            "This clears local safety/scope acknowledgement flags. Safety content remains available."
        case .allLocalData:
            "This deletes My Plan items, exercise entries, journal entries, sound preferences, the saved tinnitus sound estimate, reminder settings, safety flags, and local schema/preference records. It also resets the welcome prompt, audio preference, and transcript preference. This cannot be undone."
        case .welcomePrompt:
            "The welcome sheet will appear again on a future app launch. No saved data will be deleted."
        }
    }

    var destructiveButtonTitle: String {
        switch self {
        case .myPlanItems:
            "Clear My Plan"
        case .exerciseEntries:
            "Delete Exercise Entries"
        case .threeLinesJournalEntries:
            "Delete Journal Entries"
        case .soundPreferences:
            "Clear Sound Preferences"
        case .tinnitusSoundEstimate:
            "Clear Sound Estimate"
        case .reminderSettings:
            "Clear Reminder Settings"
        case .safetyScopeFlags:
            "Clear Safety Flags"
        case .allLocalData:
            "Reset All Local Data"
        case .welcomePrompt:
            "Show Welcome Again"
        }
    }

    var successMessage: String {
        switch self {
        case .myPlanItems:
            "My Plan items were cleared locally."
        case .exerciseEntries:
            "Exercise entries were deleted locally."
        case .threeLinesJournalEntries:
            "Three Lines Journal entries were deleted locally."
        case .soundPreferences:
            "Sound preferences were cleared locally."
        case .tinnitusSoundEstimate:
            "Tinnitus sound estimate was cleared locally."
        case .reminderSettings:
            "Reminder settings were cleared locally."
        case .safetyScopeFlags:
            "Safety acknowledgements were cleared locally."
        case .allLocalData:
            "All local app data was reset."
        case .welcomePrompt:
            "Welcome prompt was reset."
        }
    }
}

private extension View {
    func settingsCardPadding() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(MPTTheme.Spacing.large)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        SettingsPlaceholderView()
    }
}
