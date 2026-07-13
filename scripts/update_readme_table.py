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


def get_diagram_sources(extension: str) -> list[str]:
    """Return source files named after their parent diagram folder."""
    return [
        source_path
        for source_path in glob(f"{ROOT}/assets/**/*{extension}")
        if os.path.basename(source_path)
        == f"{os.path.basename(os.path.dirname(source_path))}{extension}"
    ]


def collect_diagrams() -> list[DiagramInfo]:
    """Collect visible diagram metadata with matching source files."""
    for source_path in get_diagram_sources(".tex") + get_diagram_sources(".typ"):
        dir_name = os.path.dirname(source_path)
        yaml_path = f"{dir_name}/{os.path.basename(dir_name)}.yml"
        if not os.path.isfile(yaml_path):
            raise FileNotFoundError(f"Missing {yaml_path} for {source_path}")

    diagrams: list[DiagramInfo] = []
    for yaml_path in sorted(glob(f"{ROOT}/assets/**/*.yml")):
        dir_path = os.path.dirname(yaml_path)
        name = os.path.basename(dir_path)

        with open(yaml_path) as file:
            metadata = yaml.safe_load(file) or {}

        if metadata.get("hide"):
            continue

        if "title" not in metadata:
            raise ValueError(f"Missing 'title' in {yaml_path}")

        if any(os.path.isfile(f"{dir_path}/{name}{ext}") for ext in (".typ", ".tex")):
            diagrams.append(DiagramInfo(name=name, title=metadata["title"]))

    return sorted(diagrams, key=lambda diagram: diagram.name)


def get_code_links(fig_name: str) -> str:
    """Generate markdown links to source files as language logo icons."""
    links: list[str] = []
    for ext, logo in ((".tex", "LaTeX"), (".typ", "Typst")):
        path = f"assets/{fig_name}/{fig_name}{ext}"
        if os.path.isfile(f"{ROOT}/{path}"):
            links.append(f"[![{logo}][{logo.lower()}-logo]]({path})")

    if not links:
        raise ValueError(f"No source code found for {fig_name}")

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
        dir_link1, img_link1 = table_cell(left_diagram)
        dir_link2, img_link2 = table_cell(right_diagram)

        if right_diagram is None:
            table += "<!-- markdownlint-disable MD060 -->\n"
        table += f"| {dir_link1} | {dir_link2} |\n| {img_link1} | {img_link2} |\n"
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

    for extension, lang in (
        (".typ", "Typst"),
        (".tex", "LaTeX"),
    ):
        count = len(get_diagram_sources(extension))
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
