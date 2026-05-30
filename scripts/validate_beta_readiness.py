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

EXPECTED_NOT_BETA_SCOPE_VISUALS = {
    "visual.breathing_pacer",
    "visual.stop_card",
    "visual.tipp_card",
    "visual.sleep_tinnitus_loop",
    "visual.sound_sensitivity_music_steps",
    "visual.dear_man_card",
}

EXPECTED_BREATHING_VIDEOS = {
    "video.breathing.4_2_4.loop": "breathing_4_2_4_loop.mp4",
    "video.breathing.4_4.loop": "breathing_4_4_loop.mp4",
    "video.breathing.4_6.loop": "breathing_4_6_loop.mp4",
    "video.breathing.4_2_6.loop": "breathing_4_2_6_loop.mp4",
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


def validate_mvp_visuals_and_videos(visual_manifest: dict[str, Any], video_assets: dict[str, Any]) -> None:
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
        if visual.get("status") != "available":
            add_failure("MVP visuals", f"{visual_id} should have status available")
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

    video_entries = video_assets.get("videos", [])
    video_ids = {video.get("id") for video in video_entries}
    if video_ids != set(EXPECTED_BREATHING_VIDEOS):
        missing = sorted(set(EXPECTED_BREATHING_VIDEOS) - video_ids)
        extra = sorted(video_ids - set(EXPECTED_BREATHING_VIDEOS))
        add_failure("Breathing videos", f"Breathing video IDs mismatch. Missing={missing}; extra={extra}")

    video_folder = APP_RESOURCES / "video/breathing"
    expected_video_files = set(EXPECTED_BREATHING_VIDEOS.values())
    actual_video_files = {path.name for path in video_folder.glob("*.mp4")} if video_folder.exists() else set()
    if actual_video_files != expected_video_files:
        missing = sorted(expected_video_files - actual_video_files)
        extra = sorted(actual_video_files - expected_video_files)
        add_failure("Breathing videos", f"Expected exactly four breathing MP4s in {video_folder}. Missing={missing}; extra={extra}")

    for video in video_entries:
        video_id = video.get("id", "<missing id>")
        expected_filename = EXPECTED_BREATHING_VIDEOS.get(video_id)
        if expected_filename is None:
            continue
        asset_path = video.get("assetPath", "")
        if video.get("filename") != expected_filename:
            add_failure("Breathing videos", f"{video_id} filename should be {expected_filename}")
        if asset_path != f"video/breathing/{expected_filename}":
            add_failure("Breathing videos", f"{video_id} assetPath should be video/breathing/{expected_filename}, found {asset_path!r}")
        if not resource_exists(asset_path):
            add_failure("Breathing videos", f"{video_id} does not resolve to bundled resource path {asset_path!r}")
        if video.get("category") != "mindfulness_breathing":
            add_failure("Breathing videos", f"{video_id} should use category mindfulness_breathing")
        if video.get("loopCapable") is not True:
            add_failure("Breathing videos", f"{video_id} should be loop-capable")
        if video.get("playbackMode") != "loop_until_exit":
            add_failure("Breathing videos", f"{video_id} should use playbackMode loop_until_exit")
        if video.get("mutedByDefault") is not True:
            add_failure("Breathing videos", f"{video_id} should be muted by default")
        if video.get("reducedMotionFallback") != "swiftui_breathing_pacer":
            add_failure("Breathing videos", f"{video_id} should use the SwiftUI breathing pacer reduced-motion fallback")
        for required in ["title", "description", "sourceFilename", "sourceZip", "fileSizeBytes", "sha256", "durationSeconds"]:
            if not video.get(required):
                add_failure("Breathing videos", f"{video_id} missing required field {required}")
        if ".zip" in asset_path or "http://" in asset_path or "https://" in asset_path:
            add_failure("Breathing videos", f"{video_id} points to an invalid runtime path: {asset_path}")


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
    video_assets = load_json(VIDEO_ASSETS_PATH)
    visual_manifest = load_json(VISUAL_ASSET_MANIFEST_PATH)
    exercise_definitions = load_json(EXERCISE_DEFINITIONS_PATH)

    if not all(isinstance(doc, dict) for doc in [module_library, asset_placeholders, audio_assets, video_assets, visual_manifest, exercise_definitions]):
        print_results()
        return 1

    validate_mvp_audio(audio_assets, asset_placeholders, module_library)
    validate_mvp_visuals_and_videos(visual_manifest, video_assets)
    validate_active_audio(module_library)
    validate_planning_language(module_library)
    validate_visual_references(module_library)
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
