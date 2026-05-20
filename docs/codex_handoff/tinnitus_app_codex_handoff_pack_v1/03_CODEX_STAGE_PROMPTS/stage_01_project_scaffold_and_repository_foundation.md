# Stage 01: Project Scaffold and Repository Foundation

## Objective

Create a clean iOS 17+ SwiftUI project foundation without implementing all app features yet.

## Input files

02_TECHNICAL_CONTRACTS/01_BUILD_STACK_LOCK.md, 02_TECHNICAL_CONTRACTS/app_config_v1.json

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Create an iOS 17+ SwiftUI app named MPTinnitus. Use SwiftData capability and AVFoundation imports where needed, but do not overbuild audio or persistence yet. Create a modular folder structure: App, Core, Features, Content, Audio, Persistence, DesignSystem, Resources, Tests. Add placeholder app icon/color references only. Create the app entry point, a root shell view, and placeholder tab destinations for Library, Sound Therapy Annex, Mindfulness Annex, and My Plan.

Do not add networking, remote analytics, account login, cloud sync, or external services.

## Acceptance criteria

The project opens in Xcode, builds, and runs on an iOS 17+ simulator. The app displays the four bottom navigation items and placeholder pages. There are no network calls or account prompts.

## Expected output

A compiling SwiftUI app shell.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
