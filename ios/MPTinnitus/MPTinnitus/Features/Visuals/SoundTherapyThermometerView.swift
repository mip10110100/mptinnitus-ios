//
//  SoundTherapyThermometerView.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import AVFoundation
import Combine
import SwiftUI

struct SoundTherapyThermometerView: View {
    let visual: StaticVisualReference
    let module: StaticModule

    @StateObject private var samplePreview = ThermometerSamplePreview()
    @State private var sliderValue = 0.45

    private var zone: ThermometerZone {
        ThermometerZone(value: sliderValue)
    }

    var body: some View {
        VisualToolScaffold(visual: visual, module: module) {
            VStack(alignment: .leading, spacing: MPTTheme.Spacing.large) {
                thermometerPanel
                explanationPanel
                previewPanel
                VisualExerciseLink(
                    exerciseId: "I-005",
                    title: "Open Sound Therapy Sweet Spot Reflection"
                )
            }
        }
        .onChange(of: sliderValue) { _, newValue in
            samplePreview.updateVolume(for: newValue)
        }
        .onDisappear {
            samplePreview.stop()
        }
    }

    private var thermometerPanel: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.medium) {
            HStack(alignment: .center, spacing: MPTTheme.Spacing.medium) {
                Image(systemName: zone.systemImage)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(zone.color)
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(zone.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(zone.summary)
                        .font(.subheadline)
                        .foregroundStyle(MPTTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Slider(value: $sliderValue, in: 0...1) {
                Text("Sound therapy level")
            } minimumValueLabel: {
                Text("Quiet")
                    .font(.caption2)
            } maximumValueLabel: {
                Text("Loud")
                    .font(.caption2)
            }

            HStack(alignment: .top, spacing: MPTTheme.Spacing.small) {
                zoneLabel("Too quiet / not useful", isActive: zone == .tooQuiet)
                zoneLabel("Sweet spot / hear both", isActive: zone == .sweetSpot)
                zoneLabel("Too loud / overmasking", isActive: zone == .tooLoud)
            }
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var explanationPanel: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Text("How to read this")
                .font(.headline)

            Text(zone.detail)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("The preview volume is capped for safety. This screen is educational and does not prescribe a device volume.")
                .font(.footnote)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var previewPanel: some View {
        VStack(alignment: .leading, spacing: MPTTheme.Spacing.small) {
            Text("Optional Sample Preview")
                .font(.headline)

            Text(samplePreview.statusMessage)
                .font(.subheadline)
                .foregroundStyle(MPTTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                samplePreview.togglePreview(for: sliderValue)
            } label: {
                Label(
                    samplePreview.isPlaying ? "Stop Preview" : "Play Preview",
                    systemImage: samplePreview.isPlaying ? "stop.fill" : "play.fill"
                )
            }
            .buttonStyle(.bordered)
            .disabled(!samplePreview.isPlayable)
        }
        .padding(MPTTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MPTTheme.surfaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func zoneLabel(_ text: String, isActive: Bool) -> some View {
        Text(text)
            .font(.caption.weight(isActive ? .semibold : .regular))
            .foregroundStyle(isActive ? .primary : MPTTheme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(isActive ? zone.color.opacity(0.14) : Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private enum ThermometerZone: Equatable {
    case tooQuiet
    case sweetSpot
    case tooLoud

    init(value: Double) {
        if value < 0.34 {
            self = .tooQuiet
        } else if value <= 0.67 {
            self = .sweetSpot
        } else {
            self = .tooLoud
        }
    }

    var title: String {
        switch self {
        case .tooQuiet:
            "Too quiet / not useful"
        case .sweetSpot:
            "Sweet spot"
        case .tooLoud:
            "Too loud / overmasking"
        }
    }

    var summary: String {
        switch self {
        case .tooQuiet:
            "The added sound may be present, but it is not doing much yet."
        case .sweetSpot:
            "The sound is noticeable while tinnitus is still present."
        case .tooLoud:
            "The sound may be covering too much or becoming the new problem."
        }
    }

    var detail: String {
        switch self {
        case .tooQuiet:
            "Too quiet can be a useful starting point, but the goal is usually to make sound therapy audible enough to support attention and comfort."
        case .sweetSpot:
            "The sweet spot is the middle range: you can hear the support sound and tinnitus at the same time. This can support adaptation without turning the sound into a contest."
        case .tooLoud:
            "Too loud or overmasking can be useful briefly for relief, but it is not the main practice here. Turn down or stop if sound feels painful, unsafe, or sharply uncomfortable."
        }
    }

    var color: Color {
        switch self {
        case .tooQuiet:
            .blue
        case .sweetSpot:
            .green
        case .tooLoud:
            .orange
        }
    }

    var systemImage: String {
        switch self {
        case .tooQuiet:
            "speaker.wave.1"
        case .sweetSpot:
            "speaker.wave.2"
        case .tooLoud:
            "speaker.wave.3"
        }
    }
}

@MainActor
private final class ThermometerSamplePreview: ObservableObject {
    @Published private(set) var isPlayable = false
    @Published private(set) var isPlaying = false
    @Published private(set) var statusMessage = "Sample audio will be added later."

    private let bundle: Bundle
    private var player: AVAudioPlayer?

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        loadPreviewIfAvailable()
    }

    deinit {
        player?.stop()
    }

    func togglePreview(for sliderValue: Double) {
        guard let player, isPlayable else {
            return
        }

        updateVolume(for: sliderValue)

        if player.isPlaying {
            stop()
        } else {
            player.currentTime = 0
            player.play()
            isPlaying = true
        }
    }

    func updateVolume(for sliderValue: Double) {
        player?.volume = Float(min(max(sliderValue, 0), 0.65))
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
        isPlaying = false
    }

    private func loadPreviewIfAvailable() {
        guard let url = findPreviewURL() else {
            statusMessage = "Sample audio will be added later."
            isPlayable = false
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = 0
            audioPlayer.prepareToPlay()
            player = audioPlayer
            isPlayable = true
            statusMessage = "Bundled white/broadband sample preview is available. It plays once and does not run in the background."
        } catch {
            statusMessage = "Sample audio will be added later."
            isPlayable = false

            #if DEBUG
            print("[MPTinnitus][ThermometerPreview] Could not load sample: \(error.localizedDescription)")
            #endif
        }
    }

    private func findPreviewURL() -> URL? {
        let candidatePaths = [
            "audio/sound_samples/white_noise_1min_loop_no_fades_128kbps.mp3",
            "audio/sound_samples/white_noise_1min_fade_in_out_128kbps.mp3",
            "white_noise_1min_loop_no_fades_128kbps.mp3",
            "white_noise_1min_fade_in_out_128kbps.mp3",
            "audio/samples/white_broadband_placeholder.m4a",
            "audio/sound_samples/ss_001_white_noise_loop.m4a",
            "white_broadband_placeholder.m4a",
            "ss_001_white_noise_loop.m4a"
        ]

        for path in candidatePaths {
            let nsPath = path as NSString
            let resource = nsPath.deletingPathExtension
            let fileExtension = nsPath.pathExtension

            if let url = bundle.url(forResource: resource, withExtension: fileExtension) {
                return url
            }

            if let url = bundle.resourceURL?.appendingPathComponent(path),
               FileManager.default.fileExists(atPath: url.path) {
                return url
            }

            let fileName = nsPath.lastPathComponent as NSString
            if let url = bundle.url(
                forResource: fileName.deletingPathExtension,
                withExtension: fileName.pathExtension
            ) {
                return url
            }
        }

        return nil
    }
}
