"""Auto-update readme table listing all figures in assets/."""

import json
import os
import re
from dataclasses import dataclass
from glob import glob
from html import escape
from itertools import zip_longest
from urllib.parse import quote, urlsplit

from check_yaml_files import load_yaml

ROOT = os.path.dirname(os.path.dirname(__file__))

with open(f"{ROOT}/site/package.json") as file:
    SITE_URL = json.load(file)["homepage"]


# Source extensions in README link order, with the language each badge counts.
LANGUAGES = {".tex": "LaTeX", ".typ": "Typst"}


@dataclass(frozen=True)
class DiagramInfo:
    """Diagram name, display title, and the source files it ships."""

    name: str
    title: str
    source_exts: tuple[str, ...]
    preserve_colors: bool
    provenance_links: str


def collect_diagrams() -> list[DiagramInfo]:
    """Collect visible diagram metadata with matching source files."""
    for ext in LANGUAGES:
        for src_path in glob(f"{ROOT}/assets/**/*{ext}"):
            dir_name = os.path.dirname(src_path)
            name = os.path.basename(dir_name)
            if name.startswith("_"):
                continue
            base_path = f"{dir_name}/{name}"
            if src_path != f"{base_path}{ext}":
                raise ValueError(f"Expected {base_path}{ext}, found {src_path}")
            if not os.path.isfile(f"{base_path}.yml"):
                raise FileNotFoundError(f"Missing {base_path}.yml for {src_path}")

    diagrams: list[DiagramInfo] = []
    for yaml_path in glob(f"{ROOT}/assets/**/*.yml"):
        dir_name = os.path.dirname(yaml_path)
        name = os.path.basename(dir_name)
        metadata = load_yaml(yaml_path)
        source_exts = tuple(
            ext for ext in LANGUAGES if os.path.isfile(f"{dir_name}/{name}{ext}")
        )
        if source_exts and not metadata.get("hide"):
            diagrams.append(
                DiagramInfo(
                    name=name,
                    title=metadata["title"],
                    source_exts=source_exts,
                    preserve_colors=metadata.get("preserve_colors", False),
                    provenance_links=get_provenance_links(metadata),
                )
            )
    return sorted(diagrams, key=lambda diagram: diagram.name)


def get_provenance_links(metadata: dict) -> str:
    """Show at most two links, prioritizing explicit references and credits."""
    links: dict[str, str] = {}

    def add_link(url: str, label: str, icon: str = "reference") -> None:
        """Normalize DOI links and keep the first, most descriptive label."""
        if url.startswith("10."):
            url = f"https://doi.org/{url}"
        parsed = urlsplit(url)
        if parsed.scheme not in {"http", "https"} or not parsed.netloc:
            raise ValueError(f"Invalid provenance URL: {url!r}")
        is_doi = parsed.hostname in {"doi.org", "dx.doi.org"}
        if is_doi:
            url = f"https://doi.org{parsed.path}"
        key = url.lower() if is_doi else url
        if key in links or len(links) == 2:
            return
        label = escape(" ".join(label.split())).translate(
            str.maketrans({"|": "&#124;", "[": "&#91;", "]": "&#93;"})
        )
        target = quote(url, safe=":/?#[]@!$&'()*+,;=%~")
        links[key] = f'&nbsp;[![{label}][{icon}-icon]](<{target}> "{label}")'

    for entry in metadata.get("references", []):
        for reference in entry.values():
            if url := reference.get("doi") or reference.get("url"):
                add_link(url, f"Reference: {reference.get('title', url)}")

    for credit in (metadata, metadata.get("attribution", {})):
        if url := credit.get("creator_url"):
            add_link(url, f"Creator: {credit.get('creator', url)}", "creator")
        name = ": ".join(
            credit[field] for field in ("creator", "title") if field in credit
        )
        for field, label in (("url", "Original source"), ("repo", "Source repository")):
            if url := credit.get(field):
                add_link(url, f"{label}: {name or url}", "source")

    for field in ("source", "citation", "description"):
        text = metadata.get(field, "")
        for match in re.finditer(
            r'https?://[^\s<>"\]]+|\b10\.\d{4,9}/[^\s<>"\]]+', text
        ):
            url = match[0].rstrip(".,;:!?")
            # Keep parentheses inside DOIs while dropping Markdown/prose delimiters.
            while url.endswith(")") and url.count(")") > url.count("("):
                url = url[:-1]
            caption = text if field == "citation" else url
            if label := re.search(r"\[([^\[\]]+)\]\($", text[: match.start()]):
                caption = label[1]
            add_link(url, f"Reference: {caption}")

    return "".join(links.values())


