# Stage 23M Placeholder Audit and Pre-Sound-Therapy Expansion Checkpoint

Date: 2026-05-31

Repo: `/Users/mark/projects/MPTinnitus`

## Summary

The exact six placeholders reported by the Manifest loader were reproduced by source inspection. They are the six `visualPlaceholders` entries in `ios/MPTinnitus/MPTinnitus/Resources/asset_placeholders_v1.json`. `ManifestLoader` loads them into `ManifestSnapshot.visualPlaceholders`; `ManifestDebugLogger` prints `visualPlaceholders=6`; and the DEBUG-only `ManifestDebugStatusView` shows this as `Placeholders 6`.

These six records are mostly legacy/seed placeholder records. The active module renderer now uses newer module visual IDs such as `VIS-001`, `VIS-003`, `VIS-007`, `VIS-009`, `VIS-017`, and `VIS-023`, with specialized SwiftUI routes or bundled MVP static images. The six placeholder IDs themselves do not appear in `module_library_v1.json`.

Validation and build are green:

- `python3 scripts/validate_mvp_audio_assets.py`: PASS
- `python3 scripts/validate_beta_readiness.py`: PASS with expected warnings for deferred visuals, deferred breathing videos, and hidden unsupported exercise references
- `xcodebuild -project ios/MPTinnitus/MPTinnitus.xcodeproj -scheme MPTinnitus -destination 'generic/platform=iOS Simulator' build`: PASS

Known non-blocking build warnings:

- `IDERunDestination: Supported platforms for the buildables in the current scheme is empty.`
- AppIntents metadata extraction skipped because no `AppIntents.framework` dependency exists.

## Placeholder Audit

| # | ID | Type | Source file | Module / section | User-facing title | Currently visible to users? | Current fallback behavior | Intentional for beta? | Recommended action | Notes |
|---:|---|---|---|---|---|---|---|---|---|---|
| 1 | `VIS-BML-001` | visual | `ios/MPTinnitus/MPTinnitus/Resources/asset_placeholders_v1.json` | Superseded by active `about_tinnitus` visual `VIS-001` on `AT-002` / `AT-002-BEYOND-section` | Body / Mind / Life Model | Placeholder ID itself is not visible; active `VIS-001` is visible | `StaticConceptVisualView(.bodyMindLife)` uses bundled `visuals/body_mind_life_model.png` when available, otherwise a built-in diagram | Yes, active replacement is beta-ready | Keep as-is for runtime; later align/remove legacy placeholder record from debug manifest | Exact placeholder ID has 0 occurrences in `module_library_v1.json`. |
| 2 | `VIS-ST-THERMOMETER` | visual | `ios/MPTinnitus/MPTinnitus/Resources/asset_placeholders_v1.json` and `visual_manifest_seed_v1.json` | Superseded by active `sound_therapy` visual `VIS-003` on `ST-V5-009-section` / `ST-004` | Sound Therapy Thermometer | Placeholder ID itself is not visible; active `VIS-003` is visible | `SoundTherapyThermometerView` provides interactive zones and uses bundled white-noise MP3 if found | Yes | Keep as-is for runtime; later align seed manifest naming with active visual ID | Thermometer lookup includes `white_noise_1min_loop_no_fades_128kbps.mp3` and fade sample fallback. |
| 3 | `VIS-AC-TUG` | visual | `ios/MPTinnitus/MPTinnitus/Resources/asset_placeholders_v1.json` | Superseded by active `acceptance_and_change` visuals `VIS-007` and `VIS-032` | Tug-of-War | Placeholder ID itself is not visible; active Tug-of-War is visible | `TugOfWarVisualView` uses bundled `visuals/tug_of_war.png` when available, otherwise a built-in panel | Yes | Keep as-is; do not change Acceptance and Change in this checkpoint | Acceptance and Change was reviewed by owner. Avoid nonessential edits here. |
| 4 | `VIS-MF-BREATHING` | visual | `ios/MPTinnitus/MPTinnitus/Resources/asset_placeholders_v1.json` and `visual_manifest_seed_v1.json` | Superseded by active `mindfulness` visuals `VIS-009` and `VIS-031` | Breathing Pacer | Placeholder ID itself is not visible; active breathing pacer is visible | `BreathingPacerVisualView` provides SwiftUI pacer patterns; breathing videos remain deferred | Yes | Keep as-is for beta; video assets remain post-beta/deferred | No breathing video routes should be exposed in beta. |
| 5 | `VIS-CR-TFB` | visual | `ios/MPTinnitus/MPTinnitus/Resources/asset_placeholders_v1.json` | Superseded by active `cognitive_reframing` visuals `VIS-017` and `VIS-033` | Thoughts / Feelings / Behaviors Cycle | Placeholder ID itself is not visible; active `VIS-017`/`VIS-033` are visible | `StaticConceptVisualView(.thoughtsFeelingsBehaviors)` uses bundled `visuals/thoughts_feelings_behaviors_cycle.png` when available, otherwise a built-in diagram | Yes, active replacement is beta-ready | Keep as-is for runtime; later align/remove legacy placeholder record from debug manifest | Exact placeholder ID has 0 occurrences in `module_library_v1.json`. |
| 6 | `VIS-SL-LOOP` | visual | `ios/MPTinnitus/MPTinnitus/Resources/asset_placeholders_v1.json` | Superseded by active `sleep` visuals `VIS-023` and `VIS-034` | Sleep-Tinnitus Loop | Placeholder ID itself is not visible; active Sleep-Tinnitus loop is visible | `StaticConceptVisualView(.sleepTinnitusLoop)` uses a built-in book-style diagram; no sleep-loop PNG is currently part of the five MVP static visuals | Yes if built-in diagram is acceptable for beta | Defer final static image post-beta, or replace before beta only if simulator QA finds it looks broken | This is the one placeholder most likely to be perceived as unfinished if the built-in diagram is visually weak. |

