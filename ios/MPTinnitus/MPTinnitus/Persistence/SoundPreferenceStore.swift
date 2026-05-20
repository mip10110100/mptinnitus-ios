//
//  SoundPreferenceStore.swift
//  MPTinnitus
//
//  Created by Codex on 5/20/26.
//

import Foundation
import SwiftData

@MainActor
enum SoundPreferenceStore {
    static func activeFavorite(
        in preferences: [SoundPreferenceRecord],
        matching sample: SoundSampleItem
    ) -> SoundPreferenceRecord? {
        preferences.first { preference in
            sample.preferenceIds.contains(preference.soundID) &&
            preference.isFavorite &&
            !preference.isArchived
        }
    }

    static func setFavorite(
        _ isFavorite: Bool,
        sample: SoundSampleItem,
        volumeLevel: Double,
        existingPreferences: [SoundPreferenceRecord],
        modelContext: ModelContext
    ) throws {
        if isFavorite {
            try addFavorite(
                sample: sample,
                volumeLevel: volumeLevel,
                existingPreferences: existingPreferences,
                modelContext: modelContext
            )
        } else {
            try archiveFavorites(
                sample: sample,
                existingPreferences: existingPreferences,
                modelContext: modelContext
            )
        }
    }

    private static func addFavorite(
        sample: SoundSampleItem,
        volumeLevel: Double,
        existingPreferences: [SoundPreferenceRecord],
        modelContext: ModelContext
    ) throws {
        let now = Date()
        let matchingPreferences = existingPreferences.filter { preference in
            sample.preferenceIds.contains(preference.soundID)
        }

        let preference = matchingPreferences.first ?? SoundPreferenceRecord(
            soundID: sample.id,
            soundTitle: sample.title,
            soundCategory: sample.category
        )

        preference.soundID = sample.id
        preference.soundTitle = sample.title
        preference.soundCategory = sample.category
        preference.preferredVolumeNote = "Saved from Sound Therapy Annex at about \(Int((volumeLevel * 100).rounded()))% of the app's capped preview range."
        preference.contextNote = "Starter sound sample preference. This stays on this device."
        preference.isFavorite = true
        preference.updatedAt = now
        preference.isArchived = false

        if matchingPreferences.isEmpty {
            preference.createdAt = now
            modelContext.insert(preference)
        }

        for duplicate in matchingPreferences where duplicate.id != preference.id {
            duplicate.isFavorite = false
            duplicate.isArchived = true
            duplicate.updatedAt = now
        }

        try modelContext.save()
    }

    private static func archiveFavorites(
        sample: SoundSampleItem,
        existingPreferences: [SoundPreferenceRecord],
        modelContext: ModelContext
    ) throws {
        let now = Date()
        var changed = false

        for preference in existingPreferences where sample.preferenceIds.contains(preference.soundID) && !preference.isArchived {
            preference.isFavorite = false
            preference.isArchived = true
            preference.updatedAt = now
            changed = true
        }

        if changed {
            try modelContext.save()
        }
    }
}
