import os
import re
import unicodedata
from collections import Counter
from datetime import date
from difflib import SequenceMatcher
from glob import glob
from itertools import combinations
from typing import Final

import yaml

# Special exceptions where folder name doesn't need to match param-cased title
IGNORE_SET: Final[set[str]] = {
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


def load_yaml(yaml_file: str) -> dict[str, object]:
    """Parse a YAML file into a dict, annotating any error with the file path."""
    try:
        with open(yaml_file) as file:
            data = yaml.safe_load(file)
        if not isinstance(data, dict):
            raise ValueError("Expected a metadata mapping")
        validate_metadata(data)
        return data
    except Exception as exc:
        exc.add_note(f"{yaml_file=}")
        raise


def is_text(value: object) -> bool:
    """Recognize nonempty text, including rejection of whitespace-only strings."""
    return isinstance(value, str) and bool(value.strip())


def validate_metadata(data: dict[str, object]) -> None:
    """Validate gallery fields while retaining structured provenance and date precision."""
    strings = {
        "title",
        "description",
        "creator",
        "creator_url",
        "url",
        "source",
        "citation",
    }
    string_lists = {"tags", "authors"}
    flags = {"hide", "preserve_colors"}
    allowed = strings | string_lists | flags | {"date", "references", "attribution"}
    if unknown := data.keys() - allowed:
        raise ValueError(f"Unknown metadata fields: {sorted(map(str, unknown))}")
    if missing := {"title", "description", "tags"} - data.keys():
        raise ValueError(f"Missing metadata fields: {sorted(missing)}")
    for key, value in data.items():
        if key in strings:
            if not is_text(value):
                raise ValueError(f"{key}: expected a nonempty string, got {value!r}")
        elif key in string_lists:
            if not isinstance(value, list) or not value or not all(map(is_text, value)):
                raise ValueError(
                    f"{key}: expected a nonempty list of nonempty strings, got {value!r}"
                )
            if len(value) != len(set(value)):
                raise ValueError(f"{key}: duplicate entries in {value!r}")
        elif key in flags:
            if type(value) is not bool:
                raise ValueError(f"{key}: expected a boolean, got {value!r}")
        elif key == "date":
            # Month precision is meaningful; do not invent a day in stored metadata.
            if type(value) is date:
                continue
            if not isinstance(value, str) or not re.fullmatch(
                r"\d{4}-\d{2}(?:-\d{2})?", value
            ):
                raise ValueError(f"date: expected YYYY-MM or YYYY-MM-DD, got {value!r}")
            try:
                date.fromisoformat(value + "-01" if len(value) == 7 else value)
            except ValueError as exc:
                raise ValueError(f"date: invalid calendar date {value!r}") from exc
        elif key == "references":
            if (
                not isinstance(value, list)
                or not value
                or any(
                    not isinstance(entry, dict)
                    or not entry
                    or any(
                        not is_text(ref_id)
                        or not isinstance(reference, dict)
                        or not reference
                        for ref_id, reference in entry.items()
                    )
                    for entry in value
                )
            ):
                raise ValueError(
                    f"references: expected a list of named reference mappings, got {value!r}"
                )
        elif key == "attribution":
            if (
                not isinstance(value, dict)
                or not value
                or not all(is_text(item) for pair in value.items() for item in pair)
            ):
                raise ValueError(
                    f"attribution: expected a nonempty mapping of strings, got {value!r}"
                )


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
        latin = unicodedata.name(char).split()[-1].lower()
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
        for tag1, tag2 in combinations(tags, 2)
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


def check_yaml_files(yaml_files: list[str]) -> int:
    """Report invalid metadata and title/filename mismatches without rewriting files."""
    errors = 0
    for yaml_file in yaml_files:
        try:
            data = load_yaml(yaml_file)
            file_name = os.path.splitext(os.path.basename(yaml_file))[0]
            title = data["title"]
            assert isinstance(title, str)  # Established by validate_metadata.
            if file_name not in IGNORE_SET and not (
                expand_folder_name(file_name) & expand_folder_name(to_param_case(title))
            ):
                raise ValueError(
                    f"Filename {file_name!r} does not match title {title!r}"
                )
        except (ValueError, yaml.YAMLError) as exc:
            errors += 1
            print(f"{yaml_file}: {exc}")
    return errors


if __name__ == "__main__":
    yaml_files = glob("./assets/**/*.yml")
    errors = check_yaml_files(yaml_files)
    if not errors:
        report_similar_tags(yaml_files)
    raise SystemExit(bool(errors))
