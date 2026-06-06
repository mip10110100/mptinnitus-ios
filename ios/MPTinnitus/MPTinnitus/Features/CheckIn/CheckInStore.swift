//
//  CheckInStore.swift
//  MPTinnitus
//
//  Created by Codex on 6/5/26.
//

import Combine
import Foundation

@MainActor
final class CheckInStore: ObservableObject {
    @Published private(set) var sessions: [CheckInSession] = []
    @Published private(set) var errorMessage: String?

    private let fileManager: FileManager
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        fileURL = Self.makeFileURL(fileManager: fileManager)
        load()
    }

    var latestSession: CheckInSession? {
        sortedSessions.first
    }

    var previousSession: CheckInSession? {
        Array(sortedSessions.dropFirst()).first
    }

    var sortedSessions: [CheckInSession] {
        sessions.sorted { $0.completedAt > $1.completedAt }
    }

    static func sessionCount(fileManager: FileManager = .default) -> Int {
        guard let document = try? loadDocument(fileManager: fileManager) else {
            return 0
        }

        return document.sessions.count
    }

    static func deleteAllSessions(fileManager: FileManager = .default) throws {
        let url = makeFileURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        try fileManager.removeItem(at: url)
    }

    func load() {
        do {
            let document = try Self.loadDocument(fileManager: fileManager)
            sessions = document.sessions
            errorMessage = nil
        } catch CheckInStoreError.missingFile {
            sessions = []
            errorMessage = nil
        } catch {
            sessions = []
            errorMessage = "Could not load check-in history."

            #if DEBUG
            print("[MPTinnitus][CheckInStore] Load failed: \(error.localizedDescription)")
            #endif
        }
    }

    @discardableResult
    func saveSession(
        source: CheckInSessionSource,
        questions: [CheckInQuestion],
        selections: [String: CheckInScaleSelection],
        library: StaticModuleLibrary
    ) -> CheckInSession? {
        let now = Date()
        let responses = CheckInScoring.responses(
            for: questions,
            selections: selections
        )
        let domainScores = CheckInScoring.domainScores(
            questions: questions,
            responses: responses
        )
        let recommendations = CheckInRecommendationEngine.recommendations(
            domainScores: domainScores,
            library: library
        )
        let session = CheckInSession(
            sessionId: UUID(),
            schemaVersion: "tinnitus_checkins_v1",
            createdAt: now,
            completedAt: now,
            source: source,
            responses: responses,
            domainScores: domainScores,
            recommendations: recommendations,
            appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            appBuild: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
            itemVersion: "onboarding_checkin_v1"
        )

        do {
            sessions.append(session)
            try save()
            errorMessage = nil
            return session
        } catch {
            sessions.removeAll { $0.sessionId == session.sessionId }
            errorMessage = "Could not save this check-in."

            #if DEBUG
            print("[MPTinnitus][CheckInStore] Save failed: \(error.localizedDescription)")
            #endif

            return nil
        }
    }

    func deleteAllSessions() throws {
        try Self.deleteAllSessions(fileManager: fileManager)
        sessions = []
        errorMessage = nil
    }

    private func save() throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let document = CheckInSessionDocument(
            schemaVersion: "tinnitus_checkins_v1",
            sessions: sessions
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(document)
        try data.write(to: fileURL, options: [.atomic])
    }

    private static func loadDocument(fileManager: FileManager) throws -> CheckInSessionDocument {
        let url = makeFileURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: url.path) else {
            throw CheckInStoreError.missingFile
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CheckInSessionDocument.self, from: data)
    }

    private static func makeFileURL(fileManager: FileManager) -> URL {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        return baseURL
            .appendingPathComponent("MPTinnitus", isDirectory: true)
            .appendingPathComponent("tinnitus_checkins_v1.json")
    }
}

private enum CheckInStoreError: Error {
    case missingFile
}
