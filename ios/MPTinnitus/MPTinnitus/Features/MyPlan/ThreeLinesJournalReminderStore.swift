//
//  ThreeLinesJournalReminderStore.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Foundation

enum ThreeLinesJournalReminderStore {
    static func load(fileManager: FileManager = .default) -> ThreeLinesJournalReminderPreference {
        let url = fileURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let preference = try? decoder.decode(ThreeLinesJournalReminderPreference.self, from: data) else {
            return .defaultDisabled
        }

        return preference
    }

    static func save(
        _ preference: ThreeLinesJournalReminderPreference,
        fileManager: FileManager = .default
    ) throws {
        let url = fileURL(fileManager: fileManager)
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(preference)
        try data.write(to: url, options: [.atomic])
    }

    static func deletePreference(fileManager: FileManager = .default) throws {
        let url = fileURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        try fileManager.removeItem(at: url)
    }

    static func fileURL(fileManager: FileManager = .default) -> URL {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        return baseURL
            .appendingPathComponent("MPTinnitus", isDirectory: true)
            .appendingPathComponent("three_lines_journal_reminder_v1.json")
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
