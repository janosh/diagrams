"""Auto-update readme table listing all figures in assets/."""

import json
import os
import re
import subprocess
from glob import glob
from itertools import zip_longest
from typing import Any, TypedDict

import yaml

ROOT = os.path.dirname(os.path.dirname(__file__))

with open(f"{ROOT}/site/package.json", mode="r") as file:
    site_url = json.load(file)["homepage"]

# Get all YAML files
yaml_paths = glob(f"{ROOT}/assets/**/*.yml")
# Also get .tex and .typ paths to check for missing YAML files
tex_paths = glob(f"{ROOT}/assets/**/*.tex")
typ_paths = glob(f"{ROOT}/assets/**/*.typ")

# Check that every diagram has a YAML file
for diagram_path in tex_paths + typ_paths:
    dir_name = os.path.dirname(diagram_path)
    yaml_path = f"{dir_name}/{os.path.basename(dir_name)}.yml"
    if not os.path.isfile(yaml_path):
        raise FileNotFoundError(f"Missing {yaml_path=} for {diagram_path=}")


# Create a dict mapping directory names to file paths and titles
# Prefer .typ files over .tex files when both exist
class DiagramInfo(TypedDict):
    """Structure to hold diagram source path and title."""

    source_path: str
    title: str


diagram_data_map: dict[str, DiagramInfo] = {}
for yaml_path in sorted(yaml_paths):
    dir_of_yaml = os.path.dirname(yaml_path)
    base_name = os.path.basename(
        dir_of_yaml
    )  # This is the fig_name/diagram directory name

    # Skip if diagram is marked as hidden in YAML
    with open(yaml_path, mode="r") as file:
        metadata: dict[str, Any] = yaml.safe_load(file) or {}
        if metadata.get("hide"):
            continue

        try:
            title: str = metadata["title"]
        except KeyError:
            raise ValueError(
                f"Missing 'title' in YAML metadata for {base_name} ({yaml_path})"
            )

    # Look for corresponding .typ or .tex file
    typ_path = f"{dir_of_yaml}/{base_name}.typ"
    tex_path = f"{dir_of_yaml}/{base_name}.tex"

    source_file_path: str | None = None
    if os.path.isfile(typ_path):
        source_file_path = typ_path
    elif os.path.isfile(tex_path):
        source_file_path = tex_path

    if source_file_path:
        diagram_data_map[base_name] = {"source_path": source_file_path, "title": title}

# Convert to a sorted list of diagram information objects
sorted_base_names = sorted(diagram_data_map.keys())
unique_diagram_infos: list[DiagramInfo] = [
    diagram_data_map[name] for name in sorted_base_names
]


md_table = f"| {'&emsp;' * 22} | {'&emsp;' * 22} |\n| :---: | :---: |\n"


def get_code_links(fig_name: str) -> str:
    """Generate markdown for rendering links to LaTeX and/or CeTZ source files as language logo icons."""
    tex_path = f"assets/{fig_name}/{fig_name}.tex"
    typ_path = f"assets/{fig_name}/{fig_name}.typ"

    links = []
    if os.path.isfile(f"{ROOT}/{tex_path}"):
        links.append(f"[![LaTeX][latex-logo]]({tex_path})")
    if os.path.isfile(f"{ROOT}/{typ_path}"):
        links.append(f"[![Typst][typst-logo]]({typ_path})")

    if not links:
        raise ValueError(
            f"Neither LaTeX nor Typst source code found for {fig_name=}. this should never happen."
        )

    return "&nbsp;" + "&nbsp;".join(links)


for data1, data2 in zip_longest(unique_diagram_infos[::2], unique_diagram_infos[1::2]):
    # Prepare data for the first column
    title1 = data1["title"]
    # fig_basename1 is the directory name, e.g., "alpha-helical-wheel"
    fig_basename1 = os.path.basename(os.path.dirname(data1["source_path"]))

    dir_link1 = (
        f"[{title1}]({site_url}/{fig_basename1}) {get_code_links(fig_basename1)}"
    )
    img_link1 = f"![{title1}](assets/{fig_basename1}/{fig_basename1}.png)"

    # Prepare data for the second column (if it exists)
    dir_link2 = ""
    img_link2 = ""
    if data2:
        title2 = data2["title"]
        fig_basename2 = os.path.basename(os.path.dirname(data2["source_path"]))
        dir_link2 = (
            f"[{title2}]({site_url}/{fig_basename2}) {get_code_links(fig_basename2)}"
        )
        img_link2 = f"![{title2}](assets/{fig_basename2}/{fig_basename2}.png)"

    # Add row for figure names/titles and source code links
    md_table += f"| {dir_link1} | {dir_link2} |\n"

    # Add row for images
    md_table += f"| {img_link1} | {img_link2} |\n"

with open(f"{ROOT}/readme.md", mode="r") as file:
    readme = file.read()

# insert table markdown between "## Images\n" and "## Scripts\n" headings
readme = re.sub(
    r"(?<=<!-- diagram-table -->\n)(.*)(?=## Scripts\n)",
    f"\n{md_table}\n",
    readme,
    flags=re.DOTALL,
)

# update count in "Collection of **XXX** "
readme = re.sub(
    r"(?<=Collection of \*\*)\d+(?=\*\* Scientific Diagrams)",
    str(len(unique_diagram_infos)),
    readme,
)

# Count number of Typst and LaTeX diagrams
n_typst = len(
    typ_paths
)  # This counts source files, not necessarily rendered diagrams if some are hidden
n_latex = len(tex_paths)

# update badge counts for Typst and LaTeX
readme = re.sub(r"\[\!\[(\d+) with Typst\]", f"[![{n_typst} with Typst]", readme)
readme = re.sub(r"\[\!\[(\d+) with LaTeX\]", f"[![{n_latex} with LaTeX]", readme)
# update the URL-encoded part
readme = re.sub(r"badge/\d+%20with-Typst", f"badge/{n_typst}%20with-Typst", readme)
readme = re.sub(r"badge/\d+%20with-LaTeX", f"badge/{n_latex}%20with-LaTeX", readme)

with open(f"{ROOT}/readme.md", mode="w") as file:
    file.write(readme)

# run pre-commit on readme to format white space in table
subprocess.run(["pre-commit", "run", "--files", "readme.md"])
