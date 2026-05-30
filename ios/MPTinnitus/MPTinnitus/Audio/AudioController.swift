//
//  AudioController.swift
//  MPTinnitus
//
//  Created by Mark Partain on 5/19/26.
//

import Combine
import AVFoundation
import Foundation

enum AudioPreferenceKeys {
    static let automaticallyPlayNextEducationSection = "mptinnitus.automaticallyPlayNextEducationSection"
}

@MainActor
final class AudioController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var currentAudioLabel = "No audio selected"
    @Published private(set) var currentAudioID: String?
    @Published private(set) var currentAssetPath: String?
    @Published private(set) var playbackContext: String?
    @Published private(set) var statusMessage: String?
    @Published private(set) var isPlaying = false
    @Published private(set) var isPlayable = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var hasNextSectionInQueue = false

    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private let bundle: Bundle
    private var sectionAudioQueue: [StaticAudioItem] = []
    private var sectionAudioQueueContextID: String?
    private var currentSectionQueueIndex: Int?

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        super.init()
    }

    deinit {
        progressTimer?.invalidate()
    }

    var canControlCurrentItem: Bool {
        audioPlayer != nil && isPlayable
    }

    func play(audio: StaticAudioItem) {
        stopCurrentPlayback()
        syncQueueIndex(for: audio.audioId)

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
            player.delegate = self
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
            statusMessage = "Could not play this audio."

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
            if audioPlayer.currentTime >= audioPlayer.duration {
                audioPlayer.currentTime = 0
                elapsedTime = 0
            }
            statusMessage = nil
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

    func setSectionAudioQueue(_ queue: [StaticAudioItem], contextID: String) {
        sectionAudioQueue = queue
        sectionAudioQueueContextID = contextID
        syncQueueIndex(for: currentAudioID)
    }

    func clearSectionAudioQueue(contextID: String? = nil) {
        guard contextID == nil || contextID == sectionAudioQueueContextID else {
            return
        }

        sectionAudioQueue = []
        sectionAudioQueueContextID = nil
        currentSectionQueueIndex = nil
        hasNextSectionInQueue = false
    }

    func playNextSection() {
        guard let nextAudio = nextSectionAudio else {
            hasNextSectionInQueue = false
            return
        }

        play(audio: nextAudio)
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in
            self?.handlePlaybackFinished(for: player)
        }
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
        statusMessage = "Audio file will be added later."
        stopProgressTimer()
        updateHasNextSection()

        #if DEBUG
        print("[MPTinnitus][AudioController] \(message)")
        #endif
    }

    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                self.refreshProgress()
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
            handlePlaybackFinished(for: audioPlayer)
        }
    }

    private func handlePlaybackFinished(for finishedPlayer: AVAudioPlayer) {
        guard finishedPlayer === audioPlayer else {
            return
        }

        guard isPlaying || audioPlayer != nil else {
            return
        }

        isPlaying = false
        if let audioPlayer {
            elapsedTime = audioPlayer.duration
            duration = audioPlayer.duration
        }
        stopProgressTimer()
        updateHasNextSection()

        guard UserDefaults.standard.bool(forKey: AudioPreferenceKeys.automaticallyPlayNextEducationSection) else {
            statusMessage = hasNextSectionInQueue ? "Section ended. Tap next to continue." : "Section ended."
            return
        }

        if hasNextSectionInQueue {
            playNextSection()
        } else {
            statusMessage = "Section ended."
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

        guard !pathExtension.isEmpty else {
            return path
        }

        return path
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

    private var nextSectionAudio: StaticAudioItem? {
        guard let currentSectionQueueIndex else {
            return nil
        }

        let nextIndex = currentSectionQueueIndex + 1
        guard sectionAudioQueue.indices.contains(nextIndex) else {
            return nil
        }

        return sectionAudioQueue[nextIndex]
    }

    private func syncQueueIndex(for audioID: String?) {
        guard let audioID,
              let index = sectionAudioQueue.firstIndex(where: { $0.audioId == audioID }) else {
            currentSectionQueueIndex = nil
            hasNextSectionInQueue = false
            return
        }

        currentSectionQueueIndex = index
        updateHasNextSection()
    }

    private func updateHasNextSection() {
        guard let currentSectionQueueIndex else {
            hasNextSectionInQueue = false
            return
        }

        hasNextSectionInQueue = sectionAudioQueue.indices.contains(currentSectionQueueIndex + 1)
    }
}
