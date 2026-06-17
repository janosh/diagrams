import os
import re
import unicodedata
from collections import Counter
from difflib import SequenceMatcher
from glob import glob
from typing import Final

import yaml

# Special exceptions where folder name doesn't need to match param-cased title
IGNORE_SET: Final[set[str]] = {
    "harmonic-oscillator-energy-vs-freq",
    "harmonic-oscillator-energy-vs-inv-temp",
    "qm-cost-vs-acc",
    "pie-physics-chemistry-ml",
}

# Mapping of abbreviations to their expansions
EXPANSIONS: Final[dict[str, str]] = {
    "+": "plus",
    "thermo": "thermodynamic",
    "distro": "distribution",
    "trafos": "transforms",
}


def load_yaml(yaml_file: str) -> dict:
    """Parse a YAML file into a dict, annotating any error with the file path."""
    try:
        with open(yaml_file) as file:
            return yaml.safe_load(file) or {}
    except Exception as exc:
        exc.add_note(f"{yaml_file=}")
        raise


def expand_folder_name(name: str) -> set[str]:
    """Generate all possible expansions of a folder name."""
    result = {name}
    for abbrev, expansion in EXPANSIONS.items():
        for current in result.copy():
            if abbrev in current:
                result.add(current.replace(abbrev, expansion))
    return result


def _greek_to_latin() -> dict[int, str]:
    """Map Greek letters (lower + upper) to Latin names, e.g. θ -> theta."""
    mapping: dict[int, str] = {}
    for code in range(0x03B1, 0x03CA):  # Greek lowercase letters α-ω
        char = chr(code)
        # last word handles multi-word names like "FINAL SIGMA" (ς) -> "sigma"
        words = unicodedata.name(char).removeprefix("GREEK SMALL LETTER ").split()
        latin = words[-1].lower()
        mapping[code] = latin
        mapping[ord(char.upper())] = latin.title()
    return mapping


GREEK_TO_LATIN: Final[dict[int, str]] = _greek_to_latin()


def to_param_case(text: str) -> str:
    """Convert a string to param-case (kebab-case)."""
    # transliterate Greek, then keep only alnum/hyphen/plus, collapse and trim hyphens
    text = text.replace(" ", "-").replace("_", "-").translate(GREEK_TO_LATIN)
    text = "".join(char.lower() for char in text if char.isalnum() or char in "-+")
    return re.sub(r"-{2,}", "-", text).strip("-")


def find_similar_tags(
    tags: list[str], threshold: float = 0.85
) -> list[tuple[str, str, float]]:
    """Find pairs of tags that are very similar to each other."""
    pairs = [
        (tag1, tag2, ratio)
        for idx, tag1 in enumerate(tags)
        for tag2 in tags[idx + 1 :]
        if (ratio := SequenceMatcher(None, tag1, tag2).ratio()) >= threshold
    ]
    return sorted(pairs, key=lambda pair: pair[2], reverse=True)


def report_similar_tags(yaml_files: list[str]) -> None:
    """Find minor variations of tags and suggest renaming them for cross-file consistency."""
    tag_counts: Counter[str] = Counter()

    print("\nAnalyzing tags across YAML files...")
    print(f"Found {len(yaml_files)} YAML files")

    for yaml_file in yaml_files:
        tags = load_yaml(yaml_file).get("tags")
        if isinstance(tags, list):
            tag_counts.update(tags)

    # Print tag statistics
    n_tags_to_print = 20
    print(f"\nTop {n_tags_to_print} tags by usage:")
    print("-" * 40)
    for tag, count in sorted(tag_counts.items(), key=lambda x: (-x[1], x[0]))[
        :n_tags_to_print
    ]:
        print(f"{tag:25} {count:5d}")

    # Find similar tags
    all_tags = list(tag_counts)
    similar_tags = find_similar_tags(all_tags)

    if similar_tags:
        print("\nPotentially similar tags:")
        print("-" * 40)
        for tag1, tag2, similarity in similar_tags:
            print(
                f"{tag1:25} {tag_counts[tag1]:<3d} ↔ "
                f"{tag2:25} {tag_counts[tag2]:<3d} "
                f"({similarity:.3f})"
            )


def check_yaml_titles(yaml_files: list[str]) -> int:
    errors: dict[str, str] = {}

    for yaml_file in yaml_files:
        file_name = os.path.basename(yaml_file).split(".")[0]
        if file_name in IGNORE_SET:
            continue

        data = load_yaml(yaml_file)
        if "title" not in data:
            errors[yaml_file] = "Missing title"
            continue

        title = data["title"]
        param_title = to_param_case(title)

        # pass if any folder-name expansion matches an expansion of the param-cased title
        if not (expand_folder_name(file_name) & expand_folder_name(param_title)):
            errors[yaml_file] = (
                f"should match YAML {title=} after param-casing: {param_title!r}"
            )

    for idx, (yaml_file, error) in enumerate(errors.items()):
        print(f"{idx + 1}/{len(errors)} {yaml_file}\n  {error}")

    return len(errors)


def remove_duplicate_tags(yaml_files: list[str]) -> list[str]:
    """Remove duplicate tags from all YAML files."""

    files_changed: list[str] = []

    print("\nChecking for duplicate tags...")

    for yaml_file in yaml_files:
        try:
            # Read file content to preserve comments
            with open(yaml_file) as file:
                content = file.read()
                data = yaml.safe_load(content)

            if not data or "tags" not in data or not isinstance(data["tags"], list):
                continue

            # Get unique tags while preserving order
            original_tags = data["tags"]
            unique_tags = list(dict.fromkeys(original_tags))

            # Check if there were any duplicates
            if len(unique_tags) < len(original_tags):
                files_changed.append(yaml_file)
                removed_count = len(original_tags) - len(unique_tags)
                duplicates = [
                    tag for tag in original_tags if original_tags.count(tag) > 1
                ]
                print(f"\n{yaml_file}:")
                print(
                    f"  Removed {removed_count} duplicate tags: {', '.join(set(duplicates))}"
                )

                # Replace tags section while preserving rest of file
                tag_section = "tags:\n" + "".join(f"  - {tag}\n" for tag in unique_tags)
                tag_pattern = r"tags:\n(?:  - .*\n)+"
                new_content = re.sub(tag_pattern, tag_section, content)

                # Write back preserving original format
                with open(yaml_file, "w") as file:
                    file.write(new_content)

        except Exception as exc:
            exc.add_note(f"{yaml_file=}")
            raise

    if not files_changed:
        print("No duplicate tags found.")
    else:
        print(f"\nRemoved duplicates from {len(files_changed)} files.")

    return files_changed


def check_missing_descriptions(yaml_files: list[str]) -> list[str]:
    """Find and print all YAML files with missing descriptions."""

    missing_desc: list[str] = []

    for yaml_file in yaml_files:
        data = load_yaml(yaml_file)
        if data and data.get("description") is None:
            missing_desc.append(yaml_file)

    if missing_desc:
        print(f"\n {len(missing_desc)} files with missing descriptions:")
        print("-" * 40)
        for file in missing_desc:
            print(file)
    else:
        print("\nNo files with missing descriptions found.")

    return missing_desc


if __name__ == "__main__":
    yaml_files = glob("./assets/**/*.yml")
    errors = check_yaml_titles(yaml_files)
    report_similar_tags(yaml_files)
    remove_duplicate_tags(yaml_files)
    missing = check_missing_descriptions(yaml_files)
    # TODO remove missing allowance once all diagrams have descriptions
    raise_missing = len(missing) > 10
    raise SystemExit(errors or raise_missing)  # Exit with error if any checks fail
