"""Check the geometry computed by the diagram sources through Typst."""

import json
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from itertools import batched, pairwise, product
from math import cos, exp, fsum, hypot, radians, sin
from pathlib import Path

import pytest
from convert_assets import PNG_PPI

ROOT = os.path.dirname(os.path.dirname(__file__))


@pytest.mark.parametrize(
    ("slug", "max_margin"),
    [
        ("convex-hull-of-stability", 4),
        ("seebeck-effect", 5),
        # The formula's .3cm padding adds 8.5pt beyond the 8pt page margin.
        ("spherical-volume-element", 18),
        # The projected 3D axes reserve additional space beyond the 8pt page margin.
        ("saddle-point", 31),
    ],
)
def test_standalone_artwork_has_compact_margins(
    slug: str, max_margin: int, tmp_path: Path
) -> None:
    """Exclude fixed paper margins and invisible construction geometry from exports."""
    output_path = str(tmp_path / f"{slug}.png")
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
    geometry = subprocess.check_output(
        ["magick", output_path, "-alpha", "extract", "-format", "%w %h %@", "info:"],
        text=True,
    )
    width, height, ink_width, ink_height, left, top = map(
        int, re.findall(r"\d+", geometry)
    )
    margins = (left, top, width - left - ink_width, height - top - ink_height)
    # At 72ppi one pixel is one point; allow 1pt rasterization slack at each edge.
    assert all(0 <= margin <= max_margin for margin in margins), (slug, margins)


def test_atomistic_flowchart_has_visible_forward_arrows(tmp_path: Path) -> None:
    """Keep enough space between boxes for all six forward arrow shafts."""
    output_path = tmp_path / "atomistic.svg"
    subprocess.run(
        [
            "typst",
            "compile",
            "--root",
            ROOT,
            f"{ROOT}/assets/atomistic-simulation-methods/atomistic-simulation-methods.typ",
            str(output_path),
        ],
        check=True,
    )
    shafts = [
        node.get("d", "")
        for node in ET.parse(output_path).iter("{http://www.w3.org/2000/svg}path")
        if node.get("stroke") == "#aaaaaa" and "Z" not in node.get("d", "")
    ]
    assert len(shafts) == 6
    for shaft in shafts:
        displacement = re.search(r"h (-?[\d.]+)$", shaft)
        # A shaft must run rightward and exceed the roughly 6pt arrowhead length.
        assert displacement and float(displacement[1]) > 6, shaft


def test_train_test_split_preserves_rows_and_table_bounds(tmp_path: Path) -> None:
    """Split seven schematic rows into 4/3 with correct highlights and table bounds."""
    output_path = tmp_path / "train-test-split.svg"
    subprocess.run(
        [
            "typst",
            "compile",
            "--root",
            ROOT,
            f"{ROOT}/assets/train-test-split/train-test-split.typ",
            str(output_path),
        ],
        check=True,
    )
    row_height = 72 / 2.54  # CeTZ's default unit is 1 cm, SVG coordinates are points.
    tables: list[list[tuple[float, float, str]]] = []
    for node in ET.parse(output_path).iter("{http://www.w3.org/2000/svg}path"):
        path = node.get("d", "")
        if node.get("stroke") != "#0099cc" or "Z" not in path:
            continue
        height_match = re.search(r"v ([\d.]+)", path)
        position_match = re.fullmatch(
            r"translate\([-\d.]+ ([-\d.]+)\)", node.get("transform", "")
        )
        assert height_match and position_match, node.attrib
        height, top = float(height_match[1]), float(position_match[1])
        if height > 1.5 * row_height:
            tables.append([])  # Each table is drawn before its header and row fills.
        tables[-1].append((top, height, node.get("fill", "")))

    # Full dataset is unstriped; feature/target tables show 7 rows, then 4 + 3.
    assert [len(table) - 2 for table in tables] == [0, 7, 7, 4, 4, 3, 3]
    for table, row_count in zip(tables, [7, 7, 7, 4, 4, 3, 3], strict=True):
        top, height, _fill = table[0]
        # SVG serializes 9 decimal places; 1e-7pt covers accumulated serialization error.
        assert height == pytest.approx((row_count + 1) * row_height, rel=0, abs=1e-7)
        for row_idx, (row_top, height, _fill) in enumerate(table[1:]):
            assert row_top == pytest.approx(top + row_idx * row_height, rel=0, abs=1e-7)
            assert height == pytest.approx(row_height, rel=0, abs=1e-7)
    for source_idx, split_idx, highlight in [(1, 5, "#80dfdf"), (2, 6, "#ffe680")]:
        selected = [
            row_idx
            for row_idx, (_top, _height, fill) in enumerate(tables[source_idx][2:])
            if fill == highlight
        ]
        assert selected == [1, 4, 6]
        assert len(selected) == len(tables[split_idx]) - 2 == 3


