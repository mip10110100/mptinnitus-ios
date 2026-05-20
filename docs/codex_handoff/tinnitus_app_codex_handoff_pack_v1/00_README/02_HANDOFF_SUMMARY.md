# Codex Handoff Summary

## Current roadmap status

Completed:

1. Freeze v10 asset-locked source of truth
2. Create MVP Screen Spec Pack
3. Create MVP Audio Manifest / Recording Queue
4. Create Visual / Interaction Manifest
5. Create Local Data Schema
6. Decide build stack

This package completes:

7. Create the staged Codex Handoff Pack

Next after this package:

8. Build the prototype in stages
9. Replace placeholder assets with final audio, visuals, and sound samples
10. Run QA, safety/privacy review, accessibility review, and beta-prep

## Recommended first Codex action

Start with Stage 01 only. Do not ask Codex to build the whole app. The first output should be a compiling iOS 17+ SwiftUI shell with the folder structure, root app shell, bottom navigation, and placeholder screens.

## Recommended build approach

Each stage should produce a compiling app. Review and correct before moving to the next stage. This is especially important because the app is content-heavy and local-data-heavy.

## Highest-risk implementation areas

- Persistent audio mini-player and background playback behavior
- Sound Therapy thermometer controlling audio sample volume safely
- SwiftData payload structure for varied exercises
- Avoiding accidental remote services or analytics
- Keeping the app from turning into too many tiny pages

## Things intentionally not in MVP

- Direct Muse integration
- Variable soundscape / silence-window practice
- Full external resource directory
- Manual export package
- FAST/GIVE interactive builders
- Interactive Self-Compassion Ladder
- Full CBT-I/BBTI expansion
- Gamification/streaks/badges
