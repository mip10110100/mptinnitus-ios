//
//  SoundTherapyAnnexView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftData
import SwiftUI

struct SoundTherapyAnnexView: View {
    let moduleLibrary: StaticModuleLibrary

    @Query private var soundPreferences: [SoundPreferenceRecord]
    @StateObject private var sampleController = SoundSampleController()

    private let samples: [SoundSampleItem]

    init(
        moduleLibrary: StaticModuleLibrary = .empty,
        samples: [SoundSampleItem] = SoundSampleLibraryLoader().loadSamples()
    ) {
        self.moduleLibrary = moduleLibrary
        self.samples = samples
    }

    private var activeFavorites: [SoundPreferenceRecord] {
        soundPreferences
            .filter { $0.isFavorite && !$0.isArchived }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                guidanceCard
                soundSamplesSection
                favoritesSection
                relatedToolsSection

                #if DEBUG
                debugPanel
                #endif
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(AppTab.soundAnnex.fullTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            sampleController.stop()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: AppTab.soundAnnex.systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(AppTab.soundAnnex.fullTitle)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Explore six local starter sound categories. Samples are previews only, and preference is individual.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Label("Sound therapy guidance", systemImage: "ear.and.waveform")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Sound therapy is individualized. The goal is not always to fully mask tinnitus. Many people practice in a comfortable middle range where the support sound and tinnitus can both be heard.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Start low and adjust gradually. Do not push into painful or unsafe sound. If sound sensitivity is present, keep sound under your control and below the level that feels sensitive. Hearing care, audiology, or ENT assessment may be important when hearing loss or medical concerns are present.")
                .font(.footnote)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var soundSamplesSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Starter Sound Samples", subtitle: "Local .m4a files play when available. Unavailable samples stay visible without playing.")

            ForEach(samples) { sample in
                SoundSampleCard(
                    sample: sample,
                    preferences: soundPreferences,
                    controller: sampleController
                )
            }
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Saved Preferred Sounds", subtitle: "Favorites stay on this device.")

            if activeFavorites.isEmpty {
                Text("No preferred sounds saved yet. Use Favorite on a sample card to keep track of sounds you may want to revisit.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(MPTTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MPTTheme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(activeFavorites, id: \.id) { preference in
                    favoriteRow(preference)
                }
            }
        }
    }

    private func favoriteRow(_ preference: SoundPreferenceRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(preference.soundTitle, systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            Text(preference.soundCategory)
                .font(.subheadline)
                .foregroundStyle(MPTTheme.secondaryText)

            if !preference.preferredVolumeNote.isEmpty {
                Text(preference.preferredVolumeNote)
                    .font(.caption)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var relatedToolsSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Learn and Practice", subtitle: "Return to the education and exercises that support this annex.")

            relatedToolLink(
                title: "Sound Therapy education module",
                subtitle: "Review sound therapy, masking, habituation, sound sensitivity, and hearing-care notes.",
                systemImage: "list.bullet.rectangle",
                route: .module("sound_therapy")
            )

            relatedToolLink(
                title: "Sound Therapy Thermometer",
                subtitle: "Practice the too quiet, sweet spot, and too loud volume zones.",
                systemImage: "slider.horizontal.3",
                route: .visual("VIS-003")
            )

            relatedToolLink(
                title: "Sound Therapy Sweet Spot Reflection",
                subtitle: "Save a short reflection about finding a useful middle range.",
                systemImage: "square.and.pencil",
                route: .exercise("I-005")
            )

            relatedToolLink(
                title: "Personalized Sound Therapy Plan",
                subtitle: "Choose sounds, devices, times, and contexts for practice.",
                systemImage: "checklist",
                route: .exercise("I-007")
            )

            relatedToolLink(
                title: "Enjoyable Music Speaker Exercise",
                subtitle: "Use comfortable, controlled music below the sensitivity point.",
                systemImage: "speaker.wave.2",
                route: .exercise("I-006")
            )
        }
    }

    private func relatedToolLink(
        title: String,
        subtitle: String,
        systemImage: String,
        route: AppRoute
    ) -> some View {
        NavigationLink(value: route) {
            HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(MPTTheme.accentColor)
                    .frame(width: 32)

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

    #if DEBUG
    private var debugPanel: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Sound Annex Debug")

            Text("Samples: \(samples.count)")
            Text("Active favorites: \(activeFavorites.count)")
            Text("Current sample: \(sampleController.currentSampleID ?? "none")")
            Text("Current asset path: \(sampleController.currentAssetPath ?? "none")")
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
