# Stage 12: QA, TestFlight Prep, and Build Review

## Objective

Prepare for private internal testing while preserving educational/privacy boundaries.

## Input files

05_QA_AND_REVIEW/01_QA_CHECKLIST.md

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Add lightweight QA checks: no network calls required for MVP, all audio IDs resolve to assets or placeholders, transcripts exist for all audio, exercise save/delete works, My Plan checkbox state persists, local reset works, safety pages are reachable, reminders are local, and no completion/gamification accidentally appears. Prepare TestFlight build steps but do not submit publicly.

## Acceptance criteria

A TestFlight-ready internal beta build exists. QA checklist passes or issues are documented. No MVP privacy/scope guardrails are broken.

## Expected output

Internal test-ready build and QA notes.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
