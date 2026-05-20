//
//  SoundSampleController.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import AVFoundation
import Combine
import Foundation

@MainActor
final class SoundSampleController: ObservableObject {
    static let safeVolumeCap = 0.65

    @Published private(set) var currentSampleID: String?
    @Published private(set) var currentSampleTitle = "No sample selected"
    @Published private(set) var currentAssetPath: String?
    @Published private(set) var isPlayable = false
    @Published private(set) var isPlaying = false
    @Published private(set) var statusMessage = "Choose a sample to preview."
    @Published var volumeLevel = 0.45 {
        didSet {
            applyVolume()
        }
    }

    private let bundle: Bundle
    private var player: AVAudioPlayer?

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    deinit {
        player?.stop()
    }

    var safeVolumePercent: Int {
        Int((volumeLevel * 100).rounded())
    }

    func toggle(sample: SoundSampleItem) {
        if currentSampleID == sample.id, isPlayable {
            toggleCurrentPlayback()
        } else {
            play(sample: sample)
        }
    }

    func play(sample: SoundSampleItem) {
        stopCurrentPlayback(clearSelection: false)

        currentSampleID = sample.id
        currentSampleTitle = sample.title
        currentAssetPath = sample.assetPath

        guard let url = bundledAudioURL(for: sample) else {
            markMissingSample("Sample audio will be added later.")
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = 0
            audioPlayer.prepareToPlay()
            player = audioPlayer
            isPlayable = true
            statusMessage = "Playing a local foreground preview. Volume is capped for safety."
            applyVolume()

            if audioPlayer.play() {
                isPlaying = true
            } else {
                isPlaying = false
                statusMessage = "Could not start this local sample preview."
            }
        } catch {
            markMissingSample("Could not play this bundled sample.")

            #if DEBUG
            print("[MPTinnitus][SoundSampleController] Failed to play \(sample.assetPath): \(error.localizedDescription)")
            #endif
        }
    }

    func toggleCurrentPlayback() {
        guard let player, isPlayable else {
            return
        }

        if player.isPlaying {
            player.pause()
            isPlaying = false
            statusMessage = "Preview paused."
        } else {
            if player.currentTime >= player.duration {
                player.currentTime = 0
            }

            player.play()
            isPlaying = true
            statusMessage = "Playing a local foreground preview. Volume is capped for safety."
        }
    }

    func setVolumeLevel(_ level: Double) {
        volumeLevel = min(max(level, 0), 1)
    }

    func stop() {
        stopCurrentPlayback(clearSelection: true)
    }

    private func stopCurrentPlayback(clearSelection: Bool) {
        player?.stop()
        player = nil
        isPlaying = false
        isPlayable = false

        if clearSelection {
            currentSampleID = nil
            currentSampleTitle = "No sample selected"
            currentAssetPath = nil
            statusMessage = "Choose a sample to preview."
        }
    }

    private func markMissingSample(_ message: String) {
        player = nil
        isPlayable = false
        isPlaying = false
        statusMessage = message

        #if DEBUG
        if let currentAssetPath {
            print("[MPTinnitus][SoundSampleController] Missing bundled sample for \(currentSampleID ?? "unknown"): \(currentAssetPath)")
        }
        #endif
    }

    private func applyVolume() {
        player?.volume = Float(volumeLevel * Self.safeVolumeCap)
    }

    private func bundledAudioURL(for sample: SoundSampleItem) -> URL? {
        for path in sample.lookupPaths {
            if let url = bundledAudioURL(for: path) {
                currentAssetPath = path
                return url
            }
        }

        return nil
    }

    private func bundledAudioURL(for assetPath: String) -> URL? {
        let path = assetPath.hasPrefix("/") ? String(assetPath.dropFirst()) : assetPath
        let nsPath = path as NSString
        let resource = nsPath.deletingPathExtension
        let fileExtension = nsPath.pathExtension.isEmpty ? "m4a" : nsPath.pathExtension

        if let url = bundle.url(forResource: resource, withExtension: fileExtension) {
            return url
        }

        if let url = bundle.resourceURL?.appendingPathComponent(path),
           FileManager.default.fileExists(atPath: url.path) {
            return url
        }

        let fileName = nsPath.lastPathComponent as NSString
        return bundle.url(
            forResource: fileName.deletingPathExtension,
            withExtension: fileName.pathExtension.isEmpty ? "m4a" : fileName.pathExtension
        )
    }
}
