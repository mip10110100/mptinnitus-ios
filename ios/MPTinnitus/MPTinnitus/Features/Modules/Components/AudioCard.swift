//
//  AudioCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct AudioCard: View {
    let audio: StaticAudioItem
    let module: StaticModule
    @ObservedObject var audioController: AudioController
    let showsContextLabel: Bool

    init(
        audio: StaticAudioItem,
        module: StaticModule,
        audioController: AudioController,
        showsContextLabel: Bool = true
    ) {
        self.audio = audio
        self.module = module
        self._audioController = ObservedObject(wrappedValue: audioController)
        self.showsContextLabel = showsContextLabel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: 4) {
                Text(audio.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if showsContextLabel {
                    Text("Audio explanation")
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                }
            }

            HStack(spacing: MPTTheme.Spacing.medium) {
                Button {
                    if isCurrentAudio && audioController.isPlaying {
                        audioController.togglePlayPause()
                    } else {
                        audioController.play(audio: audio)
                    }
                } label: {
                    Label(
                        isCurrentAudio && audioController.isPlaying ? "Pause" : "Play",
                        systemImage: isCurrentAudio && audioController.isPlaying ? "pause.fill" : "play.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Plays this audio when the local file is available.")

                Spacer(minLength: MPTTheme.Spacing.small)
            }

            if isCurrentAudio, let statusMessage = audioController.statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } else if isCurrentAudio, audioController.isPlayable {
                Text("Audio is ready.")
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
            }

            TranscriptDisclosure(transcript: audio.transcript)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var isCurrentAudio: Bool {
        audioController.currentAudioID == audio.audioId
    }
}
