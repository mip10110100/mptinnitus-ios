# Stage 03: Persistent App Shell and Navigation

## Objective

Implement the stable navigation model and audio mini-player placeholder.

## Input files

01_SOURCE_OF_TRUTH/02_mvp_screen_spec_pack.xlsx, 02_TECHNICAL_CONTRACTS/app_config_v1.json

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Build the root app shell with a persistent bottom navigation bar: Library, Sound Therapy Annex, Mindfulness Annex, My Plan. Add a persistent audio mini-player above the nav bar with play/pause, rewind 15, forward 15, and current audio label. At this stage the mini-player can be wired to a placeholder AudioController.

Add first-launch modal logic using local preference state. The modal should offer Start with About Tinnitus, Explore First, and Remind Me Later. Add visible Safety Information access on the welcome/first-launch path.

## Acceptance criteria

Bottom nav persists across screens. The mini-player persists above the bottom nav. First-launch modal appears once unless Remind Me Later is selected. Safety Information is reachable from the welcome flow and settings.

## Expected output

Root shell, navigation router, mini-player placeholder, first-launch behavior.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
