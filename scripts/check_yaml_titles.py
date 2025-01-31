import os
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
    # Remove any non-alphanumeric characters except hyphens and plus signs
    text = "".join(c.lower() for c in text if c.isalnum() or c == "-" or c == "+")
    # Replace multiple consecutive hyphens with a single hyphen
    while "--" in text:
        text = text.replace("--", "-")
    # Remove leading/trailing hyphens
    return text.strip("-")


def check_yaml_titles():
    errors: dict[str, str] = {}

    for yaml_file in glob("./assets/**/*.yml"):
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


if __name__ == "__main__":
    raise SystemExit(check_yaml_titles())
