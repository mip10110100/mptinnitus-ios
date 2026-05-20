//
//  LocalPersistenceController.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation
import SwiftData

@MainActor
final class LocalPersistenceController {
    struct InitializationStatus {
        let isReady: Bool
        let usesInMemoryFallback: Bool
        let errorDescription: String?
    }

    static let shared = LocalPersistenceController()

    let container: ModelContainer
    let status: InitializationStatus

    init(inMemory: Bool = false) {
        let result = Self.makeContainer(inMemory: inMemory)
        container = result.container
        status = result.status
    }

    func validateContainer() -> Bool {
        do {
            let context = ModelContext(container)
            var descriptor = FetchDescriptor<LocalSchemaMetadataRecord>()
            descriptor.fetchLimit = 1
            _ = try context.fetch(descriptor)

            #if DEBUG
            print("[MPTinnitus][LocalPersistence] ModelContainer validation succeeded.")
            #endif

            return true
        } catch {
            #if DEBUG
            print("[MPTinnitus][LocalPersistence] ModelContainer validation failed: \(error.localizedDescription)")
            #endif

            return false
        }
    }

    #if DEBUG
    func logInitializationStatus() {
        let fallbackSuffix = status.usesInMemoryFallback ? " using in-memory fallback" : ""
        let errorSuffix = status.errorDescription.map { " after error: \($0)" } ?? ""
        print("[MPTinnitus][LocalPersistence] ModelContainer ready\(fallbackSuffix)\(errorSuffix).")
    }
    #endif

    private static func makeContainer(inMemory: Bool) -> (container: ModelContainer, status: InitializationStatus) {
        do {
            let container = try buildContainer(inMemory: inMemory)
            return (
                container,
                InitializationStatus(isReady: true, usesInMemoryFallback: inMemory, errorDescription: nil)
            )
        } catch {
            #if DEBUG
            print("[MPTinnitus][LocalPersistence] Persistent ModelContainer failed: \(error.localizedDescription)")
            #endif

            do {
                let fallbackContainer = try buildContainer(inMemory: true)
                return (
                    fallbackContainer,
                    InitializationStatus(
                        isReady: true,
                        usesInMemoryFallback: true,
                        errorDescription: error.localizedDescription
                    )
                )
            } catch {
                fatalError("Unable to initialize local SwiftData container: \(error.localizedDescription)")
            }
        }
    }

    private static func buildContainer(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema(MPTinnitusLocalSchema.models)
        let configuration = ModelConfiguration(
            "MPTinnitusLocalStore",
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
