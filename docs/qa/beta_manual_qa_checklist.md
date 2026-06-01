# MPTinnitus Beta Manual QA Checklist

Use this checklist for a 30 to 60 minute simulator smoke pass before a beta build. Record every issue in the issue log at the bottom, even if it looks minor.

## 1. Setup

- [ ] Confirm the build installs on an iOS 17+ simulator.
- [ ] Launch the app from a fresh simulator install.
- [ ] Confirm the app opens without a crash.
- [ ] Confirm the app remains usable after force quit and relaunch.
- [ ] Confirm airplane mode does not affect core app usage.
- [ ] Confirm no sign-in, account, network, cloud, analytics, notification, or download prompt appears.
- [ ] Confirm no debug/internal IDs, manifest-loader text, source IDs, or route strings appear in normal app UI.

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
- [ ] Confirm no visible debug panels appear on Library, Sound, Mindfulness, My Plan, or Settings.

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
- [ ] Confirm FAQ groups are titled “FAQs,” not “FAQs / Common Questions.”
- [ ] In About Tinnitus, confirm the Body / Mind / Life image appears under “Why go beyond the sound?”
- [ ] In About Tinnitus, confirm the Body / Mind / Life image does not repeat inside the individual Body, Mind, or Life sections.
- [ ] In About Tinnitus, confirm the Body / Mind / Life image does not repeat inside the multimodal care section.
- [ ] In About Tinnitus, confirm Pause & Reflect opens as a fill-in-the-blanks reflection exercise, not a static text-only card.
- [ ] In Acceptance and Change, confirm content and Tug-of-War placement still match the previously reviewed state, aside from any global FAQ title normalization.
- [ ] In Distress Tolerance, confirm practice labels appear as STOP, Temperature/Ice, TIPP, and The Frozen Orange.
- [ ] In Distress Tolerance, confirm STOP and TIPP do not appear as “STOP card” or “TIPP card” titles.
- [ ] In Cognitive Reframing, confirm Heaven’s Reward Fallacy appears in the Distortion Library.
- [ ] In Cognitive Reframing, confirm Heaven’s Reward Fallacy is not grouped under Reality-Checking Thoughts.

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

- [ ] Open the Sound tab and confirm the page title is Sound Therapy Player.
- [ ] Confirm the guidance section is concise and does not repeat long warning blocks.
- [ ] Confirm the Sound Therapy Player shows only actual demo sound sample cards, not incomplete secondary resource cards.
- [ ] Confirm Sound Therapy sample groups are visible:
  - [ ] Nature / Environmental
  - [ ] Household / Environmental
  - [ ] Urban / Environmental
  - [ ] Static / Artificial
  - [ ] Focused / Filtered
- [ ] Confirm the expanded grouped Sound Therapy sample set is visible.
- [ ] Confirm the original 7 visible Sound Therapy demo cards are still present:
  - [ ] Rain
  - [ ] Stream / Flowing Water
  - [ ] Crickets
  - [ ] Fan Noise
  - [ ] Brown Noise
  - [ ] Pink Noise
  - [ ] White Noise
- [ ] Confirm the 15 add-on Sound Therapy sample cards are present:
  - [ ] Ocean Waves
  - [ ] Rolling Waves
  - [ ] Waterfall
  - [ ] Rain on Window
  - [ ] Wind in Trees
  - [ ] Woods and Campfire
  - [ ] Shower
  - [ ] Cityscape
  - [ ] Grey Noise
  - [ ] Blue Noise
  - [ ] Low Rumble
  - [ ] High Hiss
  - [ ] Focused Hiss — Low
  - [ ] Focused Hiss — Mid
  - [ ] Focused Hiss — High
