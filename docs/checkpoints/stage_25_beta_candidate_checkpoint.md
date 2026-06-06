# Stage 25 Beta Candidate Checkpoint

Generated from local repo inspection at `/Users/mark/projects/MPTinnitus`.

## Validation Results

- `python3 scripts/validate_mvp_audio_assets.py`: passed.
- `python3 scripts/validate_beta_readiness.py`: passed.
- `xcodebuild -project ios/MPTinnitus/MPTinnitus.xcodeproj -scheme MPTinnitus -destination 'generic/platform=iOS Simulator' build`: passed.

Known non-blocking command warnings:
- `IDERunDestination: Supported platforms for the buildables in the current scheme is empty.`
- `Metadata extraction skipped. No AppIntents.framework dependency found.`

## Audio Asset Status

- Original MVP audio validation remains green:
  - 10 original sound/noise assets.
  - 14 mindfulness assets.
  - 24 original MVP MP3 assets.
- Sound Therapy add-on registry exists at `ios/MPTinnitus/MPTinnitus/Resources/sound_therapy_addon_assets_v1.json`.
- Sound sample resource folder contains 25 MP3 files:
  - 10 original Sound Therapy assets, including 3 hidden one-minute static samples.
  - 15 Sound Therapy add-on samples.
- Mindfulness resource folder contains 14 MP3 files.
- Narration resource folder contains 243 MP3 files.
- No source ZIPs, `__MACOSX`, `.DS_Store`, AppleDouble files, README files, or source manifests were found inside `ios/MPTinnitus/MPTinnitus/Resources`.

## Sound Therapy Player Status

- Sound Therapy Player is reachable from the Sound tab.
- Current sample groups are validated:
  - Nature / Environmental.
  - Household / Environmental.
  - Urban / Environmental.
  - Static / Artificial.
  - Focused / Filtered.
- Original visible demo sounds remain present:
  - Rain.
  - Stream / Flowing Water.
  - Crickets.
  - Fan Noise.
  - Brown Noise.
  - Pink Noise.
  - White Noise.
- Add-on samples are registered and bundled:
  - Ocean Waves, Rolling Waves, Waterfall, Rain on Window, Wind in Trees, Woods and Campfire.
  - Shower.
  - Cityscape.
  - Grey Noise, Blue Noise, Low Rumble, High Hiss.
  - Focused Hiss — Low, Focused Hiss — Mid, Focused Hiss — High.
- One-minute Brown/Pink/White sample cards remain hidden from the visible player filter.
- The shared `SoundSampleController` still supports one active sample at a time, loop-capable samples, capped volume, favorite state, and the global foreground Sound Therapy control.

## Pitch Estimate Status

- Tinnitus sound estimate exists under customized Sound Therapy.
- Pitch range is 100 Hz to 14 kHz.
- Live `Tone volume` defaults to zero and does not auto-raise when Play Tone is tapped.
- Saved loudness estimate remains summary/profile data and is not restored into the live pitch-tone volume.
- Pure-tone playback uses foreground-only generated tone behavior with capped amplitude.
- Manual listening QA is still required for silence at zero volume, smooth ramping, and high-frequency behavior on actual speakers/headphones.

## Mindfulness Practice Status

- Mindfulness Practice screen is reachable from the Mindfulness tab.
- The 14 guided mindfulness recordings are validated as bundled single-play MP3 assets.
- `st_mindful.mp3` remains classified as `mindfulness.sound_therapy_mindful`, not a Sound Therapy sample.
- `full_body_scan1.mp3` and `full_body_scan2.mp3` remain absent and unexposed.
- Mindfulness transcripts and grouped practice UI are covered by beta readiness validation.

## Exercise And Save Status

- Module library contains 32 exercise references.
- Exercise definitions remain valid and loadable.
- Unsupported future exercise refs remain warnings only; `ModuleOverviewScreen` filters unsupported exercise cards from normal module flow.
- My Plan, Three Lines Journal, and local exercise entry persistence are covered by the existing beta readiness checks and recent manual QA checklist.
- No new persistence models or export behavior were added in this checkpoint.

## Visual Status

- Five MVP static visual PNGs are bundled.
- Specialized SwiftUI visual fallbacks remain available.
- Beta readiness validation intentionally warns that some static visuals are not beta-scope and that breathing videos are deferred.
- No paced breathing videos are required for this beta candidate.

## Settings And Reset Status

- Settings remains reachable from the navigation toolbar.
- Local-only privacy, safety/scope text, welcome reset, transcript preference, and local data reset controls are covered by beta readiness validation.
- Reset coverage includes My Plan, exercise entries, Three Lines Journal, sound preferences/favorites, and all local app data.
- Tinnitus sound estimate reset support remains present.

## Offline And Privacy Guardrails

- Prohibited API scan found no app source use of:
  - `URLSession`, remote URLs, `UNUserNotificationCenter`, notification authorization/scheduling, `AVQueuePlayer`, or `AVAudioSession`.
  - Firebase, Supabase, CloudKit, analytics/tracking SDKs, third-party SDK indicators, background tasks, or App Tracking Transparency.
