//
//  ExpandableContentCard.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import SwiftUI
import UIKit

struct ExpandableContentCard: View {
    let card: StaticContentCard
    let module: StaticModule
    let sectionAudio: StaticAudioItem?
    let visuals: [StaticVisualReference]
    let showsSoundTherapyPlayerLink: Bool
    let isCollapsible: Bool
    @ObservedObject var audioController: AudioController

    @State private var isExpanded: Bool

    init(
        card: StaticContentCard,
        module: StaticModule,
        sectionAudio: StaticAudioItem? = nil,
        visuals: [StaticVisualReference] = [],
        showsSoundTherapyPlayerLink: Bool = false,
        isCollapsible: Bool = true,
        audioController: AudioController,
        initiallyExpanded: Bool = false
    ) {
        self.card = card
        self.module = module
        self.sectionAudio = sectionAudio
        self.visuals = visuals
        self.showsSoundTherapyPlayerLink = showsSoundTherapyPlayerLink
        self.isCollapsible = isCollapsible
        self.audioController = audioController
        _isExpanded = State(initialValue: initiallyExpanded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            header

            if let statusMessage, isCurrentAudio {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if shouldShowContent {
                content
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var header: some View {
        HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
            if allowsCollapse {
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(alignment: .center, spacing: MPTTheme.Spacing.small) {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .foregroundStyle(MPTTheme.secondaryText)

                        titleLabel
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(card.title)
                .accessibilityHint("Expands or collapses this section.")
            } else {
                titleLabel
            }

            Spacer(minLength: MPTTheme.Spacing.small)

            if let sectionAudio {
                Button {
                    if isCurrentAudioPlaying {
                        audioController.togglePlayPause()
                    } else {
                        audioController.play(audio: sectionAudio)
                    }
                } label: {
                    Image(systemName: isCurrentAudioPlaying ? "pause.fill" : "play.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityLabel(isCurrentAudioPlaying ? "Pause section audio" : "Play section audio")
                .accessibilityHint("Uses the written section text as the transcript.")
            }
        }
    }

    private var titleLabel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.title)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Text(card.bodyMarkdown)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(visuals, id: \.visualId) { visual in
                InlineVisualLink(visual: visual)
            }

            if showsSoundTherapyPlayerLink {
                SoundTherapyPlayerInlineLink()
            }
        }
    }

    private var shouldShowContent: Bool {
        !allowsCollapse || isExpanded
    }

    private var allowsCollapse: Bool {
        isCollapsible && card.isExpandable
    }

    private var isCurrentAudio: Bool {
        audioController.currentAudioID == sectionAudio?.audioId
    }

    private var isCurrentAudioPlaying: Bool {
        isCurrentAudio && audioController.isPlaying
    }

    private var statusMessage: String? {
        audioController.statusMessage
    }
}

private struct SoundTherapyPlayerInlineLink: View {
    var body: some View {
        NavigationLink(value: AppRoute.soundTherapyPlayer) {
            HStack(alignment: .center, spacing: MPTTheme.Spacing.small) {
                Image(systemName: "speaker.wave.2")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MPTTheme.accentColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Open Sound Therapy Player")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("Try sound therapy samples and adjust the volume while you practice.")
                        .font(.footnote)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: MPTTheme.Spacing.small)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MPTTheme.secondaryText)
            }
            .padding(MPTTheme.Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Sound Therapy Player")
        .accessibilityHint("Opens sound therapy samples and volume controls.")
    }
}

private struct InlineVisualLink: View {
    let visual: StaticVisualReference

    var body: some View {
        NavigationLink(value: AppRoute.visual(visual.visualId)) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                if let asset = MVPStaticVisualAsset.asset(for: visual.visualId),
                   let image = asset.image() {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 180)
                        .accessibilityLabel(asset.altText)
                }

                HStack(alignment: .center, spacing: MPTTheme.Spacing.small) {
                    Image(systemName: iconName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MPTTheme.accentColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(visual.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text(visual.description)
                            .font(.footnote)
                            .foregroundStyle(MPTTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: MPTTheme.Spacing.small)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MPTTheme.secondaryText)
                }
            }
            .padding(MPTTheme.Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open \(visual.title)")
    }

    private var iconName: String {
        switch visual.visualId {
        case "VIS-003":
            "slider.horizontal.3"
        case "VIS-009", "VIS-031":
            "lungs"
        case "VIS-013":
            "pause.circle"
        case "VIS-014":
            "thermometer.medium"
        case "VIS-001", "VIS-017", "VIS-023", "VIS-033", "VIS-034":
            "circle.hexagongrid"
        default:
            "rectangle.3.group"
        }
    }
}