- [ ] Confirm Brown Noise, 1-Minute Sample; Pink Noise, 1-Minute Sample; and White Noise, 1-Minute Sample are not visible in the player.
- [ ] Confirm Fan Noise is tagged Household / Environmental.
- [ ] Confirm Brown Noise, Pink Noise, and White Noise are tagged Static / Artificial.
- [ ] Confirm no ZIP/source/manifest/README artifacts appear as sound cards.
- [ ] Confirm sample cards do not repeat long instructions already covered in Guidance.
- [ ] Confirm sample volume shows a simple percentage such as 35%, 50%, or 65%.
- [ ] Confirm Saved Preferred Sounds appears without the “Favorites stay on this device” sublabel.
- [ ] Confirm no incomplete secondary resource cards such as hearing care/amplification appear unless finalized.
- [ ] Play each of the 7 visible Sound Therapy demo samples and confirm each starts without a crash.
- [ ] Play at least one sample from each visible Sound Therapy group.
- [ ] Play Rain and confirm it starts.
- [ ] Switch from Rain to White Noise and confirm only the new sample remains active.
- [ ] Switch between an original sample and an add-on sample and confirm the previous sample stops.
- [ ] Adjust the volume slider and confirm volume changes without jumping to an unsafe level.
- [ ] Favorite an add-on sample and confirm favorite state appears.
- [ ] Remove the favorite and confirm state clears.
- [ ] Leave the Sound tab while the app remains in the foreground and confirm the active sample continues.
- [ ] Confirm a compact Sound Therapy control appears outside Sound Therapy Player while the sample is active.
- [ ] Confirm the global Sound Therapy control shows the active sample title.
- [ ] Tap Stop in the global Sound Therapy control and confirm sample playback stops.
- [ ] Start another sample and confirm the global Sound Therapy control updates to the new title.
- [ ] Return to Sound Therapy Player and pause the active sample.
- [ ] Play Rain, then select Brown Noise, and confirm Rain stops while Brown Noise starts.
- [ ] Confirm samples switch rather than layer on top of each other.
- [ ] Send the app to the background or lock the simulator and confirm sound sample playback stops or is released safely.
- [ ] Return to the app and confirm the global Sound Therapy control disappears after foreground playback stops.
- [ ] Confirm the Customized sound therapy section appears below Sound Therapy Samples.
- [ ] Open Tinnitus sound estimate.
- [ ] Confirm a new estimate screen shows “No estimate saved yet” before saving.
- [ ] Confirm the pitch range goes up to 14,000 Hz.
- [ ] Confirm Tone volume starts at zero.
- [ ] Tap Play Tone while Tone volume is zero.
- [ ] Confirm no audible tone plays until Tone volume is raised.
- [ ] Raise Tone volume slowly and confirm the tone becomes audible.
- [ ] Move the pitch slider and confirm the frequency display updates in Hz/kHz.
- [ ] Use the down/up fine nudge buttons and confirm pitch changes by small steps.
- [ ] Play and pause the pitch tone.
- [ ] Confirm the tone starts softly and stops cleanly.
- [ ] Move the pitch slider while the tone is playing and confirm there are no clicks or abrupt zipper sounds.
- [ ] Confirm the high-frequency note mentions headphones and phone speaker limitations.
- [ ] Confirm the loudness slider starts at the bottom for a new estimate.
- [ ] Raise loudness gently and play at that loudness.
- [ ] Save estimate and confirm “Saved on this device. You can update it later.” appears.
- [ ] Leave and return to Tinnitus sound estimate; confirm the saved pitch, confidence, laterality, and loudness summary persists.
- [ ] Leave and return to Tinnitus sound estimate; confirm live Tone volume starts at zero again.
- [ ] Confirm a saved loudness estimate does not automatically make Play Tone audible.
- [ ] Start Rain, then start the pitch tone; confirm Rain stops.
- [ ] Start the pitch tone, return to Sound Therapy Player, then start Brown Noise; confirm the pitch tone stops and Brown Noise starts.
- [ ] Send the app to the background while the pitch tone is playing and confirm the tone stops or safely pauses.
- [ ] Confirm no treatment, reset, neuromodulation, or clinical-protocol language appears in Tinnitus sound estimate.
- [ ] From the Sound Therapy module, confirm Sound Therapy samples or links are reachable where expected.
- [ ] In the Sound Therapy module, confirm the Sound Therapy Thermometer visual appears only at the first useful sweet-spot instructional point.
- [ ] Confirm later volume-zone and volume-setting references link to the Sound Therapy Player instead of repeating the thermometer image.
- [ ] Confirm no blank visual containers or missing-image placeholders appear where repeated thermometer images were removed.
- [ ] Open the Sound Therapy Thermometer and confirm the slider works.
- [ ] Confirm the thermometer preview uses a local sound safely when available and does not crash.
- [ ] Confirm the former Enjoyable Music Exercise is now titled Sound Sensitivity Exercise.
- [ ] Confirm Sound Sensitivity Exercise opens normally.
- [ ] Confirm `st_mindful.mp3` is not exposed as a Sound Therapy sample.

