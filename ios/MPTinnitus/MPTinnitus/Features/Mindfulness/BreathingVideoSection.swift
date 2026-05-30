//
//  BreathingVideoSection.swift
//  MPTinnitus
//
//  Created by Codex on 5/30/26.
//

import AVKit
import SwiftUI

struct BreathingVideoSection: View {
    let module: StaticModule
    private let videos: [BreathingVideoItem]

    init(
        module: StaticModule,
        videos: [BreathingVideoItem] = BreathingVideoLibraryLoader().loadVideos()
    ) {
        self.module = module
        self.videos = videos
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            SectionHeader(
                "Breathing Practice Videos",
                subtitle: "Follow a muted local breathing loop. Stop or switch back to the visual pacer if animation does not fit."
            )

            if videos.isEmpty {
                Text("Breathing videos are not available right now. Use the Breathing Pacer as the fallback.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(MPTTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MPTTheme.surfaceBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(videos) { video in
                    NavigationLink {
                        BreathingVideoPlayerView(
                            video: video,
                            module: module,
                            fallbackVisual: fallbackVisual
                        )
                    } label: {
                        BreathingVideoCard(video: video)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(video.accessibilityLabel)
                }
            }
        }
    }

    private var fallbackVisual: StaticVisualReference? {
        module.visuals.first { visual in
            visual.visualId == "VIS-009" || visual.visualId == "VIS-031"
        }
    }
}

private struct BreathingVideoCard: View {
    let video: BreathingVideoItem

    var body: some View {
        HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
            Image(systemName: "play.rectangle")
                .font(.title3.weight(.semibold))
                .foregroundStyle(MPTTheme.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(video.description)
                    .font(.subheadline)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Pattern: \(video.pattern.shortLabel). Muted and loops until you leave.")
                    .font(.caption)
                    .foregroundStyle(MPTTheme.secondaryText)
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
}

struct BreathingVideoPlayerView: View {
    let video: BreathingVideoItem
    let module: StaticModule
    let fallbackVisual: StaticVisualReference?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var player: AVPlayer?
    @State private var loopObserver: NSObjectProtocol?
    @State private var statusMessage: String?
    @State private var didStopManually = false

    var body: some View {
        if reduceMotion, let fallbackVisual {
            BreathingPacerVisualView(visual: fallbackVisual, module: module)
        } else {
            playerContent
        }
    }

    private var playerContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                header
                videoPanel
                fallbackNote
            }
            .padding(MPTTheme.Spacing.screen)
            .padding(.bottom, MPTTheme.Spacing.bottomScrollContent)
        }
        .background(MPTTheme.screenBackground)
        .navigationTitle(video.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startVideo()
        }
        .onDisappear {
            stopVideo()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Image(systemName: "play.rectangle")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MPTTheme.accentColor)

            Text(video.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text(video.description)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("This local video is muted by default and loops only while this screen is open.")
                .font(.footnote)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var videoPanel: some View {
        if let player {
            VideoPlayer(player: player)
                .aspectRatio(16.0 / 9.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityLabel(video.accessibilityLabel)

            Button {
                stopVideo(showStoppedMessage: true)
            } label: {
                Label("Stop Video", systemImage: "stop.fill")
            }
            .buttonStyle(.bordered)
        } else {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
                Label(
                    didStopManually ? "Video stopped" : "Video unavailable",
                    systemImage: didStopManually ? "stop.circle" : "exclamationmark.triangle"
                )
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(statusMessage ?? "This local video could not be loaded.")
                    .font(.body)
                    .foregroundStyle(MPTTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if didStopManually {
                    Button {
                        startVideo()
                    } label: {
                        Label("Restart Video", systemImage: "play.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(MPTTheme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MPTTheme.surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var fallbackNote: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Text("Prefer less motion?")
                .font(.headline)

            Text("Turn on Reduce Motion in iOS Accessibility settings to use the built-in SwiftUI breathing pacer instead of the looping video.")
                .font(.body)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func startVideo() {
        guard player == nil else {
            player?.play()
            return
        }

        guard let url = video.bundledURL() else {
            statusMessage = "This bundled breathing video is not available."
            didStopManually = false
            return
        }

        let playerItem = AVPlayerItem(url: url)
        let videoPlayer = AVPlayer(playerItem: playerItem)
        videoPlayer.isMuted = video.mutedByDefault

        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            videoPlayer.seek(to: .zero)
            videoPlayer.play()
        }

        player = videoPlayer
        didStopManually = false
        statusMessage = nil
        videoPlayer.play()
    }

    private func stopVideo(showStoppedMessage: Bool = false) {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil

        if let loopObserver {
            NotificationCenter.default.removeObserver(loopObserver)
            self.loopObserver = nil
        }

        if showStoppedMessage {
            statusMessage = "Video stopped. Use Restart Video or the back button when you are done."
            didStopManually = true
        }
    }
}
