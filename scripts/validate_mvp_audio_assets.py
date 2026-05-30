#!/usr/bin/env python3
"""Validate the MVP packaged sound and mindfulness audio asset registry."""

import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
APP_RESOURCES = ROOT / "ios/MPTinnitus/MPTinnitus/Resources"
ASSET_MANIFEST_PATH = APP_RESOURCES / "audio_assets_mvp_2026_05_29.json"
ASSET_PLACEHOLDERS_PATH = APP_RESOURCES / "asset_placeholders_v1.json"
MODULE_LIBRARY_PATH = APP_RESOURCES / "module_library_v1.json"

EXPECTED_SOUND_IDS = [
    "st.noise.rain",
    "st.noise.stream_flowing_water",
    "st.noise.crickets",
    "st.noise.fan",
    "st.noise.brown.loop_1min_128",
    "st.noise.pink.loop_1min_128",
    "st.noise.white.loop_1min_128",
    "st.noise.brown.fade_1min_128",
    "st.noise.pink.fade_1min_128",
    "st.noise.white.fade_1min_128",
]

EXPECTED_MINDFULNESS_IDS = [
    "mindfulness.long_bodyscan",
    "mindfulness.long_sleep",
    "mindfulness.acceptance_present_moment",
    "mindfulness.body_scan",
    "mindfulness.mindful_listening",
    "mindfulness.sound_therapy_mindful",
    "mindfulness.three_two_one",
    "mindfulness.name_it",
    "mindfulness.one_breath",
    "mindfulness.settling_sleep",
    "mindfulness.open_hands",
    "mindfulness.sound_shifting",
    "mindfulness.body_anchor",
    "mindfulness.breathing_space",
]

SOUND_SAMPLE_TITLES = {
    "Rain",
    "Stream / Flowing Water",
    "Crickets",
    "Fan Noise",
    "Brown Noise",
    "Pink Noise",
    "White Noise",
}

REMOVED_FILENAMES = {
    "full_body_scan1.mp3",
    "full_body_scan2.mp3",
}

UNLISTED_RECORDING_MARKERS = {
    "during_fluctuation",
    "hard_tinnitus",
}


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def load_json(path: Path):
    if not path.exists():
        fail(f"Missing {path}")
    return json.loads(path.read_text())


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


asset_manifest = load_json(ASSET_MANIFEST_PATH)
asset_placeholders = load_json(ASSET_PLACEHOLDERS_PATH)
module_library = load_json(MODULE_LIBRARY_PATH)

assets = asset_manifest.get("assets", [])
assets_by_id = {asset.get("id"): asset for asset in assets}
sound_assets = [asset for asset in assets if asset.get("id") in EXPECTED_SOUND_IDS]
mindfulness_assets = [asset for asset in assets if asset.get("id") in EXPECTED_MINDFULNESS_IDS]

require(len(assets) == 24, f"Expected 24 MVP assets, found {len(assets)}")
require(set(assets_by_id) == set(EXPECTED_SOUND_IDS + EXPECTED_MINDFULNESS_IDS), "Asset manifest IDs do not match the expected MVP inventory")
require(len(sound_assets) == 10, f"Expected 10 sound/noise assets, found {len(sound_assets)}")
require(len(mindfulness_assets) == 14, f"Expected 14 mindfulness assets, found {len(mindfulness_assets)}")

required_asset_fields = [
    "id",
    "displayTitle",
    "category",
    "playbackMode",
    "assetPath",
    "sourceFilename",
    "sourceZip",
    "sourceZipPath",
    "fileSizeBytes",
    "sha256",
]

for asset in assets:
    missing_fields = [field for field in required_asset_fields if not asset.get(field)]
    require(not missing_fields, f"{asset.get('id')} is missing required fields: {missing_fields}")
    path = APP_RESOURCES / asset["assetPath"]
    require(path.exists(), f"{asset['id']} does not resolve to a packaged file at {path}")
    require(path.suffix.lower() == ".mp3", f"{asset['id']} is not an MP3 asset")

