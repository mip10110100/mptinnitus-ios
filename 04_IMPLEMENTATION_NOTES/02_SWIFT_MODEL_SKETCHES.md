# Swift Model Sketches

These are sketches, not final code. They show how Codex should think about the data layer.

## Manifest models

```swift
struct RouteItem: Codable, Identifiable {
    var id: String { screenId }
    let screenId: String
    let route: String
    let module: String
    let title: String
    let role: String
}

struct AudioManifestItem: Codable, Identifiable {
    var id: String { audioId }
    let audioId: String
    let moduleId: String
    let topic: String
    let type: String
    let assetPath: String
    let transcript: String
    let embeddedForMVP: Bool
    let playbackContext: AudioPlaybackContext
}
```

## SwiftData model sketches

```swift
@Model
final class ExerciseEntry {
    @Attribute(.unique) var id: UUID
    var exerciseId: String
    var screenId: String
    var moduleId: String
    var createdAt: Date
    var updatedAt: Date
    var title: String
    var summary: String?
    var payloadJSON: Data
    var isAddedToMyPlan: Bool
}

@Model
final class MyPlanItem {
    @Attribute(.unique) var id: UUID
    var sourceType: String
    var sourceId: String
    var moduleId: String
    var title: String
    var displayText: String?
    var createdAt: Date
    var updatedAt: Date
    var payloadJSON: Data?
}

@Model
final class ThreeLinesJournalEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var soundTherapyText: String?
    var emotionalRegulationText: String?
    var mindfulnessText: String?
    var createdAt: Date
    var updatedAt: Date
}
```

## Payload strategy

Use typed payload structs in code, but store as JSON/Data for flexibility. Examples:

- BodyMindLifePayload
- SoundTherapyLevelPayload
- YesAndPayload
- ThoughtRecordPayload
- DearManPayload
- SleepThoughtPayload

This avoids needing a separate SwiftData entity for every worksheet while still preserving local entries.