## 7. Mindfulness

- [ ] Open the Mindfulness tab and confirm the Mindfulness Practice page appears.
- [ ] Confirm guided practice sections are collapsed by default:
  - [ ] Short Guided Practices
  - [ ] Medium Guided Practices
  - [ ] Long Guided Practices
  - [ ] Sleep-Oriented Practices
  - [ ] Breathing Pacer
  - [ ] Reflection Exercises
- [ ] Confirm “Audio Explanation” does not appear under guided practice titles.
- [ ] Confirm guided practice cards show titles without redundant short descriptions under the titles.
- [ ] Expand Short Guided Practices and confirm it includes:
  - [ ] One Breath Reset
  - [ ] Name It and Widen
  - [ ] 3-2-1 Senses Mini
  - [ ] Sound Therapy Mindful Start
- [ ] Expand Medium Guided Practices and confirm it includes:
  - [ ] Breathing Space
  - [ ] Body Anchor and Room Sounds
  - [ ] Sound Shifting
  - [ ] Open Hands Grounding
  - [ ] Mindful Listening with Tinnitus and External Sound
  - [ ] Acceptance in the Present Moment
  - [ ] Medium Length Body-Scan
- [ ] Expand Long Guided Practices and confirm it includes only:
  - [ ] Full Body Scan
- [ ] Expand Sleep-Oriented Practices and confirm it includes:
  - [ ] Settling Without Forcing Sleep
  - [ ] Evening Body and Sound Wind-Down
- [ ] Open Breathing Pacer and confirm the SwiftUI breathing pacer is visible and usable.
- [ ] Open each Breathing Pacer timing option:
  - [ ] 4-4 Even Breathing
  - [ ] 4-2-4 Balanced Breathing
  - [ ] 4-6 Extended Exhale
  - [ ] 4-2-6 Extended Exhale with Pause
- [ ] Confirm Reflection Exercises appears below Breathing Pacer.
- [ ] Confirm Reflection Exercises is collapsed by default.
- [ ] Expand Reflection Exercises and confirm the implemented reflection exercises are visible:
  - [ ] Deep Breath Check-In Reflection
  - [ ] 3-2-1 Senses
  - [ ] Mindful Listening
  - [ ] Sound Shifting
- [ ] Open each listed reflection exercise and confirm it opens a real exercise page.
- [ ] Confirm no unsupported or broken exercise cards appear in Reflection Exercises.
- [ ] Confirm no breathing video cards appear in the beta Mindfulness Practice page or Mindfulness module practice area.
- [ ] Confirm the 14 mindfulness assets are reachable through the grouped practice sections above.
- [ ] Play at least 3 mindfulness recordings from different sections and confirm playback starts, pauses, and switches cleanly.
- [ ] Confirm switching from one guided practice to another stops or replaces the prior one cleanly.
- [ ] Open transcript disclosures and confirm accurate script text for sampled mindfulness exercises:
  - [ ] One Breath Reset
  - [ ] 3-2-1 Senses Mini
  - [ ] Settling Without Forcing Sleep
  - [ ] Medium Length Body-Scan
  - [ ] Full Body Scan