def table_cell(diagram: DiagramInfo | None) -> tuple[str, str]:
    """Build the title and image markdown for one diagram table cell."""
    if diagram is None:
        return "&nbsp;", "&nbsp;"
    name, title = diagram.name, diagram.title
    base_path = f"assets/{name}/{name}"
    suffixes = (".avif",) if diagram.preserve_colors else (".avif", "-dark.avif")
    for suffix in suffixes:
        if not os.path.isfile(f"{ROOT}/{base_path}{suffix}"):
            raise FileNotFoundError(f"Missing README preview: {base_path}{suffix}")
    image = f'<img alt="{escape(title, quote=True)}" src="{base_path}.avif">'
    if not diagram.preserve_colors:
        image = (
            f'<picture><source media="(prefers-color-scheme: dark)" '
            f'srcset="{base_path}-dark.avif">{image}</picture>'
        )
    code_links = "".join(
        f"&nbsp;[![{LANGUAGES[ext]}][{LANGUAGES[ext].lower()}-logo]]({base_path}{ext})"
        for ext in diagram.source_exts
    )
    return (
        f"[{title}]({SITE_URL}/{name}) "
        f"<sub>{code_links}{diagram.provenance_links}</sub>",
        image,
    )


def generate_table(diagrams: list[DiagramInfo]) -> str:
    """Generate a two-column markdown table from diagram info."""
    rows = [f"| {'&emsp;' * 22} | {'&emsp;' * 22} |", "| :---: | :---: |"]
    for pair in zip_longest(diagrams[::2], diagrams[1::2]):
        (left_title, left_image), (right_title, right_image) = map(table_cell, pair)
        rows += [
            f"| {left_title} | {right_title} |",
            f"| {left_image} | {right_image} |",
        ]
    return "\n".join(rows) + "\n"


def source_counts(diagrams: list[DiagramInfo]) -> dict[str, int]:
    """Count visible diagrams per source language, matching the heading's total."""
    return {
        lang: sum(ext in diagram.source_exts for diagram in diagrams)
        for ext, lang in LANGUAGES.items()
    }


def update_readme(diagrams: list[DiagramInfo]) -> None:
    """Update README diagram table, heading count, and language badges."""
    with open(f"{ROOT}/readme.md") as file:
        readme = file.read()

    table_pattern = r"(?<=<!-- diagram-table -->\n)(.*)(?=## Scripts\n)"
    table = generate_table(diagrams)
    readme = re.sub(table_pattern, f"\n{table}\n", readme, flags=re.DOTALL)

    heading_pattern = r"(?<=\n  )\d+(?= Scientific Diagrams\n</h1>)"
    readme = re.sub(heading_pattern, str(len(diagrams)), readme)

    for lang, count in source_counts(diagrams).items():
        readme = re.sub(
            rf"\[\!\[(\d+) with {lang}\]", f"[![{count} with {lang}]", readme
        )
        readme = re.sub(
            rf"badge/\d+%20with-{lang}", f"badge/{count}%20with-{lang}", readme
        )

    with open(f"{ROOT}/readme.md", "w") as file:
        file.write(readme)


if __name__ == "__main__":
    update_readme(collect_diagrams())
