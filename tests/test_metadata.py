"""Validate diagram metadata at the YAML boundary."""

import os
from datetime import date, datetime
from glob import glob
from pathlib import Path

import pytest
import yaml
from check_yaml_files import check_yaml_files, load_yaml


@pytest.mark.parametrize(
    "metadata_date", [None, date(2024, 2, 29), "2024-02-29", "2020-03"]
)
def test_valid_metadata(metadata_date: date | str | None, tmp_path: Path) -> None:
    """Accept optional provenance, explicit flags, and both supported date precisions."""
    data = {
        "title": "Example",
        "description": "A diagram.",
        "tags": ["physics"],
        "hide": False,
        "preserve_colors": True,
        "authors": ["Example Author"],
        "creator": "Example Author",
        "creator_url": "https://example.com",
        "url": "https://example.com/diagram",
        "source": "Lecture notes",
        "citation": "Example (2020)",
        "references": [{"example": {"title": "Example", "year": 2020}}],
        "attribution": {"creator": "Example Author", "license": "CC-BY-4.0"},
    }
    if metadata_date is not None:
        data["date"] = metadata_date
    source = tmp_path / "example.yml"
    source.write_text(yaml.safe_dump(data))
    assert load_yaml(str(source)) == data
    assert check_yaml_files([str(source)]) == 0


@pytest.mark.parametrize(
    "field, value, error",
    [
        ("preserve_color", True, "Unknown metadata fields"),
        ("title", None, "title"),
        ("description", "  ", "description"),
        ("description", 12, "description"),
        ("tags", "physics", "tags"),
        ("tags", [], "tags"),
        ("tags", [""], "tags"),
        ("tags", [1], "tags"),
        ("tags", ["physics", "physics"], "duplicate"),
        ("hide", "false", "hide"),
        ("preserve_colors", 1, "preserve_colors"),
        ("creator", [], "creator"),
        ("date", 2024, "date"),
        ("date", "2023-02-29", "date"),
        ("date", "2024-13", "date"),
        ("date", "20240229", "date"),
        ("date", datetime(2024, 2, 29), "date"),
        ("authors", [False], "authors"),
        ("references", "citation", "references"),
        ("references", [{"example": "citation"}], "references"),
        ("attribution", {"license": False}, "attribution"),
    ],
)
def test_invalid_metadata(
    field: str,
    value: object,
    error: str,
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Reject malformed fields without rewriting YAML or bypassing title exceptions."""
    source = tmp_path / "qm-cost-vs-acc.yml"
    source.write_text(
        yaml.safe_dump(
            {
                "title": "Example",
                "description": "A diagram.",
                "tags": ["physics"],
                field: value,
            }
        )
    )
    original = source.read_bytes()
    assert check_yaml_files([str(source)]) == 1
    output = capsys.readouterr().out
    assert str(source) in output and error in output
    assert source.read_bytes() == original


@pytest.mark.parametrize(
    "document, error",
    [
        ("", "mapping"),
        ("- list", "mapping"),
        ("title: Example", "Missing metadata fields"),
        ("title: [", "expected"),
        ("title: Other\ndescription: Diagram\ntags: [physics]", "does not match title"),
    ],
)
def test_invalid_document(
    document: str, error: str, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Report YAML, root-shape, required-field, and filename failures with file context."""
    source = tmp_path / "example.yml"
    source.write_text(document)
    assert check_yaml_files([str(source)]) == 1
    output = capsys.readouterr().out
    assert str(source) in output and error in output


def test_repository_metadata() -> None:
    """Keep every existing diagram, including hidden entries, valid under the schema."""
    root = os.path.dirname(os.path.dirname(__file__))
    sources = glob(f"{root}/assets/**/*.yml")
    assert sources and check_yaml_files(sources) == 0
