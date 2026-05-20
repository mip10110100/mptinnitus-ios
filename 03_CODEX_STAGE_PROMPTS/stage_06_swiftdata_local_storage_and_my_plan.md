# Stage 06: SwiftData Local Storage and My Plan

## Objective

Implement local-only persistence, My Plan behavior, and delete/reset controls.

## Input files

01_SOURCE_OF_TRUTH/08_local_data_schema.xlsx, 01_SOURCE_OF_TRUTH/09_local_data_schema.json

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Create SwiftData models for ExerciseEntry, MyPlanItem, ThreeLinesJournalEntry, SoundPreference, ReminderSetting, UserPreference, and SafetyAcknowledgement/SeenFlag. Exercise-specific content can be stored as Codable JSON/Data payloads where appropriate. Implement Add to My Plan checkbox behavior on exercise screens. Implement My Plan dashboard with saved items and ability to remove items.

No data may be transmitted. No account or cloud sync.

## Acceptance criteria

Exercise entries save locally. My Plan items are added/removed locally. Existing My Plan items show checked on their source exercise page. Delete/reset settings can remove selected scopes with confirmation.

## Expected output

SwiftData models, local repositories, My Plan, delete/reset behavior.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
