//
//  TinnitusSoundProfileStore.swift
//  MPTinnitus
//
//  Created by Codex on 5/31/26.
//

import Combine
import Foundation

@MainActor
final class TinnitusSoundProfileStore: ObservableObject {
    @Published private(set) var profile: TinnitusSoundProfile?
    @Published private(set) var errorMessage: String?

    private let fileManager: FileManager
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        fileURL = Self.makeFileURL(fileManager: fileManager)
        load()
    }

    static func savedProfileExists(fileManager: FileManager = .default) -> Bool {
        fileManager.fileExists(atPath: makeFileURL(fileManager: fileManager).path)
    }

    static func deleteSavedProfile(fileManager: FileManager = .default) throws {
        let url = makeFileURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        try fileManager.removeItem(at: url)
    }

    func save(
        matchedFrequencyHz: Double,
        loudnessEstimate: Double?,
        matchConfidence: TinnitusMatchConfidence,
        laterality: TinnitusLaterality
    ) {
        let now = Date()
        let createdAt = profile?.createdAt ?? now
        let normalizedLoudness = loudnessEstimate.map { min(max($0, 0), 1) }
        let nextProfile = TinnitusSoundProfile(
            profileVersion: TinnitusSoundProfile.currentProfileVersion,
            matchedFrequencyHz: min(max(matchedFrequencyHz, TinnitusPitchScale.minFrequencyHz), TinnitusPitchScale.maxFrequencyHz),
            loudnessEstimate: normalizedLoudness,
            matchConfidence: matchConfidence,
            laterality: laterality,
            createdAt: createdAt,
            updatedAt: now
        )

        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(nextProfile)
            try data.write(to: fileURL, options: [.atomic])
            profile = nextProfile
            errorMessage = nil
        } catch {
            errorMessage = "Could not save this local estimate."

            #if DEBUG
            print("[MPTinnitus][TinnitusSoundProfileStore] Save failed: \(error.localizedDescription)")
            #endif
        }
    }

    func load() {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            profile = nil
            errorMessage = nil
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            profile = try decoder.decode(TinnitusSoundProfile.self, from: data)
            errorMessage = nil
        } catch {
            profile = nil
            errorMessage = "Could not load the saved local estimate."

            #if DEBUG
            print("[MPTinnitus][TinnitusSoundProfileStore] Load failed: \(error.localizedDescription)")
            #endif
        }
    }

    func deleteSavedProfile() throws {
        try Self.deleteSavedProfile(fileManager: fileManager)
        load()
    }

    private static func makeFileURL(fileManager: FileManager) -> URL {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        return baseURL
            .appendingPathComponent("MPTinnitus", isDirectory: true)
            .appendingPathComponent("tinnitus_sound_profile_v1.json")
    }
}

enum TinnitusPitchScale {
    static let minFrequencyHz = 100.0
    static let maxFrequencyHz = 10_000.0

    static func frequencyHz(for sliderValue: Double) -> Double {
        let clampedValue = min(max(sliderValue, 0), 1)
        return minFrequencyHz * pow(maxFrequencyHz / minFrequencyHz, clampedValue)
    }

    static func sliderValue(for frequencyHz: Double) -> Double {
        let clampedFrequency = min(max(frequencyHz, minFrequencyHz), maxFrequencyHz)
        return log(clampedFrequency / minFrequencyHz) / log(maxFrequencyHz / minFrequencyHz)
    }
}
