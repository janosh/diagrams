import os
import runpy
import subprocess
import sys

from scripts.convert_assets import pdf_to_svg_png_compressed

# Get name of directory containing the Typst file.
input_file = sys.argv[1]

# Get base path of Typst file, i.e. path without extension.
base_path = os.path.splitext(input_file)[0]

print("Generating PDF from Typst file")
ret_val = subprocess.run(["typst", "compile", input_file]).returncode

pdf_to_svg_png_compressed(f"{base_path}.pdf")

print("Update readme table listing all figures in assets/")
runpy.run_path("scripts/update_readme_table.py")
