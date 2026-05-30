# MPTinnitus Beta Manual QA Checklist

Use this checklist for a 30 to 60 minute simulator smoke pass before a beta build. Record every issue in the issue log at the bottom, even if it looks minor.

## 1. Setup

- [ ] Confirm the build installs on an iOS 17+ simulator.
- [ ] Launch the app from a fresh simulator install.
- [ ] Confirm the app opens without a crash.
- [ ] Confirm the app remains usable after force quit and relaunch.
- [ ] Confirm airplane mode does not affect core app usage.
- [ ] Confirm no sign-in, account, network, cloud, analytics, notification, or download prompt appears.

## 2. First Launch And Safety/Scope

- [ ] On first launch, confirm the welcome flow appears when expected.
- [ ] Confirm safety/scope language is readable and not hidden behind the tab bar or mini-player.
- [ ] Confirm crisis, urgent medical, hearing-health, sleep, and sound-sensitivity guidance is visible where expected.
- [ ] Confirm the user can continue from welcome/safety into the app.
- [ ] Open Settings and confirm Safety Information remains reachable from Settings.
- [ ] Use Settings to reset/show the welcome prompt again, if present, then confirm the welcome prompt returns.

## 3. Navigation

- [ ] Confirm the bottom navigation tabs are visible and tappable.
- [ ] Open Library.
- [ ] Open Sound.
- [ ] Open Mindfulness.
- [ ] Open My Plan.
- [ ] Confirm switching tabs does not crash or lose normal navigation state unexpectedly.
- [ ] Confirm the audio mini-player, when visible, does not block tab selection.

## 4. Module Content

- [ ] From Library, open all 9 modules:
  - [ ] About Tinnitus
  - [ ] Sound Therapy
  - [ ] Acceptance and Change
  - [ ] Mindfulness
  - [ ] Distress Tolerance
  - [ ] Cognitive Reframing
  - [ ] Confidence and Communication
  - [ ] Sleep
  - [ ] My Plan
- [ ] Confirm each module has a patient-facing header card.
- [ ] Confirm each module uses grouped education sections.
- [ ] Confirm the first/core group is expanded by default.
- [ ] Confirm later groups, terms, FAQs, main points, and safety/scope groups start collapsed where expected.
- [ ] Expand and collapse several groups and confirm content opens in place without flying in from the top of the screen.
- [ ] Confirm there is no top-level Audio section.
- [ ] Confirm there is no top-level Visual Tools section.
- [ ] Confirm audio buttons and visual links are integrated inside learning content.
- [ ] Confirm Add to My Plan appears only on exercises or practice tools.
- [ ] Confirm internal IDs, source IDs, editor notes, removal notes, and planning language are not visible.
- [ ] Scroll to the bottom of each module and confirm the last content is not blocked by the mini-player or tab bar.

## 5. Narration Audio

- [ ] In at least 3 different modules, tap an education-card play button.
- [ ] Confirm the mini-player appears or updates with the correct section title.
- [ ] Confirm imported MP3-backed narration plays.
- [ ] Confirm missing narration, if encountered, shows a safe missing-audio state and does not crash.
- [ ] Confirm pause/resume works.
- [ ] Confirm rewind and forward controls work.
- [ ] Confirm the next-section control plays the next visible expanded section.
- [ ] Collapse a group, then use next-section and confirm collapsed content is skipped.
- [ ] Confirm autoplay next section is OFF by default in Settings.
- [ ] With autoplay OFF, confirm one section ending does not automatically start the next section.
- [ ] Toggle autoplay ON, if present, and confirm the next visible section can start automatically after the current section ends.
- [ ] Return autoplay to OFF before ending QA.
- [ ] Start narration, then start a Sound Therapy sample, then start a thermometer preview; confirm behavior is acceptable and log any overlapping playback or stale mini-player state.

## 6. Sound Therapy

- [ ] Open the Sound tab and confirm the Sound Therapy Annex appears.
- [ ] Confirm Sound Therapy sample groups are visible:
  - [ ] Nature and environmental sounds
  - [ ] Static noise
  - [ ] One-minute static noise samples, if exposed separately
