//
//  BreathingVideoLibrary.swift
//  MPTinnitus
//
//  Created by Codex on 5/30/26.
//

import Foundation

struct BreathingVideoLibraryDocument: Codable, Equatable {
    let schemaVersion: String
    let manifestVersion: String
    let videos: [BreathingVideoItem]
}

struct BreathingVideoItem: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let category: String
    let pattern: BreathingVideoPattern
    let filename: String
    let assetPath: String
    let loopCapable: Bool
    let playbackMode: String
    let mutedByDefault: Bool
    let sourceFilename: String
    let sourceZip: String
    let fileSizeBytes: Int
    let sha256: String
    let durationSeconds: Double
    let reducedMotionFallback: String
    let status: String

    var accessibilityLabel: String {
        switch id {
        case "video.breathing.4_2_4.loop":
            "Looping breathing video for a four-count inhale, two-count pause, and four-count exhale."
        case "video.breathing.4_4.loop":
            "Looping breathing video for a four-count inhale and four-count exhale."
        case "video.breathing.4_6.loop":
            "Looping breathing video for a four-count inhale and six-count exhale."
        case "video.breathing.4_2_6.loop":
            "Looping breathing video for a four-count inhale, two-count pause, and six-count exhale."
        default:
            "Looping breathing video."
        }
    }

    func bundledURL(bundle: Bundle = .main) -> URL? {
        if let url = bundle.resourceURL?.appendingPathComponent(assetPath),
           FileManager.default.fileExists(atPath: url.path) {
            return url
        }

        let nsPath = filename as NSString
        if let url = bundle.url(
            forResource: nsPath.deletingPathExtension,
            withExtension: nsPath.pathExtension
        ) {
            return url
        }

        return nil
    }
}

struct BreathingVideoPattern: Codable, Equatable {
    let inhale: Int
    let holdAfterInhale: Int
    let exhale: Int
    let holdAfterExhale: Int

    var shortLabel: String {
        if holdAfterInhale > 0 {
            return "\(inhale)-\(holdAfterInhale)-\(exhale)"
        }

        return "\(inhale)-\(exhale)"
    }
}

struct BreathingVideoLibraryLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    func loadVideos() -> [BreathingVideoItem] {
        guard let url = bundle.url(forResource: "video_assets_v1", withExtension: "json") else {
            #if DEBUG
            print("[MPTinnitus][BreathingVideoLibrary] video_assets_v1.json is missing.")
            #endif
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let document = try decoder.decode(BreathingVideoLibraryDocument.self, from: data)
            return document.videos.filter { video in
                video.status == "available" && video.category == "mindfulness_breathing"
            }
        } catch {
            #if DEBUG
            print("[MPTinnitus][BreathingVideoLibrary] Could not decode video_assets_v1.json: \(error.localizedDescription)")
            #endif
            return []
        }
    }
}
