"""Check the geometry computed by the diagram sources through Typst."""

import json
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from itertools import batched, pairwise
from pathlib import Path

import pytest

ROOT = os.path.dirname(os.path.dirname(__file__))


@pytest.mark.parametrize(
    ("slug", "max_margin"),
    [
        ("convex-hull-of-stability", 4),
        ("seebeck-effect", 5),
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
    """Render all seven samples exactly once per split without overflowing tables."""
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
        selected = sum(fill == highlight for _top, _height, fill in tables[source_idx][2:])
        assert selected == len(tables[split_idx]) - 2 == 3


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
        ("ergodic", ["Opposite edges identified.", "Finite segment shown."], 10.5),
        (
            "semi-supervised-learning",
            ["Gray samples ignored.", "Boundary follows the low-density gap."],
            10.5,
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
