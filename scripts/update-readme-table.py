"""Auto-update readme table listing all figures in assets/."""

import json
import os
import re
from glob import glob
from itertools import zip_longest

import yaml

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(MOD_DIR)
TEX_DIR = f"{ROOT}/assets"

with open(f"{ROOT}/site/package.json", mode="r") as file:
    site_url = json.load(file)["homepage"]

# Get all YAML files
yaml_paths = glob(f"{TEX_DIR}/**/*.yml")
# Also get .tex and .typ paths to check for missing YAML files
tex_paths = glob(f"{TEX_DIR}/**/*.tex")
typ_paths = glob(f"{TEX_DIR}/**/*.typ")

# Check that every diagram has a YAML file
for diagram_path in tex_paths + typ_paths:
    dir_name = os.path.dirname(diagram_path)
    yaml_path = f"{dir_name}/{os.path.basename(dir_name)}.yml"
    if not os.path.isfile(yaml_path):
        raise FileNotFoundError(f"Missing {yaml_path=} for {diagram_path=}")

# Create a dict mapping directory names to file paths
# Prefer .typ files over .tex files when both exist
path_dict: dict[str, str] = {}
for yaml_path in sorted(yaml_paths):
    base_name = os.path.basename(os.path.dirname(yaml_path))

    # Skip if diagram is marked as hidden in YAML
    with open(yaml_path, mode="r") as file:
        metadata = yaml.safe_load(file) or {}
        if metadata.get("hide"):
            continue

    # Look for corresponding .typ or .tex file
    typ_path = f"{os.path.dirname(yaml_path)}/{base_name}.typ"
    tex_path = f"{os.path.dirname(yaml_path)}/{base_name}.tex"

    if os.path.isfile(typ_path):
        path_dict[base_name] = typ_path
    elif os.path.isfile(tex_path):
        path_dict[base_name] = tex_path

# Convert back to sorted list
unique_paths = sorted(path_dict.values())

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


for path1, path2 in zip_longest(unique_paths[::2], unique_paths[1::2]):
    dir1, dir2 = map(os.path.dirname, (path1, path2 or ""))
    fig1, fig2 = map(os.path.basename, (dir1, dir2))

    # file name row with source code links
    dir_link1 = f"[`{fig1}`]({site_url}/{fig1}) {get_code_links(fig1)}"
    dir_link2 = f"[`{fig2}`]({site_url}/{fig2}) {get_code_links(fig2)}" if path2 else ""
    md_table += f"| {dir_link1} | {dir_link2} |\n"

    # image row
    img_link1 = f"![`{fig1}.png`](assets/{fig1}/{fig1}.png)"
    img_link2 = f"![`{fig2}.png`](assets/{fig2}/{fig2}.png)" if path2 else ""
    md_table += f"| {img_link1} | {img_link2} |\n"

with open(f"{ROOT}/readme.md", mode="r") as file:
    readme = file.read()

# insert table markdown between "## Images\n" and "## Scripts\n" headings
readme = re.sub(
    r"(?<=## Images\n)(.*)(?=## Scripts\n)",
    f"\n{md_table}\n",
    readme,
    flags=re.DOTALL,
)

# update count in "Collection of **110** "
readme = re.sub(r"(?<=)\d+(?= Scientific Diagrams)", str(len(unique_paths)), readme)

with open(f"{ROOT}/readme.md", mode="w") as file:
    file.write(readme)

# run pre-commit on readme to format white space in table
os.system("pre-commit run --files readme.md")
