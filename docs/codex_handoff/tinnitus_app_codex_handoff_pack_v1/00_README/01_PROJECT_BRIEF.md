# Project Brief

## Product intent

The app is an audio-first educational companion for tinnitus management based on the Multimodal Protocol and patient workbook. It is designed to help users understand tinnitus from multiple angles and practice simple self-management tools without presenting itself as medical treatment, therapy, or crisis care.

## Core user experience

The user can browse educational modules, listen to brief explanations, open transcripts, practice selected exercises, save responses locally, and add useful items to My Plan. The app should feel like a calm, structured, modern/minimal workbook with practical audio support.

## Main modules

1. About Tinnitus
2. Sound Therapy
3. Acceptance and Change
4. Mindfulness
5. Distress Tolerance
6. Cognitive Reframing
7. Confidence and Communication
8. Sleep
9. My Plan

## Persistent bottom navigation

The app shell should use a persistent four-item bottom navigation:

1. Library / Table of Contents
2. Sound Therapy Annex
3. Mindfulness Annex
4. My Plan

Above this bottom nav, the app should include a persistent audio mini-player with play/pause, rewind 15 seconds, forward 15 seconds, and current audio title. The mini-player should distinguish narration, guided practice, and background sound/sample playback when practical.

## Screen behavior

The MVP uses a hybrid content model:

- Module loops are scrollable overview screens with expandable cards.
- Exercises and deeper interactions open as their own detail screens.
- Audio cards show two buttons: Play and Transcript.
- Transcripts are collapsed by default.
- Exercises include Save, Skip, Repeat, View/Delete past entries where applicable.
- Exercise pages include an Add to My Plan checkbox.

## Privacy behavior

All user data stays local on the device. There is no automatic transmission, clinician dashboard, account requirement, cloud sync, or remote monitoring in the MVP.

## Build intent

Build a strong native iOS foundation first. Do not make a quick throwaway prototype that will need to be rebuilt. Use structured manifests so content, routes, assets, and local-data logic are not hard-coded into scattered Swift files.