@pytest.mark.parametrize(
    "slug",
    [
        "amplitude-vs-frequency-modulation",
        "atomistic-simulation-methods",
        "autoencoder-architectures",
        "complex-sign-function",
        "convexity-and-jensens-inequality",
        "feynman-building-blocks",
        "fractal-atlas",
        "gibbs-free-energy",
        "gpu-batching",
        "graph-neural-networks",
        "matsubara-contours",
        "ml-activations",
        "normalizing-flows",
        "particle-statistics",
        "quantum-harmonic-oscillator",
        "regulated-and-unregulated-propagators",
        "string-worldsheet-topologies",
        "symmetry-breaking",
    ],
)
def test_compound_layout_follows_artwork_aspect_ratios(slug: str) -> None:
    """Fill each card's width and balance neighboring drawings without height caps."""
    stacked = slug in {
        "atomistic-simulation-methods",
        "gpu-batching",
        "regulated-and-unregulated-propagators",
    }
    measurements = (
        """
  measure(stack(dir: ttb, spacing: 12pt,
    card([], rect(width: 400pt, height: 100pt), []),
    card([], rect(width: 400pt, height: 100pt), []),
  ), width: 400pt),
  measure(card([], rect(width: 400pt, height: 100pt), []), width: 400pt),
"""
        if stacked
        else """
  measure(card-grid(
    ([], rect(width: 400pt, height: 100pt), []),
    ([], rect(width: 100pt, height: 100pt), []),
  ), width: 400pt),
  measure(card-grid(columns: 1,
    ([], rect(width: 100pt, height: 100pt), []),
  ), width: 92pt),
"""
    )
    source = f"""
#import "/assets/{slug}/{slug}.typ": {"card" if stacked else "card-grid"}
#let panel(body) = {"card([], body, [])" if stacked else "card-grid(columns: 1, ([], body, []))"}
#set page(width: 400pt, height: auto, margin: 0pt)
#context [#metadata((
  measure(panel(rect(width: 50pt, height: 100pt)), width: 224pt),
  measure(panel(rect(width: 400pt, height: 100pt)), width: 224pt),
  {measurements}
)) <bounds>]
"""
    output = subprocess.check_output(
        [
            "typst",
            "query",
            "--root",
            ROOT,
            "-",
            "<bounds>",
            "--field",
            "value",
            "--one",
        ],
        input=source,
        text=True,
    )
    tall, wide, row, single = json.loads(output)
    assert tall["width"] == wide["width"] == "224pt"
    # 24pt padding leaves 200pt for artwork: tall/wide heights differ by 350pt.
    # Allow 1e-9pt for serialized layout arithmetic, far below a rendered pixel.
    height_difference = float(tall["height"][:-2]) - float(wide["height"][:-2])
    assert height_difference == pytest.approx(350, rel=0, abs=1e-9)
    if stacked:
        assert row["width"] == single["width"] == "400pt"
        assert float(row["height"][:-2]) == pytest.approx(
            2 * float(single["height"][:-2]) + 12, rel=0, abs=1e-9
        )
    else:
        assert row["width"] == "400pt"
        # 400 - 12 gutter - 48 padding = 340; a 4:1 split gives both drawings 68pt height.
        # The equivalent square needs 68 + 24 padding = 92pt total width.
        assert row["height"] == single["height"]


def test_torus_normalization() -> None:
    """Normalize the second generator by the same complex division as the first."""
    output = subprocess.check_output(
        [
            "typst",
            "eval",
            (
                '{ import "/assets/tori/tori.typ": basis_u, basis_v, normalized_basis; '
                "(basis_u, basis_v, normalized_basis) }"
            ),
            "--root",
            ROOT,
        ],
        text=True,
    )
    basis_u, basis_v, normalized_basis = (
        complex(*components) for components in json.loads(output)
    )
    # A few f64 arithmetic operations: allow 16 machine eps, including near zero.
    tolerance = 16 * sys.float_info.epsilon
    assert normalized_basis == pytest.approx(
        basis_v / basis_u, rel=tolerance, abs=tolerance
    )
    assert normalized_basis.imag > 0


def evaluate_typst(expression: str, *, source: str = "") -> list:
    """Evaluate a Typst array, optionally in a rendered document."""
    output = subprocess.check_output(
        ["typst", "eval", "--root", ROOT, "--in", "-", expression],
        input=source,
        text=True,
    )
    result = json.loads(output)
    assert isinstance(result, list), (expression, result)
    return result


def evaluate_diagram(slug: str, expression: str) -> list:
    """Evaluate the actual scientific helpers used by a standalone diagram."""
    return evaluate_typst(
        f'{{ import "/assets/{slug}/{slug}.typ" as diagram; {expression} }}'
    )


def compile_svg(slug: str, *, source: str | None = None) -> ET.Element:
    """Compile a standalone diagram or an explicit render of its exported helpers."""
    input_path = f"{ROOT}/assets/{slug}/{slug}.typ" if source is None else "-"
    svg = subprocess.check_output(
        ["typst", "compile", "--format", "svg", "--root", ROOT, input_path, "-"],
        input=source,
        text=True,
    )
    return ET.fromstring(svg)


def svg_size(root: ET.Element) -> list[float]:
    """Read a Typst SVG's canvas dimensions in points."""
    return [float(root.attrib[dimension][:-2]) for dimension in ("width", "height")]


def svg_path_points(path: ET.Element) -> list[tuple[float, float]]:
    """Decode endpoints of CeTZ's relative moves, lines and cubic Bezier segments."""
    number_pattern = r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?"
    x_coord, y_coord = map(
        float, re.findall(number_pattern, path.attrib["transform"])
    )
    points = []
    for command, values in re.findall(r"([mlc])([^mlc]*)", path.attrib["d"]):
        coords = list(map(float, re.findall(number_pattern, values)))
        assert len(coords) == {"m": 2, "l": 2, "c": 6}[command]
        x_coord += coords[-2]
        y_coord += coords[-1]
        points.append((x_coord, y_coord))
    return points


def test_spherical_coordinates_guides_share_origin() -> None:
    """Make all four radial guides meet at the marked sphere center in the combined panel."""
    paths = list(
        compile_svg("change-of-variables").iter("{http://www.w3.org/2000/svg}path")
    )
    guides = [
        path
        for path in paths
        if path.get("stroke") == "#cbd5e1" and path.get("stroke-width") == "0.7"
    ]
    assert len(guides) == 4
    markers = [
        path
        for path in paths
        if path.get("fill") == "#64748b" and path.get("d", "").count("c") == 4
    ]
    assert len(markers) == 1
    marker_x, marker_y = svg_path_points(markers[0])[0]
    marker_radius = 0.035 * 72 / 2.54
    center = (marker_x, marker_y + marker_radius)
    for path in guides:
        assert "stroke-dasharray" in path.attrib
        points = svg_path_points(path)
        assert len(points) == 2 and path.attrib["d"].count("l") == 1
        # One translation and move, serialized to 9 decimals: allow 1e-8pt.
        assert points[0] == pytest.approx(center, rel=0, abs=1e-8)


