"""Auto-update readme table listing all figures in assets/."""

import json
import os
import re
from glob import glob
from itertools import zip_longest
from typing import TypedDict

import yaml

ROOT = os.path.dirname(os.path.dirname(__file__))

with open(f"{ROOT}/site/package.json") as file:
    site_url = json.load(file)["homepage"]


class DiagramInfo(TypedDict):
    """Structure to hold diagram source path and title."""

    source_path: str
    title: str


def collect_diagrams() -> list[DiagramInfo]:
    """Collect all diagram info from YAML files."""
    yaml_paths = glob(f"{ROOT}/assets/**/*.yml")
    tex_paths = glob(f"{ROOT}/assets/**/*.tex")
    typ_paths = glob(f"{ROOT}/assets/**/*.typ")

    # Verify every diagram has a YAML file
    for path in tex_paths + typ_paths:
        dir_name = os.path.dirname(path)
        yaml_path = f"{dir_name}/{os.path.basename(dir_name)}.yml"
        if not os.path.isfile(yaml_path):
            raise FileNotFoundError(f"Missing {yaml_path} for {path}")

    diagrams = {}
    for yaml_path in sorted(yaml_paths):
        dir_path = os.path.dirname(yaml_path)
        name = os.path.basename(dir_path)

        with open(yaml_path) as file:
            metadata = yaml.safe_load(file) or {}

        if metadata.get("hide"):
            continue

        if "title" not in metadata:
            raise ValueError(f"Missing 'title' in {yaml_path}")

        # Prefer .typ over .tex
        for ext in (".typ", ".tex"):
            source_path = f"{dir_path}/{name}{ext}"
            if os.path.isfile(source_path):
                diagrams[name] = {
                    "source_path": source_path,
                    "title": metadata["title"],
                }
                break

    return [diagrams[name] for name in sorted(diagrams)]


def get_code_links(fig_name: str) -> str:
    """Generate markdown links to source files as language logo icons."""
    links = []
    for ext, logo in [(".tex", "LaTeX"), (".typ", "Typst")]:
        path = f"assets/{fig_name}/{fig_name}{ext}"
        if os.path.isfile(f"{ROOT}/{path}"):
            links.append(f"[![{logo}][{logo.lower()}-logo]]({path})")

    if not links:
        raise ValueError(f"No source code found for {fig_name}")

    return "&nbsp;" + "&nbsp;".join(links)


def generate_table(diagrams: list[DiagramInfo]) -> str:
    """Generate markdown table from diagram info."""
    table = f"| {'&emsp;' * 22} | {'&emsp;' * 22} |\n| :---: | :---: |\n"

    pairs = list(zip_longest(diagrams[::2], diagrams[1::2]))
    for idx, (left_diagram, right_diagram) in enumerate(pairs):
        # First column
        name1 = os.path.basename(os.path.dirname(left_diagram["source_path"]))
        title1 = left_diagram["title"]
        dir_link1 = f"[{title1}]({site_url}/{name1}) {get_code_links(name1)}"
        img_link1 = f"![{title1}](assets/{name1}/{name1}.png)"

        # Second column (if exists)
        if right_diagram:
            name2 = os.path.basename(os.path.dirname(right_diagram["source_path"]))
            title2 = right_diagram["title"]
            dir_link2 = f"[{title2}]({site_url}/{name2}) {get_code_links(name2)}"
            img_link2 = f"![{title2}](assets/{name2}/{name2}.png)"
        else:
            dir_link2 = img_link2 = ""
            # Add markdownlint disable comment for last row with empty cell
            if idx == len(pairs) - 1:
                table += "<!-- markdownlint-disable MD060 -->\n"

        table += f"| {dir_link1} | {dir_link2} |\n| {img_link1} | {img_link2} |\n"

        # Close markdownlint disable comment for last row with empty cell
        if right_diagram is None and idx == len(pairs) - 1:
            table += "<!-- markdownlint-enable MD060 -->\n"

    return table


def update_readme(table: str, diagram_count: int) -> None:
    """Update README with new table and counts."""
    with open(f"{ROOT}/readme.md") as file:
        readme = file.read()

    # Insert table
    readme = re.sub(
        pattern=r"(?<=<!-- diagram-table -->\n)(.*)(?=## Scripts\n)",
        repl=f"\n{table}\n",
        string=readme,
        flags=re.DOTALL,
    )

    # Update diagram count
    readme = re.sub(
        r"(?<=Collection of \*\*)\d+(?=\*\* Scientific Diagrams)",
        str(diagram_count),
        readme,
    )

    # Update badge counts
    n_typst = len(glob(f"{ROOT}/assets/**/*.typ"))
    n_latex = len(glob(f"{ROOT}/assets/**/*.tex"))

    for count, lang in [(n_typst, "Typst"), (n_latex, "LaTeX")]:
        readme = re.sub(
            rf"\[\!\[(\d+) with {lang}\]", f"[![{count} with {lang}]", readme
        )
        readme = re.sub(
            rf"badge/\d+%20with-{lang}", f"badge/{count}%20with-{lang}", readme
        )

    with open(f"{ROOT}/readme.md", "w") as file:
        file.write(readme)


if __name__ == "__main__":
    diagrams = collect_diagrams()
    table = generate_table(diagrams)
    update_readme(table, len(diagrams))
