#!/usr/bin/env python3
"""Validate beta-readiness blockers for the local MPTinnitus app repo.

This script is intentionally read-only. It checks app resources and source for
release-blocking issues that should be fixed before a beta/TestFlight build.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
APP_ROOT = ROOT / "ios/MPTinnitus/MPTinnitus"
APP_RESOURCES = APP_ROOT / "Resources"

MODULE_LIBRARY_PATH = APP_RESOURCES / "module_library_v1.json"
ASSET_PLACEHOLDERS_PATH = APP_RESOURCES / "asset_placeholders_v1.json"
AUDIO_ASSETS_PATH = APP_RESOURCES / "audio_assets_mvp_2026_05_29.json"
VIDEO_ASSETS_PATH = APP_RESOURCES / "video_assets_v1.json"
MINDFULNESS_TRANSCRIPTS_PATH = APP_RESOURCES / "mindfulness_transcripts_v1.json"
EXERCISE_DEFINITIONS_PATH = APP_RESOURCES / "exercise_definitions_v1.json"
APP_ICON_CONTENTS_PATH = APP_ROOT / "Assets.xcassets/AppIcon.appiconset/Contents.json"
VISUAL_ASSET_MANIFEST_PATH = ROOT / "docs/visual_assets/visual_asset_manifest_v1.json"

EXPECTED_SOUND_IDS = {
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
}

EXPECTED_SOUND_PLAYER_IDS = {
    "st.noise.rain",
    "st.noise.stream_flowing_water",
    "st.noise.crickets",
    "st.noise.fan",
    "st.noise.brown.loop_1min_128",
    "st.noise.pink.loop_1min_128",
    "st.noise.white.loop_1min_128",
}

EXPECTED_SOUND_PLAYER_LABELS = {
    "st.noise.rain": ("Rain", "Nature / Environmental"),
    "st.noise.stream_flowing_water": ("Stream / Flowing Water", "Nature / Environmental"),
    "st.noise.crickets": ("Crickets", "Nature / Environmental"),
    "st.noise.fan": ("Fan Noise", "Household / Environmental"),
    "st.noise.brown.loop_1min_128": ("Brown Noise", "Static / Artificial"),
    "st.noise.pink.loop_1min_128": ("Pink Noise", "Static / Artificial"),
    "st.noise.white.loop_1min_128": ("White Noise", "Static / Artificial"),
}

HIDDEN_SOUND_PLAYER_IDS = {
    "st.noise.brown.fade_1min_128",
    "st.noise.pink.fade_1min_128",
    "st.noise.white.fade_1min_128",
}

FORBIDDEN_TINNITUS_SOUND_ESTIMATE_CLAIMS = [
    "coordinated reset",
    "neuromodulation",
    "desynchronization",
    "anti-kindling",
    "reset your brain",
    "clinically proven",
    "treats tinnitus",
    "cures tinnitus",
]

EXPECTED_MINDFULNESS_IDS = {
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
}

REMOVED_MINDFULNESS_FILES = {
    "full_body_scan1.mp3",
    "full_body_scan2.mp3",
}

EXPECTED_STATIC_VISUALS = {
    "visual.body_mind_life_model": "body_mind_life_model.png",
    "visual.sound_therapy_thermometer": "sound_therapy_thermometer.png",
    "visual.tug_of_war": "tug_of_war.png",
    "visual.thoughts_feelings_behaviors_cycle": "thoughts_feelings_behaviors_cycle.png",
    "visual.self_compassion_response_card": "self_compassion_response_card.png",
}

SELF_COMPASSION_VISUAL_ID = "VIS-021"
SELF_COMPASSION_RETAINED_CARD_ID = "CC-V5-006-section"
SELF_COMPASSION_RETAINED_CARD_TITLE = "The three parts of self-compassion"
SELF_COMPASSION_DUPLICATE_CARD_IDS = {
    "CC-V5-002-section",
    "CC-V5-005-section",
    "CC-V5-007-section",
    "CC-V5-008-section",
    "CC-V5-010-section",
    "CC-V5-011-section",
    "CC-V5-012-section",
    "CC-V5-014-section",
    "CC-V5-015-section",
    "CC-V5-016-section",
    "CC-V5-017-section",
    "CC-V5-018-section",
    "CC-V5-019-section",
    "CC-V5-022-section",
    "CC-V5-034-section",
}

EXPECTED_NOT_BETA_SCOPE_VISUALS = {
    "visual.stop_card",
    "visual.tipp_card",
    "visual.sleep_tinnitus_loop",
    "visual.sound_sensitivity_music_steps",
    "visual.dear_man_card",
}

EXPECTED_DEFERRED_BREATHING_VIDEO_IDS = {
    "video.breathing.4_2_4.loop",
    "video.breathing.4_4.loop",
    "video.breathing.4_6.loop",
    "video.breathing.4_2_6.loop",
}

EXPECTED_MINDFULNESS_TRANSCRIPTS = {
    "mindfulness.one_breath": "MF-SHORT-001",
    "mindfulness.name_it": "MF-SHORT-002",
    "mindfulness.three_two_one": "MF-SHORT-003",
    "mindfulness.sound_therapy_mindful": "MF-SHORT-004",
    "mindfulness.breathing_space": "MF-MED-001",
    "mindfulness.body_anchor": "MF-MED-002",
    "mindfulness.sound_shifting": "MF-MED-003",
    "mindfulness.open_hands": "MF-MED-004",
    "mindfulness.settling_sleep": "MF-MED-005",
    "mindfulness.mindful_listening": "MF-LONG-001",
    "mindfulness.body_scan": "MF-LONG-002",
    "mindfulness.acceptance_present_moment": "MF-LONG-003",
    "mindfulness.long_sleep": "MF-LONG-005",
    "mindfulness.long_bodyscan": "MF-EXT-001",
}

EXPECTED_MINDFULNESS_PRACTICE_DISPLAY_TITLES = {
    "mindfulness.one_breath": "One Breath Reset",
    "mindfulness.name_it": "Name It and Widen",
    "mindfulness.three_two_one": "3-2-1 Senses Mini",
    "mindfulness.sound_therapy_mindful": "Sound Therapy Mindful Start",
    "mindfulness.breathing_space": "Breathing Space",
    "mindfulness.body_anchor": "Body Anchor and Room Sounds",
    "mindfulness.sound_shifting": "Sound Shifting",
    "mindfulness.open_hands": "Open Hands Grounding",
    "mindfulness.mindful_listening": "Mindful Listening with Tinnitus and External Sound",
    "mindfulness.acceptance_present_moment": "Acceptance in the Present Moment",
    "mindfulness.body_scan": "Medium Length Body-Scan",
    "mindfulness.long_bodyscan": "Full Body Scan",
    "mindfulness.settling_sleep": "Settling Without Forcing Sleep",
    "mindfulness.long_sleep": "Evening Body and Sound Wind-Down",
}

EXPECTED_MINDFULNESS_PRACTICE_GROUPS = {
    "shortGuidedPracticeAudioOrder": [
        "mindfulness.one_breath",
        "mindfulness.name_it",
        "mindfulness.three_two_one",
        "mindfulness.sound_therapy_mindful",
    ],
    "mediumGuidedPracticeAudioOrder": [
        "mindfulness.breathing_space",
        "mindfulness.body_anchor",
        "mindfulness.sound_shifting",
        "mindfulness.open_hands",
        "mindfulness.mindful_listening",
        "mindfulness.acceptance_present_moment",
        "mindfulness.body_scan",
    ],
    "longGuidedPracticeAudioOrder": [
        "mindfulness.long_bodyscan",
    ],
    "sleepGuidedPracticeAudioOrder": [
        "mindfulness.settling_sleep",
        "mindfulness.long_sleep",
    ],
}

EXPECTED_MINDFULNESS_PRACTICE_SECTIONS = {
    "Short Guided Practices",
    "Medium Guided Practices",
    "Long Guided Practices",
    "Sleep-Oriented Practices",
    "Breathing Pacer",
    "Reflection Exercises",
}

EXPECTED_BREATHING_PACER_OPTIONS = {
    "4-4 Even Breathing",
    "4-2-4 Balanced Breathing",
    "4-6 Extended Exhale",
    "4-2-6 Extended Exhale with Pause",
}

EXPECTED_MINDFULNESS_REFLECTION_EXERCISES = {
    "I-011": "Deep Breath Check-In Reflection",
    "I-012": "3-2-1 Senses",
    "I-013": "Mindful Listening",
    "I-014": "Sound Shifting",
}

ABOUT_BML_VISUAL_ID = "VIS-001"
ABOUT_BML_VISUAL_CARD = "AT-002-BEYOND-section"
ABOUT_BML_VISUAL_SCREEN = "AT-002"
ABOUT_PAUSE_REFLECT_EXERCISE_ID = "I-002"
ABOUT_PAUSE_REFLECT_CARD = "AT-010-PAUSE-section"
ABOUT_PAUSE_REFLECT_FIELDS = {
    "body_note": "In my body, I notice…",
    "mind_note": "In my mind, I notice…",
    "life_note": "In my daily life, I notice…",
    "support_note": "One area I may want to support first is…",
}

SOUND_THERAPY_THERMOMETER_VISUAL_ID = "VIS-003"
SOUND_THERAPY_THERMOMETER_CARD = "ST-V5-009-section"
SOUND_THERAPY_PLAYER_LINK_CARDS = {
    "ST-V5-010-section",
    "ST-V5-014-section",
}
SOUND_SENSITIVITY_EXERCISE_ID = "I-006"
OLD_SOUND_SENSITIVITY_TITLES = [
    "Enjoyable Music Exercise",
    "Enjoyable Music Speaker Exercise",
    "Enjoyable music speaker exercise",
    "Enjoyable music speaker practice",
    "Open Enjoyable Music Speaker Exercise",
]

EXPECTED_DISTRESS_TOLERANCE_EXERCISE_TITLES = {
    "I-016": "STOP",
    "I-017": "Temperature/Ice",
    "I-018": "TIPP",
    "I-019": "The Frozen Orange",
}

FORBIDDEN_DISTRESS_TOLERANCE_LABELS = [
    "STOP card",
    "Stop card",
    "TIPP card",
    "TIPP Card",
    "STOP Practice",
    "STOP practice",
    "Temperature/Ice Practice",
    "Temperature/Ice practice",
    "TIPP Practice",
    "TIPP practice",
    "The Frozen Orange Practice",
    "Frozen orange practice",
    "Open STOP Practice",
    "Open TIPP Practice",
]

EXCLUDED_MINDFULNESS_SCRIPT_IDS = {
    "MF-SHORT-005",
    "MF-LONG-004",
    "MF-EXT-002",
}

PLANNING_PATTERNS = [
    ("REMOVE", re.compile(r"\bREMOVE\b")),
    ("LET’S REMOVE", re.compile(r"LET’S REMOVE")),
    ("LET'S REMOVE", re.compile(r"LET'S REMOVE")),
    ("REMOVE FAST", re.compile(r"REMOVE FAST")),
    ("REMOVE/COMBINE", re.compile(r"REMOVE/COMBINE")),
    ("COMBINE WITH", re.compile(r"COMBINE WITH")),
    ("TODO", re.compile(r"\bTODO\b")),
    ("FIXME", re.compile(r"\bFIXME\b")),
    ("planned", re.compile(r"\bplanned\b", re.IGNORECASE)),
    ("placeholder", re.compile(r"\bplaceholder\b", re.IGNORECASE)),
    ("not implemented", re.compile(r"\bnot implemented\b", re.IGNORECASE)),
    ("source-of-truth", re.compile(r"\bsource-of-truth\b", re.IGNORECASE)),
    ("replace me", re.compile(r"\breplace me\b", re.IGNORECASE)),
    ("draft", re.compile(r"\bdraft\b", re.IGNORECASE)),
    ("temporary", re.compile(r"\btemporary\b", re.IGNORECASE)),
    ("needs copy", re.compile(r"\bneeds copy\b", re.IGNORECASE)),
]

PROHIBITED_SOURCE_TERMS = [
    "Firebase",
    "Supabase",
    "CloudKit",
    "Analytics",
    "URLSession",
    "http://",
    "https://",
    "UNUserNotificationCenter",
    "requestAuthorization",
    "UNNotificationRequest",
    "AVQueuePlayer",
    "AVAudioSession",
]

RELEASE_UI_FORBIDDEN_STRINGS = [
    "Manifest Loader",
    "Static Module Library",
    "Sound Player Debug",
    "Mindfulness Practice Debug",
    "Local Data Status",
    "Sound Therapy Annex",
    "Mindfulness Annex",
    "FAQs / Common Questions",
    "Enjoyable Music",
    "STOP card",
    "TIPP card",
]

MEDIA_EXTENSIONS = {
    ".mp3",
    ".m4a",
    ".wav",
    ".aac",
    ".png",
    ".jpg",
    ".jpeg",
    ".webp",
    ".pdf",
    ".svg",
    ".mp4",
    ".mov",
}


failures: dict[str, list[str]] = {}
warnings: dict[str, list[str]] = {}


def add_failure(category: str, message: str) -> None:
    failures.setdefault(category, []).append(message)


def add_warning(category: str, message: str) -> None:
    warnings.setdefault(category, []).append(message)


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text())
    except FileNotFoundError:
        add_failure("JSON validity", f"Missing required JSON file: {path}")
    except json.JSONDecodeError as error:
        add_failure("JSON validity", f"Invalid JSON in {path}: {error}")
    return None


def resource_exists(asset_path: str) -> bool:
    if not asset_path:
        return False

    normalized = asset_path[1:] if asset_path.startswith("/") else asset_path
    direct = APP_RESOURCES / normalized
    if direct.exists():
        return True

    # Xcode's synchronized root group may flatten resources in the built app.
    # Keep source-resource validation strict but support app lookup by basename.
    basename_matches = list(APP_RESOURCES.rglob(Path(normalized).name))
    return len(basename_matches) == 1


def validate_mvp_audio(audio_assets: dict[str, Any], asset_placeholders: dict[str, Any], module_library: dict[str, Any]) -> None:
    assets = audio_assets.get("assets", [])
    ids = {asset.get("id") for asset in assets}
    expected = EXPECTED_SOUND_IDS | EXPECTED_MINDFULNESS_IDS

    if len(assets) != 24:
        add_failure("MVP audio", f"Expected 24 MVP MP3 assets, found {len(assets)} in {AUDIO_ASSETS_PATH}")
    if ids != expected:
        missing = sorted(expected - ids)
        extra = sorted(ids - expected)
        add_failure("MVP audio", f"MVP audio IDs mismatch. Missing={missing}; extra={extra}")

    sound_assets = [asset for asset in assets if asset.get("id") in EXPECTED_SOUND_IDS]
    mindfulness_assets = [asset for asset in assets if asset.get("id") in EXPECTED_MINDFULNESS_IDS]
    if len(sound_assets) != 10:
        add_failure("MVP audio", f"Expected 10 sound/noise assets, found {len(sound_assets)}")
    if len(mindfulness_assets) != 14:
        add_failure("MVP audio", f"Expected 14 mindfulness assets, found {len(mindfulness_assets)}")

    for asset in assets:
        asset_id = asset.get("id", "<missing id>")
        path = asset.get("assetPath", "")
        if not path.endswith(".mp3"):
            add_failure("MVP audio", f"{asset_id} should reference an MP3 path, found {path!r}")
        if not resource_exists(path):
            add_failure("MVP audio", f"{asset_id} does not resolve to bundled resource path {path!r}")
        for required in ["displayTitle", "category", "playbackMode", "sourceFilename", "sourceZip", "sourceZipPath", "fileSizeBytes", "sha256"]:
            if not asset.get(required):
                add_failure("MVP audio", f"{asset_id} missing required field {required}")

    assets_by_id = {asset.get("id"): asset for asset in assets}
    for asset_id in [
        "st.noise.brown.loop_1min_128",
        "st.noise.pink.loop_1min_128",
        "st.noise.white.loop_1min_128",
        "st.noise.rain",
        "st.noise.stream_flowing_water",
        "st.noise.crickets",
        "st.noise.fan",
    ]:
        if assets_by_id.get(asset_id, {}).get("loopCapable") is not True:
            add_failure("MVP audio", f"{asset_id} should be loop-capable")

    for asset_id in [
        "st.noise.brown.fade_1min_128",
        "st.noise.pink.fade_1min_128",
        "st.noise.white.fade_1min_128",
        *EXPECTED_MINDFULNESS_IDS,
    ]:
        if assets_by_id.get(asset_id, {}).get("loopCapable") is not False:
            add_failure("MVP audio", f"{asset_id} should not be loop-capable")

    sound_samples = asset_placeholders.get("soundSamples", [])
    sound_sample_ids = {sample.get("id") for sample in sound_samples}
    if sound_sample_ids != EXPECTED_SOUND_IDS:
        add_failure("MVP audio", f"Sound sample registry IDs mismatch: {ASSET_PLACEHOLDERS_PATH}")

    expected_sound_titles = {
        "st.noise.rain": "Rain",
        "st.noise.stream_flowing_water": "Stream / Flowing Water",
        "st.noise.crickets": "Crickets",
        "st.noise.fan": "Fan Noise",
        "st.noise.brown.loop_1min_128": "Brown Noise",
        "st.noise.pink.loop_1min_128": "Pink Noise",
        "st.noise.white.loop_1min_128": "White Noise",
        "st.noise.brown.fade_1min_128": "Brown Noise, 1-Minute Sample",
        "st.noise.pink.fade_1min_128": "Pink Noise, 1-Minute Sample",
        "st.noise.white.fade_1min_128": "White Noise, 1-Minute Sample",
    }
    for sample in sound_samples:
        sample_id = sample.get("id")
        if sample_id in expected_sound_titles and sample.get("title") != expected_sound_titles[sample_id]:
            add_failure("MVP audio", f"{sample_id} title should be {expected_sound_titles[sample_id]!r}, found {sample.get('title')!r}")

    combined_user_data = json.dumps(
        {
            "audioAssets": audio_assets,
            "assetPlaceholders": asset_placeholders,
            "moduleCards": [card for module in module_library.get("modules", []) for card in module.get("cards", [])],
            "moduleAudio": [audio for module in module_library.get("modules", []) for audio in module.get("audio", [])],
        },
        ensure_ascii=False,
    )
    for filename in REMOVED_MINDFULNESS_FILES:
        if filename in combined_user_data:
            add_failure("MVP audio", f"Removed mindfulness file is exposed or required: {filename}")


def validate_sound_therapy_player(asset_placeholders: dict[str, Any]) -> None:
    sound_samples = asset_placeholders.get("soundSamples", [])
    samples_by_id = {sample.get("id"): sample for sample in sound_samples}

    for sample_id, (expected_title, expected_category) in EXPECTED_SOUND_PLAYER_LABELS.items():
        sample = samples_by_id.get(sample_id)
        if not sample:
            add_failure("Sound Therapy Player", f"Visible player sample is missing from sound sample registry: {sample_id}")
            continue
        if sample.get("title") != expected_title:
            add_failure("Sound Therapy Player", f"{sample_id} title should be {expected_title!r}, found {sample.get('title')!r}")
        if sample.get("category") != expected_category:
            add_failure("Sound Therapy Player", f"{sample_id} category should be {expected_category!r}, found {sample.get('category')!r}")
        if sample.get("displayGroup") != expected_category:
            add_failure("Sound Therapy Player", f"{sample_id} displayGroup should be {expected_category!r}, found {sample.get('displayGroup')!r}")

    view_path = APP_ROOT / "Features/SoundTherapy/SoundTherapyAnnexView.swift"
    card_path = APP_ROOT / "Features/SoundTherapy/SoundSampleCard.swift"
    app_tab_path = APP_ROOT / "Core/AppTab.swift"

    view_text = view_path.read_text()
    card_text = card_path.read_text()
    app_tab_text = app_tab_path.read_text()

    for expected_text in [
        "Sound Therapy Player",
        "Guidance",
        "Sound Therapy Samples",
        "Set these sounds to a comfortable level to explore how they work as sound therapy options.",
        "Saved Preferred Sounds",
    ]:
        if expected_text not in view_text and expected_text not in app_tab_text:
            add_failure("Sound Therapy Player", f"Expected player UI text is missing: {expected_text!r}")

    for old_text in [
        "Sound Therapy Annex",
        "support this annex",
        "Sound Annex Debug",
        "Favorites stay on this device.",
        "Do not push into painful or unsafe sound",
    ]:
        if old_text in view_text or old_text in app_tab_text:
            add_failure("Sound Therapy Player", f"Old annex or warning copy remains in player UI source: {old_text!r}")

    for old_text in [
        "sample.guidance",
        "% of capped range",
        "The app caps this preview below full device volume",
    ]:
        if old_text in card_text:
            add_failure("Sound Therapy Player", f"Repeated per-card instruction text remains: {old_text!r}")

    for sample_id in EXPECTED_SOUND_PLAYER_IDS:
        if sample_id not in view_text:
            add_failure("Sound Therapy Player", f"Visible player sample ID is not included in the beta display filter: {sample_id}")
    for sample_id in HIDDEN_SOUND_PLAYER_IDS:
        if sample_id in view_text:
            add_failure("Sound Therapy Player", f"One-minute sample should not be visible in the beta display filter: {sample_id}")


def validate_sound_sample_foreground_continuity() -> None:
    root_shell_path = APP_ROOT / "App/RootShellView.swift"
    sound_player_path = APP_ROOT / "Features/SoundTherapy/SoundTherapyAnnexView.swift"
    controller_path = APP_ROOT / "Audio/SoundSampleController.swift"

    root_shell_text = root_shell_path.read_text()
    sound_player_text = sound_player_path.read_text()
    controller_text = controller_path.read_text()

    if "@StateObject private var soundSampleController = SoundSampleController()" not in root_shell_text:
        add_failure("Sound sample foreground continuity", "RootShellView should own one shared SoundSampleController for foreground tab navigation.")
    if "sampleController: soundSampleController" not in root_shell_text:
        add_failure("Sound sample foreground continuity", "RootShellView should pass the shared SoundSampleController into SoundTherapyAnnexView.")
    if "@ObservedObject private var sampleController: SoundSampleController" not in sound_player_text:
        add_failure("Sound sample foreground continuity", "SoundTherapyAnnexView should observe the shared SoundSampleController instead of owning a tab-local one.")
    if ".onDisappear" in sound_player_text and "sampleController.stop()" in sound_player_text:
        add_failure("Sound sample foreground continuity", "SoundTherapyAnnexView should not stop sound samples merely because the user navigates away in the foreground.")
    if "newPhase != .active" not in root_shell_text or "soundSampleController.stop()" not in root_shell_text:
        add_failure("Sound sample foreground continuity", "Sound samples should stop or release when the app leaves the foreground.")
    if "stopCurrentPlayback(clearSelection: false)" not in controller_text:
        add_failure("Sound sample foreground continuity", "Starting a sound sample should stop the prior sample before playing the next one.")
    if "audioPlayer.numberOfLoops = sample.loopCapable ? -1 : 0" not in controller_text:
        add_failure("Sound sample foreground continuity", "Loop-capable sound samples should continue looping in the foreground.")


def validate_tinnitus_sound_estimate_feature(asset_placeholders: dict[str, Any]) -> None:
    route_path = APP_ROOT / "Core/AppRoute.swift"
    destination_path = APP_ROOT / "App/AppRouteDestinationView.swift"
    player_path = APP_ROOT / "Features/SoundTherapy/SoundTherapyAnnexView.swift"
    sample_controller_path = APP_ROOT / "Audio/SoundSampleController.swift"
    feature_dir = APP_ROOT / "Features/SoundTherapy/Customized"
    view_path = feature_dir / "TinnitusSoundEstimateView.swift"
    profile_path = feature_dir / "TinnitusSoundProfile.swift"
    store_path = feature_dir / "TinnitusSoundProfileStore.swift"
    engine_path = feature_dir / "TinnitusPitchMatchAudioEngine.swift"

    for path in [view_path, profile_path, store_path, engine_path]:
        if not path.exists():
            add_failure("Tinnitus sound estimate", f"Required feature file is missing: {path}")

    route_text = route_path.read_text()
    destination_text = destination_path.read_text()
    player_text = player_path.read_text()
    sample_controller_text = sample_controller_path.read_text()
    feature_text = "\n".join(
        path.read_text(errors="ignore")
        for path in [view_path, profile_path, store_path, engine_path]
        if path.exists()
    )

    required_snippets = {
        "AppRoute route": "case tinnitusSoundEstimate" in route_text,
        "AppRoute path": '"/sound/tinnitus-sound-estimate"' in route_text,
        "Destination view": "TinnitusSoundEstimateView(sampleController: soundSampleController)" in destination_text,
        "Player section": "Customized sound therapy" in player_text,
        "Player card title": "Tinnitus sound estimate" in player_text,
        "Player card CTA": "Start pitch match" in player_text,
        "Pitch slider formula": "minFrequencyHz * pow(maxFrequencyHz / minFrequencyHz, clampedValue)" in feature_text,
        "Pitch inverse formula": "log(clampedFrequency / minFrequencyHz) / log(maxFrequencyHz / minFrequencyHz)" in feature_text,
        "Profile store": "tinnitus_sound_profile_v1.json" in feature_text,
        "Pure tone engine": "AVAudioSourceNode" in feature_text and "sin(localPhase)" in feature_text,
        "Stops samples before tone": "sampleController.stop()" in feature_text,
        "Samples stop pitch callback": "onWillStartPlayback" in sample_controller_text and "onWillStartPlayback?()" in sample_controller_text,
        "Foreground stop": "scenePhase" in feature_text and "newPhase != .active" in feature_text and "stopTone()" in feature_text,
    }
    for label, passed in required_snippets.items():
        if not passed:
            add_failure("Tinnitus sound estimate", f"Missing expected implementation detail: {label}")

    for expected_text in [
        "Estimate your tinnitus pitch and optional loudness. An exact match is not required.",
        "Move the slider until the tone is close to your tinnitus. It does not need to be exact.",
        "Headphones may help with pitch matching, especially for higher pitches.",
        "Saved on this device. You can update it later.",
    ]:
        if expected_text not in feature_text:
            add_failure("Tinnitus sound estimate", f"Expected user-facing copy is missing: {expected_text!r}")

    combined_feature_text = f"{player_text}\n{feature_text}".lower()
    for claim in FORBIDDEN_TINNITUS_SOUND_ESTIMATE_CLAIMS:
        if claim in combined_feature_text:
            add_failure("Tinnitus sound estimate", f"Forbidden claim appears in feature source: {claim!r}")

    sound_samples = asset_placeholders.get("soundSamples", [])
    visible_ids_in_registry = {
        sample.get("id")
        for sample in sound_samples
        if sample.get("id") in EXPECTED_SOUND_PLAYER_IDS
    }
    if visible_ids_in_registry != EXPECTED_SOUND_PLAYER_IDS:
        add_failure("Tinnitus sound estimate", "Sound Therapy demo sample registry changed while adding sound estimate.")

    for path in APP_RESOURCES.rglob("*"):
        if not path.is_file():
            continue
        lower_name = path.name.lower()
        if "generated" in lower_name or "personalized" in lower_name or "notched" in lower_name:
            add_failure("Tinnitus sound estimate", f"Generated/personalized audio resource should not be added in this stage: {path}")

    plist_candidates = list(APP_ROOT.rglob("*.plist"))
    for plist in plist_candidates:
        text = plist.read_text(errors="ignore")
        if "UIBackgroundModes" in text and "audio" in text:
            add_failure("Tinnitus sound estimate", f"Background audio mode should not be present: {plist}")


def validate_stage_24b_release_ui_cleanup() -> None:
    ui_paths = [
        APP_ROOT / "App/RootShellView.swift",
        APP_ROOT / "Core/AppTab.swift",
        APP_ROOT / "Features/Library/LibraryView.swift",
        APP_ROOT / "Features/Library/LibraryPlaceholderView.swift",
        APP_ROOT / "Features/SoundTherapy/SoundTherapyAnnexView.swift",
        APP_ROOT / "Features/Mindfulness/MindfulnessAnnexView.swift",
        APP_ROOT / "Features/MyPlan/MyPlanView.swift",
        APP_ROOT / "Features/Settings/SettingsPlaceholderView.swift",
        APP_ROOT / "Features/SoundTherapy/Customized/TinnitusSoundEstimateView.swift",
    ]
    for path in ui_paths:
        text = path.read_text(errors="ignore")
        for forbidden in RELEASE_UI_FORBIDDEN_STRINGS:
            if forbidden in text:
                add_failure("Stage 24B release UI cleanup", f"{path} contains release-facing internal/debug wording: {forbidden!r}")

    root_shell_text = (APP_ROOT / "App/RootShellView.swift").read_text()
    foreground_control_path = APP_ROOT / "Audio/SoundTherapyForegroundControlView.swift"
    if not foreground_control_path.exists():
        add_failure("Stage 24B release UI cleanup", f"Global Sound Therapy foreground control is missing: {foreground_control_path}")
    else:
        foreground_control_text = foreground_control_path.read_text()
        for snippet in [
            "Sound Therapy",
            "controller.currentSampleTitle",
            "controller.stop()",
            "accessibilityLabel(\"Stop Sound Therapy\")",
        ]:
            if snippet not in foreground_control_text:
                add_failure("Stage 24B release UI cleanup", f"Foreground control is missing expected snippet: {snippet}")

    if "SoundTherapyForegroundControlView(controller: soundSampleController)" not in root_shell_text:
        add_failure("Stage 24B release UI cleanup", "RootShellView should show the global Sound Therapy foreground control.")
    if "if soundSampleController.isPlaying" not in root_shell_text:
        add_failure("Stage 24B release UI cleanup", "Global Sound Therapy foreground control should be hidden when no sample is playing.")

    settings_text = (APP_ROOT / "Features/Settings/SettingsPlaceholderView.swift").read_text()
    if "case tinnitusSoundEstimate" not in settings_text:
        add_failure("Stage 24B release UI cleanup", "Settings should expose a reset action for the tinnitus sound estimate.")
    if "TinnitusSoundProfileStore.deleteSavedProfile()" not in settings_text:
        add_failure("Stage 24B release UI cleanup", "Reset all local data should delete tinnitus_sound_profile_v1.json.")
    if "Clear tinnitus sound estimate" not in settings_text:
        add_failure("Stage 24B release UI cleanup", "Settings should show clear copy for clearing the tinnitus sound estimate.")

    estimate_view_text = (APP_ROOT / "Features/SoundTherapy/Customized/TinnitusSoundEstimateView.swift").read_text()
    if "No estimate saved yet" not in estimate_view_text:
        add_failure("Stage 24B release UI cleanup", "Tinnitus sound estimate should have a product-like empty state before save.")


def validate_mindfulness_practice_ui(module_library: dict[str, Any], exercise_definitions: dict[str, Any]) -> None:
    app_tab_path = APP_ROOT / "Core/AppTab.swift"
    practice_path = APP_ROOT / "Features/Mindfulness/MindfulnessAnnexView.swift"
    pacer_path = APP_ROOT / "Features/Visuals/BreathingPacerVisualView.swift"
    root_shell_path = APP_ROOT / "App/RootShellView.swift"
    audio_card_path = APP_ROOT / "Features/Modules/Components/AudioCard.swift"

    app_tab_text = app_tab_path.read_text()
    practice_text = practice_path.read_text()
    pacer_text = pacer_path.read_text()
    root_shell_text = root_shell_path.read_text()
    audio_card_text = audio_card_path.read_text()
    module_library_text = json.dumps(module_library, ensure_ascii=False)

    if "Mindfulness Practice" not in app_tab_text:
        add_failure("Mindfulness Practice", "AppTab user-facing title should be Mindfulness Practice.")
    if "Mindfulness Annex" in practice_text or '"Mindfulness Annex"' in app_tab_text:
        add_failure("Mindfulness Practice", "Mindfulness practice page source should not show Mindfulness Annex as user-facing copy.")

    for section_title in EXPECTED_MINDFULNESS_PRACTICE_SECTIONS:
        if section_title not in practice_text:
            add_failure("Mindfulness Practice", f"Missing collapsed practice section title: {section_title}")

    expected_audio_ids = set(EXPECTED_MINDFULNESS_TRANSCRIPTS)
    for audio_id in sorted(expected_audio_ids):
        if audio_id not in practice_text:
            add_failure("Mindfulness Practice", f"Mindfulness Practice does not surface expected audio asset ID: {audio_id}")

    for title in EXPECTED_MINDFULNESS_PRACTICE_DISPLAY_TITLES.values():
        if title not in practice_text:
            add_failure("Mindfulness Practice", f"Mindfulness Practice is missing expected display title: {title}")

    for array_name, expected_ids in EXPECTED_MINDFULNESS_PRACTICE_GROUPS.items():
        match = re.search(rf"private let {array_name} = \[(.*?)\]", practice_text, re.S)
        if not match:
            add_failure("Mindfulness Practice", f"Missing practice audio group: {array_name}")
            continue
        actual_ids = re.findall(r'"([^"]+)"', match.group(1))
        if actual_ids != expected_ids:
            add_failure("Mindfulness Practice", f"{array_name} should be {expected_ids}, found {actual_ids}")

    if "Audio explanation" in practice_text:
        add_failure("Mindfulness Practice", "Mindfulness Practice should not render the repeated Audio explanation label.")
    if "showsContextLabel: false" not in practice_text or "showsContextLabel" not in audio_card_text:
        add_failure("Mindfulness Practice", "Mindfulness Practice should hide the reusable AudioCard context label for guided practice cards.")
    if "TranscriptDisclosure(transcript: audio.transcript)" not in audio_card_text:
        add_failure("Mindfulness Practice", "Mindfulness Practice guided recordings should keep the reusable transcript disclosure.")
    if "Text(audio.title)" not in audio_card_text:
        add_failure("Mindfulness Practice", "Mindfulness Practice guided recordings should keep the practice title visible.")

    for title in EXPECTED_BREATHING_PACER_OPTIONS:
        if title not in pacer_text:
            add_failure("Mindfulness Practice", f"Missing Breathing Pacer timing option: {title}")

    mindfulness_module = next(
        (module for module in module_library.get("modules", []) if module.get("moduleId") == "mindfulness"),
        {},
    )
    mindfulness_exercise_ids = {
        exercise.get("exerciseId")
        for exercise in mindfulness_module.get("exercises", [])
    }
    implemented_exercise_ids = {
        definition.get("exerciseId")
        for definition in exercise_definitions.get("definitions", [])
    }
    for exercise_id, title in EXPECTED_MINDFULNESS_REFLECTION_EXERCISES.items():
        if exercise_id not in practice_text:
            add_failure("Mindfulness Practice", f"Reflection Exercises section does not expose expected exercise route: {exercise_id} {title}")
        if exercise_id not in mindfulness_exercise_ids:
            add_failure("Mindfulness Practice", f"Mindfulness module is missing reflection exercise reference: {exercise_id} {title}")
        if exercise_id not in implemented_exercise_ids:
            add_failure("Mindfulness Practice", f"Reflection exercise lacks an implemented definition: {exercise_id} {title}")
    if "exerciseDefinitionLibrary: exerciseDefinitionLibrary" not in root_shell_text:
        add_failure("Mindfulness Practice", "RootShellView should pass ExerciseDefinitionLibrary into Mindfulness Practice so unsupported exercises can stay hidden.")

    for forbidden in [
        "single-play recordings, not continuous loops",
        "not continuous loops",
        "single-play guided recording",
        "single-play sleep-oriented guided practice",
        "not a looped sound therapy sample",
    ]:
        if forbidden in practice_text or forbidden in module_library_text:
            add_failure("Mindfulness Practice", f"Technical single-play/loop contrast copy remains user-facing: {forbidden!r}")

    for forbidden in ["BreathingVideoSection", "BreathingVideoLibrary", "VideoPlayer", "AVKit"]:
        if forbidden in practice_text or forbidden in pacer_text:
            add_failure("Mindfulness Practice", f"Breathing video runtime code should not be exposed for beta: {forbidden}")

    support_index = practice_text.find("If Practice Feels Too Intense")
    learn_index = practice_text.find("Mindfulness education module")
    if support_index == -1:
        add_failure("Mindfulness Practice", "If Practice Feels Too Intense support link is missing.")
    elif learn_index != -1 and support_index > learn_index:
        add_failure("Mindfulness Practice", "If Practice Feels Too Intense should be the first lower learning/support link.")


def validate_stage_23k_copy_cleanup(module_library: dict[str, Any], exercise_definitions: dict[str, Any]) -> None:
    renderer_path = APP_ROOT / "Features/Modules/ModuleOverviewScreen.swift"
    renderer_text = renderer_path.read_text()
    if '"FAQs / Common Questions"' in renderer_text:
        add_failure("Stage 23K copy cleanup", "Module group headings should use FAQs instead of FAQs / Common Questions.")
    if 'return "FAQs"' not in renderer_text:
        add_failure("Stage 23K copy cleanup", "Module group headings should include the user-facing title FAQs.")
    if 'title.contains("fallacy")' not in renderer_text:
        add_failure("Stage 23K copy cleanup", "Cognitive Reframing grouping should send singular fallacy titles to the Distortion Library.")

    searchable_paths = [
        path
        for path in APP_ROOT.rglob("*")
        if path.is_file() and path.suffix in {".swift", ".json"}
    ]
    for path in searchable_paths:
        text = path.read_text(errors="ignore")
        if "FAQs / Common Questions" in text:
            add_failure("Stage 23K copy cleanup", f"User-facing FAQ section title remains in {path}.")
        for forbidden in FORBIDDEN_DISTRESS_TOLERANCE_LABELS:
            if forbidden in text:
                add_failure("Stage 23K copy cleanup", f"Old Distress Tolerance label remains in {path}: {forbidden!r}")

    distress_module = next(
        (module for module in module_library.get("modules", []) if module.get("moduleId") == "distress_tolerance"),
        None,
    )
    if not distress_module:
        add_failure("Stage 23K copy cleanup", "Distress Tolerance module is missing.")
    else:
        exercises_by_id = {exercise.get("exerciseId"): exercise for exercise in distress_module.get("exercises", [])}
        for exercise_id, expected_title in EXPECTED_DISTRESS_TOLERANCE_EXERCISE_TITLES.items():
            exercise = exercises_by_id.get(exercise_id)
            if not exercise:
                add_failure("Stage 23K copy cleanup", f"Distress Tolerance exercise {exercise_id} is missing.")
            elif exercise.get("title") != expected_title:
                add_failure(
                    "Stage 23K copy cleanup",
                    f"Distress Tolerance exercise {exercise_id} should be titled {expected_title!r}, found {exercise.get('title')!r}.",
                )

        visuals_by_id = {visual.get("visualId"): visual for visual in distress_module.get("visuals", [])}
        for visual_id, expected_title in {"VIS-013": "STOP", "VIS-014": "TIPP"}.items():
            visual = visuals_by_id.get(visual_id)
            if not visual:
                add_failure("Stage 23K copy cleanup", f"Distress Tolerance visual {visual_id} is missing.")
            elif visual.get("title") != expected_title:
                add_failure(
                    "Stage 23K copy cleanup",
                    f"Distress Tolerance visual {visual_id} should be titled {expected_title!r}, found {visual.get('title')!r}.",
                )

    definitions_by_id = {
        definition.get("exerciseId"): definition
        for definition in exercise_definitions.get("definitions", [])
    }
    for exercise_id, expected_title in EXPECTED_DISTRESS_TOLERANCE_EXERCISE_TITLES.items():
        definition = definitions_by_id.get(exercise_id)
        if not definition:
            add_failure("Stage 23K copy cleanup", f"Exercise definition {exercise_id} is missing.")
        elif definition.get("title") != expected_title:
            add_failure(
                "Stage 23K copy cleanup",
                f"Exercise definition {exercise_id} should be titled {expected_title!r}, found {definition.get('title')!r}.",
            )

    cognitive_module = next(
        (module for module in module_library.get("modules", []) if module.get("moduleId") == "cognitive_reframing"),
        None,
    )
    if not cognitive_module:
        add_failure("Stage 23K copy cleanup", "Cognitive Reframing module is missing.")
    else:
        heaven_reward_cards = [
            card for card in cognitive_module.get("cards", [])
            if "heaven" in card.get("title", "").lower() and "reward" in card.get("title", "").lower()
        ]
        if not heaven_reward_cards:
            add_failure("Stage 23K copy cleanup", "Heaven’s Reward Fallacy card is missing from Cognitive Reframing.")

    acceptance_module = next(
        (module for module in module_library.get("modules", []) if module.get("moduleId") == "acceptance_and_change"),
        None,
    )
    if acceptance_module:
        acceptance_text = json.dumps(acceptance_module, ensure_ascii=False)
        for forbidden in FORBIDDEN_DISTRESS_TOLERANCE_LABELS:
            if forbidden in acceptance_text:
                add_failure("Stage 23K copy cleanup", f"Acceptance and Change unexpectedly contains Stage 23K Distress label {forbidden!r}.")


def validate_mvp_visuals_and_deferred_videos(visual_manifest: dict[str, Any]) -> None:
    static_visuals = visual_manifest.get("staticVisuals", [])
    static_ids = {visual.get("id") for visual in static_visuals}
    if static_ids != set(EXPECTED_STATIC_VISUALS):
        missing = sorted(set(EXPECTED_STATIC_VISUALS) - static_ids)
        extra = sorted(static_ids - set(EXPECTED_STATIC_VISUALS))
        add_failure("MVP visuals", f"Static MVP visual IDs mismatch. Missing={missing}; extra={extra}")

    visuals_folder = APP_RESOURCES / "visuals"
    expected_visual_files = set(EXPECTED_STATIC_VISUALS.values())
    actual_visual_files = {path.name for path in visuals_folder.glob("*.png")} if visuals_folder.exists() else set()
    if actual_visual_files != expected_visual_files:
        missing = sorted(expected_visual_files - actual_visual_files)
        extra = sorted(actual_visual_files - expected_visual_files)
        add_failure("MVP visuals", f"Expected exactly five MVP visual PNGs in {visuals_folder}. Missing={missing}; extra={extra}")

    for visual in static_visuals:
        visual_id = visual.get("id", "<missing id>")
        expected_filename = EXPECTED_STATIC_VISUALS.get(visual_id)
        if expected_filename is None:
            continue
        if visual.get("status") not in {"integrated_mvp", "mapped", "available"}:
            add_failure("MVP visuals", f"{visual_id} should be marked integrated or available")
        if visual.get("bundledFilename") != expected_filename:
            add_failure("MVP visuals", f"{visual_id} bundledFilename should be {expected_filename}")
        asset_path = visual.get("assetPath", "")
        if asset_path != f"visuals/{expected_filename}":
            add_failure("MVP visuals", f"{visual_id} assetPath should be visuals/{expected_filename}, found {asset_path!r}")
        if not resource_exists(asset_path):
            add_failure("MVP visuals", f"{visual_id} does not resolve to bundled resource path {asset_path!r}")
        for required in ["sourceFilename", "altText", "fileSizeBytes", "sha256"]:
            if not visual.get(required):
                add_failure("MVP visuals", f"{visual_id} missing required field {required}")

    excluded_ids = {visual.get("id") for visual in visual_manifest.get("excludedVisuals", [])}
    missing_exclusions = sorted(EXPECTED_NOT_BETA_SCOPE_VISUALS - excluded_ids)
    if missing_exclusions:
        add_failure("MVP visuals", f"Not-beta-scope visual IDs are not marked excluded: {missing_exclusions}")
    for visual in visual_manifest.get("excludedVisuals", []):
        if visual.get("id") in EXPECTED_NOT_BETA_SCOPE_VISUALS and visual.get("status") != "not_beta_scope":
            add_failure("MVP visuals", f"{visual.get('id')} should be marked not_beta_scope")
    if EXPECTED_NOT_BETA_SCOPE_VISUALS <= excluded_ids:
        add_warning("MVP visuals", "Not-beta-scope static visual IDs are intentionally excluded from visual asset validation.")

    breathing_pacer = next(
        (visual for visual in visual_manifest.get("excludedVisuals", []) if visual.get("id") == "visual.breathing_pacer"),
        None,
    )
    if not breathing_pacer or breathing_pacer.get("status") != "existing_swiftui_kept":
        add_failure("MVP visuals", "visual.breathing_pacer should be marked existing_swiftui_kept")

    deferred_video_ids = {video.get("id") for video in visual_manifest.get("breathingVideos", [])}
    if deferred_video_ids != EXPECTED_DEFERRED_BREATHING_VIDEO_IDS:
        missing = sorted(EXPECTED_DEFERRED_BREATHING_VIDEO_IDS - deferred_video_ids)
        extra = sorted(deferred_video_ids - EXPECTED_DEFERRED_BREATHING_VIDEO_IDS)
        add_failure("Breathing videos", f"Deferred breathing video IDs mismatch. Missing={missing}; extra={extra}")

    for video in visual_manifest.get("breathingVideos", []):
        video_id = video.get("id", "<missing id>")
        if video.get("status") != "deferred_post_beta":
            add_failure("Breathing videos", f"{video_id} should be marked deferred_post_beta")

    if deferred_video_ids == EXPECTED_DEFERRED_BREATHING_VIDEO_IDS:
        add_warning("Breathing videos", "Breathing videos are listed as deferred_post_beta and are not required for beta runtime.")

    if VIDEO_ASSETS_PATH.exists():
        add_failure("Breathing videos", f"Runtime video registry should not be bundled for beta: {VIDEO_ASSETS_PATH}")

    video_resource_root = APP_RESOURCES / "video"
    if video_resource_root.exists():
        bundled_video_files = [path for path in video_resource_root.rglob("*") if path.is_file()]
        if bundled_video_files:
            add_failure(
                "Breathing videos",
                "Breathing video files should not be bundled for beta: "
                + "; ".join(str(path) for path in bundled_video_files),
            )


def validate_mindfulness_transcripts(transcripts: dict[str, Any], audio_assets: dict[str, Any], module_library: dict[str, Any]) -> None:
    entries = transcripts.get("transcripts", [])
    entries_by_audio_id = {entry.get("audioAssetId"): entry for entry in entries}
    expected_audio_ids = set(EXPECTED_MINDFULNESS_TRANSCRIPTS)

    if set(entries_by_audio_id) != expected_audio_ids:
        missing = sorted(expected_audio_ids - set(entries_by_audio_id))
        extra = sorted(set(entries_by_audio_id) - expected_audio_ids)
        add_failure("Mindfulness transcripts", f"Expected exactly 14 mindfulness transcript mappings. Missing={missing}; extra={extra}")

    audio_asset_ids = {asset.get("id") for asset in audio_assets.get("assets", [])}
    for audio_id, script_id in EXPECTED_MINDFULNESS_TRANSCRIPTS.items():
        entry = entries_by_audio_id.get(audio_id)
        if audio_id not in audio_asset_ids:
            add_failure("Mindfulness transcripts", f"{audio_id} is missing from {AUDIO_ASSETS_PATH}")
        if not entry:
            continue
        if entry.get("sourceScriptId") != script_id:
            add_failure("Mindfulness transcripts", f"{audio_id} should map to {script_id}, found {entry.get('sourceScriptId')}")
        if not str(entry.get("transcriptText", "")).strip():
            add_failure("Mindfulness transcripts", f"{audio_id} has an empty transcriptText")
        expected_display_title = EXPECTED_MINDFULNESS_PRACTICE_DISPLAY_TITLES.get(audio_id)
        if entry.get("displayTitle") != expected_display_title:
            add_failure("Mindfulness transcripts", f"{audio_id} should record displayTitle {expected_display_title!r}, found {entry.get('displayTitle')!r}")
        if not str(entry.get("sourceTitle", "")).strip():
            add_failure("Mindfulness transcripts", f"{audio_id} should preserve a non-empty sourceTitle")
        if entry.get("sourceWorkbook") != "mptinnitus_mindfulness_exercise_scripts_v1.xlsx":
            add_failure("Mindfulness transcripts", f"{audio_id} should record the source workbook")
        if entry.get("sourceSheet") != "Script Manifest":
            add_failure("Mindfulness transcripts", f"{audio_id} should record the source sheet")

    exposed_registry_script_ids = {entry.get("sourceScriptId") for entry in entries}
    exposed_runtime_text = json.dumps(
        {
            "transcripts": entries,
            "moduleAudio": [audio for module in module_library.get("modules", []) for audio in module.get("audio", [])],
        },
        ensure_ascii=False,
    )
    for script_id in EXCLUDED_MINDFULNESS_SCRIPT_IDS:
        if script_id in exposed_registry_script_ids or script_id in exposed_runtime_text:
            add_failure("Mindfulness transcripts", f"Excluded spreadsheet script is exposed: {script_id}")

    module_audio_by_id: dict[str, list[dict[str, Any]]] = {}
    for module in module_library.get("modules", []):
        for audio in module.get("audio", []):
            module_audio_by_id.setdefault(audio.get("audioId"), []).append(audio)

    for audio_id, entry in entries_by_audio_id.items():
        if audio_id not in expected_audio_ids:
            continue
        expected_text = str(entry.get("transcriptText", "")).strip()
        if not expected_text:
            continue
        for audio in module_audio_by_id.get(audio_id, []):
            if str(audio.get("transcript", "")).strip() != expected_text:
                add_failure("Mindfulness transcripts", f"{audio_id} transcript in {MODULE_LIBRARY_PATH} does not match transcript registry")


def validate_active_audio(module_library: dict[str, Any]) -> None:
    for module in module_library.get("modules", []):
        module_id = module.get("moduleId", "<unknown module>")
        for audio in module.get("audio", []):
            audio_id = audio.get("audioId", "<missing audioId>")
            path = audio.get("assetPath", "")
            if not path:
                add_failure("Active audio references", f"{module_id}/{audio_id} has an empty assetPath")
                continue
            if not resource_exists(path):
                add_failure("Active audio references", f"{module_id}/{audio_id} points to missing local asset: {path}")
            if path.endswith(".m4a") and not resource_exists(path):
                add_failure("Active audio references", f"{module_id}/{audio_id} still points to missing .m4a: {path}")


def iter_user_facing_strings(module_library: dict[str, Any]) -> list[tuple[str, str]]:
    strings: list[tuple[str, str]] = []
    for module in module_library.get("modules", []):
        module_id = module.get("moduleId", "<unknown module>")
        for key in ["title", "purpose", "overviewMarkdown"]:
            if module.get(key):
                strings.append((f"{module_id}.{key}", str(module[key])))
        for card in module.get("cards", []):
            card_id = card.get("screenId") or card.get("sectionId") or "<unknown card>"
            for key in ["title", "bodyMarkdown", "safetyNote"]:
                if card.get(key):
                    strings.append((f"{module_id}.card[{card_id}].{key}", str(card[key])))
        for audio in module.get("audio", []):
            audio_id = audio.get("audioId", "<unknown audio>")
            for key in ["title", "transcript"]:
                if audio.get(key):
                    strings.append((f"{module_id}.audio[{audio_id}].{key}", str(audio[key])))
        for exercise in module.get("exercises", []):
            exercise_id = exercise.get("exerciseId", "<unknown exercise>")
            for key in ["title", "description", "inputSummary", "defaultCTAs"]:
                if exercise.get(key):
                    strings.append((f"{module_id}.exercise[{exercise_id}].{key}", str(exercise[key])))
        for safety in module.get("safetyScopes", []):
            safety_id = safety.get("safetyScopeId", "<unknown safety>")
            for key in ["title", "bodyMarkdown"]:
                if safety.get(key):
                    strings.append((f"{module_id}.safety[{safety_id}].{key}", str(safety[key])))
    return strings


def validate_planning_language(module_library: dict[str, Any]) -> None:
    for location, text in iter_user_facing_strings(module_library):
        for term, pattern in PLANNING_PATTERNS:
            if pattern.search(text):
                add_failure("User-facing planning language", f"{location} contains {term!r}: {text[:180]}")


def validate_visual_references(module_library: dict[str, Any]) -> None:
    known_visual_ids: set[str] = set()
    referenced_visual_ids: list[tuple[str, str, str]] = []

    fallback_visual_ids = {
        "VIS-003",
        "VIS-009",
        "VIS-031",
        "VIS-007",
        "VIS-032",
        "VIS-013",
        "VIS-014",
        "VIS-005",
        "VIS-030",
        "VIS-001",
        "VIS-017",
        "VIS-033",
        "VIS-023",
        "VIS-034",
    }

    for module in module_library.get("modules", []):
        module_id = module.get("moduleId", "<unknown module>")
        for visual in module.get("visuals", []):
            if visual.get("visualId"):
                known_visual_ids.add(visual["visualId"])
        for card in module.get("cards", []):
            card_id = card.get("screenId") or card.get("sectionId") or "<unknown card>"
            for visual_id in card.get("visualIds", []):
                referenced_visual_ids.append((module_id, card_id, visual_id))

    known_or_fallback = known_visual_ids | fallback_visual_ids
    for module_id, card_id, visual_id in referenced_visual_ids:
        if visual_id not in known_or_fallback:
            add_failure("Visual references", f"{module_id}/{card_id} references unknown visual ID {visual_id}")

    sound_therapy_stand_ins = {"VIS-002", "VIS-004"}
    exposed_stand_ins = [
        f"{module_id}/{card_id}/{visual_id}"
        for module_id, card_id, visual_id in referenced_visual_ids
        if module_id == "sound_therapy" and visual_id in sound_therapy_stand_ins
    ]
    if exposed_stand_ins:
        add_failure(
            "Visual references",
            "Sound Therapy beta should not expose incomplete secondary visual stand-ins: "
            + "; ".join(exposed_stand_ins),
        )


def validate_about_tinnitus_beta(module_library: dict[str, Any], exercise_definitions: dict[str, Any], visual_manifest: dict[str, Any]) -> None:
    about_module = next(
        (module for module in module_library.get("modules", []) if module.get("moduleId") == "about_tinnitus"),
        None,
    )
    if not about_module:
        add_failure("About Tinnitus beta fixes", "About Tinnitus module is missing from module library.")
        return

    bml_visual_path = APP_RESOURCES / "visuals/body_mind_life_model.png"
    if not bml_visual_path.exists():
        add_failure("About Tinnitus beta fixes", f"Body / Mind / Life visual file is missing: {bml_visual_path}")

    bml_manifest_entry = next(
        (visual for visual in visual_manifest.get("staticVisuals", []) if visual.get("id") == "visual.body_mind_life_model"),
        None,
    )
    if not bml_manifest_entry:
        add_failure("About Tinnitus beta fixes", "visual.body_mind_life_model is missing from the visual asset manifest.")
    elif bml_manifest_entry.get("assetPath") != "visuals/body_mind_life_model.png":
        add_failure(
            "About Tinnitus beta fixes",
            f"visual.body_mind_life_model should use visuals/body_mind_life_model.png, found {bml_manifest_entry.get('assetPath')!r}",
        )

    cards_with_bml_visual = [
        (card.get("sectionId"), card.get("screenId"), card.get("title"))
        for card in about_module.get("cards", [])
        if ABOUT_BML_VISUAL_ID in card.get("visualIds", [])
    ]
    expected_bml_card = [(ABOUT_BML_VISUAL_CARD, "AT-002-BEYOND", "Why go beyond the sound?")]
    if cards_with_bml_visual != expected_bml_card:
        add_failure(
            "About Tinnitus beta fixes",
            f"{ABOUT_BML_VISUAL_ID} should appear only on {ABOUT_BML_VISUAL_CARD}; found {cards_with_bml_visual}",
        )

    bml_visual_entries = [
        visual for visual in about_module.get("visuals", []) if visual.get("visualId") == ABOUT_BML_VISUAL_ID
    ]
    if len(bml_visual_entries) != 1:
        add_failure("About Tinnitus beta fixes", f"Expected exactly one About Tinnitus {ABOUT_BML_VISUAL_ID} visual entry, found {len(bml_visual_entries)}.")
    elif bml_visual_entries[0].get("screenId") != ABOUT_BML_VISUAL_SCREEN:
        add_failure(
            "About Tinnitus beta fixes",
            f"{ABOUT_BML_VISUAL_ID} should route through screenId {ABOUT_BML_VISUAL_SCREEN}, found {bml_visual_entries[0].get('screenId')!r}.",
        )

    about_exercises = {exercise.get("exerciseId"): exercise for exercise in about_module.get("exercises", [])}
    pause_manifest = about_exercises.get(ABOUT_PAUSE_REFLECT_EXERCISE_ID)
    if not pause_manifest:
        add_failure("About Tinnitus beta fixes", f"About Tinnitus is missing exercise {ABOUT_PAUSE_REFLECT_EXERCISE_ID}.")
    else:
        expected_manifest_values = {
            "screenId": "AT-010",
            "title": "Pause & Reflect",
            "inputSummary": "Body, Mind, Life, and Support reflection fields",
        }
        for key, expected in expected_manifest_values.items():
            if pause_manifest.get(key) != expected:
                add_failure(
                    "About Tinnitus beta fixes",
                    f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID} manifest {key} should be {expected!r}, found {pause_manifest.get(key)!r}.",
                )

    definitions_by_id = {
        definition.get("exerciseId"): definition
        for definition in exercise_definitions.get("definitions", [])
    }
    pause_definition = definitions_by_id.get(ABOUT_PAUSE_REFLECT_EXERCISE_ID)
    if not pause_definition:
        add_failure("About Tinnitus beta fixes", f"Exercise definition {ABOUT_PAUSE_REFLECT_EXERCISE_ID} is missing.")
    else:
        if pause_definition.get("moduleId") != "about_tinnitus":
            add_failure("About Tinnitus beta fixes", f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID} should belong to about_tinnitus.")
        if pause_definition.get("screenId") != "AT-010":
            add_failure("About Tinnitus beta fixes", f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID} should use screenId AT-010.")
        if pause_definition.get("title") != "Pause & Reflect":
            add_failure("About Tinnitus beta fixes", f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID} should be titled Pause & Reflect.")

        save_rule = pause_definition.get("saveRule", {})
        if save_rule.get("mode") != "anyOf":
            add_failure("About Tinnitus beta fixes", f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID} should use an anyOf save rule.")
        if set(save_rule.get("fieldIds", [])) != set(ABOUT_PAUSE_REFLECT_FIELDS):
            add_failure(
                "About Tinnitus beta fixes",
                f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID} save fields should be {sorted(ABOUT_PAUSE_REFLECT_FIELDS)}, found {save_rule.get('fieldIds', [])}.",
            )

        fields_by_id = {
            field.get("fieldId"): field
            for field in pause_definition.get("fields", [])
        }
        for field_id, expected_prompt in ABOUT_PAUSE_REFLECT_FIELDS.items():
            field = fields_by_id.get(field_id)
            if not field:
                add_failure("About Tinnitus beta fixes", f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID} is missing field {field_id}.")
                continue
            if field.get("type") != "longText":
                add_failure("About Tinnitus beta fixes", f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID}/{field_id} should be a longText field.")
            if field.get("prompt") != expected_prompt:
                add_failure(
                    "About Tinnitus beta fixes",
                    f"{ABOUT_PAUSE_REFLECT_EXERCISE_ID}/{field_id} prompt should be {expected_prompt!r}, found {field.get('prompt')!r}.",
                )

    renderer_path = APP_ROOT / "Features/Modules/ModuleOverviewScreen.swift"
    renderer_text = renderer_path.read_text()
    required_renderer_snippets = [
        "private var inlineExerciseIDs: Set<String>",
        "\"about_tinnitus\"",
        "\"I-002\"",
        "card.sectionId == \"AT-010-PAUSE-section\"",
        "ExerciseLaunchCard(exercise: inlineExercise, module: module)",
        "&& !inlineExerciseIDs.contains(exercise.exerciseId)",
    ]
    for snippet in required_renderer_snippets:
        if snippet not in renderer_text:
            add_failure("About Tinnitus beta fixes", f"Module renderer is missing inline Pause & Reflect support snippet: {snippet}")


def validate_sound_therapy_beta_visuals_and_labels(module_library: dict[str, Any], exercise_definitions: dict[str, Any], visual_manifest: dict[str, Any]) -> None:
    sound_module = next(
        (module for module in module_library.get("modules", []) if module.get("moduleId") == "sound_therapy"),
        None,
    )
    if not sound_module:
        add_failure("Sound Therapy beta visual cleanup", "Sound Therapy module is missing from module library.")
        return

    thermometer_asset_path = APP_RESOURCES / "visuals/sound_therapy_thermometer.png"
    if not thermometer_asset_path.exists():
        add_failure("Sound Therapy beta visual cleanup", f"Sound Therapy Thermometer visual file is missing: {thermometer_asset_path}")

    thermometer_manifest_entry = next(
        (visual for visual in visual_manifest.get("staticVisuals", []) if visual.get("id") == "visual.sound_therapy_thermometer"),
        None,
    )
    if not thermometer_manifest_entry:
        add_failure("Sound Therapy beta visual cleanup", "visual.sound_therapy_thermometer is missing from the visual asset manifest.")
    else:
        if thermometer_manifest_entry.get("status") != "integrated_mvp":
            add_failure("Sound Therapy beta visual cleanup", "visual.sound_therapy_thermometer should remain integrated_mvp.")
        if thermometer_manifest_entry.get("assetPath") != "visuals/sound_therapy_thermometer.png":
            add_failure(
                "Sound Therapy beta visual cleanup",
                f"visual.sound_therapy_thermometer should use visuals/sound_therapy_thermometer.png, found {thermometer_manifest_entry.get('assetPath')!r}",
            )
        placement_note = str(thermometer_manifest_entry.get("placementNote", ""))
        if "link to the Sound Therapy Player" not in placement_note:
            add_failure("Sound Therapy beta visual cleanup", "visual.sound_therapy_thermometer should document that later reminders link to the Sound Therapy Player.")

    cards_with_thermometer = [
        (card.get("sectionId"), card.get("title"))
        for card in sound_module.get("cards", [])
        if SOUND_THERAPY_THERMOMETER_VISUAL_ID in card.get("visualIds", [])
    ]
    expected_placement = [(SOUND_THERAPY_THERMOMETER_CARD, "Finding the sound therapy sweet spot")]
    if cards_with_thermometer != expected_placement:
        add_failure(
            "Sound Therapy beta visual cleanup",
            f"{SOUND_THERAPY_THERMOMETER_VISUAL_ID} should appear only on {SOUND_THERAPY_THERMOMETER_CARD}; found {cards_with_thermometer}",
        )

    sound_visual = next(
        (visual for visual in sound_module.get("visuals", []) if visual.get("visualId") == SOUND_THERAPY_THERMOMETER_VISUAL_ID),
        None,
    )
    if not sound_visual:
        add_failure("Sound Therapy beta visual cleanup", f"{SOUND_THERAPY_THERMOMETER_VISUAL_ID} is missing from Sound Therapy visuals.")
    elif sound_visual.get("title") != "Sound Therapy Thermometer":
        add_failure("Sound Therapy beta visual cleanup", f"{SOUND_THERAPY_THERMOMETER_VISUAL_ID} should remain titled Sound Therapy Thermometer.")

    renderer_path = APP_ROOT / "Features/Modules/ModuleOverviewScreen.swift"
    renderer_text = renderer_path.read_text()
    for card_id in sorted(SOUND_THERAPY_PLAYER_LINK_CARDS):
        if f'"{card_id}"' not in renderer_text:
            add_failure("Sound Therapy beta visual cleanup", f"Module renderer should attach a Sound Therapy Player link to {card_id}.")

    expandable_card_path = APP_ROOT / "Features/Modules/Components/ExpandableContentCard.swift"
    expandable_card_text = expandable_card_path.read_text()
    if "Open Sound Therapy Player" not in expandable_card_text or "AppRoute.soundTherapyPlayer" not in expandable_card_text:
        add_failure("Sound Therapy beta visual cleanup", "ExpandableContentCard should render an inline Sound Therapy Player link card.")

    route_text = (APP_ROOT / "Core/AppRoute.swift").read_text()
    destination_text = (APP_ROOT / "App/AppRouteDestinationView.swift").read_text()
    if "case soundTherapyPlayer" not in route_text or "AppTab.soundAnnex.route" not in route_text:
        add_failure("Sound Therapy beta visual cleanup", "AppRoute should expose the existing Sound Therapy Player route.")
    if "SoundTherapyAnnexView(" not in destination_text or "soundSampleController" not in destination_text:
        add_failure("Sound Therapy beta visual cleanup", "Sound Therapy Player route should use the shared SoundSampleController.")

    sound_exercises = {exercise.get("exerciseId"): exercise for exercise in sound_module.get("exercises", [])}
    sound_sensitivity_manifest = sound_exercises.get(SOUND_SENSITIVITY_EXERCISE_ID)
    if not sound_sensitivity_manifest:
        add_failure("Sound Therapy beta visual cleanup", f"Sound Therapy is missing exercise {SOUND_SENSITIVITY_EXERCISE_ID}.")
    elif sound_sensitivity_manifest.get("title") != "Sound Sensitivity Exercise":
        add_failure("Sound Therapy beta visual cleanup", f"{SOUND_SENSITIVITY_EXERCISE_ID} manifest title should be Sound Sensitivity Exercise.")

    definitions_by_id = {
        definition.get("exerciseId"): definition
        for definition in exercise_definitions.get("definitions", [])
    }
    sound_sensitivity_definition = definitions_by_id.get(SOUND_SENSITIVITY_EXERCISE_ID)
    if not sound_sensitivity_definition:
        add_failure("Sound Therapy beta visual cleanup", f"Exercise definition {SOUND_SENSITIVITY_EXERCISE_ID} is missing.")
    elif sound_sensitivity_definition.get("title") != "Sound Sensitivity Exercise":
        add_failure("Sound Therapy beta visual cleanup", f"{SOUND_SENSITIVITY_EXERCISE_ID} definition title should be Sound Sensitivity Exercise.")

    if "Sound Sensitivity Exercise" not in (APP_ROOT / "Features/SoundTherapy/SoundTherapyAnnexView.swift").read_text():
        add_failure("Sound Therapy beta visual cleanup", "Sound Therapy Player related tools should link to Sound Sensitivity Exercise.")

    searchable_paths = [
        path
        for path in APP_ROOT.rglob("*")
        if path.is_file() and path.suffix in {".swift", ".json"}
    ]
    for path in searchable_paths:
        text = path.read_text(errors="ignore")
        for old_title in OLD_SOUND_SENSITIVITY_TITLES:
            if old_title in text:
                add_failure("Sound Therapy beta visual cleanup", f"Old user-facing exercise title remains in {path}: {old_title!r}")


def validate_self_compassion_visual_deduplication(module_library: dict[str, Any], visual_manifest: dict[str, Any]) -> None:
    confidence_module = next(
        (module for module in module_library.get("modules", []) if module.get("moduleId") == "confidence_communication"),
        None,
    )
    if not confidence_module:
        add_failure("Self-compassion visual", "Confidence and Communication module is missing from module library.")
        return

    manifest_entry = next(
        (visual for visual in visual_manifest.get("staticVisuals", []) if visual.get("id") == "visual.self_compassion_response_card"),
        None,
    )
    if not manifest_entry:
        add_failure("Self-compassion visual", "visual.self_compassion_response_card is missing from the visual asset manifest.")
    else:
        if manifest_entry.get("status") != "integrated_mvp":
            add_failure("Self-compassion visual", "visual.self_compassion_response_card should remain integrated_mvp.")
        if manifest_entry.get("assetPath") != "visuals/self_compassion_response_card.png":
            add_failure(
                "Self-compassion visual",
                f"visual.self_compassion_response_card should use visuals/self_compassion_response_card.png, found {manifest_entry.get('assetPath')!r}",
            )
        placement_note = str(manifest_entry.get("placementNote", ""))
        if SELF_COMPASSION_RETAINED_CARD_TITLE not in placement_note:
            add_failure(
                "Self-compassion visual",
                f"visual.self_compassion_response_card should document its retained placement in {SELF_COMPASSION_RETAINED_CARD_TITLE!r}.",
            )

    module_visual = next(
        (visual for visual in confidence_module.get("visuals", []) if visual.get("visualId") == SELF_COMPASSION_VISUAL_ID),
        None,
    )
    if not module_visual:
        add_failure("Self-compassion visual", f"{SELF_COMPASSION_VISUAL_ID} is missing from Confidence and Communication visuals.")

    cards_with_visual = [
        (card.get("sectionId"), card.get("title"))
        for card in confidence_module.get("cards", [])
        if SELF_COMPASSION_VISUAL_ID in card.get("visualIds", [])
    ]
    expected_cards = [(SELF_COMPASSION_RETAINED_CARD_ID, SELF_COMPASSION_RETAINED_CARD_TITLE)]
    if cards_with_visual != expected_cards:
        add_failure(
            "Self-compassion visual",
            f"{SELF_COMPASSION_VISUAL_ID} should appear only on {SELF_COMPASSION_RETAINED_CARD_ID}; found {cards_with_visual}",
        )

    cards_by_id = {
        card.get("sectionId"): card
        for card in confidence_module.get("cards", [])
    }
    for card_id in sorted(SELF_COMPASSION_DUPLICATE_CARD_IDS):
        card = cards_by_id.get(card_id)
        if not card:
            add_failure("Self-compassion visual", f"Expected Confidence and Communication card is missing: {card_id}")
            continue
        if SELF_COMPASSION_VISUAL_ID in card.get("visualIds", []):
            add_failure("Self-compassion visual", f"Duplicate self-compassion visual remains on {card_id}: {card.get('title')}")
        if not str(card.get("bodyMarkdown", "")).strip():
            add_failure("Self-compassion visual", f"{card_id} should still retain body text after visual deduplication.")


def validate_exercise_references(module_library: dict[str, Any], exercise_definitions: dict[str, Any]) -> None:
    implemented = {definition.get("exerciseId") for definition in exercise_definitions.get("definitions", [])}
    unsupported: list[str] = []
    for module in module_library.get("modules", []):
        module_id = module.get("moduleId", "<unknown module>")
        for exercise in module.get("exercises", []):
            exercise_id = exercise.get("exerciseId")
            if exercise_id not in implemented:
                unsupported.append(f"{module_id}/{exercise_id} {exercise.get('title', '')}".strip())

    if unsupported:
        add_warning("Exercise references", "Unsupported exercise refs are expected to be hidden by ModuleOverviewScreen. Review if UI changes: " + "; ".join(unsupported))

    renderer_path = APP_ROOT / "Features/Modules/ModuleOverviewScreen.swift"
    renderer_text = renderer_path.read_text()
    if "exerciseDefinitionLibrary.definition(id: exercise.exerciseId) != nil" not in renderer_text:
        add_failure("Exercise references", f"Unsupported exercise refs may not be filtered in {renderer_path}")


def validate_duplicate_flattened_resource_names() -> None:
    media_files = [path for path in APP_RESOURCES.rglob("*") if path.is_file() and path.suffix.lower() in MEDIA_EXTENSIONS]
    counts = Counter(path.name for path in media_files)
    duplicates = sorted(name for name, count in counts.items() if count > 1)
    for name in duplicates:
        paths = [str(path) for path in media_files if path.name == name]
        add_failure("Duplicate flattened resource filenames", f"{name} appears more than once and may collide in bundle lookup: {paths}")


def validate_prohibited_source_terms() -> None:
    swift_and_resources = [
        path
        for path in APP_ROOT.rglob("*")
        if path.is_file() and path.suffix in {".swift", ".json", ".plist", ".entitlements", ".xcprivacy"}
    ]
    for path in swift_and_resources:
        text = path.read_text(errors="ignore")
        for term in PROHIBITED_SOURCE_TERMS:
            if term in text:
                add_failure("Prohibited app source/API terms", f"{path} contains {term!r}")


def validate_app_icon() -> None:
    contents = load_json(APP_ICON_CONTENTS_PATH)
    if not isinstance(contents, dict):
        return

    images = contents.get("images", [])
    if not images:
        add_failure("App icon", f"No AppIcon entries found in {APP_ICON_CONTENTS_PATH}")
        return

    missing_filename_entries = []
    missing_files = []
    for index, image in enumerate(images):
        filename = image.get("filename")
        if not filename:
            missing_filename_entries.append(str(index))
            continue
        icon_path = APP_ICON_CONTENTS_PATH.parent / filename
        if not icon_path.exists():
            missing_files.append(str(icon_path))

    if missing_filename_entries:
        add_failure("App icon", f"AppIcon entries without filename in {APP_ICON_CONTENTS_PATH}: {', '.join(missing_filename_entries)}")
    for path in missing_files:
        add_failure("App icon", f"AppIcon referenced file is missing: {path}")


def validate_source_archive_cleanliness() -> None:
    bad_inside_resources = []
    for path in APP_RESOURCES.rglob("*"):
        if not path.is_file():
            continue
        if (
            path.name == ".DS_Store"
            or path.name.startswith("._")
            or path.suffix.lower() == ".zip"
            or "__MACOSX" in path.parts
        ):
            bad_inside_resources.append(path)
    for path in bad_inside_resources:
        add_failure("Source/archive cleanliness", f"Archive/system file is inside app resources: {path}")

    try:
        status = subprocess.run(
            ["git", "status", "--short", "--ignored", "--", "*.zip", ".DS_Store"],
            cwd=ROOT,
            check=False,
            capture_output=True,
            text=True,
        ).stdout.splitlines()
    except OSError:
        status = []
    tracked_or_dirty_archives = [line for line in status if line and not line.startswith("!! ")]
    for line in tracked_or_dirty_archives:
        add_warning("Source/archive cleanliness", f"Review git status for archive/system file: {line}")


def main() -> int:
    module_library = load_json(MODULE_LIBRARY_PATH)
    asset_placeholders = load_json(ASSET_PLACEHOLDERS_PATH)
    audio_assets = load_json(AUDIO_ASSETS_PATH)
    mindfulness_transcripts = load_json(MINDFULNESS_TRANSCRIPTS_PATH)
    visual_manifest = load_json(VISUAL_ASSET_MANIFEST_PATH)
    exercise_definitions = load_json(EXERCISE_DEFINITIONS_PATH)

    if not all(isinstance(doc, dict) for doc in [module_library, asset_placeholders, audio_assets, mindfulness_transcripts, visual_manifest, exercise_definitions]):
        print_results()
        return 1

    validate_mvp_audio(audio_assets, asset_placeholders, module_library)
    validate_sound_therapy_player(asset_placeholders)
    validate_sound_sample_foreground_continuity()
    validate_tinnitus_sound_estimate_feature(asset_placeholders)
    validate_stage_24b_release_ui_cleanup()
    validate_mindfulness_practice_ui(module_library, exercise_definitions)
    validate_stage_23k_copy_cleanup(module_library, exercise_definitions)
    validate_mvp_visuals_and_deferred_videos(visual_manifest)
    validate_mindfulness_transcripts(mindfulness_transcripts, audio_assets, module_library)
    validate_active_audio(module_library)
    validate_planning_language(module_library)
    validate_visual_references(module_library)
    validate_about_tinnitus_beta(module_library, exercise_definitions, visual_manifest)
    validate_sound_therapy_beta_visuals_and_labels(module_library, exercise_definitions, visual_manifest)
    validate_self_compassion_visual_deduplication(module_library, visual_manifest)
    validate_exercise_references(module_library, exercise_definitions)
    validate_duplicate_flattened_resource_names()
    validate_prohibited_source_terms()
    validate_app_icon()
    validate_source_archive_cleanliness()

    print_results()
    return 1 if failures else 0


def print_results() -> None:
    if failures:
        print("Beta readiness validation FAILED.")
        for category, messages in failures.items():
            print(f"\n[{category}]")
            for message in messages:
                print(f"- {message}")
    else:
        print("PASS: Beta readiness validation passed.")

    if warnings:
        print("\nWarnings:")
        for category, messages in warnings.items():
            print(f"\n[{category}]")
            for message in messages:
                print(f"- {message}")


if __name__ == "__main__":
    sys.exit(main())
