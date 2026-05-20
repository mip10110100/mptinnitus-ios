//
//  AudioMiniPlayerPlaceholderView.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import SwiftUI

struct AudioMiniPlayerPlaceholderView: View {
    @ObservedObject var audioController: AudioController

    var body: some View {
        HStack(spacing: MPTTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Audio")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MPTTheme.secondaryText)

                Text(audioController.currentAudioLabel)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                if audioController.duration > 0 {
                    Text("\(formattedTime(audioController.elapsedTime)) / \(formattedTime(audioController.duration))")
                        .font(.caption)
                        .foregroundStyle(MPTTheme.secondaryText)
                } else if let statusMessage = audioController.statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(MPTTheme.secondaryText)
                }
            }

            Spacer(minLength: MPTTheme.Spacing.medium)

            Group {
                Button(action: audioController.rewindFifteenSeconds) {
                    Image(systemName: "gobackward.15")
                }
                .accessibilityLabel("Rewind 15 seconds")
                .disabled(!audioController.canControlCurrentItem)

                Button(action: audioController.togglePlayPause) {
                    Image(systemName: audioController.isPlaying ? "pause.fill" : "play.fill")
                }
                .accessibilityLabel(audioController.isPlaying ? "Pause" : "Play")
                .disabled(!audioController.canControlCurrentItem)

                Button(action: audioController.forwardFifteenSeconds) {
                    Image(systemName: "goforward.15")
                }
                .accessibilityLabel("Forward 15 seconds")
                .disabled(!audioController.canControlCurrentItem)
            }
            .buttonStyle(.plain)
            .font(.title3.weight(.semibold))
            .foregroundStyle(MPTTheme.secondaryText)
        }
        .padding(.horizontal, MPTTheme.Spacing.medium)
        .padding(.vertical, MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        guard time.isFinite, time > 0 else {
            return "0:00"
        }

        let totalSeconds = Int(time.rounded())
        return "\(totalSeconds / 60):\(String(format: "%02d", totalSeconds % 60))"
    }
}

#Preview {
    AudioMiniPlayerPlaceholderView(audioController: AudioController())
        .padding()
        .background(MPTTheme.screenBackground)
}