## Beta-Critical Asset and Runtime Status

### Audio

- MVP audio registry: 24 assets total in `ios/MPTinnitus/MPTinnitus/Resources/audio_assets_mvp_2026_05_29.json`.
- Sound/noise assets: 10.
- Mindfulness assets: 14.
- Bundled sound samples are under `ios/MPTinnitus/MPTinnitus/Resources/audio/sound_samples/`.
- Bundled mindfulness recordings are under `ios/MPTinnitus/MPTinnitus/Resources/audio/mindfulness/`.
- Rain and Crickets replacement status: both now have updated 60.048-second MP3 records, file size `964864`, and updated SHA-256 values in the MVP audio registry.
- Missing active audio references: 0 found by source inspection; beta readiness validation also passes active audio reference checks.
- Known audio QA risks:
  - Xcode flattens copied resources into the app bundle, so playback relies on the existing flat filename fallback after reading manifest paths.
  - Foreground-only audio is expected; there is no background audio configuration.
  - Manual simulator QA should still spot-check switching between narration, mindfulness recordings, and sound samples to confirm one-active-source behavior feels right.

### Sound Therapy Player

- Current visible Sound Therapy sample set is seven cards:
  - Rain
  - Stream / Flowing Water
  - Crickets
  - Fan Noise
  - Brown Noise
  - Pink Noise
  - White Noise
- One-minute fade samples are still bundled and registered, but hidden from the current visible player list:
  - Brown Noise, 1-Minute Sample
  - Pink Noise, 1-Minute Sample
  - White Noise, 1-Minute Sample
- `SoundSampleController` plays local bundled files only, caps effective volume with `safeVolumeCap = 0.65`, loops loop-capable samples, and does not configure background audio.
- Upcoming expansion risks:
  - Decide whether one-minute fade samples should become visible as preview-only cards or remain registry-only.
  - Preserve the current classification: mindfulness recordings, including `st_mindful.mp3`, must not be mixed into Sound Therapy samples.
  - Keep the seven demo sounds stable until the expansion rules are explicit.

### Mindfulness Practice

- Current collapsed sections in `MindfulnessAnnexView`:
  - Short Guided Practices
  - Medium Guided Practices
  - Long Guided Practices
  - Sleep-Oriented Practices
  - Breathing Pacer
  - Reflection Exercises
- Mindfulness transcript mapping status: validation passes exactly 14 mindfulness transcript mappings.
- Reflection exercises restored:
  - `I-011`
  - `I-012`
  - `I-013`
  - `I-014`
- Breathing pacer status: active SwiftUI component is available through `VIS-009` / `VIS-031`; no video assets are exposed.
- Breathing videos: listed as `deferred_post_beta` in `docs/visual_assets/visual_asset_manifest_v1.json`; related MP4 files and `video_assets_v1.json` are currently deleted in the working tree and validation treats breathing videos as deferred.

### Visuals

Five MVP static visuals are registered in `docs/visual_assets/visual_asset_manifest_v1.json`:

