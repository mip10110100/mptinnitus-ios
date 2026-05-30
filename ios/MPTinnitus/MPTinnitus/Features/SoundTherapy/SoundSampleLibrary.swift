//
//  SoundSampleLibrary.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation

struct SoundSampleItem: Identifiable, Equatable {
    let sampleId: String
    let title: String
    let category: String
    let assetPath: String
    let alternateAssetPaths: [String]
    let legacyIds: [String]
    let status: String
    let guidance: String
    let displayGroup: String
    let playbackMode: String
    let loopCapable: Bool
    let sourceFilename: String?
    let sourceZip: String?
    let fileSizeBytes: Int?
    let durationSeconds: Double?
    let sha256: String?

    var id: String {
        sampleId
    }

    var lookupPaths: [String] {
        ([assetPath] + alternateAssetPaths).reduce(into: []) { paths, path in
            if !paths.contains(path) {
                paths.append(path)
            }
        }
    }

    var preferenceIds: [String] {
        ([sampleId] + legacyIds).reduce(into: []) { ids, id in
            if !ids.contains(id) {
                ids.append(id)
            }
        }
    }
}

struct SoundSampleLibraryLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    func loadSamples() -> [SoundSampleItem] {
        guard let url = bundle.url(forResource: "asset_placeholders_v1", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let document = try? decoder.decode(AssetPlaceholderDocument.self, from: data) else {
            return Self.fallbackSamples
        }

        let samples = document.soundSamples.map { placeholder in
            makeSample(from: placeholder)
        }

        return samples.isEmpty ? Self.fallbackSamples : samples
    }

    private func makeSample(from placeholder: SoundSamplePlaceholder) -> SoundSampleItem {
        let metadata = Self.metadata(for: placeholder.id, title: placeholder.title)
        let usesPackagedMetadata = placeholder.status == "packaged"
            || placeholder.playbackMode != nil
            || placeholder.id.hasPrefix("st.noise.")

        let sampleId = usesPackagedMetadata ? placeholder.id : metadata.sampleId
        let primaryPath = usesPackagedMetadata ? placeholder.assetPath : metadata.primaryPath
        let alternatePaths = usesPackagedMetadata
            ? (placeholder.alternateAssetPaths ?? [])
            : ([placeholder.assetPath] + (placeholder.alternateAssetPaths ?? []) + metadata.alternatePaths)
        let legacyIds = usesPackagedMetadata ? (placeholder.legacyIds ?? []) : ((placeholder.legacyIds ?? []) + metadata.legacyIds)

        return SoundSampleItem(
            sampleId: sampleId,
            title: placeholder.title,
            category: placeholder.category ?? metadata.category,
            assetPath: primaryPath,
            alternateAssetPaths: alternatePaths.filter { $0 != primaryPath },
            legacyIds: legacyIds.filter { $0 != sampleId },
            status: placeholder.status,
            guidance: placeholder.guidance ?? metadata.guidance,
            displayGroup: placeholder.displayGroup ?? metadata.displayGroup,
            playbackMode: placeholder.playbackMode ?? metadata.playbackMode,
            loopCapable: placeholder.loopCapable ?? metadata.loopCapable,
            sourceFilename: placeholder.sourceFilename,
            sourceZip: placeholder.sourceZip,
            fileSizeBytes: placeholder.fileSizeBytes,
            durationSeconds: placeholder.durationSeconds,
            sha256: placeholder.sha256
        )
    }

    private static let fallbackSamples: [SoundSampleItem] = [
        makeFallbackSample(
            id: "SS-001",
            title: "White / steady broadband noise",
            category: "Noise",
            path: "audio/sound_samples/ss_001_white_noise_loop.m4a",
            alternates: ["audio/samples/white_broadband_placeholder.m4a"],
            legacyIds: ["SND-WHITE-001"],
            guidance: "A steady broadband sound. Start low and use it only if it feels comfortable.",
            displayGroup: "Static noise",
            playbackMode: "sound_therapy_loop",
            loopCapable: true
        ),
        makeFallbackSample(
            id: "SS-002",
            title: "Pink / soft broadband noise",
            category: "Noise",
            path: "audio/sound_samples/ss_002_pink_noise_loop.m4a",
            alternates: ["audio/samples/pink_soft_broadband_placeholder.m4a"],
            legacyIds: ["SND-PINK-001"],
            guidance: "A softer broadband option. Some people prefer it to white noise.",
            displayGroup: "Static noise",
            playbackMode: "sound_therapy_loop",
            loopCapable: true
        ),
        makeFallbackSample(
            id: "SS-003",
            title: "Soft rain",
            category: "Water / nature",
            path: "audio/sound_samples/ss_003_soft_rain_loop.m4a",
            alternates: ["audio/samples/soft_rain_placeholder.m4a"],
            legacyIds: ["SND-RAIN-001"],
            guidance: "A natural sound option. Avoid harsh or startling sound.",
            displayGroup: "Nature and environmental sounds",
            playbackMode: "sound_therapy_sample",
            loopCapable: true
        ),
        makeFallbackSample(
            id: "SS-004",
            title: "Running water / stream",
            category: "Water",
            path: "audio/sound_samples/ss_004_stream_loop.m4a",
            alternates: ["audio/samples/running_water_stream_placeholder.m4a"],
            legacyIds: ["SND-STREAM-001"],
            guidance: "A moving-water option that some people find easier to blend with tinnitus.",
            displayGroup: "Nature and environmental sounds",
            playbackMode: "sound_therapy_sample",
            loopCapable: true
        ),
        makeFallbackSample(
            id: "SS-005",
            title: "Fan / steady air",
            category: "Mechanical steady sound",
            path: "audio/sound_samples/ss_005_fan_loop.m4a",
            alternates: ["audio/samples/fan_steady_air_placeholder.m4a"],
            legacyIds: ["SND-FAN-001"],
            guidance: "A practical steady sound similar to sounds many people already use at home.",
            displayGroup: "Nature and environmental sounds",
            playbackMode: "sound_therapy_sample",
            loopCapable: true
        ),
        makeFallbackSample(
            id: "SS-006",
            title: "Crickets / night insects",
            category: "Nature / night ambience",
            path: "audio/sound_samples/ss_006_crickets_loop.m4a",
            alternates: ["audio/samples/crickets_night_placeholder.m4a"],
            legacyIds: ["SND-CRICKETS-001"],
            guidance: "A night ambience option. Preference varies, and that is expected.",
            displayGroup: "Nature and environmental sounds",
            playbackMode: "sound_therapy_sample",
            loopCapable: true
        )
    ]

