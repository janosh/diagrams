import os
import re
import unicodedata
from collections import Counter
from datetime import date
from difflib import SequenceMatcher
from glob import glob
from itertools import combinations
from typing import Any, Final

import yaml

# Special exceptions where folder name doesn't need to match param-cased title
IGNORE_SET: Final[set[str]] = {
    "qm-cost-vs-acc",
}

# Mapping of abbreviations to their expansions
EXPANSIONS: Final[dict[str, str]] = {
    "+": "plus",
    "thermo": "thermodynamic",
    "distro": "distribution",
    "trafos": "transforms",
}

# Greek letters α-ω and their capitals to Latin names, e.g. θ -> theta. The last word of
# the Unicode name handles multi-word names like "FINAL SIGMA" (ς) -> "sigma".
GREEK_TO_LATIN: Final[dict[int, str]] = str.maketrans(
    {
        char: name
        for code in range(0x03B1, 0x03CA)
        for latin in [unicodedata.name(chr(code)).split()[-1].lower()]
        for char, name in ((chr(code), latin), (chr(code).upper(), latin.title()))
    }
)


def load_yaml(yaml_file: str) -> dict[str, Any]:
    """Parse and validate a metadata YAML file, annotating any error with its path."""
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
        if key in strings and not is_text(value):
            raise ValueError(f"{key}: expected a nonempty string, got {value!r}")
        elif key in string_lists:
            if not (isinstance(value, list) and value and all(map(is_text, value))):
                raise ValueError(
                    f"{key}: expected a nonempty list of nonempty strings, got {value!r}"
                )
            if len(value) != len(set(value)):
                raise ValueError(f"{key}: duplicate entries in {value!r}")
        elif key in flags and type(value) is not bool:
            raise ValueError(f"{key}: expected a boolean, got {value!r}")
        # Month precision is meaningful; do not invent a day in stored metadata.
        elif key == "date" and type(value) is not date:
            if not (
                isinstance(value, str)
                and re.fullmatch(r"\d{4}-\d{2}(?:-\d{2})?", value)
            ):
                raise ValueError(f"date: expected YYYY-MM or YYYY-MM-DD, got {value!r}")
            try:
                date.fromisoformat(value if len(value) == 10 else f"{value}-01")
            except ValueError as exc:
                raise ValueError(f"date: invalid calendar date {value!r}") from exc
        elif key == "references" and not (
            isinstance(value, list)
            and value
            and all(
                isinstance(entry, dict)
                and entry
                and all(
                    is_text(ref_id) and isinstance(reference, dict) and reference
                    for ref_id, reference in entry.items()
                )
                for entry in value
            )
        ):
            raise ValueError(
                f"references: expected a list of named reference mappings, got {value!r}"
            )
        elif key == "attribution" and not (
            isinstance(value, dict)
            and value
            and all(is_text(item) for pair in value.items() for item in pair)
        ):
            raise ValueError(
                f"attribution: expected a nonempty mapping of strings, got {value!r}"
            )


def expand_folder_name(name: str) -> set[str]:
    """Generate all possible expansions of a folder name."""
    result = {name}
    for abbrev, expansion in EXPANSIONS.items():
        result |= {current.replace(abbrev, expansion) for current in result}
    return result


def to_param_case(text: str) -> str:
    """Convert a string to param-case (kebab-case)."""
    # transliterate Greek, then keep only alnum/hyphen/plus, collapse and trim hyphens
    text = text.replace(" ", "-").replace("_", "-").translate(GREEK_TO_LATIN)
    text = "".join(char.lower() for char in text if char.isalnum() or char in "-+")
    return re.sub(r"-{2,}", "-", text).strip("-")


def report_similar_tags(yaml_files: list[str]) -> None:
    """Find minor variations of tags and suggest renaming them for cross-file consistency."""
    print("\nAnalyzing tags across YAML files...")
    print(f"Found {len(yaml_files)} YAML files")
    tag_counts = Counter(tag for path in yaml_files for tag in load_yaml(path)["tags"])

    print("\nTop 20 tags by usage:")
    print("-" * 40)
    for tag, count in sorted(tag_counts.items(), key=lambda x: (-x[1], x[0]))[:20]:
        print(f"{tag:25} {count:5d}")

    similar_tags = sorted(
        (
            (tag1, tag2, ratio)
            for tag1, tag2 in combinations(tag_counts, 2)
            if (ratio := SequenceMatcher(None, tag1, tag2).ratio()) >= 0.85
        ),
        key=lambda pair: pair[2],
        reverse=True,
    )
    if not similar_tags:
        return
    print("\nPotentially similar tags:")
    print("-" * 40)
    for tag1, tag2, similarity in similar_tags:
        print(
            f"{tag1:25} {tag_counts[tag1]:<3d} ↔ "
            f"{tag2:25} {tag_counts[tag2]:<3d} ({similarity:.3f})"
        )


def check_yaml_files(yaml_files: list[str]) -> int:
    """Report invalid metadata and title/filename mismatches without rewriting files."""
    errors = 0
    for yaml_file in yaml_files:
        try:
            title = load_yaml(yaml_file)["title"]
            file_name = os.path.splitext(os.path.basename(yaml_file))[0]
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