| Static visual ID | File | Expected active placement |
|---|---|---|
| `visual.body_mind_life_model` | `ios/MPTinnitus/MPTinnitus/Resources/visuals/body_mind_life_model.png` | About Tinnitus, active `VIS-001` |
| `visual.sound_therapy_thermometer` | `ios/MPTinnitus/MPTinnitus/Resources/visuals/sound_therapy_thermometer.png` | Sound Therapy Thermometer support asset / active `VIS-003` |
| `visual.tug_of_war` | `ios/MPTinnitus/MPTinnitus/Resources/visuals/tug_of_war.png` | Acceptance and Change, active `VIS-007` / `VIS-032` |
| `visual.thoughts_feelings_behaviors_cycle` | `ios/MPTinnitus/MPTinnitus/Resources/visuals/thoughts_feelings_behaviors_cycle.png` | Cognitive Reframing, active `VIS-017` / `VIS-033` |
| `visual.self_compassion_response_card` | `ios/MPTinnitus/MPTinnitus/Resources/visuals/self_compassion_response_card.png` | Confidence and Communication, active `VIS-021` |

Visual cleanup passes completed before this checkpoint:

- Body / Mind / Life duplicate placement cleanup is represented in QA checklist expectations.
- Sound Therapy Thermometer visual cleanup is represented in beta validation.
- Breathing videos are deferred and not required for beta runtime.

Visual placement still needing simulator verification:

- Sleep-Tinnitus loop uses a built-in diagram fallback rather than a bundled static PNG.
- Static/fallback visuals should be checked on small screens and dark mode.
- STOP/TIPP visual detail screens still have internal titles `STOP Quick Card` and `TIPP Quick Card` in Swift; this is not part of the six Manifest placeholders but should be reviewed after Stage 23K if the project owner wants all "Card" wording removed.

### Exercises

- Implemented exercise definitions: 21 in `ios/MPTinnitus/MPTinnitus/Resources/exercise_definitions_v1.json`.
- Module exercise references: 32 total.
- Unsupported exercise refs remain expected warnings in `scripts/validate_beta_readiness.py` and are expected to be hidden by `ModuleOverviewScreen`.
- Recent label changes verified by validation include:
  - `I-016` -> STOP
  - `I-017` -> Temperature/Ice
  - `I-018` -> TIPP
  - `I-019` -> The Frozen Orange

### Privacy / Offline Guardrails

`scripts/validate_beta_readiness.py` passes the prohibited API checks for the current beta scope:

- No Firebase, Supabase, CloudKit, analytics SDK, URLSession, AVQueuePlayer, or prohibited remote/network API usage found in app source.
- No notification scheduling or authorization APIs found.
- No `AVAudioSession` background-audio configuration found.
- The current audio behavior remains local, bundled, and foreground-only.

### Repo Status

The working tree is still dirty from several Stage 23 passes. High-level categories:

- Stage 23K copy/QA changes are present in module copy, route/exercise labels, validation, and QA checklist.
- Stage 23 audio/sample replacement files are present, including modified `rain.mp3` and `crickets.mp3`.
- Breathing video files and `video_assets_v1.json` are deleted in the working tree because breathing videos are deferred.
- Untracked local/source artifacts remain:
  - `docs/audio_import/stage_23c_sound_sample_replacements.md`
  - `ios/MPTinnitus/MPTinnitus/Resources/mindfulness_transcripts_v1.json`
  - `mptinnitus_mindfulness_exercise_scripts_v1.xlsx`
  - `replacement_audio/`
- This checkpoint report is intentionally added under `docs/checkpoints/`.

Do not stage source archives or local replacement folders until the owner explicitly decides they belong in the repo. Stage 23 changes look buildable and validation-clean, but should receive a consolidation review before commit because the worktree spans multiple manual QA passes.

## Self-Compassion Visual Deduplication Check

Stage 23L update: the requested self-compassion visual deduplication pass has been applied.

Current state:

- `VIS-021` appears as the active Confidence and Communication module visual.
- `VIS-021` remains attached only to `The three parts of self-compassion`.
- The repeated card-level visual references were removed from later self-compassion explanations, validation, practice, important terms, FAQs, main points, and related communication sections.

Expected owner direction:

- Keep the self-compassion visual in `The three parts of self-compassion`.
- Remove duplicate copies from component explanations, validation, practice, connection, terms, FAQs, and related sections.

Recommendation:

- During manual QA, confirm `The three parts of self-compassion` still shows the visual and later self-compassion sections render text normally with no blank image containers.

## Recommended Next Step Before Sound Therapy Expansion

Before expanding Sound Therapy Player, do one focused cleanup pass:

1. Spot-check whether the active Sleep-Tinnitus built-in diagram looks beta-ready or should stay explicitly deferred.
2. Decide whether the legacy six `visualPlaceholders` should remain in `asset_placeholders_v1.json` for DEBUG manifest compatibility or be reconciled with the newer visual asset manifest after beta.

Then proceed to a separate Sound Therapy Player expansion pass with explicit rules for whether hidden one-minute static previews should become visible.