- [ ] Confirm `full_body_scan1.mp3` and `full_body_scan2.mp3` are not visible or required.
- [ ] Confirm mindfulness practice cards in the Mindfulness module route correctly.
- [ ] Open Breathing Pacer and confirm it remains functional.
- [ ] Confirm no technical loop-contrast copy appears in the normal Mindfulness Practice UI.
- [ ] Confirm “If Practice Feels Too Intense” remains below Reflection Exercises as a separate first learning/support link.
- [ ] Confirm mindfulness guidance does not imply forced silence, cure, or treatment replacement.

## 8. Sleep

- [ ] Open the Sleep module from Library.
- [ ] Confirm sleep education content renders in grouped sections.
- [ ] Confirm sleep safety/scope language is available near the bottom when present.
- [ ] Confirm Long Sleep Practice is surfaced where expected.
- [ ] Confirm Settling for Sleep is surfaced where expected.
- [ ] Play a sleep-oriented recording and confirm playback starts and can be paused or switched cleanly.
- [ ] Confirm sleep copy does not claim to treat insomnia or replace sleep medicine evaluation.

## 9. Exercises

- [ ] Open practice/exercise cards from several modules.
- [ ] From About Tinnitus, open Pause & Reflect.
- [ ] Enter notes in the Body, Mind, Life, and Support fields.
- [ ] Save the Pause & Reflect entry.
- [ ] Review the saved Pause & Reflect entry using the existing saved exercise pattern.
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
- [ ] Save a tinnitus sound estimate, then clear it from Settings if that control is present.
- [ ] Save a tinnitus sound estimate, use Reset all local app data on disposable simulator data, and confirm the estimate is cleared.
- [ ] Test one narrow reset action on disposable simulator data.
- [ ] Confirm Reset all local data uses a clear confirmation dialog.
- [ ] Confirm no notification permission prompt appears.
- [ ] Confirm Settings empty/count states use patient-facing copy, not technical debug copy.

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
- [ ] Confirm the Body / Mind / Life visual does not repeat on nearby About Tinnitus cards.
- [ ] Confirm no blank visual container or missing-image placeholder appears where duplicate Body / Mind / Life visuals were removed.
- [ ] Confirm the Sound Therapy Thermometer visual/diagram appears without breaking thermometer slider or preview behavior.
- [ ] Confirm repeated Sound Therapy Thermometer images do not appear later in the Sound Therapy education flow.
- [ ] Confirm the Tug-of-War visual appears in Acceptance and Change.
- [ ] Confirm the Thoughts / Feelings / Behaviors cycle appears in Cognitive Reframing.
- [ ] Confirm the Self-Compassion Response Card appears in “The three parts of self-compassion.”
- [ ] Confirm the Self-Compassion Response Card does not repeat in later self-compassion component, validation, practice, connection, important terms, main points, or FAQ dropdowns.
- [ ] Confirm later self-compassion sections such as validation, practice, “How self-compassion connects to the other tools,” “From self-blame to a supportive inner voice,” important terms, and FAQs still show their text normally.
- [ ] Confirm no blank image container or missing-image placeholder appears where duplicate Self-Compassion Response Card placements were removed.
- [ ] Confirm no STOP, TIPP, DEAR MAN, sleep-loop, sound-sensitivity, or breathing-pacer static placeholder appears as a broken MVP card.
- [ ] Confirm missing final images fall back to clean built-in diagrams or text without crashing.
- [ ] Confirm the five MVP static visuals are readable on the tested small screen size.
- [ ] Switch between light and dark mode if practical and confirm static visuals remain readable.
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
- [ ] Confirm major audio buttons and sliders have sensible VoiceOver labels if VoiceOver testing is practical.

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
