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


def expand_folder_name(name: str) -> list[str]:
    """Generate all possible expansions of a folder name."""
    result = {name}

    # For each abbreviation, try replacing it in all current results
    for abbrev, expansion in EXPANSIONS.items():
        current_results = result.copy()
        for current in current_results:
            if abbrev in current:
                expanded = current.replace(abbrev, expansion)
                result.add(expanded)

    return list(result)


def to_param_case(text: str) -> str:
    """Convert a string to param-case (kebab-case)."""
    # Replace spaces and underscores with hyphens
    text = text.replace(" ", "-").replace("_", "-")

    # Replace Greek letters with Latin equivalents using unicodedata
    for idx in range(0x03B1, 0x03C0):  # Greek lowercase letters α-ω
        char = chr(idx)
        name = unicodedata.name(char).lower().replace("greek small letter ", "")
        text = text.replace(char, name)  # Replace lowercase
        text = text.replace(char.upper(), name.title())  # Replace uppercase

    # Remove any remaining non-alphanumeric characters except hyphens and plus signs
    text = "".join(c.lower() for c in text if c.isalnum() or c == "-" or c == "+")
    # Replace multiple consecutive hyphens with a single hyphen
    while "--" in text:
        text = text.replace("--", "-")
    # Remove leading/trailing hyphens
    return text.strip("-")


def find_similar_tags(
    tags: list[str], threshold: float = 0.85
) -> list[tuple[str, str, float]]:
    """Find pairs of tags that are very similar to each other."""
    similar_pairs = []
    for i, tag1 in enumerate(tags):
        for tag2 in tags[i + 1 :]:
            similarity = SequenceMatcher(None, tag1, tag2).ratio()
            if similarity >= threshold:
                similar_pairs.append((tag1, tag2, similarity))
    return sorted(similar_pairs, key=lambda x: x[2], reverse=True)


def report_similar_tags(yaml_files: list[str]):
    """Find minor variations of tags and suggest renaming them for cross-file consistency."""
    tag_counter = Counter()

    print("\nAnalyzing tags across YAML files...")
    print(f"Found {len(yaml_files)} YAML files")

    for yaml_file in yaml_files:
        try:
            with open(yaml_file) as file:
                data = yaml.safe_load(file)
                if data and "tags" in data:
                    tags = data["tags"]
                    if isinstance(tags, list):
                        tag_counter.update(tags)
        except Exception as exc:
            exc.add_note(f"{yaml_file=}")
            raise

    # Print tag statistics
    n_tags_to_print = 20
    print(f"\nTop {n_tags_to_print} tags by usage:")
    print("-" * 40)
    for tag, count in sorted(tag_counter.items(), key=lambda x: (-x[1], x[0]))[
        :n_tags_to_print
    ]:
        print(f"{tag:25} {count:5d}")

    # Find similar tags
    all_tags = list(tag_counter)
    similar_tags = find_similar_tags(all_tags)

    if similar_tags:
        print("\nPotentially similar tags:")
        print("-" * 40)
        for tag1, tag2, similarity in similar_tags:
            print(
                f"{tag1:25} {tag_counter[tag1]:<3d} ↔ "
                f"{tag2:25} {tag_counter[tag2]:<3d} "
                f"({similarity:.3f})"
            )


def check_yaml_titles(yaml_files: list[str]) -> int:
    errors: dict[str, str] = {}

    for yaml_file in yaml_files:
        file_name = os.path.basename(yaml_file).split(".")[0]
        if file_name in IGNORE_SET:
            continue

        if not os.path.exists(yaml_file):
            errors[yaml_file] = "Missing YAML file"
            continue

        with open(yaml_file) as file:
            data = yaml.safe_load(file)

        if "title" not in data:
            errors[yaml_file] = "Missing title"
            continue

        title = data["title"]
        param_title = to_param_case(title)
        folder_name = file_name

        # Get all possible expansions for both the folder name and param-cased title
        folder_expansions = expand_folder_name(folder_name)
        title_expansions = expand_folder_name(param_title)

        # Check if there's any overlap between the two sets of expansions
        if not (set(folder_expansions) & set(title_expansions)):
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
                files_changed += [yaml_file]
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
        try:
            with open(yaml_file) as file:
                data = yaml.safe_load(file)
                if data and data.get("description") is None:
                    missing_desc += [yaml_file]
        except Exception as exc:
            exc.add_note(f"{yaml_file=}")
            raise

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
    missing = check_missing_descriptions(yaml_files)  # Add description check
    # TODO remove missing allowance once all diagrams have descriptions
    raise_missing = len(missing) > 10
    raise SystemExit(errors or raise_missing)  # Exit with error if any checks fail
