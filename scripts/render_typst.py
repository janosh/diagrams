import os
import shutil
import subprocess
import sys

sys.path.append(os.path.dirname(__file__))

from convert_assets import compress_png

ROOT = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))


def render_typst(input_file: str) -> None:
    """Compile a Typst file to PDF, SVG, and PNG outputs."""
    base_path = os.path.splitext(input_file)[0]
    compile_cmd = ["typst", "compile", "--root", ROOT, input_file]

    print("Compiling Typst → PDF")
    subprocess.run(compile_cmd, check=True)

    print("Compiling Typst → SVG")
    svg_path = f"{base_path}.svg"
    subprocess.run([*compile_cmd, svg_path, "-f", "svg"], check=True)
    if os.path.isfile(svg_path) and os.path.getsize(svg_path) > 500_000:
        print(f"  SVG too large ({os.path.getsize(svg_path)} bytes), removing")
        os.remove(svg_path)
    elif shutil.which("svgo"):
        subprocess.run(["svgo", "--multipass", svg_path])

    for label, ppi in (("PNG (200 ppi)", "200"), ("PNG HD (400 ppi)", "400")):
        suffix = "-hd.png" if ppi == "400" else ".png"
        out_path = f"{base_path}{suffix}"
        print(f"Compiling Typst → {label}")
        subprocess.run(
            [*compile_cmd, out_path, "-f", "png", "--ppi", ppi],
            check=True,
        )
        compress_png(out_path)


input_file = sys.argv[1]
render_typst(input_file)

print("\nUpdate readme table listing all figures in assets/")
# best-effort post-step (assets are already written); don't fail the render if it errors
subprocess.run([sys.executable, f"{os.path.dirname(__file__)}/update_readme_table.py"])
