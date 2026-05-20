# Manifest Contracts

These are the suggested manifest types for the iOS build. The exact Swift implementation can evolve, but the app should keep these concepts separate.

## screen_manifest.json

Each screen should have:

```json
{
  "screenId": "ST-003",
  "route": "/sound/thermometer",
  "moduleId": "sound_therapy",
  "title": "Finding the Sweet Spot",
  "role": "interactive_exercise",
  "layout": "exercise_detail",
  "sections": ["section_id_1"],
  "audioIds": ["AUD-104-G"],
  "visualIds": ["VIS-ST-THERMOMETER"],
  "interactionIds": ["INT-ST-THERMOMETER"],
  "primaryCtas": ["Save", "Add to My Plan", "Continue"],
  "localDataKeys": ["sound_therapy_level_entry"],
  "safetyScopeId": "sound_safety",
  "nextRoutes": ["/sound/preferences"]
}
```

## content_sections.json

Each section/card should have:

```json
{
  "sectionId": "ST-003-CARD-01",
  "screenId": "ST-003",
  "title": "The middle zone",
  "bodyMarkdown": "The useful range is where you can hear both the sound therapy and some awareness of tinnitus.",
  "expandable": true,
  "audioId": "AUD-104-G",
  "transcriptCollapsed": true
}
```

## audio_manifest.json

Each audio asset should have:

```json
{
  "audioId": "AUD-104-G",
  "moduleId": "sound_therapy",
  "topic": "Sound Therapy Thermometer",
  "type": "exercise_walkthrough",
  "assetPath": "audio/sound_therapy/p_104_aud_104_g_sound_therapy_thermometer.m4a",
  "transcript": "Start with the sound low and slowly bring it up...",
  "embeddedForMVP": true,
  "playbackContext": "narration"
}
```

## visual_manifest.json

Each visual/component should have:

```json
{
  "visualId": "VIS-ST-THERMOMETER",
  "type": "interactive_component",
  "title": "Sound Therapy Thermometer",
  "status": "build_component",
  "placeholderAllowed": true,
  "acceptanceCriteria": [
    "Shows too quiet, sweet spot, and too loud zones",
    "Controls a white/broadband sample volume",
    "Uses safe volume cap",
    "Can continue without saving"
  ]
}
```

## local_data_schema.json

Use the existing file in `01_SOURCE_OF_TRUTH/09_local_data_schema.json` as the primary schema reference.

## Versioning

All manifests should include a schema version. MVP can start at `1.0.0`.

## Bundle-first rule

MVP content, audio, and visual placeholders are bundled in the app. Later versions may support downloadable content packs, but MVP should work offline after install.
