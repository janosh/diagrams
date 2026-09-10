import os
import shutil
import subprocess
import sys

from convert_assets import PNG_PPI, finalize_assets

ROOT = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))


def render_typst(input_file: str) -> None:
    """Compile a Typst file to PDF, SVG, PNG, and AVIF outputs."""
    base_path = os.path.splitext(input_file)[0]
    compile_cmd = ["typst", "compile", "--root", ROOT, input_file]

    print("Compiling Typst → PDF")
    subprocess.run(compile_cmd, check=True)

    print("Compiling Typst → SVG")
    svg_path = f"{base_path}.svg"
    subprocess.run([*compile_cmd, svg_path, "-f", "svg", "--pages", "1"], check=True)
    if shutil.which("svgo"):
        subprocess.run(["svgo", "--multipass", svg_path])

    print(f"Compiling Typst → PNG ({PNG_PPI} ppi)")
    subprocess.run(
        [*compile_cmd, f"{base_path}-hd.png", "--pages", "1", "--ppi", PNG_PPI],
        check=True,
    )
    finalize_assets(base_path)


if __name__ == "__main__":
    render_typst(sys.argv[1])

    print("\nUpdate readme table listing all figures in assets/")
    # best-effort post-step (assets are already written); don't fail the render if it errors
    subprocess.run(
        [sys.executable, f"{os.path.dirname(__file__)}/update_readme_table.py"]
    )
