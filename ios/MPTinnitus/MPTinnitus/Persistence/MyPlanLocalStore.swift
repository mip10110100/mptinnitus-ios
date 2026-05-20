//
//  MyPlanLocalStore.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation
import SwiftData

@MainActor
enum MyPlanLocalStore {
    static func activeItem(
        in items: [MyPlanItemRecord],
        matching descriptor: MyPlanItemDescriptor
    ) -> MyPlanItemRecord? {
        items.first { item in
            matches(item, descriptor: descriptor) && !item.isArchived
        }
    }

    static func setSaved(
        _ isSaved: Bool,
        descriptor: MyPlanItemDescriptor,
        existingItems: [MyPlanItemRecord],
        modelContext: ModelContext
    ) throws {
        if isSaved {
            try add(descriptor: descriptor, existingItems: existingItems, modelContext: modelContext)
        } else if let item = activeItem(in: existingItems, matching: descriptor) {
            try archive(item, modelContext: modelContext)
        }
    }

    static func archive(_ item: MyPlanItemRecord, modelContext: ModelContext) throws {
        item.isArchived = true
        item.updatedAt = Date()
        try modelContext.save()
    }

    private static func add(
        descriptor: MyPlanItemDescriptor,
        existingItems: [MyPlanItemRecord],
        modelContext: ModelContext
    ) throws {
        let now = Date()
        let matchingItems = existingItems.filter { matches($0, descriptor: descriptor) }

        let item = matchingItems.first ?? MyPlanItemRecord(
            sourceType: descriptor.sourceType.rawValue,
            sourceID: descriptor.sourceID,
            moduleID: descriptor.moduleID,
            title: descriptor.title
        )

        item.sourceType = descriptor.sourceType.rawValue
        item.sourceID = descriptor.sourceID
        item.moduleID = descriptor.moduleID
        item.title = descriptor.title
        item.summary = descriptor.summary
        item.payloadJSON = descriptor.payloadJSON
        item.updatedAt = now
        item.sortOrder = now.timeIntervalSinceReferenceDate
        item.isArchived = false

        if matchingItems.isEmpty {
            item.createdAt = now
            modelContext.insert(item)
        }

        for duplicate in matchingItems where duplicate.id != item.id {
            duplicate.isArchived = true
            duplicate.updatedAt = now
        }

        try modelContext.save()
    }

    private static func matches(_ item: MyPlanItemRecord, descriptor: MyPlanItemDescriptor) -> Bool {
        item.sourceType == descriptor.sourceType.rawValue && item.sourceID == descriptor.sourceID
    }
}
