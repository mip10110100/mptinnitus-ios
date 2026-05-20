# Stage 10: Settings, Reminders, Safety, and Privacy

## Objective

Implement settings, local reminders, safety information, and local data controls.

## Input files

01_SOURCE_OF_TRUTH/08_local_data_schema.xlsx, 01_SOURCE_OF_TRUTH/02_mvp_screen_spec_pack.xlsx

## Prompt to Codex

You are building the MPTinnitus iOS MVP. Follow the locked app contracts. Do not add networking, accounts, cloud sync, analytics, remote monitoring, clinician dashboards, or features outside the MVP unless explicitly requested.

Build Settings with local data explanation, audio/transcript preference placeholders, local reminder settings, accessibility notes, scope/safety information, and delete/reset controls. Implement local scheduled reminders for Three Lines Journal if enabled by the user. Reminders are off by default.

Safety information should include crisis/self-harm boundary, direct hearing healthcare boundary, sound sensitivity painful sound caveat, sleep help boundary, and exercise/temperature caveats.

## Acceptance criteria

Settings are reachable. Reminders can be enabled/disabled locally. Delete/reset local data requires confirmation. Safety information is clear and accessible. No remote push service is used.

## Expected output

Settings, local reminders, safety/privacy pages.

## Review before moving on

- Does the app compile?
- Did this stage avoid adding disallowed services or MVP-expanding features?
- Are placeholders named clearly?
- Are source-of-truth IDs preserved where relevant?
