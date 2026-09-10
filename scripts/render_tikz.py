import os
import subprocess
import sys

from convert_assets import pdf_to_svg_png_compressed


def render_tikz(input_file: str) -> None:
    """Compile TeX and convert successful output without cleaning up failed builds."""
    base_path = os.path.splitext(input_file)[0]

    print("Running latexmk to generate PDF from TeX file")
    subprocess.run(
        ["latexmk", "-pdf", f"-jobname={base_path}", input_file],
        check=True,
    )

    print("Delete LaTeX auxiliary files")
    for suffix in (".aux", ".log", ".fls", ".fdb_latexmk"):
        auxiliary = f"{base_path}{suffix}"
        if os.path.isfile(auxiliary):
            os.remove(auxiliary)

    pdf_to_svg_png_compressed(f"{base_path}.pdf")


if __name__ == "__main__":
    render_tikz(sys.argv[1])

    print("Update readme table listing all figures in assets/")
    # best-effort post-step (assets are already written); don't fail the render if it errors
    subprocess.run(
        [sys.executable, f"{os.path.dirname(__file__)}/update_readme_table.py"]
    )
