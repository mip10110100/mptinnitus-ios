# Tinnitus App Build Stack Decision v1

## Recommendation

Use a **native iOS-first stack**:

- Swift + SwiftUI for the app UI.
- AVFoundation / AVFAudio / AVAudioSession for narration, guided practices, sound therapy playback, and future background audio behavior.
- SwiftData if we target iOS 17+; Core Data if we need iOS 16 support.
- Bundled JSON/Markdown-style content manifests so screens, transcripts, audio IDs, visual IDs, and route IDs are not hard-coded into every view.
- Bundled `.m4a` / AAC assets for MVP narration and sample sounds.
- Local notifications for optional reminders.
- No account, no server, no analytics, no clinician dashboard, no automatic data transmission in MVP.
- Xcode + GitHub + TestFlight for development and beta distribution.

## Why this is the best fit

Your constraints point away from no-code and away from a temporary prototype stack. You want iOS first, a production-quality foundation, no recurring builder cost, local/offline behavior, code ownership, and enough audio control to support narration plus background sound therapy. A native SwiftUI build gives the strongest iOS-first foundation while keeping the app simple and locally controlled.

The tradeoff is that Android will require a later implementation. To reduce that cost, the content, local-data schema, route IDs, audio IDs, and asset names should be platform-neutral from the beginning. The future Android version can reuse the content database, local data schema, transcripts, audio files, and visual assets even if the UI code is rewritten.

## Why not Flutter as the primary stack?

Flutter is the closest alternative because it supports a single codebase across platforms. If Android becomes urgent before iOS stabilizes, Flutter becomes more attractive. But for the current plan—iOS first, strong foundation, no ongoing platform costs, native polish, and audio behavior—the native SwiftUI path is the cleaner first choice.

## Why not FlutterFlow / no-code?

FlutterFlow or another visual builder would be faster at the beginning, but it conflicts with the stated goal of building a strong foundation rather than layering tools. It also adds recurring platform cost and potential lock-in. This app is content-heavy but not conceptually complex enough to justify that tradeoff.

## Architecture

The app should be built around reusable components:

- PersistentShell
- BottomNavigationBar
- AudioMiniPlayer
- AudioCard
- TranscriptDisclosure
- ExpandableContentCard
- ExercisePage
- MyPlanToggle
- SoundTherapyAnnex
- MindfulnessAnnex
- LocalDataStore
- AudioController

The content itself should come from structured files rather than being manually embedded in each Swift screen.

## Remaining build-stack decision

The one true remaining technical decision is the **minimum iOS version**.

Recommended default: iOS 17+ so we can use SwiftData.

If older-device support matters, use Core Data instead.
