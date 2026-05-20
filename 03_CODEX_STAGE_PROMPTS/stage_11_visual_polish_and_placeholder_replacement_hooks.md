# Stage 11: Visual Polish and Placeholder Replacement Hooks

## Objective

Add visual assets, placeholders, and consistent modern/minimal warm-professional styling.

## Input files

01_SOURCE_OF_TRUTH/07_visual_interaction_manifest.xlsx, 02_TECHNICAL_CONTRACTS/asset_placeholders_v1.json

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Apply design tokens for colors, typography, spacing, cards, buttons, audio cards, and exercise screens. Use green-forward warm-professional styling aligned with the MPTinnitus practice palette once provided. Add placeholders for user-supplied assets: Tug-of-War image, Thoughts/Feelings/Behaviors cycle, Body/Mind/Life model, Sleep-Tinnitus loop. Build the components that should not be static images: thermometer slider and breathing pacer.

## Acceptance criteria

The app looks cohesive, readable, and not crowded. Placeholder assets are clearly named and easy to replace. Dynamic components work on multiple screen sizes.

## Expected output

Design system and placeholder asset implementation.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
