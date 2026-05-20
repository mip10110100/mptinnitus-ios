# Stage 02: Content and Manifest Loader

## Objective

Create bundle-based content manifest loading so future screens render from structured data instead of hard-coded scattered content.

## Input files

02_TECHNICAL_CONTRACTS/03_MANIFEST_CONTRACTS.md, 02_TECHNICAL_CONTRACTS/route_manifest_seed_v1.json

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Add Codable models for ScreenManifest, ContentSection, AudioManifestItem, VisualManifestItem, RouteItem, and SafetyScopeItem. Add a ManifestLoader that loads JSON files from the app bundle. Include seed JSON files from this handoff package or create placeholders matching the contracts. Add validation logs in debug builds for missing audio IDs, route IDs, and section IDs.

Keep the manifest layer platform-neutral where possible.

## Acceptance criteria

The app loads route and screen seed manifests from the bundle. Debug output reports loaded counts. Missing manifest files fail gracefully with a visible developer placeholder, not a crash.

## Expected output

Codable manifest models and bundle loader.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
