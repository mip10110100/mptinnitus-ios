# QA Checklist

## Build/runtime

- App builds on iOS 17+ simulator.
- App runs without network access.
- First-launch modal behaves correctly.
- Bottom navigation persists.
- Audio mini-player persists.

## Content/manifests

- All route IDs in route manifest resolve.
- All screen IDs used by buttons/routes exist.
- All audio IDs used by screens exist in audio manifest.
- All transcripts exist and are non-empty.
- Placeholder assets are named clearly.

## Audio

- Narration audio plays.
- Guided practice audio plays.
- Sound samples play and stop.
- Mini-player reflects active audio.
- Rewind/forward controls work.
- Missing audio does not crash the app.

## Local data

- Exercise entries save locally.
- Entries can be viewed and deleted.
- Add to My Plan works.
- My Plan checkbox state persists and can be removed.
- Three Lines Journal saves local entries.
- Reminder settings are local and off by default.
- Delete/reset local data requires confirmation and works by selected scope.

## Safety/privacy

- Safety information reachable from welcome/first-launch and settings.
- No account prompt exists.
- No analytics package is added.
- No network request is required for MVP operation.
- No crisis narrative fields are stored.

## UX

- Transcripts are collapsed by default.
- No completion tracking appears.
- No streaks/badges/gamification appear.
- Modules use hybrid layout: overview cards plus exercise detail screens.
- Visuals are readable on small screens.