- The scan term `Amplitude` matched local pure-tone variable names such as `currentAmplitude`; this is not analytics.
- No background audio mode was found.
- No networking, accounts, analytics, cloud sync, downloads, reminders, or remote transmission were added.

## Source Scan Notes

Observed non-blocking scan hits:
- `#if DEBUG` logging and debug-only support views remain in source. They are not user-facing in normal UI.
- `SourceIDDebugLabel` call sites remain, but `SourceIDDebugLabel.body` returns `EmptyView()`, so raw IDs are not rendered.
- Old seed manifests still contain strings such as `placeholder_hub`, `placeholder_annex`, and `Sound Therapy Annex`; these are seed/debug manifest resources, not the current Sound/Mindfulness tab UI.
- `SoundTherapyAnnexPlaceholderView` and `MindfulnessAnnexPlaceholderView` still exist as unused fallback/preview views.
- `PlaceholderDetailScreen` remains as a fallback if an unsupported exercise route is opened directly or from older saved data.
- `sourceZip` metadata in JSON registries intentionally records source archive names; no ZIP files are bundled in app resources.
- Clinical-scope scans found words such as treatment/cure only in cautionary context, for example “not treatment,” “not a treatment plan,” or “search constantly for cures.”

## Build And Project Readiness

- Effective target build settings show:
  - Bundle ID: `com.mptinnitus.MPTinnitus`.
  - Version: `1.0`.
  - Build: `1`.
  - Effective target deployment: iOS `17.0`.
  - Automatic signing with team `V7886MGG9U`.
- App icon asset catalog has a referenced `app_icon_1024.png` and passed asset catalog build.
- Launch screen is generated by Xcode build settings.
- No checked-in `Info.plist` privacy permission strings were found because the project uses generated Info.plist settings.
- App Store Connect metadata, screenshots, privacy nutrition labels, tester groups, export compliance, and TestFlight build upload are outside repo-verifiable scope.

## Must Fix Before Private Beta

- No P0 runtime blockers were found by validation/build/source inspection.

## Acceptable Beta Risks

- Manual audio QA is still required on a real device or simulator with audio output:
  - Play one sample from each Sound Therapy group.
  - Confirm switching samples stops the previous sample.
  - Confirm foreground navigation keeps Sound Therapy sample playback active.
  - Confirm backgrounding stops Sound Therapy sample playback.
  - Confirm pitch estimate zero-volume behavior is silent before raising Tone volume.
- Seed placeholder manifests and unused placeholder views remain in source. They do not appear to be normal user-facing routes, but they should be cleaned up post-beta if the repo needs stricter source hygiene.
- Unsupported exercise route fallback remains. Normal module flow should hide unsupported exercise refs, but old saved data or direct route construction can still show a generic fallback screen.

## Post-Beta Polish

- Remove or archive unused placeholder view files once no fallback route depends on them.
- Normalize old seed manifest titles/layouts or remove obsolete seed manifests if they are no longer part of the app’s active runtime.
- Add UI automation or lightweight screenshot checks for Sound Therapy Player grouping and Settings reset flows.
- Add paced breathing videos only in the later scoped video stage.
- Continue image/visual polish after private beta blockers stay green.

## Remaining Manual QA Items

Run the checklist at `docs/qa/beta_manual_qa_checklist.md`, with priority on:
- Fresh install and first-launch safety flow.
- Library opens all 9 modules.
- Module audio play buttons and mini-player next-section behavior.
- Sound Therapy Player original and add-on samples.
- Global Sound Therapy foreground control.
- Tinnitus sound estimate pitch/tone-volume behavior.
- Mindfulness Practice grouped recordings.
- Exercise save/review/delete flows.
- My Plan add/remove and old saved item display.
- Three Lines Journal save/delete.
- Settings reset confirmations and reset-all behavior.
- Background/foreground transitions for narration, Sound Therapy samples, and pitch tone.

## Remaining TestFlight / App Store Connect Tasks

- Confirm signing team and bundle ID are correct for the target App Store Connect app.
- Decide whether version `1.0` build `1` should be used for the first private beta.
- Create/upload archive from a clean checkout.
- Complete App Store Connect app metadata, screenshots, age rating, privacy nutrition labels, support/contact URLs if required, tester groups, and beta review notes.
- Confirm the medical/educational disclaimer language is represented in beta notes and app metadata.
- Confirm no privacy permission prompts appear during manual beta QA.

## Git / Reproducibility Notes

Current repo status should be reviewed before a beta tag or archive. At checkpoint time, the working tree still had uncommitted tinnitus sound estimate safety changes and unrelated local untracked files at repo root:
- `mptinnitus_mindfulness_exercise_scripts_v1.xlsx`
- `replacement_audio/`

Before producing a beta archive, stage and commit intended app/report changes and remove, ignore, or deliberately retain unrelated local files outside app resources.
