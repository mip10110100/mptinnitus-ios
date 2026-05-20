# Stage 08: Sound Therapy Annex and Sound Samples

## Objective

Implement the dedicated practical sound therapy area.

## Input files

01_SOURCE_OF_TRUTH/06_sound_sample_placeholders.csv, 02_TECHNICAL_CONTRACTS/asset_placeholders_v1.json

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Build the Sound Therapy Annex with starter sound sample cards, favorites, a simple timer if feasible, background playback support where feasible, and links back to the sound therapy education screens. Add the Sound Therapy Thermometer slider component controlling the white/broadband sound sample volume. The slider should have too quiet, sweet spot, and too loud/overmasking zones, safe volume cap, and clear explanatory labels.

Use placeholder .m4a samples until final samples are supplied.

## Acceptance criteria

Users can open the Sound Therapy Annex, play/stop samples, favorite sounds, and use the thermometer slider without unsafe volume behavior. Sound samples use placeholder assets and clear labels.

## Expected output

Sound Therapy Annex, sample cards, thermometer slider.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
