# Stage 05: Audio System and Transcript Binding

## Objective

Implement reliable local audio playback for embedded m4a assets and transcripts.

## Input files

01_SOURCE_OF_TRUTH/03_mvp_audio_manifest_recording_queue.xlsx, 01_SOURCE_OF_TRUTH/04_tts_recording_queue.csv, 01_SOURCE_OF_TRUTH/06_sound_sample_placeholders.csv

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Implement AudioController using AVFoundation. Support play, pause, rewind 15 seconds, forward 15 seconds, current title, playback context, and stop/replace behavior when a new audio card is played. Bind AudioCard play buttons to AudioController. Show transcripts from the audio manifest.

Use placeholder .m4a files for missing assets and ensure the asset path contract works. Add basic background audio session behavior for guided practices and sound samples as feasible.

## Acceptance criteria

Audio cards play bundled .m4a assets. Mini-player updates. Rewind/forward works. Transcripts match the manifest and remain collapsed until opened. Missing asset placeholders do not crash the app.

## Expected output

AudioController, AudioCard integration, transcript binding.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
