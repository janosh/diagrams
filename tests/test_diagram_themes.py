"""Check transparent exports and theme-aware README previews."""

import os
import re
import subprocess
import sys
from pathlib import Path

import pytest
import render_tikz
import yaml
from convert_assets import finalize_assets
from update_readme_table import (
    collect_diagrams,
    generate_table,
    table_cell,
)

ROOT = os.path.dirname(os.path.dirname(__file__))


@pytest.mark.parametrize("ci", ["false", "true"])
@pytest.mark.parametrize(
    "renderer, compiler, extension",
    [
        ("render_typst.py", "typst", ".typ"),
        ("render_tikz.py", "latexmk", ".tex"),
    ],
)
def test_failed_compilation_preserves_outputs(
    renderer: str, compiler: str, extension: str, ci: str, tmp_path: Path
) -> None:
    """Stop before conversion or cleanup when either compiler fails locally or in CI."""
    source = tmp_path / f"diagram{extension}"
    source.write_text("invalid source")
    (tmp_path / compiler).symlink_to("/usr/bin/false")
    outputs = [
        tmp_path / f"diagram{suffix}"
        for suffix in (
            ".pdf",
            ".svg",
            ".avif",
            ".png",
            "-dark.avif",
            ".aux",
            ".log",
        )
    ]
    for output in outputs:
        output.write_bytes(b"previous output")
    result = subprocess.run(
        [sys.executable, f"{ROOT}/scripts/{renderer}", str(source)],
        env={**os.environ, "PATH": str(tmp_path), "CI": ci},
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode != 0
    assert compiler in result.stderr
    assert all(
        output.is_file() and output.read_bytes() == b"previous output"
        for output in outputs
    )


def read_rgba(image_path: str) -> bytes:
    """Decode image pixels independently of format and compression choices."""
    return subprocess.check_output(["magick", image_path, "-depth", "8", "rgba:-"])


def test_successful_tex_cleanup(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Convert successful TeX output and remove only that diagram's auxiliary files."""
    source = tmp_path / "diagram.tex"
    source.touch()
    auxiliary = [
        tmp_path / f"diagram{suffix}"
        for suffix in (".aux", ".log", ".fls", ".fdb_latexmk")
    ]
    for output in auxiliary:
        output.touch()
    other_log = tmp_path / "other.log"
    other_log.write_text("another diagram's build")
    (tmp_path / "latexmk").symlink_to("/usr/bin/true")
    monkeypatch.setenv("PATH", str(tmp_path))
    converted: list[str] = []
    monkeypatch.setattr(render_tikz, "pdf_to_svg_png_compressed", converted.append)
    render_tikz.render_tikz(str(source))
    assert converted == [str(tmp_path / "diagram.pdf")]
    assert all(not output.is_file() for output in auxiliary)
    assert other_log.read_text() == "another diagram's build"


@pytest.mark.parametrize("metadata_flag", ["", "preserve_colors", "hide"])
def test_finalize_assets(
    metadata_flag: str, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Keep the PNG master, preserve AVIF resolution/alpha, and recolor eligible previews."""
    base_path = f"{tmp_path}/diagram"
    metadata = f"{metadata_flag}: true" if metadata_flag else "title: Test"
    (tmp_path / "diagram.yml").write_text(metadata)
    colors = [(0, 0, 0, 255), (255, 255, 255, 255), (0, 0, 0, 128), (137, 21, 83, 0)]
    colors.extend((shade, shade, shade, 255) for shade in range(256))
    original = bytes(channel for color in colors for channel in color)
    with pytest.raises(FileNotFoundError, match="diagram.png"):
        finalize_assets(base_path)
    subprocess.run(
        [
            "magick",
            "-size",
            "260x1",
            "-depth",
            "8",
            "rgba:-",
            "-units",
            "PixelsPerInch",
            "-density",
            "400",
            f"{base_path}.png",
        ],
        input=original,
        check=True,
    )
    png_size = os.path.getsize(f"{base_path}.png")
    metadata_command = [
        "magick",
        "identify",
        "-format",
        "%x %y %[gamma]",
        f"{base_path}.png",
    ]
    png_metadata = subprocess.check_output(metadata_command)
    finalize_assets(base_path)
    assert os.path.getsize(f"{base_path}.png") <= png_size
    assert subprocess.check_output(metadata_command) == png_metadata
    assert read_rgba(f"{base_path}.png") == original
    assert not os.path.isfile(f"{base_path}-hd.png")
    dark_path = f"{base_path}-dark.avif"
    assert os.path.isfile(dark_path) is not bool(metadata_flag)
    previews = (
        [f"{base_path}.avif"] if metadata_flag else [f"{base_path}.avif", dark_path]
    )
    for preview in previews:
        pixels = read_rgba(preview)
        assert len(pixels) == len(original)
        # AVIF is lossy: allow at most 2/255 alpha levels of quantization on this ramp.
        assert all(
            abs(actual - expected) <= 2
            for actual, expected in zip(pixels[3::4], original[3::4], strict=True)
        )
        if preview == dark_path:
            assert min(pixels[:3]) >= 227  # Black ink becomes light.
            assert max(pixels[4:7]) <= 28  # White fills become dark, remaining opaque.
    # Exercise a real failing subprocess without depending on the installed optimizer.
    (tmp_path / "zopflipng").symlink_to("/usr/bin/false")
    monkeypatch.setenv("PATH", str(tmp_path))
    with pytest.raises(subprocess.CalledProcessError):
        finalize_assets(base_path)
    (tmp_path / "zopflipng").unlink()
    with pytest.raises(FileNotFoundError, match="zopflipng"):
        finalize_assets(base_path)


@pytest.mark.parametrize("n_diagrams", [1, 2, 3])
def test_readme_preview_files_exist(n_diagrams: int) -> None:
    """Keep every generated README theme source backed by an actual preview file."""
    diagrams = collect_diagrams()
    table = generate_table(diagrams)
    assert table
    assert all(diagram.provenance_links.count("](<") <= 2 for diagram in diagrams)
    assert "high-entropy-alloy-dark.avif" not in table
    sierpinski = next(item for item in diagrams if item.name == "sierpinski-triangle")
    title, _image = table_cell(sierpinski)
    assert title.count("<https://doi.org/10.1021/jacs.7b05720>") == 1
    assert title.index("sierpinski-triangle.typ") < title.index("reference-icon")
    for icon in ("reference", "creator", "source"):
        assert os.path.isfile(f"{ROOT}/assets/icons/{icon}.svg")
    rows = generate_table(diagrams[:n_diagrams]).splitlines()
    assert all(row.startswith("| ") and row.endswith(" |") for row in rows)
    assert len(rows) == 2 + 2 * ((n_diagrams + 1) // 2)
    assert all(row.endswith("| &nbsp; |") for row in rows[-2:]) == bool(n_diagrams % 2)
    visible = {diagram.name for diagram in diagrams}
    assert {"materials-informatics", "ergodic"} <= visible
    assert visible.isdisjoint(
        {
            "materials-informatics-challenges",
            "momentum-shell",
            "dna-double-helix",
            "risk-opportunity-matrix",
        }
    )


@pytest.mark.parametrize("preserve_colors", [False, True])
@pytest.mark.parametrize("with_provenance", [False, True])
def test_readme_theme_sources(
    preserve_colors: bool,
    with_provenance: bool,
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Limit provenance to two prioritized links and select the correct theme artwork."""
    monkeypatch.setattr("update_readme_table.ROOT", str(tmp_path))
    asset_dir = tmp_path / "assets" / "diagram"
    asset_dir.mkdir(parents=True)
    (asset_dir / "diagram.typ").touch()
    metadata = {
        "title": 'A "quoted" title',
        "description": "An [internal link](../another-diagram).",
        "preserve_colors": preserve_colors,
    }
    if with_provenance:
        metadata.update(
            creator="Example Creator",
            creator_url="https://creator.example/",
            url="https://original.example/diagram",
            references=[
                {
                    "paper": {
                        "title": 'A "quoted" [study] | notes',
                        "doi": "10.1234/Example(2024)",
                        "url": "https://arxiv.org/abs/1234.5678",
                    },
                    "repeated": {"doi": "https://dx.doi.org/10.1234/example(2024)"},
                    "unlinked": {"title": "A citation without a URL"},
                }
            ],
        )
    (asset_dir / "diagram.yml").write_text(yaml.safe_dump(metadata))
    (diagram,) = collect_diagrams()
    suffixes = (".avif",) if preserve_colors else (".avif", "-dark.avif")
    for suffix in suffixes:
        with pytest.raises(FileNotFoundError, match=f"diagram{suffix}"):
            table_cell(diagram)
        (asset_dir / f"diagram{suffix}").touch()
    title, image = table_cell(diagram)
    assert title.index("<sub>") < title.index("[![")
    assert title.endswith("</sub>")
    assert 'alt="A &quot;quoted&quot; title"' in image
    assert ("prefers-color-scheme: dark" in image) is not preserve_colors
    assert ("-dark.avif" in image) is not preserve_colors
    if with_provenance:
        assert re.findall(r"\]\(<([^>]+)>", title) == [
            "https://doi.org/10.1234/Example(2024)",
            "https://creator.example/",
        ]
        assert "Creator: Example Creator][creator-icon]" in title
        assert "Reference: A &quot;quoted&quot; &#91;study&#93; &#124; notes" in title
        assert "another-diagram" not in title
        assert "|" not in title
    else:
        assert "-icon]" not in title


@pytest.mark.parametrize(
    "slug, white_foreground",
    [
        ("feynman-building-blocks", False),
        ("xc-functional", True),
        ("feynman-diagram-loop", False),
        ("convexity-and-jensens-inequality", False),
        ("critical-temperature", False),
        ("zt-vs-n", False),
        ("theta-beta-m-diagram", False),
    ],
)
def test_sources_render_shaded_backgrounds(
    slug: str, white_foreground: bool, tmp_path: Path
) -> None:
    """Render transparent pages with opaque gray masks, panels, and nested legends."""
    output_path = f"{tmp_path}/{slug}.png"
    subprocess.run(
        [
            "typst",
            "compile",
            "--root",
            ROOT,
            f"{ROOT}/assets/{slug}/{slug}.typ",
            output_path,
            "--ppi",
            "72",
        ],
        check=True,
    )
    opaque = subprocess.check_output(
        ["magick", "identify", "-format", "%[opaque]", output_path], text=True
    )
    assert opaque == "False", f"{slug} rendered an opaque page"
    if not white_foreground:
        raw_pixels = read_rgba(output_path)
        pixels = {
            tuple(raw_pixels[offset : offset + 4])
            for offset in range(0, len(raw_pixels), 4)
        }
        # The single thermoelectric plot has no panel or inset legend to shade.
        if slug != "zt-vs-n":
            assert (205, 211, 218, 255) in pixels, f"{slug} lost its opaque gray fill"
        # Ignore faint antialiased edges, but include CeTZ's alpha-200 white legend.
        assert not any(
            alpha >= 128 and min(red, green, blue) > 235
            for red, green, blue, alpha in pixels
        ), f"{slug} still contains white or near-white artwork"
