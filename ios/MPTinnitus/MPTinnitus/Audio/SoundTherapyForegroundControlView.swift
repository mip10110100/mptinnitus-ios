//
//  SoundTherapyForegroundControlView.swift
//  MPTinnitus
//
//  Created by Codex on 5/31/26.
//

import SwiftUI

struct SoundTherapyForegroundControlView: View {
    @ObservedObject var controller: SoundSampleController

    var body: some View {
        HStack(spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "speaker.wave.2")
                .font(.headline)
                .foregroundStyle(MPTTheme.accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text("Sound Therapy")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MPTTheme.secondaryText)

                Text(controller.currentSampleTitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer(minLength: MPTTheme.Spacing.small)

            Button {
                controller.stop()
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Stop Sound Therapy")
            .accessibilityHint("Stops the active foreground sound therapy sample.")
        }
        .padding(.horizontal, MPTTheme.Spacing.medium)
        .padding(.vertical, MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    SoundTherapyForegroundControlView(controller: SoundSampleController())
        .padding()
        .background(MPTTheme.screenBackground)
}
