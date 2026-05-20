//
//  AudioController.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import Combine
import AVFoundation
import Foundation

@MainActor
final class AudioController: ObservableObject {
    @Published private(set) var currentAudioLabel = "No audio selected"
    @Published private(set) var currentAudioID: String?
    @Published private(set) var currentAssetPath: String?
    @Published private(set) var playbackContext: String?
    @Published private(set) var statusMessage: String?
    @Published private(set) var isPlaying = false
    @Published private(set) var isPlayable = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    deinit {
        progressTimer?.invalidate()
    }

    var canControlCurrentItem: Bool {
        audioPlayer != nil && isPlayable
    }

    func play(audio: StaticAudioItem) {
        stopCurrentPlayback()

        currentAudioID = audio.audioId
        currentAudioLabel = audio.title
        currentAssetPath = normalizedAssetPath(audio.assetPath)
        playbackContext = audio.playbackContext
        elapsedTime = 0
        duration = 0

        guard let assetPath = currentAssetPath, !assetPath.isEmpty else {
            markMissingAudio("Missing audio path for \(audio.audioId).")
            return
        }

        guard let url = bundledAudioURL(for: assetPath) else {
            markMissingAudio("Missing bundled audio file: \(assetPath)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayer = player
            isPlayable = true
            duration = player.duration
            statusMessage = nil
            player.play()
            isPlaying = true
            startProgressTimer()
        } catch {
            audioPlayer = nil
            isPlayable = false
            isPlaying = false
            statusMessage = "Could not play bundled audio."

            #if DEBUG
            print("[MPTinnitus][AudioController] Failed to play \(assetPath): \(error.localizedDescription)")
            #endif
        }
    }

    func togglePlayPause() {
        guard let audioPlayer, isPlayable else {
            return
        }

        if audioPlayer.isPlaying {
            audioPlayer.pause()
            isPlaying = false
            refreshProgress()
            stopProgressTimer()
        } else {
            audioPlayer.play()
            isPlaying = true
            startProgressTimer()
        }
    }

    func rewindFifteenSeconds() {
        guard let audioPlayer, isPlayable else {
            return
        }

        audioPlayer.currentTime = max(audioPlayer.currentTime - 15, 0)
        refreshProgress()
    }

    func forwardFifteenSeconds() {
        guard let audioPlayer, isPlayable else {
            return
        }

        audioPlayer.currentTime = min(audioPlayer.currentTime + 15, audioPlayer.duration)
        refreshProgress()
    }

    private func stopCurrentPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        isPlayable = false
        elapsedTime = 0
        duration = 0
        stopProgressTimer()
    }

    private func markMissingAudio(_ message: String) {
        audioPlayer = nil
        isPlayable = false
        isPlaying = false
        statusMessage = message
        stopProgressTimer()

        #if DEBUG
        print("[MPTinnitus][AudioController] \(message)")
        #endif
    }

    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshProgress()
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func refreshProgress() {
        guard let audioPlayer else {
            elapsedTime = 0
            duration = 0
            isPlaying = false
            return
        }

        elapsedTime = audioPlayer.currentTime
        duration = audioPlayer.duration

        if isPlaying && !audioPlayer.isPlaying {
            isPlaying = false
            stopProgressTimer()
        }
    }

    private func normalizedAssetPath(_ assetPath: String) -> String {
        let trimmedPath = assetPath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else {
            return trimmedPath
        }

        let path = trimmedPath.hasPrefix("/") ? String(trimmedPath.dropFirst()) : trimmedPath
        let nsPath = path as NSString
        let pathExtension = nsPath.pathExtension.lowercased()

        guard !pathExtension.isEmpty, pathExtension != "m4a" else {
            return path
        }

        let normalized = nsPath.deletingPathExtension + ".m4a"

        #if DEBUG
        print("[MPTinnitus][AudioController] Normalized audio path from \(path) to \(normalized).")
        #endif

        return normalized
    }

    private func bundledAudioURL(for assetPath: String) -> URL? {
        let nsPath = assetPath as NSString
        let resource = nsPath.deletingPathExtension
        let fileExtension = nsPath.pathExtension.isEmpty ? "m4a" : nsPath.pathExtension

        if let url = bundle.url(forResource: resource, withExtension: fileExtension) {
            return url
        }

        if let url = bundle.resourceURL?.appendingPathComponent(assetPath), FileManager.default.fileExists(atPath: url.path) {
            return url
        }

        let fileName = nsPath.lastPathComponent as NSString
        let flatResource = fileName.deletingPathExtension
        return bundle.url(forResource: flatResource, withExtension: fileExtension)
    }
}
