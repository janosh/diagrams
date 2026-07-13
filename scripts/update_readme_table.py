"""Auto-update readme table listing all figures in assets/."""

import json
import os
import re
from dataclasses import dataclass
from glob import glob
from itertools import zip_longest

import yaml

ROOT = os.path.dirname(os.path.dirname(__file__))

with open(f"{ROOT}/site/package.json") as file:
    site_url = json.load(file)["homepage"]


@dataclass(frozen=True)
class DiagramInfo:
    """Diagram name and display title."""

    name: str
    title: str


def get_diagram_sources(ext: str) -> list[str]:
    """Return source files named after their parent diagram folder."""
    return [
        src_path
        for src_path in glob(f"{ROOT}/assets/**/*{ext}")
        if os.path.basename(src_path)
        == f"{os.path.basename(os.path.dirname(src_path))}{ext}"
    ]


def collect_diagrams() -> list[DiagramInfo]:
    """Collect visible diagram metadata with matching source files."""
    for src_path in get_diagram_sources(".tex") + get_diagram_sources(".typ"):
        dir_name = os.path.dirname(src_path)
        yaml_path = f"{dir_name}/{os.path.basename(dir_name)}.yml"
        if not os.path.isfile(yaml_path):
            raise FileNotFoundError(f"Missing {yaml_path} for {src_path}")

    diagrams: list[DiagramInfo] = []
    for yaml_path in sorted(glob(f"{ROOT}/assets/**/*.yml")):
        dir_name = os.path.dirname(yaml_path)
        name = os.path.basename(dir_name)

        with open(yaml_path) as file:
            metadata = yaml.safe_load(file) or {}

        if metadata.get("hide"):
            continue

        if "title" not in metadata:
            raise ValueError(f"Missing 'title' in {yaml_path}")

        if any(os.path.isfile(f"{dir_name}/{name}{ext}") for ext in (".typ", ".tex")):
            diagrams.append(DiagramInfo(name=name, title=metadata["title"]))

    return sorted(diagrams, key=lambda diagram: diagram.name)


def get_code_links(figure_name: str) -> str:
    """Generate markdown links to source files as language logo icons."""
    links: list[str] = []
    for ext, lang_logo in ((".tex", "LaTeX"), (".typ", "Typst")):
        src_path = f"assets/{figure_name}/{figure_name}{ext}"
        if os.path.isfile(f"{ROOT}/{src_path}"):
            links.append(f"[![{lang_logo}][{lang_logo.lower()}-logo]]({src_path})")

    if not links:
        raise ValueError(f"No source code found for {figure_name}")

    return "&nbsp;" + "&nbsp;".join(links)


def table_cell(diagram: DiagramInfo | None) -> tuple[str, str]:
    """Build the title and image markdown for one diagram table cell."""
    if diagram is None:
        return "", ""
    name = diagram.name
    title = diagram.title
    return (
        f"[{title}]({site_url}/{name}) {get_code_links(name)}",
        f"![{title}](assets/{name}/{name}.png)",
    )


def generate_table(diagrams: list[DiagramInfo]) -> str:
    """Generate a two-column markdown table from diagram info."""
    table = f"| {'&emsp;' * 22} | {'&emsp;' * 22} |\n| :---: | :---: |\n"

    for left_diagram, right_diagram in zip_longest(diagrams[::2], diagrams[1::2]):
        left_title_link, left_image_link = table_cell(left_diagram)
        right_title_link, right_image_link = table_cell(right_diagram)

        if right_diagram is None:
            table += "<!-- markdownlint-disable MD060 -->\n"
        table += (
            f"| {left_title_link} | {right_title_link} |\n"
            f"| {left_image_link} | {right_image_link} |\n"
        )
        if right_diagram is None:
            table += "<!-- markdownlint-enable MD060 -->\n"

    return table


def update_readme(table: str, diagram_count: int) -> None:
    """Update README diagram table, heading count, and language badges."""
    with open(f"{ROOT}/readme.md") as file:
        readme = file.read()

    readme = re.sub(
        pattern=r"(?<=<!-- diagram-table -->\n)(.*)(?=## Scripts\n)",
        repl=f"\n{table}\n",
        string=readme,
        flags=re.DOTALL,
    )

    for pattern in (
        r"(?<=Collection of \*\*)\d+(?=\*\* Scientific Diagrams)",
        r"(?<=\n  )\d+(?= Scientific Diagrams\n</h1>)",
    ):
        readme = re.sub(pattern, str(diagram_count), readme)

    for ext, lang in (
        (".typ", "Typst"),
        (".tex", "LaTeX"),
    ):
        count = len(get_diagram_sources(ext))
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
    update_readme(generate_table(diagrams), len(diagrams))