- [ ] Confirm the 10 sound/noise assets are present where expected:
  - [ ] Rain
  - [ ] Stream / Flowing Water
  - [ ] Crickets
  - [ ] Fan Noise
  - [ ] Brown Noise
  - [ ] Pink Noise
  - [ ] White Noise
  - [ ] Brown Noise, 1-Minute Sample
  - [ ] Pink Noise, 1-Minute Sample
  - [ ] White Noise, 1-Minute Sample
- [ ] Play Rain and confirm it starts.
- [ ] Switch from Rain to White Noise and confirm only the new sample remains active.
- [ ] Adjust the volume slider and confirm volume changes without jumping to an unsafe level.
- [ ] Favorite a sample and confirm favorite state appears.
- [ ] Remove the favorite and confirm state clears.
- [ ] Leave the Sound tab and confirm sample playback stops or behaves according to the foreground-only design.
- [ ] From the Sound Therapy module, confirm Sound Therapy samples or links are reachable where expected.
- [ ] Open the Sound Therapy Thermometer and confirm the slider works.
- [ ] Confirm the thermometer preview uses a local sound safely when available and does not crash.
- [ ] Confirm `st_mindful.mp3` is not exposed as a Sound Therapy sample.

## 7. Mindfulness

- [ ] Open the Mindfulness tab and confirm the Mindfulness Annex appears.
- [ ] Confirm guided practice cards are visible and grouped appropriately.
- [ ] Confirm Breathing Practice Videos appears in the Mindfulness Annex.
- [ ] Confirm Breathing Practice Videos appears in the Mindfulness module practice area.
- [ ] Confirm all four breathing video cards appear:
  - [ ] 4-2-4 Balanced Breathing
  - [ ] 4-4 Even Breathing
  - [ ] 4-6 Extended Exhale
  - [ ] 4-2-6 Extended Exhale with Pause
- [ ] Play each breathing video.
- [ ] Confirm each breathing video loops until exit.
- [ ] Confirm exiting the video screen stops playback.
- [ ] Confirm breathing videos are muted by default.
- [ ] Confirm no network, permission, or download prompt appears for breathing videos.
- [ ] Turn on Reduce Motion if practical and confirm the SwiftUI breathing pacer remains an acceptable fallback.
- [ ] Confirm the 14 mindfulness assets are reachable where expected:
  - [ ] Long Body Scan
  - [ ] Long Sleep Practice
  - [ ] Acceptance and Present Moment
  - [ ] Body Scan
  - [ ] Mindful Listening
  - [ ] Sound Therapy Mindfulness
  - [ ] 3-2-1 Grounding
  - [ ] Name It
  - [ ] One Breath
  - [ ] Settling for Sleep
  - [ ] Open Hands
  - [ ] Sound Shifting
  - [ ] Body Anchor
  - [ ] Breathing Space
- [ ] Play at least 3 mindfulness recordings and confirm they are single-play guided audio, not looped.
- [ ] Confirm switching from one guided practice to another stops or replaces the prior one cleanly.
- [ ] Confirm `full_body_scan1.mp3` and `full_body_scan2.mp3` are not visible or required.
- [ ] Confirm mindfulness practice cards in the Mindfulness module route correctly.
- [ ] Open Breathing Pacer and confirm it remains functional.
- [ ] Confirm mindfulness guidance does not imply forced silence, cure, or treatment replacement.

## 8. Sleep

- [ ] Open the Sleep module from Library.
- [ ] Confirm sleep education content renders in grouped sections.
- [ ] Confirm sleep safety/scope language is available near the bottom when present.
- [ ] Confirm Long Sleep Practice is surfaced where expected.
- [ ] Confirm Settling for Sleep is surfaced where expected.
- [ ] Play a sleep-oriented recording and confirm it behaves as single-play guided audio.
- [ ] Confirm sleep copy does not claim to treat insomnia or replace sleep medicine evaluation.

## 9. Exercises

- [ ] Open practice/exercise cards from several modules.
- [ ] Confirm implemented exercise screens open without crash.
- [ ] Complete and save at least one exercise entry.
- [ ] Review past entries if the exercise supports review.
- [ ] Delete or remove an entry if the screen supports that behavior.
- [ ] Confirm unsupported or future exercises are not shown as unfinished placeholder cards in normal module flow.
- [ ] Confirm Add to My Plan remains available for exercise/practice tools.

