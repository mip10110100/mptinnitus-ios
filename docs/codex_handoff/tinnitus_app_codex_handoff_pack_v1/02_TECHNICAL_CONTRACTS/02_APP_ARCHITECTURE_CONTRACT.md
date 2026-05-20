# App Architecture Contract

## High-level architecture

The MVP should be structured around four layers:

1. App shell and navigation
2. Content/manifest layer
3. Audio layer
4. Local data layer

The UI should render as much as practical from structured manifests, while custom interactive exercises use dedicated SwiftUI components.

## App shell

The shell includes:

- persistent bottom navigation
- persistent audio mini-player
- safety information access from first launch/welcome and settings
- module/library navigation
- settings access

Bottom navigation items:

- Library / Table of Contents
- Sound Therapy Annex
- Mindfulness Annex
- My Plan

## Content layer

Content screens should be defined by manifests with:

- screen ID
- route
- module
- screen title
- screen role
- content sections/cards
- audio IDs
- transcript IDs or transcript text
- visual/component IDs
- CTAs
- local-save behavior
- safety/scope copy requirements
- next routes

## Audio layer

Audio should be referenced by audio ID and asset path. Every audio clip should have transcript text. Audio cards render Play and Transcript controls. The transcript is collapsed by default.

Audio categories:

- narration
- short explainer
- chapter overview
- guided practice
- prompt
- bridge explainer
- sound sample
- background sound/sample

## Local data layer

SwiftData handles user-owned local data. The app should not store sensitive medical/crisis narratives. It should store only the local preferences and exercise entries needed for app functionality.

## Screen model

Module content should not be implemented as dozens of tiny independent pages unless an exercise or complex interaction needs its own route. Use scrollable overview screens with expandable cards, and route to exercise/detail screens where needed.

## My Plan model

My Plan is a local saved-items hub. It is not completion tracking. Adding something to My Plan is user-selected and reversible.

## Three Lines Journal

Three Lines Journal is available immediately inside My Plan.

- ST = Sound Therapy
- E = Emotional Regulation
- M = Mindfulness

Entries can be brief. A checkmark or a few words are enough.
