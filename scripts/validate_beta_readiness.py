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
EXERCISE_DEFINITIONS_PATH = APP_RESOURCES / "exercise_definitions_v1.json"
APP_ICON_CONTENTS_PATH = APP_ROOT / "Assets.xcassets/AppIcon.appiconset/Contents.json"

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
        if path.name == ".DS_Store" or path.suffix.lower() == ".zip" or "__MACOSX" in path.parts:
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
    exercise_definitions = load_json(EXERCISE_DEFINITIONS_PATH)

    if not all(isinstance(doc, dict) for doc in [module_library, asset_placeholders, audio_assets, exercise_definitions]):
        print_results()
        return 1

    validate_mvp_audio(audio_assets, asset_placeholders, module_library)
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
