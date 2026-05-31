//
//  TinnitusPitchMatchAudioEngine.swift
//  MPTinnitus
//
//  Created by Codex on 5/31/26.
//

import AVFoundation
import Combine
import Foundation

final class TinnitusPitchMatchAudioEngine: ObservableObject {
    static let safeAmplitudeCap = 0.22

    @Published private(set) var isPlaying = false
    @Published private(set) var statusMessage: String?

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let stateLock = NSLock()
    private var phase = 0.0
    private var currentFrequencyHz = 1_000.0
    private var targetFrequencyHz = 1_000.0
    private var currentAmplitude = 0.0
    private var targetAmplitude = 0.0
    private var sampleRate = 44_100.0
    private var stopGeneration = 0

    deinit {
        engine.stop()
    }

    func start(frequencyHz: Double, loudness: Double) {
        stopGeneration += 1
        updateTargets(frequencyHz: frequencyHz, loudness: loudness)
        configureIfNeeded()

        guard !engine.isRunning else {
            isPlaying = true
            statusMessage = nil
            return
        }

        do {
            engine.prepare()
            try engine.start()
            isPlaying = true
            statusMessage = nil
        } catch {
            isPlaying = false
            statusMessage = "Could not start the local tone."

            #if DEBUG
            print("[MPTinnitus][TinnitusPitchMatchAudioEngine] Start failed: \(error.localizedDescription)")
            #endif
        }
    }

    func update(frequencyHz: Double, loudness: Double) {
        updateTargets(frequencyHz: frequencyHz, loudness: loudness)
    }

    func stop() {
        guard engine.isRunning || isPlaying else {
            return
        }

        stopGeneration += 1
        let generation = stopGeneration
        setTargetAmplitude(0)
        isPlaying = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            guard let self else {
                return
            }

            Task { @MainActor in
                guard self.stopGeneration == generation, !self.isPlaying else {
                    return
                }

                self.engine.stop()
                self.stateLock.lock()
                self.currentAmplitude = 0
                self.targetAmplitude = 0
                self.stateLock.unlock()
            }
        }
    }

    private func configureIfNeeded() {
        guard sourceNode == nil else {
            return
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        )

        let node = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else {
                return noErr
            }

            self.render(
                frameCount: Int(frameCount),
                audioBufferList: audioBufferList
            )
            return noErr
        }

        sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)

        if let sampleRate = format?.sampleRate {
            self.sampleRate = sampleRate
        }
    }

    private func render(
        frameCount: Int,
        audioBufferList: UnsafeMutablePointer<AudioBufferList>
    ) {
        stateLock.lock()
        let targetFrequency = targetFrequencyHz
        let targetAmp = targetAmplitude
        var localFrequency = currentFrequencyHz
        var localAmplitude = currentAmplitude
        var localPhase = phase
        let localSampleRate = sampleRate
        stateLock.unlock()

        let frequencySmoothing = 0.0015
        let amplitudeSmoothing = 0.01
        let twoPi = Double.pi * 2
        let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)

        for frame in 0..<frameCount {
            localFrequency += (targetFrequency - localFrequency) * frequencySmoothing
            localAmplitude += (targetAmp - localAmplitude) * amplitudeSmoothing
            localPhase += twoPi * localFrequency / localSampleRate

            if localPhase > twoPi {
                localPhase -= twoPi
            }

            let sample = Float(sin(localPhase) * localAmplitude)

            for buffer in buffers {
                guard let data = buffer.mData else {
                    continue
                }

                data.assumingMemoryBound(to: Float.self)[frame] = sample
            }
        }

        stateLock.lock()
        currentFrequencyHz = localFrequency
        currentAmplitude = localAmplitude
        phase = localPhase
        stateLock.unlock()
    }

    private func updateTargets(frequencyHz: Double, loudness: Double) {
        let clampedFrequency = min(max(frequencyHz, TinnitusPitchScale.minFrequencyHz), TinnitusPitchScale.maxFrequencyHz)
        let clampedLoudness = min(max(loudness, 0), 1)

        stateLock.lock()
        targetFrequencyHz = clampedFrequency
        targetAmplitude = clampedLoudness * Self.safeAmplitudeCap
        stateLock.unlock()
    }

    private func setTargetAmplitude(_ amplitude: Double) {
        stateLock.lock()
        targetAmplitude = min(max(amplitude, 0), Self.safeAmplitudeCap)
        stateLock.unlock()
    }
}
