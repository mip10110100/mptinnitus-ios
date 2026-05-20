# Audio Implementation Notes

## MVP audio behavior

- All MVP audio should be bundled `.m4a` / AAC assets.
- Every audio file must have transcript text.
- Audio cards show Play and Transcript buttons.
- Transcripts are collapsed by default.
- The persistent mini-player shows current audio title and controls.
- Rewind and forward controls skip 15 seconds.

## Playback contexts

- narration
- guided_practice
- prompt
- sound_sample
- background_sound

## Sound sample placeholders

Use the six locked placeholder samples. Final files will be supplied later.

- white / steady broadband noise
- pink / soft broadband noise
- soft rain
- running water / stream
- fan / steady air
- crickets / night insects

## Sound Therapy thermometer

The thermometer component should control a white/broadband sample volume. It should start muted or very low, then allow gradual movement through zones:

- Too quiet
- Sweet spot
- Too loud / overmasking

Use a safe volume cap. The point is education, not maximum output.

## Background playback

MVP should support background playback where practical, especially for sound samples and guided practices. If a background behavior proves complex, implement a safe foreground version first and document the limitation.