## 10. My Plan

- [ ] Add an exercise/practice tool to My Plan from a module.
- [ ] Open My Plan and confirm the item appears.
- [ ] Remove the item and confirm it disappears.
- [ ] Confirm older saved items, if present, display safely.
- [ ] Confirm My Plan does not transmit data or request an account.

## 11. Three Lines Journal

- [ ] Open Three Lines Journal from My Plan or the expected route.
- [ ] Create a journal entry.
- [ ] Confirm the entry saves locally.
- [ ] Relaunch the app and confirm the entry remains.
- [ ] Delete or archive the entry if that control exists.
- [ ] Confirm no account, sync, sharing, or export prompt appears.

## 12. Settings/Reset

- [ ] Open Settings.
- [ ] Confirm local-only privacy copy is visible.
- [ ] Confirm safety/scope information is visible or linked.
- [ ] Confirm transcript/audio preferences appear if implemented.
- [ ] Confirm autoplay next education section setting exists and defaults OFF.
- [ ] Confirm destructive local reset controls use confirmation dialogs.
- [ ] Test one narrow reset action on disposable simulator data.
- [ ] Confirm Reset all local data uses a clear confirmation dialog.
- [ ] Confirm no notification permission prompt appears.

## 13. Visuals/Layout

- [ ] Open specialized visuals:
  - [ ] Sound Therapy Thermometer
  - [ ] Breathing Pacer
  - [ ] Tug-of-War
  - [ ] STOP
  - [ ] TIPP
  - [ ] Sound Sensitivity step-by-step card
  - [ ] Body / Mind / Life, if linked
  - [ ] Thoughts / Feelings / Behaviors, if linked
  - [ ] Sleep-Tinnitus loop, if linked
- [ ] Confirm the Body / Mind / Life visual appears where expected.
- [ ] Confirm the Sound Therapy Thermometer visual/diagram appears without breaking thermometer slider or preview behavior.
- [ ] Confirm the Tug-of-War visual appears in Acceptance and Change.
- [ ] Confirm the Thoughts / Feelings / Behaviors cycle appears in Cognitive Reframing.
- [ ] Confirm the Self-Compassion visual appears in the self-compassion/validation area.
- [ ] Confirm no STOP, TIPP, DEAR MAN, sleep-loop, sound-sensitivity, or breathing-pacer static placeholder appears as a broken MVP card.
- [ ] Confirm missing final images fall back to clean built-in diagrams or text without crashing.
- [ ] Confirm no card text is clipped on the tested simulator size.
- [ ] Confirm final content on scroll screens remains readable above the mini-player and tab bar.
- [ ] Confirm app icon appears on the simulator home screen after install.

## 14. Final Smoke Test

- [ ] Force quit and relaunch the app.
- [ ] Navigate Library -> Sound -> Mindfulness -> My Plan -> Settings.
- [ ] Play one narration section, one Sound Therapy sample, and one mindfulness recording in separate checks.
- [ ] Confirm the app remains responsive after repeated audio start/stop actions.
- [ ] Confirm no crash occurs after several tab switches.
- [ ] Confirm no network, account, notification, analytics, or download prompt appears.

## Issue Log

| ID | Area | Device/simulator | Steps | Expected | Actual | Severity | Screenshot/video | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QA-001 |  |  |  |  |  |  |  | Open |  |
| QA-002 |  |  |  |  |  |  |  | Open |  |
| QA-003 |  |  |  |  |  |  |  | Open |  |

## Severity Guide

| Severity | Meaning |
| --- | --- |
| P0 | Crash, data loss, app cannot complete a core beta flow, prohibited privacy/network behavior, or unsafe clinical/safety wording. |
| P1 | Core feature broken, missing bundled asset, misleading UI, blocked audio/navigation flow, or visible unfinished/editorial content. |
| P2 | Noticeable polish issue, layout problem, unclear label, or awkward but usable flow. |
| P3 | Minor copy, spacing, or cosmetic issue that does not affect beta usability. |
