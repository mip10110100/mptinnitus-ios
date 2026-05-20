# Stage 04: Static Screen Renderer and Module Library

## Objective

Render the educational screens with expandable cards, play/transcript controls, and module routing.

## Input files

01_SOURCE_OF_TRUTH/02_mvp_screen_spec_pack.xlsx, 01_SOURCE_OF_TRUTH/05_full_audio_manifest.csv

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Implement reusable SwiftUI components: ModuleCard, ExpandableContentCard, AudioCard, TranscriptDisclosure, SafetyScopeCard, ModuleOverviewScreen, ExerciseLaunchCard. Render About Tinnitus, Sound Therapy, Acceptance and Change, Mindfulness, Distress Tolerance, Cognitive Reframing, Confidence and Communication, Sleep, and My Plan module cards.

Do not implement all custom exercise logic yet. Buttons can route to placeholder detail screens where needed.

## Acceptance criteria

Users can browse the Library, open module overview screens, expand cards, see Play and Transcript buttons, and route to placeholder exercise screens. Transcripts start collapsed.

## Expected output

Reusable screen/card system and module browsing.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