for asset_id in [
    "st.noise.brown.loop_1min_128",
    "st.noise.pink.loop_1min_128",
    "st.noise.white.loop_1min_128",
    "st.noise.rain",
    "st.noise.stream_flowing_water",
    "st.noise.crickets",
    "st.noise.fan",
]:
    require(assets_by_id[asset_id].get("loopCapable") is True, f"{asset_id} should be loop-capable")

for asset_id in [
    "st.noise.brown.fade_1min_128",
    "st.noise.pink.fade_1min_128",
    "st.noise.white.fade_1min_128",
    *EXPECTED_MINDFULNESS_IDS,
]:
    require(assets_by_id[asset_id].get("loopCapable") is False, f"{asset_id} should not be loop-capable")

sound_samples = asset_placeholders.get("soundSamples", [])
require(len(sound_samples) == 10, f"Expected 10 sound samples in asset_placeholders_v1.json, found {len(sound_samples)}")
require({sample.get("id") for sample in sound_samples} == set(EXPECTED_SOUND_IDS), "Sound sample registry IDs do not match expected sound/noise assets")
require(SOUND_SAMPLE_TITLES.issubset({sample.get("title") for sample in sound_samples}), "Sound Therapy Samples labels are missing expected titles")

modules_by_id = {module.get("moduleId"): module for module in module_library.get("modules", [])}
mindfulness_module = modules_by_id.get("mindfulness")
sleep_module = modules_by_id.get("sleep")
require(mindfulness_module is not None, "Mindfulness module is missing")
require(sleep_module is not None, "Sleep module is missing")

mindfulness_audio_ids = {audio.get("audioId") for audio in mindfulness_module.get("audio", [])}
sleep_audio_ids = {audio.get("audioId") for audio in sleep_module.get("audio", [])}
mindfulness_section_ids = {
    audio_id
    for card in mindfulness_module.get("cards", [])
    for audio_id in card.get("audioIds", [])
}
sleep_section_ids = {
    audio_id
    for card in sleep_module.get("cards", [])
    for audio_id in card.get("audioIds", [])
}

expected_mindfulness_section_ids = set(EXPECTED_MINDFULNESS_IDS) - {
    "mindfulness.long_sleep",
    "mindfulness.settling_sleep",
}
expected_sleep_section_ids = {
    "mindfulness.long_sleep",
    "mindfulness.settling_sleep",
}

require(expected_mindfulness_section_ids.issubset(mindfulness_audio_ids), "Mindfulness module audio is missing guided recordings")
require(expected_mindfulness_section_ids.issubset(mindfulness_section_ids), "Mindfulness module cards do not surface guided recordings")
require(expected_sleep_section_ids.issubset(sleep_audio_ids), "Sleep module audio is missing sleep-oriented guided recordings")
require(expected_sleep_section_ids.issubset(sleep_section_ids), "Sleep module cards do not surface sleep-oriented guided recordings")

combined_app_text = json.dumps(
    {
        "assetManifest": asset_manifest,
        "assetPlaceholders": asset_placeholders,
        "moduleAudio": [
            audio
            for module in module_library.get("modules", [])
            for audio in module.get("audio", [])
        ],
        "moduleCards": [
            card
            for module in module_library.get("modules", [])
            for card in module.get("cards", [])
        ],
    },
    ensure_ascii=False,
)

for filename in REMOVED_FILENAMES:
    require(filename not in combined_app_text, f"Removed recording should not be required or exposed: {filename}")

for marker in UNLISTED_RECORDING_MARKERS:
    require(marker not in combined_app_text, f"Unlisted removed recording marker is exposed: {marker}")

sound_controller = (ROOT / "ios/MPTinnitus/MPTinnitus/Audio/SoundSampleController.swift").read_text()
audio_controller = (ROOT / "ios/MPTinnitus/MPTinnitus/Audio/AudioController.swift").read_text()
require("stopCurrentPlayback(clearSelection: false)" in sound_controller, "Sound sample playback does not stop the prior sample before starting a new one")
require("stopCurrentPlayback()" in audio_controller, "Narration playback does not stop the prior item before starting a new one")

print("MVP audio asset validation passed.")
print(f"Validated {len(sound_assets)} sound/noise assets and {len(mindfulness_assets)} mindfulness assets.")
