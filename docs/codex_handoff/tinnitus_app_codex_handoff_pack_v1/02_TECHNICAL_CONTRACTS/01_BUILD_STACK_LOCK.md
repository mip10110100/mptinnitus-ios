# Build Stack Lock

## Locked platform

- iOS first
- Minimum target: iOS 17+
- Android later

## Locked iOS stack

- Swift
- SwiftUI
- SwiftData
- AVFoundation / AVFAudio / AVAudioSession
- UserNotifications for local reminders
- Bundle-based JSON/content manifests for MVP
- Embedded `.m4a` / AAC narration and starter sound samples for MVP

## Why this stack

The app prioritizes a strong foundation, offline behavior, local-only privacy, ownership of code, reliable audio behavior, and low recurring platform cost. Native SwiftUI is preferred over no-code and over a temporary prototype stack.

## Persistence choice

Use SwiftData because the app targets iOS 17+. Exercise-specific response content may be stored in Codable payload structures to avoid creating a separate persistence model for every worksheet variation.

Recommended SwiftData entities:

- UserPreference
- ExerciseEntry
- MyPlanItem
- ThreeLinesJournalEntry
- SoundPreference
- AudioPlaybackBookmark or AudioPlaybackState
- ReminderSetting
- SafetyAcknowledgement or ScopeSeenFlag

## Audio choice

Use AVFoundation for audio. MVP audio should support:

- short narration clips
- guided practice clips
- embedded sound samples
- background sound/sample playback where feasible
- mini-player controls
- transcript display

## Do not add for MVP

- Account system
- Cloud database
- Remote analytics
- Remote push notification service
- Clinician dashboard
- Automatic export
- Muse device integration
- Gamification system
