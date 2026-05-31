# Stage 23C Sound Sample Replacements

## Summary

Rain and Crickets were replaced because the prior bundled files contained an audible metronome. The replacement kept the existing stable asset IDs, labels, bundle paths, grouping, and loop behavior.

## Files

| Asset ID | Label | Source | Destination |
| --- | --- | --- | --- |
| `st.noise.rain` | Rain | `/Users/mark/projects/MPTinnitus/replacement_audio/sound_samples/rain.mp3` | `ios/MPTinnitus/MPTinnitus/Resources/audio/sound_samples/rain.mp3` |
| `st.noise.crickets` | Crickets | `/Users/mark/projects/MPTinnitus/replacement_audio/sound_samples/crickets.mp3` | `ios/MPTinnitus/MPTinnitus/Resources/audio/sound_samples/crickets.mp3` |

## Metadata

| Asset ID | Old SHA-256 | New SHA-256 | New Size | New Duration | Format |
| --- | --- | --- | --- | --- | --- |
| `st.noise.rain` | `86ef474e132112f6673fc6969dcce1252e4241e2bc9cdfb7e6d492864b92db78` | `285547e99a301ede498b56f27a3c290d50d28bf676c0086f6207f750802ef41a` | 964,864 bytes | 60.048 seconds | MP3, 128 kbps, 48 kHz, 2 channels |
| `st.noise.crickets` | `4fa6974767e09ce36b29945c9aadb7552fe6353eb9a016384c4f5f7ff512c57c` | `ae6ddc76f685d77bcd4ea8e1310d6d647db8eec10b959b4a3f67848793b08b95` | 964,864 bytes | 60.048 seconds | MP3, 128 kbps, 48 kHz, 2 channels |

## Manifest Updates

Updated metadata for `st.noise.rain` and `st.noise.crickets` in:

- `ios/MPTinnitus/MPTinnitus/Resources/audio_assets_mvp_2026_05_29.json`
- `ios/MPTinnitus/MPTinnitus/Resources/asset_placeholders_v1.json`

Preserved:

- stable asset IDs
- user-facing labels
- `assetPath`
- `displayGroup`
- `loopCapable: true`
- `playbackMode: sound_therapy_sample`

## Validation

- `python3 scripts/validate_mvp_audio_assets.py`: PASS
- `python3 scripts/validate_beta_readiness.py`: PASS
- `xcodebuild -project ios/MPTinnitus/MPTinnitus.xcodeproj -scheme MPTinnitus -destination 'generic/platform=iOS Simulator' build`: PASS

The Xcode build retained the known `IDERunDestination` warning and completed successfully.