    private static func makeFallbackSample(
        id: String,
        title: String,
        category: String,
        path: String,
        alternates: [String],
        legacyIds: [String],
        guidance: String,
        displayGroup: String,
        playbackMode: String,
        loopCapable: Bool
    ) -> SoundSampleItem {
        SoundSampleItem(
            sampleId: id,
            title: title,
            category: category,
            assetPath: path,
            alternateAssetPaths: alternates,
            legacyIds: legacyIds,
            status: "placeholder",
            guidance: guidance,
            displayGroup: displayGroup,
            playbackMode: playbackMode,
            loopCapable: loopCapable,
            sourceFilename: nil,
            sourceZip: nil,
            fileSizeBytes: nil,
            durationSeconds: nil,
            sha256: nil
        )
    }

    private static func metadata(for id: String, title: String) -> (
        sampleId: String,
        category: String,
        primaryPath: String,
        alternatePaths: [String],
        legacyIds: [String],
        guidance: String,
        displayGroup: String,
        playbackMode: String,
        loopCapable: Bool
    ) {
        let normalized = title.lowercased()

        if id == "SS-001" || id == "SND-WHITE-001" || normalized.contains("white") {
            return (
                "SS-001",
                "Noise",
                "audio/sound_samples/ss_001_white_noise_loop.m4a",
                ["audio/samples/white_broadband_placeholder.m4a"],
                ["SND-WHITE-001"],
                "A steady broadband sound. Start low and use it only if it feels comfortable.",
                "Static noise",
                "sound_therapy_loop",
                true
            )
        } else if id == "SS-002" || id == "SND-PINK-001" || normalized.contains("pink") {
            return (
                "SS-002",
                "Noise",
                "audio/sound_samples/ss_002_pink_noise_loop.m4a",
                ["audio/samples/pink_soft_broadband_placeholder.m4a"],
                ["SND-PINK-001"],
                "A softer broadband option. Some people prefer it to white noise.",
                "Static noise",
                "sound_therapy_loop",
                true
            )
        } else if id == "SS-003" || id == "SND-RAIN-001" || normalized.contains("rain") {
            return (
                "SS-003",
                "Water / nature",
                "audio/sound_samples/ss_003_soft_rain_loop.m4a",
                ["audio/samples/soft_rain_placeholder.m4a"],
                ["SND-RAIN-001"],
                "A natural sound option. Avoid harsh or startling sound.",
                "Nature and environmental sounds",
                "sound_therapy_sample",
                true
            )
        } else if id == "SS-004" || id == "SND-STREAM-001" || normalized.contains("stream") || normalized.contains("water") {
            return (
                "SS-004",
                "Water",
                "audio/sound_samples/ss_004_stream_loop.m4a",
                ["audio/samples/running_water_stream_placeholder.m4a"],
                ["SND-STREAM-001"],
                "A moving-water option that some people find easier to blend with tinnitus.",
                "Nature and environmental sounds",
                "sound_therapy_sample",
                true
            )
        } else if id == "SS-005" || id == "SND-FAN-001" || normalized.contains("fan") {
            return (
                "SS-005",
                "Mechanical steady sound",
                "audio/sound_samples/ss_005_fan_loop.m4a",
                ["audio/samples/fan_steady_air_placeholder.m4a"],
                ["SND-FAN-001"],
                "A practical steady sound similar to sounds many people already use at home.",
                "Nature and environmental sounds",
                "sound_therapy_sample",
                true
            )
        } else if id == "SS-006" || id == "SND-CRICKETS-001" || normalized.contains("cricket") {
            return (
                "SS-006",
                "Nature / night ambience",
                "audio/sound_samples/ss_006_crickets_loop.m4a",
                ["audio/samples/crickets_night_placeholder.m4a"],
                ["SND-CRICKETS-001"],
                "A night ambience option. Preference varies, and that is expected.",
                "Nature and environmental sounds",
                "sound_therapy_sample",
                true
            )
        }

        return (
            id,
            "Sound sample",
            title.replacingOccurrences(of: " ", with: "_").lowercased() + ".m4a",
            [],
            [],
            "Use comfortable sound and stop if it feels painful or unsafe.",
            "Sound samples",
            "sound_therapy_sample",
            false
        )
    }
}
