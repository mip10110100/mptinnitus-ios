# Tinnitus App Codex Handoff Pack v1

Created: 2026-05-19

This package is the first build-facing handoff for the MVP. It should be used together with the source-of-truth files in `01_SOURCE_OF_TRUTH`.

The goal is not to ask Codex to build the entire app in one pass. The goal is to stage the build so each layer can be created, reviewed, and corrected before the next layer is added.

## Locked build target

- Platform: iOS first
- Minimum iOS version: iOS 17+
- App framework: Swift + SwiftUI
- Local data: SwiftData, with Codable payloads for exercise-specific responses where appropriate
- Audio: AVFoundation / AVFAudio / AVAudioSession
- Audio assets: embedded `.m4a` / AAC for MVP
- Storage: local-only, on-device
- Accounts/server: none for MVP
- Notifications: local scheduled notifications only
- Android: future implementation using the same content, route, audio, visual, and local-data contracts

## How to use this package

1. Read `00_README/01_PROJECT_BRIEF.md`.
2. Read `02_TECHNICAL_CONTRACTS/01_BUILD_STACK_LOCK.md`.
3. Read `02_TECHNICAL_CONTRACTS/02_APP_ARCHITECTURE_CONTRACT.md`.
4. Read `02_TECHNICAL_CONTRACTS/03_MANIFEST_CONTRACTS.md`.
5. Use the staged prompts in `03_CODEX_STAGE_PROMPTS` in order.
6. Do not skip stage acceptance criteria. Each stage should compile and run before moving on.

## Core source files

The most important source files are:

- `01_SOURCE_OF_TRUTH/01_v10_asset_locked_source.xlsx`
- `01_SOURCE_OF_TRUTH/02_mvp_screen_spec_pack.xlsx`
- `01_SOURCE_OF_TRUTH/03_mvp_audio_manifest_recording_queue.xlsx`
- `01_SOURCE_OF_TRUTH/07_visual_interaction_manifest.xlsx`
- `01_SOURCE_OF_TRUTH/08_local_data_schema.xlsx`
- `01_SOURCE_OF_TRUTH/09_local_data_schema.json`

## Non-negotiable rules

- The MVP must not require an account.
- The MVP must not transmit user entries, preferences, journal content, exercise responses, or My Plan items.
- The MVP must not use remote analytics or remote monitoring.
- Safety and scope copy must be visible where specified.
- Audio must have a transcript.
- Exercise pages must allow save/skip/repeat and local delete of past entries.
- Add-to-My-Plan is the only MVP status marker. There is no completion tracking, streaks, or gamification.
