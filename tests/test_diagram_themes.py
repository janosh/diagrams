"""Check transparent exports and theme-aware README previews."""

import os
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = os.path.dirname(os.path.dirname(__file__))
sys.path.insert(0, f"{ROOT}/scripts")

from convert_assets import finalize_pngs
from update_readme_table import (
    DiagramInfo,
    collect_diagrams,
    generate_table,
    table_cell,
)


def read_rgba(png_path: str) -> bytes:
    """Decode PNG pixels independently of palette and compression choices."""
    return subprocess.check_output(["magick", png_path, "-depth", "8", "rgba:-"])


@pytest.mark.parametrize("metadata_flag", ["", "preserve_colors", "hide"])
def test_finalize_pngs(
    metadata_flag: str, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Preserve both PNGs, recolor only eligible previews, and propagate failures."""
    base_path = f"{tmp_path}/diagram"
    metadata = f"{metadata_flag}: true" if metadata_flag else "title: Test"
    (tmp_path / "diagram.yml").write_text(metadata)
    colors = [(0, 0, 0, 255), (255, 255, 255, 255), (0, 0, 0, 128), (0, 0, 0, 0)]
    colors.extend((shade, shade, shade, 255) for shade in range(256))
    original = bytes(channel for color in colors for channel in color)
    for suffix in (".png", "-hd.png"):
        with pytest.raises(FileNotFoundError, match=f"diagram{suffix}"):
            finalize_pngs(base_path)
        subprocess.run(
            [
                "magick",
                "-size",
                "260x1",
                "-depth",
                "8",
                "rgba:-",
                f"{base_path}{suffix}",
            ],
            input=original,
            check=True,
        )
    finalize_pngs(base_path)
    for suffix in (".png", "-hd.png"):
        assert read_rgba(f"{base_path}{suffix}") == original
    dark_path = f"{base_path}-dark.png"
    assert os.path.isfile(dark_path) is not bool(metadata_flag)
    if not metadata_flag:
        pixels = read_rgba(dark_path)
        assert pixels[3::4] == original[3::4]  # Includes opaque fills and transparency.
        assert min(pixels[:3]) >= 229  # Black ink becomes light.
        assert max(pixels[4:7]) <= 26  # White fills become dark, remaining opaque.
    # Exercise a real failing subprocess without depending on the installed optimizer.
    (tmp_path / "zopflipng").symlink_to("/usr/bin/false")
    monkeypatch.setenv("PATH", str(tmp_path))
    with pytest.raises(subprocess.CalledProcessError):
        finalize_pngs(base_path)


def test_readme_preview_files_exist() -> None:
    """Keep every generated README theme source backed by an actual preview file."""
    diagrams = collect_diagrams()
    assert generate_table(diagrams)
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
def test_readme_theme_sources(
    preserve_colors: bool, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Select dark artwork only for diagrams that permit theme recoloring."""
    monkeypatch.setattr("update_readme_table.ROOT", str(tmp_path))
    asset_dir = tmp_path / "assets" / "diagram"
    asset_dir.mkdir(parents=True)
    (asset_dir / "diagram.typ").touch()
    diagram = DiagramInfo("diagram", 'A "quoted" title', preserve_colors)
    suffixes = (".png",) if preserve_colors else (".png", "-dark.png")
    for suffix in suffixes:
        with pytest.raises(FileNotFoundError, match=f"diagram{suffix}"):
            table_cell(diagram)
        (asset_dir / f"diagram{suffix}").touch()
    _, image = table_cell(diagram)
    assert 'alt="A &quot;quoted&quot; title"' in image
    assert ("prefers-color-scheme: dark" in image) is not preserve_colors
    assert ("-dark.png" in image) is not preserve_colors


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
