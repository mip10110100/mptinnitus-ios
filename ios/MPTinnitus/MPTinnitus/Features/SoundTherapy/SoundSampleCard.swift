//
//  SoundSampleCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftData
import SwiftUI

struct SoundSampleCard: View {
    let sample: SoundSampleItem
    let preferences: [SoundPreferenceRecord]
    @ObservedObject var controller: SoundSampleController

    @Environment(\.modelContext) private var modelContext
    @State private var preferenceErrorMessage: String?

    private var isCurrentSample: Bool {
        controller.currentSampleID == sample.id
    }

    private var isFavorite: Bool {
        SoundPreferenceStore.activeFavorite(in: preferences, matching: sample) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            HStack(alignment: .top, spacing: MPTTheme.Spacing.medium) {
                Image(systemName: iconName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(MPTTheme.accentColor)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(sample.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(sample.category)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MPTTheme.accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(MPTTheme.accentColor.opacity(0.12))
                        .clipShape(Capsule())

                    SourceIDDebugLabel("sound", ids: [sample.id])
                }
            }

            if isCurrentSample {
                activeSampleStatus
            }

            HStack(spacing: MPTTheme.Spacing.small) {
                Button {
                    controller.toggle(sample: sample)
                } label: {
                    Label(playButtonTitle, systemImage: playButtonIcon)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("\(playButtonTitle) \(sample.title)")
                .accessibilityHint("Plays or pauses this foreground Sound Therapy sample.")

                Button {
                    toggleFavorite()
                } label: {
                    Label(isFavorite ? "Saved" : "Favorite", systemImage: isFavorite ? "star.fill" : "star")
                }
                .buttonStyle(.bordered)
                .tint(isFavorite ? .yellow : MPTTheme.accentColor)
                .accessibilityLabel(isFavorite ? "Remove \(sample.title) from saved preferred sounds" : "Save \(sample.title) as a preferred sound")
            }

            if isCurrentSample {
                volumeControl
            }

            if let preferenceErrorMessage {
                Text(preferenceErrorMessage)
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

    private var activeSampleStatus: some View {
        Label(controller.statusMessage, systemImage: controller.isPlayable ? "speaker.wave.2" : "exclamationmark.triangle")
            .font(.footnote)
            .foregroundStyle(controller.isPlayable ? MPTTheme.secondaryText : .orange)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var volumeControl: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            HStack {
                Text("Preview volume")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(controller.safeVolumePercent)%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(MPTTheme.secondaryText)
            }

            Slider(
                value: Binding(
                    get: { controller.volumeLevel },
                    set: { controller.setVolumeLevel($0) }
                ),
                in: 0...1
            ) {
                Text("Preview volume for \(sample.title)")
            } minimumValueLabel: {
                Image(systemName: "speaker.wave.1")
                    .font(.caption)
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.2")
                    .font(.caption)
            }
            .disabled(!controller.isPlayable)
            .accessibilityHint("Adjusts the capped preview volume for this sample.")
        }
    }

    private var playButtonTitle: String {
        if isCurrentSample, controller.isPlaying {
            "Pause"
        } else {
            "Play"
        }
    }

    private var playButtonIcon: String {
        if isCurrentSample, controller.isPlaying {
            "pause.fill"
        } else {
            "play.fill"
        }
    }

    private var iconName: String {
        let id = sample.id.lowercased()
        let title = sample.title.lowercased()

        if id.contains("rain") || title.contains("rain") {
            return "cloud.rain"
        } else if id.contains("stream") || title.contains("stream") || title.contains("water") {
            return "water.waves"
        } else if id.contains("fan") || title.contains("fan") {
            return "fan"
        } else if id.contains("crickets") || title.contains("crickets") {
            return "moon.stars"
        } else if id.contains("noise") || title.contains("noise") {
            return "waveform"
        } else {
            return "speaker.wave.2"
        }
    }

    private func toggleFavorite() {
        preferenceErrorMessage = nil

        do {
            try SoundPreferenceStore.setFavorite(
                !isFavorite,
                sample: sample,
                volumeLevel: controller.volumeLevel,
                existingPreferences: preferences,
                modelContext: modelContext
            )
        } catch {
            preferenceErrorMessage = "Could not update this local sound preference."

            #if DEBUG
            print("[MPTinnitus][SoundPreferenceStore] \(error.localizedDescription)")
            #endif
        }
    }
}