@pytest.mark.parametrize(
    "crop",
    [(-2.75, -1.45, 5.4, 5.2), (0, 0, 4, 3), (-1, -1, 3, 2), (-8, -8, 8, 8)],
)
def test_spherical_volume_crop_bounds(crop: tuple[float, float, float, float]) -> None:
    """Honor crop size and position, including equal-size windows at different origins."""
    source = f"""
#import "/assets/spherical-volume-element/spherical-volume-element.typ": volume_element
#set page(width: auto, height: auto, margin: 0pt, fill: none)
#volume_element(crop: {crop})
"""
    root = compile_svg("spherical-volume-element", source=source)
    x_min, y_min, x_max, y_max = crop
    # Centimeters to points, with 9-decimal SVG serialization: allow 1e-8pt.
    assert svg_size(root) == pytest.approx(
        [(x_max - x_min) * 72 / 2.54, (y_max - y_min) * 72 / 2.54], rel=0, abs=1e-8
    )
    assert len(list(root.iter("{http://www.w3.org/2000/svg}clipPath"))) == 1
    position_vectors = [
        path
        for path in root.iter("{http://www.w3.org/2000/svg}path")
        if path.get("stroke") == "#000000"
        and path.get("stroke-width") == "1.2"
        and path.get("fill") == "none"
    ]
    assert len(position_vectors) == 1
    # The position vector starts at the axes' origin, offset by the crop's top-left corner.
    assert svg_path_points(position_vectors[0])[0] == pytest.approx(
        [-x_min * 72 / 2.54, y_max * 72 / 2.54], rel=0, abs=1e-8
    )


def test_euler_angles_geometry_fills_frame() -> None:
    """Keep projected rotation guides large enough for readable axes and angles."""
    root = compile_svg("euler-angles")
    guide_x = [
        x_coord
        for path in root.iter("{http://www.w3.org/2000/svg}path")
        if "stroke-dasharray" in path.attrib and path.get("d", "").count("c") == 4
        for x_coord, _y_coord in svg_path_points(path)
    ]
    assert len(guide_x) == 15  # Three circles, each with four cubic segments.
    assert (max(guide_x) - min(guide_x)) / svg_size(root)[0] >= 0.7


@pytest.mark.parametrize("slug", ["spherical-volume-element", "euler-angles"])
def test_standalone_exports_match_canvas(slug: str) -> None:
    """Keep downloadable PNGs and both AVIF themes at the authored size and resolution."""
    canvas_size = svg_size(compile_svg(slug))
    exported_svg = ET.parse(f"{ROOT}/assets/{slug}/{slug}.svg").getroot()
    # Both SVGs serialize to 9 decimals; allow 1e-8pt.
    assert svg_size(exported_svg) == pytest.approx(canvas_size, rel=0, abs=1e-8)
    # Typst rounds the 400ppi raster dimensions to the nearest whole pixel.
    pixel_size = [round(length * int(PNG_PPI) / 72) for length in canvas_size]
    for suffix in (".png", ".avif", "-dark.avif"):
        artwork = f"{ROOT}/assets/{slug}/{slug}{suffix}"
        width, height, opaque = subprocess.check_output(
            ["magick", "identify", "-format", "%w %h %[opaque]", artwork], text=True
        ).split()
        assert [int(width), int(height)] == pixel_size, artwork
        assert opaque == "False", artwork


