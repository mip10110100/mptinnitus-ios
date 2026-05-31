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
    @ObservedObject private var sampleController: SoundSampleController

    private let samples: [SoundSampleItem]

    init(
        moduleLibrary: StaticModuleLibrary = .empty,
        sampleController: SoundSampleController,
        samples: [SoundSampleItem] = SoundSampleLibraryLoader().loadSamples()
    ) {
        self.moduleLibrary = moduleLibrary
        self.sampleController = sampleController
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
                customizedSoundTherapySection
                favoritesSection
                relatedToolsSection
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(AppTab.soundAnnex.fullTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: AppTab.soundAnnex.systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(AppTab.soundAnnex.fullTitle)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Label("Guidance", systemImage: "ear.and.waveform")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Sound therapy is individual. Pick a sound that is comfortable, soothing, or calming to you.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Start with the volume low, and increase it until you can hear the sound therapy. If you want to explore the high-volume side of the range, increase the sound therapy until it entirely covers tinnitus. Then lower it until the sound therapy is below the volume of the tinnitus.")
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var soundSamplesSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Sound Therapy Samples", subtitle: "Set these sounds to a comfortable level to explore how they work as sound therapy options.")

            ForEach(groupedSamples, id: \.title) { group in
                VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                    Text(group.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MPTTheme.secondaryText)
                        .padding(.top, MPTTheme.Spacing.small)

                    ForEach(group.samples) { sample in
                        SoundSampleCard(
                            sample: sample,
                            preferences: soundPreferences,
                            controller: sampleController
                        )
                    }
                }
            }
        }
    }

    private var groupedSamples: [(title: String, samples: [SoundSampleItem])] {
        let groupOrder = [
            "Nature / Environmental",
            "Household / Environmental",
            "Static / Artificial"
        ]
        let visibleSamples = samples.filter { sample in
            Self.visibleBetaSampleIDs.contains(sample.id)
        }
        let grouped = Dictionary(grouping: visibleSamples, by: \.displayGroup)

        var orderedGroups = groupOrder.compactMap { title -> (title: String, samples: [SoundSampleItem])? in
            guard let samples = grouped[title], !samples.isEmpty else {
                return nil
            }
            return (title, samples)
        }

        for title in grouped.keys.sorted() where !groupOrder.contains(title) {
            if let samples = grouped[title], !samples.isEmpty {
                orderedGroups.append((title, samples))
            }
        }

        return orderedGroups
    }

    private static let visibleBetaSampleIDs: Set<String> = [
        "st.noise.rain",
        "st.noise.stream_flowing_water",
        "st.noise.crickets",
        "st.noise.fan",
        "st.noise.brown.loop_1min_128",
        "st.noise.pink.loop_1min_128",
        "st.noise.white.loop_1min_128"
    ]

    private var customizedSoundTherapySection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Customized sound therapy")

            NavigationLink(value: AppRoute.tinnitusSoundEstimate) {
                HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                    Image(systemName: "waveform.and.magnifyingglass")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(MPTTheme.accentColor)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tinnitus sound estimate")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Match your tinnitus pitch and save a local estimate. This can help personalize sound options later.")
                            .font(.subheadline)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Start pitch match")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MPTTheme.accentColor)
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

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader("Saved Preferred Sounds")

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
            SectionHeader("Learn and Practice", subtitle: "Return to the education and exercises that support sound therapy.")

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
                title: "Sound Sensitivity Exercise",
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
}