def test_spherical_volume_rendering() -> None:
    """Check physical edge endpoints, occlusion, continuous guides and labels."""
    source = """
#show math.equation: item => [#metadata(repr(item.body)) <formula>#item]
#include "/assets/spherical-volume-element/spherical-volume-element.typ"
"""
    formulas = "$arrow(r)$, $r sin theta$, $d r$, $r d theta$, $r sin theta d phi$, $d V = r^2 sin theta d r d theta d phi$"
    assert (
        evaluate_typst(
            f"{{ let bodies = query(<formula>).map(item => item.value); ({formulas}).map(item => bodies.contains(repr(item.body))) }}",
            source=source,
        )
        == [True] * 6
    )
    full_source = """
#import "/assets/spherical-volume-element/spherical-volume-element.typ": volume_element
#set page(width: auto, height: auto, margin: 8pt, fill: none)
#volume_element(crop: none)
"""
    root = compile_svg("spherical-volume-element", source=full_source)
    assert not list(root.iter("{http://www.w3.org/2000/svg}clipPath"))
    paths = list(root.iter("{http://www.w3.org/2000/svg}path"))
    guides = [
        path
        for path in paths
        if path.get("stroke") in {"#aaaaaa", "#bfbfbf"}
        and path.get("stroke-width") == "0.5"
    ]
    radius = 4 * 72 / 2.54
    center_x, circle_y = svg_path_points(guides[0])[0]
    center_y = circle_y + radius
    guide_paths = [path for path in guides if path.attrib["d"].count("c") == 2]
    assert len(guide_paths) == 6
    assert sum("stroke-dasharray" in path.attrib for path in guide_paths) == 3
    azimuth, elevation = radians(30), radians(10)
    view = (
        cos(elevation) * cos(azimuth),
        cos(elevation) * sin(azimuth),
        sin(elevation),
    )

    def project_point(
        cart_x: float, cart_y: float, cart_z: float
    ) -> tuple[float, float]:
        """Independently project Cartesian coordinates from the authored camera view."""
        screen_x = -cart_x * sin(azimuth) + cart_y * cos(azimuth)
        screen_y = (
            -cart_x * sin(elevation) * cos(azimuth)
            - cart_y * sin(elevation) * sin(azimuth)
            + cart_z * cos(elevation)
        )
        return (
            center_x + screen_x * 72 / 2.54,
            center_y - screen_y * 72 / 2.54,
        )

    for path_idx, path in enumerate(guide_paths):
        points = svg_path_points(path)
        for x_coord, y_coord in (points[0], points[-1]):
            # CeTZ rounds matrices to 10 decimals and SVG coordinates to 9; allow 1e-7pt.
            assert hypot(x_coord - center_x, y_coord - center_y) == pytest.approx(
                radius, rel=0, abs=1e-7
            )
        # The front/back centers maximize/minimize depth in each guide's plane.
        active_axes = ((0, 1), (0, 2), (1, 2))[path_idx // 2]
        depth_norm = hypot(*(view[axis] for axis in active_axes))
        depth_sign = -1 if "stroke-dasharray" in path.attrib else 1
        midpoint = project_point(
            *(
                4 * depth_sign * component / depth_norm if axis in active_axes else 0
                for axis, component in enumerate(view)
            )
        )
        assert points[1] == pytest.approx(midpoint, rel=0, abs=1e-7)

    # Independently project all eight physical corners to validate the drawn edges.
    corners = {}
    for corner_idx in product((0, 1), repeat=3):
        radius_idx, theta_idx, phi_idx = corner_idx
        radius = 3 + 0.5 * radius_idx
        theta, phi = radians(55 + 12 * theta_idx), radians(50 + 14 * phi_idx)
        cart_x = radius * sin(theta) * cos(phi)
        cart_y = radius * sin(theta) * sin(phi)
        cart_z = radius * cos(theta)
        corners[corner_idx] = project_point(cart_x, cart_y, cart_z)
    edge_paths = [
        path
        for path in paths
        if (path.get("stroke"), path.get("stroke-width"))
        in {("#0074d9", "1"), ("#99c7f0", "0.6")}
    ]
    assert len(edge_paths) == 12
    origin_extensions = [
        path
        for path in paths
        if path.get("stroke") == "#dddddd" and path.get("stroke-width") == "0.6"
    ]
    assert len(origin_extensions) == 3
    assert max(paths.index(path) for path in edge_paths[:3]) < min(
        paths.index(path) for path in origin_extensions
    )
    assert max(paths.index(path) for path in origin_extensions) < min(
        paths.index(path) for path in edge_paths[3:]
    )
    actual_edges = set()
    for path_idx, path in enumerate(edge_paths):
        points = svg_path_points(path)
        endpoints = []
        for point in (points[0], points[-1]):
            distances = {
                idx: hypot(point[0] - vertex[0], point[1] - vertex[1])
                for idx, vertex in corners.items()
            }
            closest = min(distances, key=distances.__getitem__)
            assert distances[closest] == pytest.approx(0, rel=0, abs=1e-7)
            endpoints.append(closest)
        actual_edges.add(frozenset(endpoints))
        assert ((0, 0, 1) in endpoints) == (path_idx < 3)
    assert actual_edges == {
        frozenset((start, end))
        for start in corners
        for end in corners
        if sum(lower != upper for lower, upper in zip(start, end, strict=True)) == 1
    }


@pytest.mark.parametrize("inverse_temperature", [0.1, 0.5, 1, 4, 10, 100])
def test_oscillator_thermodynamics_match_boltzmann_sum(
    inverse_temperature: float,
) -> None:
    """Check energies, occupations, heat capacities, and ladder populations independently."""
    energy, occupation, heat_capacity, probabilities, limits = evaluate_typst(
        f"""{{
          import "/assets/quantum-harmonic-oscillator/quantum-harmonic-oscillator.typ": energy-in-quanta, energy-in-thermal-units
          import "/assets/particle-statistics/particle-statistics.typ": bose-occupation
          import "/assets/einstein-crystal/einstein-crystal.typ": mode_cv, level_probability
          let inverse = {inverse_temperature}
          (
            energy-in-quanta(inverse), bose-occupation(inverse), mode_cv(inverse),
            range(5).map(level => level_probability(level, 1 / inverse)),
            ((0,1e-8).map(energy-in-thermal-units), energy-in-quanta(1000), mode_cv(0)),
          )
        }}""",
    )
    weights = [exp(-inverse_temperature * level) for level in range(1000)]
    partition = fsum(weights)
    mean = fsum(level * weight for level, weight in enumerate(weights)) / partition
    variance = (
        fsum(level**2 * weight for level, weight in enumerate(weights)) / partition
        - mean**2
    )
    # The omitted Boltzmann tail is < 4e-42; these tolerances cover f64 accumulation.
    tolerance = 1e-12 * max(1, mean + 0.5)
    assert energy == pytest.approx(mean + 0.5, rel=0, abs=tolerance)
    assert occupation == pytest.approx(mean, rel=0, abs=tolerance)
    assert heat_capacity == pytest.approx(
        inverse_temperature**2 * variance, rel=1e-12, abs=0
    )
    assert probabilities == pytest.approx(
        [weight / partition for weight in weights[:5]], rel=1e-14, abs=0
    )
    assert limits == [[1, 1], 0.5, 1]


def test_debye_heat_capacity_matches_independent_quadrature() -> None:
    """Validate the plotted Debye integral from freeze-out to the classical limit."""
    actual = evaluate_diagram(
        "einstein-crystal",
        "(0,0.01,0.1,0.2,0.5,1,2,10,100).map(diagram.debye_cv)",
    )
    # 60-digit adaptive quadrature of 3*y²*c_mode(y/T) on y in [0,1].
    # The diagram's 400-step Simpson rule has measured relative error < 6e-12.
    expected = [
        0,
        0.0000779272728272019498,
        0.0758210030310913252,
        0.368634823605172392,
        0.825408038412502814,
        0.951732135703279447,
        0.987610752099737466,
        0.999500178516329711,
        0.999995000017857088,
    ]
    assert actual == pytest.approx(expected, rel=1e-11, abs=0)


def test_einstein_microstates_exhaust_fixed_energy_allocations() -> None:
    """Show each allocation of two quanta across three modes exactly once."""
    allocations = evaluate_diagram("einstein-crystal", "diagram.allocations")
    expected = [list(state) for state in product(range(3), repeat=3) if sum(state) == 2]
    assert sorted(allocations) == expected


def test_wannier_equation_keeps_position_outside_subscripts() -> None:
    """Keep x as the function argument, separate from Wannier and Bloch state indices."""
    source = """
#show math.equation: item => [#metadata(repr(item.body)) <formula>#item]
#include "/assets/wannierization-and-wannier-centers/wannierization-and-wannier-centers.typ"
"""
    formula = "$w_(R)(x) = 1 / sqrt(N_k) sum_k e^(-i k R) e^(i phi(k)) psi_(k)(x)$"
    assert evaluate_typst(
        f"(query(<formula>).any(item => item.value == repr({formula}.body)),)",
        source=source,
    ) == [True]


@pytest.mark.parametrize("cell_idx", [-14, -7, *range(-3, 4), 7, 14])
def test_wannier_phase_arrows_reinforce_or_close(cell_idx: int) -> None:
    """Add seven unit phases at each periodic target and cancel in other cells."""
    vertices = evaluate_diagram(
        "wannierization-and-wannier-centers",
        f"diagram.phase_vertices({cell_idx})",
    )
    assert len(vertices) == 8
    # Seven unit vectors evaluated with f64 trig; allow 64 eps for accumulated error.
    tolerance = 64 * sys.float_info.epsilon
    for start, end in pairwise(vertices):
        length_squared = fsum(
            (end_coord - start_coord) ** 2
            for start_coord, end_coord in zip(start, end, strict=True)
        )
        assert length_squared == pytest.approx(1, rel=0, abs=tolerance)
    assert vertices[-1] == pytest.approx(
        [7 if cell_idx % 7 == 0 else 0, 0], rel=0, abs=tolerance
    )


def test_wannier_gauge_preserves_total_occupied_density() -> None:
    """Change individual orbital weights while preserving the filled-band density."""
    probabilities, densities = evaluate_diagram(
        "wannierization-and-wannier-centers",
        """(
          (diagram.localized_gauge.probabilities, diagram.spread_gauge.probabilities),
          (range(281).map(sample_idx => -3.5 + sample_idx / 40) + (
            -4, -3.36, -0.360000000001, -0.36, -0.359999999999,
            0.359999999999, 0.36, 0.360000000001, 3.36, 4,
          )).map(position => (
            (diagram.localized_gauge.density)(position),
            (diagram.spread_gauge.density)(position),
            diagram.cell_indices.map(cell_idx =>
              calc.pow(diagram.local_orbital(position - cell_idx), 2)).sum(),
          )),
        )""",
    )
    # Several seven-term sums and products: 128 eps covers their accumulated f64 error.
    tolerance = 128 * sys.float_info.epsilon
    for gauge_probabilities in probabilities:
        assert min(gauge_probabilities) >= 0
        assert fsum(gauge_probabilities) == pytest.approx(1, rel=0, abs=tolerance)
    assert probabilities[0][3] == pytest.approx(1, rel=0, abs=tolerance)
    assert probabilities[1][3] < 0.5
    for constant_gauge, spread_gauge, site_density in densities:
        assert (constant_gauge, spread_gauge) == pytest.approx(
            (site_density, site_density), rel=tolerance, abs=tolerance
        )


@pytest.mark.parametrize(
    ("example_name", "expected_center"),
    [("center_example", 0.7), ("si_bond", 0.5), ("gaas_bond", 0.617)],
)
def test_wannier_center_matches_drawn_density_and_balance(
    example_name: str, expected_center: float
) -> None:
    """Normalize the center and chemical-bond examples and verify their first moments."""
    density, center, left_weight, sigma = evaluate_diagram(
        "wannierization-and-wannier-centers",
        f"""{{
          let bond = diagram.{example_name}
          (
            range(2801).map(sample_idx => (bond.density)(-3 + sample_idx / 400)),
            bond.center, bond.left_weight, bond.sigma,
          )
        }}""",
    )
    # At least 64 points per Gaussian sigma; tails outside [-3, 4] are <1e-22.
    # Allow 128 f64 eps for sampling, weighted summation, and Typst serialization.
    tolerance = 128 * sys.float_info.epsilon
    assert center == pytest.approx(expected_center, rel=0, abs=tolerance)
    moments = [
        fsum(
            sample
            * (-3 + sample_idx / 400) ** order
            * (0.5 if sample_idx in (0, len(density) - 1) else 1)
            for sample_idx, sample in enumerate(density)
        )
        / 400
        for order in range(3)
    ]
    assert moments == pytest.approx(
        [1, center, sigma**2 + center], rel=0, abs=tolerance
    )
    assert left_weight * center == pytest.approx(
        (1 - left_weight) * (1 - center), rel=0, abs=tolerance
    )


@pytest.mark.parametrize("caller_font_size", [8, 20])
@pytest.mark.parametrize("slug", ["atomistic-simulation-methods", "change-of-variables"])
def test_compound_typography_uses_consistent_readable_sizes(
    caller_font_size: int, slug: str
) -> None:
    """Keep labels, headings, captions, and takeaways independent of caller text size."""
    if slug == "change-of-variables":
        imports = "card"
        panels = """
#card([Panel heading], [Coordinate formula], box(width: 200pt, height: 80pt)[Diagram label], [Jacobian factors], [Measure formula], [Panel caption])
"""
        expected = {
            "Panel heading": 21,
            "Coordinate formula": 18,
            "Diagram label": 14,
            "Jacobian factors": 18,
            "Measure formula": 24,
            "Panel caption": 17,
        }
    else:
        imports = "card, takeaway"
        panels = """
#card([Panel heading], box(width: 200pt, height: 80pt)[Diagram label], [Panel caption])
#takeaway[Takeaway paragraph]
"""
        expected = {
            "Panel heading": 16,
            "Diagram label": 12,
            "Panel caption": 14,
            "Takeaway paragraph": 14,
        }
    source = f"""
#import "/assets/{slug}/{slug}.typ": {imports}
#set page(width: 300pt, height: auto, margin: 0pt)
#set text(size: {caller_font_size}pt)
#show text: item => context [#metadata((item.text, text.size / 1pt)) <typography>#item]
{panels}
"""
    sizes = dict(evaluate_typst("query(<typography>).map(item => item.value)", source=source))
    assert sizes == expected


def test_sabatier_binding_regimes(tmp_path: Path) -> None:
    """Label the correct binding regimes and anchor the optimum above the spline peak."""
    assert evaluate_diagram("sabatier-principle", "diagram.limitations") == [
        "activation of reactant",
        "desorption of product",
    ]
    svg_path = tmp_path / "sabatier.svg"
    subprocess.run(
        [
            "typst",
            "compile",
            "--root",
            ROOT,
            f"{ROOT}/assets/sabatier-principle/sabatier-principle.typ",
            str(svg_path),
        ],
        check=True,
    )
    paths = list(ET.parse(svg_path).iter("{http://www.w3.org/2000/svg}path"))
    curve = next(path for path in paths if path.get("stroke-width") == "1.2")
    leader = next(path for path in paths if path.get("stroke") == "#39cccc")
    assert paths.index(leader) < paths.index(curve)
    curve_offset = list(map(float, re.findall(r"-?[\d.]+", curve.get("transform", ""))))
    leader_offset = list(
        map(float, re.findall(r"-?[\d.]+", leader.get("transform", "")))
    )
    commands = re.findall(r"([Mmc])([^Mmc]+)", curve.get("d", ""))
    start = 0j
    points = []
    for command, raw in commands:
        coordinates = [
            complex(*pair) for pair in batched(map(float, raw.split()), 2, strict=True)
        ]
        if command == "M":
            start = coordinates[0]
        elif command == "m":
            start += coordinates[0]
        else:
            controls = [start, *(start + offset for offset in coordinates)]
            for sample in range(1001):
                phase = sample / 1000
                weights = (
                    (1 - phase) ** 3,
                    3 * (1 - phase) ** 2 * phase,
                    3 * (1 - phase) * phase**2,
                    phase**3,
                )
                points.append(
                    sum(
                        weight * point
                        for weight, point in zip(weights, controls, strict=True)
                    )
                )
            start = controls[-1]
    peak = min(points, key=lambda point: point.imag)
    blue = next(path for path in paths if path.get("fill") == "#c8dcff")
    orange = next(path for path in paths if path.get("fill") == "#ffe6c8")
    blue_origin = float(re.findall(r"-?[\d.]+", blue.get("transform", ""))[0])
    blue_width = re.search(r"h ([\d.]+)", blue.get("d", ""))
    assert blue_width
    orange_origin = float(re.findall(r"-?[\d.]+", orange.get("transform", ""))[0])
    # SVG coordinates serialize to 9 decimal places; allow 1e-8pt for summed offsets.
    assert blue_origin + float(blue_width[1]) == pytest.approx(
        leader_offset[0], rel=0, abs=1e-8
    )
    assert orange_origin == pytest.approx(leader_offset[0], rel=0, abs=1e-8)
    # Sampling at 0.001 parameter steps locates the peak within 0.05pt, below one pixel.
    assert leader_offset[0] == pytest.approx(
        curve_offset[0] + peak.real, rel=0, abs=0.05
    )
    leader_start = re.search(r"m 0 ([\d.]+)", leader.get("d", ""))
    assert leader_start
    gap = curve_offset[1] + peak.imag - leader_offset[1] - float(leader_start[1])
    assert 0.8 < gap < 1.5  # About 1pt clearance, including the 0.6pt curve half-width.


def test_branch_and_bound_optimality_certificate() -> None:
    """Check the displayed LP vertices and exhaustively certify the integer optimum."""
    result = evaluate_diagram(
        "branch-and-bound",
        """(
      diagram.lp_points.map(point => (..point, diagram.objective(..point), diagram.feasible(..point))),
      range(5).map(x => range(5).filter(y => diagram.feasible(x,y)).map(y => diagram.objective(x,y))).flatten(),
    )""",
    )
    vertices, integer_values = result
    # The root's dual weights (4/3, 1/3) certify U = (4/3)*4 + (1/3)*4.
    # In the x <= 1 branch, 3x+2y = 2x+(x+2y) <= 2+4 = 6.
    tolerance = 16 * sys.float_info.epsilon
    for vertex, expected in zip(
        vertices,
        [(4 / 3, 4 / 3, 20 / 3), (2, 0, 6), (1, 1.5, 6), (1, 1, 5), (0, 2, 4)],
        strict=True,
    ):
        assert vertex[-1] is True
        assert vertex[:3] == pytest.approx(expected, rel=tolerance, abs=tolerance)
    assert max(integer_values) == 6
    # Left-first traversal: x <= 1, y <= 1 bounds z by 5.
    # In its sibling, y >= 2 and x+2y <= 4 force (x,y)=(0,2).
    assert vertices[4][2] < vertices[3][2] < vertices[1][2]


def test_thermoelectric_curve_normalization() -> None:
    """Normalize each transport curve independently without moving its samples."""
    result = evaluate_diagram(
        "zt-vs-n",
        """(
      diagram.curves.map(curve => (curve.points, diagram.normalize(curve.points))),
      diagram.zt_peak,
      diagram.plot_points,
    )""",
    )
    curves, peak, plotted = result
    assert len(curves) == 5
    tolerance = 4 * sys.float_info.epsilon  # One division of positive f64 values.
    for original, normalized in curves:
        maximum = max(value for _, value in original)
        assert [carrier for carrier, _ in original] == [
            carrier for carrier, _ in normalized
        ]
        assert [value for _, value in normalized] == pytest.approx(
            [value / maximum for _, value in original],
            rel=tolerance,
            abs=0,
        )
        assert max(value for _, value in normalized) == 1
    assert peak == max(curves[0][0], key=lambda point: point[1])
    # Dense curves retain every input point exactly and cannot introduce new extrema.
    for idx, (dense, (original, normalized)) in enumerate(
        zip(plotted, curves, strict=True)
    ):
        knots = original if idx == 0 else normalized
        assert len(dense) == 100
        assert all(knot in dense for knot in knots)
        assert all(left[0] < right[0] for left, right in pairwise(dense))
        for left, right in pairwise(knots):
            values = [point[1] for point in dense if left[0] <= point[0] <= right[0]]
            # Cubic evaluation uses ~20 f64 operations; allow 32 eps of endpoint scale.
            slack = 32 * sys.float_info.epsilon * max(abs(left[1]), abs(right[1]))
            assert min(values) >= min(left[1], right[1]) - slack
            assert max(values) <= max(left[1], right[1]) + slack
            direction = 1 if right[1] >= left[1] else -1
            assert all(
                direction * (after - before) >= -slack
                for before, after in pairwise(values)
            )

    # A symmetric peak has zero tangent at its center and secant endpoint tangents.
    # Its half-interval values are 5/8, distinguishing cubic smoothing from straight lines.
    example = evaluate_diagram(
        "zt-vs-n", "diagram.densify(((1, 0), (10, 1), (100, 0)), sample_count: 5)"
    )
    assert isinstance(example, list)
    assert [value for _, value in example] == [0, 0.625, 1, 0.625, 0]
    assert [carrier for carrier, _ in example] == pytest.approx(
        [1, 10**0.5, 10, 10**1.5, 100], rel=4 * sys.float_info.epsilon, abs=0
    )


@pytest.mark.parametrize(
    "slug,formulas",
    [
        ("zt-vs-n", [r"f(n) \/ (max f)"]),
        (
            "critical-temperature",
            [r"sqrt(3)(T_c \/ T - 1)^(1 \/ 2)", r"sqrt(3)(T \/ T_c)^(3 \/ 2)"],
        ),
        (
            "branch-and-bound",
            [r"(x,y)=(4 \/ 3,4 \/ 3), quad U=20 \/ 3", r"(1,3 \/ 2)"],
        ),
        ("k-space", [r"2pi \/ L_x", r"2pi \/ L_y"]),
        ("signal-sampling", [r"1 \/ f_s", r"2 \/ f_s", r"3 \/ f_s"]),
        (
            "thermo-ensemble-trafos",
            [
                r"sigma = S_m \/ N",
                r"f = F \/ N",
                r"Omega \/ V",
                r"epsilon = E \/ N",
                r"rho = N \/ V",
            ],
        ),
        ("how-atoms-become-energy-bands", [r"-pi \/ a", r"pi \/ a", r"k = pi \/ a"]),
        ("quantum-harmonic-oscillator", [r'beta=1 \/ (k_"B" T)', r"ℏ omega \/ 2"]),
        ("particle-statistics", [r"prop 1 \/ beta", r'beta=1 \/ (k_"B" T)']),
        ("tori", [r"z mapsto z \/ u", r'tau = v \/ u, quad op("Im") tau > 0']),
        ("torus-fundamental-domain", [r"-1 \/ 2", r"1 \/ 2"]),
        ("gas-pressure-on-wall", [r"1 \/ alpha << ell"]),
        ("spontaneous-magnetization", [r"T \/ T_c"]),
        (
            "isotherms",
            [r"p_0 = R T \/ v", r"p_1 = p_0 + B_1 \/ v^2", r"p_2 = p_1 + B_2 \/ v^3"],
        ),
    ],
)
def test_small_label_ratios_use_inline_math(slug: str, formulas: list[str]) -> None:
    """Render simple label ratios at full size while retaining denominator grouping."""
    source = f"""
#show math.equation: item => [#metadata(repr(item.body)) <formula>#item]
#include "/assets/{slug}/{slug}.typ"
"""
    expected = ", ".join(f"${formula}$" for formula in formulas)
    result = evaluate_typst(
        f"{{ let bodies = query(<formula>).map(item => item.value); ({expected},).map(item => bodies.contains(repr(item.body))) }}",
        source=source,
    )
    assert result == [True] * len(formulas), (slug, formulas, result)


@pytest.mark.parametrize(
    "energy,mass,stiffness", [(1, 1, 1), (4, 2, 3), (0.25, 5, 0.5)]
)
def test_energy_shell_uses_canonical_momentum(
    energy: float, mass: float, stiffness: float
) -> None:
    """Both ellipse intercepts must have the stated Hamiltonian energy."""
    axes = evaluate_diagram(
        "ergodic", f"diagram.shell_axes({energy}, mass: {mass}, stiffness: {stiffness})"
    )
    position, momentum = axes
    tolerance = 16 * sys.float_info.epsilon  # sqrt, multiplication, and division.
    assert stiffness * position**2 / 2 == pytest.approx(energy, rel=tolerance, abs=0)
    assert momentum**2 / (2 * mass) == pytest.approx(energy, rel=tolerance, abs=0)
    assert evaluate_diagram("ergodic", "diagram.angle_point(1, 2)") == [0, 0]


def test_semi_supervised_panels_share_bounds() -> None:
    """Keep identical point coordinates aligned when switching decision boundaries."""
    source = """
#import "/assets/semi-supervised-learning/semi-supervised-learning.typ": example
#context [#metadata((measure(example()), measure(example(use_unlabeled: true)))) <bounds>]
"""
    ((left, right),) = evaluate_typst(
        "query(<bounds>).map(item => item.value)", source=source
    )
    assert left == right


@pytest.mark.parametrize(
    "slug,captions,min_font_size",
    [
        ("ergodic", ["Opposite edges identified.", "Finite segment shown."], 14),
        (
            "semi-supervised-learning",
            ["Gray samples ignored.", "Boundary follows the low-density gap."],
            14,
        ),
        ("matsubara-contours", ["Bosons", "Fermions"], 14),
    ],
)
def test_short_plot_captions_are_centered(
    slug: str, captions: list[str], min_font_size: float
) -> None:
    """Keep centered captions readable, including inline frequency ratios."""
    source = f"""
#show math.frac: fraction => {{
  assert(fraction.num != $omega_2$.body, message: "Use an inline frequency ratio in captions")
  fraction
}}
#show text: item => context [
  #metadata((text: item.text, alignment: repr(align.alignment), size: text.size / 1pt)) <alignment>#item
]
#include "/assets/{slug}/{slug}.typ"
"""
    result = evaluate_typst("query(<alignment>).map(item => item.value)", source=source)
    rendered = {item["text"].lstrip("· "): item for item in result}
    for caption in captions:
        assert rendered[caption]["alignment"] == "center + top"
        assert rendered[caption]["size"] >= min_font_size


@pytest.mark.parametrize(
    "slug,word_budget",
    [
        ("branch-and-bound", 25),
        ("deep-belief-network", 25),
        ("semi-supervised-learning", 45),
        ("qm-cost-vs-acc", 80),
        ("materials-informatics", 55),
        ("zt-vs-n", 55),
        ("ergodic", 75),
    ],
)
def test_diagram_copy_stays_concise(slug: str, word_budget: int) -> None:
    """Keep prose in page descriptions and reserve artwork for labels and equations."""
    source = f"""
#show text: item => [#metadata(item.text) <copy>#item]
#include "/assets/{slug}/{slug}.typ"
"""
    result = evaluate_typst("query(<copy>).map(item => item.value)", source=source)
    # Count rendered English labels, excluding math symbols and numerical values.
    # Budgets allow short label edits, but reject reintroducing paragraph captions.
    words = re.findall(r"\b[A-Za-z]+(?:[–-][A-Za-z]+)*\b", " ".join(result))
    assert len(words) <= word_budget, (slug, len(words), word_budget)


def test_dbn_math_and_footer_are_readable() -> None:
    """Keep math legible and the equation panel compact with subtle shading."""
    source = """
#show math.equation: item => context [#metadata(text.size / 1pt) <math-size>#item]
#show block: item => context {
  if item.fill != none {
    [#metadata((width: measure(item).width / 1pt,
      opacity: item.fill.components().last() / 100%)) <panel>]
  }
  item
}
#include "/assets/deep-belief-network/deep-belief-network.typ"
"""
    sizes, panels = evaluate_typst(
        "(query(<math-size>).map(item => item.value), query(<panel>).map(item => item.value))",
        source=source,
    )
    assert sizes and min(sizes) >= 14
    (panel,) = panels
    assert panel["width"] < 250  # Less than half the 500pt content width.
    assert 0 < panel["opacity"] <= 0.4


def test_qm_cost_plot_qualifies_method_scaling() -> None:
    """Tie plotted costs to specific methods and explicitly qualify the accuracy axis."""
    methods, scope, qualification = evaluate_diagram(
        "qm-cost-vs-acc",
        """(
      diagram.methods.map(method => (method.name, method.exponent)),
      diagram.scope,
      diagram.qualification,
    )""",
    )
    assert dict(methods) == {
        "Semilocal DFT": 3,
        "Hartree–Fock": 4,
        "MP2": 5,
        "CCSD": 6,
        "CCSD(T)": 7,
    }
    assert "Single-reference" in scope and "near equilibrium" in scope
    assert "Schematic" in qualification
    assert all(term in qualification for term in ("system", "observable", "basis"))


def test_materials_molecule_and_descriptor_are_consistent() -> None:
    """Keep the carbonyl double bond and derive the heatmap from the depicted atoms."""
    atoms, bonds, matrix = evaluate_diagram(
        "materials-informatics", "(diagram.atoms, diagram.bonds, diagram.matrix)"
    )
    assert [atom["element"] for atom in atoms] == ["C", "C", "N", "O"] + ["H"] * 5
    valences = [0] * len(atoms)
    for left_idx, right_idx, order in bonds:
        valences[left_idx] += order
        valences[right_idx] += order
    assert valences == [
        {"C": 4, "N": 3, "O": 2, "H": 1}[atom["element"]] for atom in atoms
    ]
    assert len(matrix) == len(atoms)
    # Powers, square root, multiplication, and division span fewer than eight f64 operations.
    tolerance = 8 * sys.float_info.epsilon
    for row_idx, row in enumerate(matrix):
        assert len(row) == len(atoms)
        left = atoms[row_idx]
        for col_idx, value in enumerate(row):
            right = atoms[col_idx]
            assert value == matrix[col_idx][row_idx]
            if row_idx == col_idx:
                expected = 0.5 * left["charge"] ** 2.4
            else:
                separation = (
                    sum(
                        (start - end) ** 2
                        for start, end in zip(left["pos"], right["pos"], strict=True)
                    )
                    ** 0.5
                )
                expected = left["charge"] * right["charge"] / separation
            assert value == pytest.approx(expected, rel=tolerance, abs=0)


@pytest.mark.parametrize(
    "slug,redundant_title",
    [
        ("amplitude-vs-frequency-modulation", "Amplitude vs Frequency Modulation"),
        ("atomistic-simulation-methods", "Atomistic Simulation Methods"),
        ("autoencoder-architectures", "Autoencoder Architectures"),
        ("branch-and-bound", "Branch and bound"),
        ("complex-sign-function", "Complex Sign Function"),
        ("convexity-and-jensens-inequality", "Convexity and Jensen’s Inequality"),
        ("deep-belief-network", "Deep belief network"),
        ("ergodic", "Ergodicity and energy shells"),
        ("feynman-building-blocks", "Feynman Building Blocks"),
        ("fractal-atlas", "Fractal Atlas"),
        ("gibbs-free-energy", "Gibbs Free Energy"),
        ("gpu-batching", "GPU Batching"),
        ("graph-neural-networks", "Graph Neural Networks"),
        ("h2-bond-breaking", "Why breaking H₂ is hard"),
        ("how-atoms-become-energy-bands", "How atoms become energy bands"),
        ("long-short-term-memory", "LSTM"),
        ("matsubara-contours", "Matsubara Contours"),
        ("ml-activations", "ML Activations"),
        ("mosfet", "MOSFET"),
        ("normalizing-flows", "Normalizing Flows"),
        ("particle-statistics", "Particle Statistics"),
        ("periodic-table", "Periodic Table of Elements"),
        ("qm-cost-vs-acc", "Cost versus accuracy"),
        ("quantum-harmonic-oscillator", "Quantum Harmonic Oscillator"),
        (
            "regulated-and-unregulated-propagators",
            "Regulated and Unregulated Propagators",
        ),
        ("semi-supervised-learning", "Semi-supervised learning"),
        ("single-head-attention", "Single-head attention"),
        ("string-worldsheet-topologies", "String Worldsheet Topologies"),
        ("symmetry-breaking", "Symmetry Breaking"),
        ("theta-beta-m-diagram", "Diagram for Diatomic Gases"),
        ("which-band-gap-do-you-mean", "Which “band gap” do you mean?"),
        ("xc-functional", "Exchange & correlation"),
    ],
)
def test_diagrams_omit_redundant_page_titles(slug: str, redundant_title: str) -> None:
    """Keep duplicate page headings out of the rendered artwork."""
    source = f"""
#show text: item => [#metadata(item.text) <copy>#item]
#include "/assets/{slug}/{slug}.typ"
"""
    rendered = evaluate_typst("query(<copy>).map(item => item.value)", source=source)
    assert redundant_title.casefold() not in " ".join(rendered).casefold()
