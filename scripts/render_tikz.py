import os
import subprocess
import sys

sys.path.append(os.path.dirname(__file__))

from convert_assets import pdf_to_svg_png_compressed

# Get name of directory containing the TeX file.
tex_file = sys.argv[1]

# Get base path of TeX file, i.e. path without extension.
base_path = os.path.splitext(tex_file)[0]
in_dir = os.path.dirname(tex_file)

print("Running latexmk to generate PDF from TeX file")
ret_val = subprocess.run(
    ["latexmk", "-silent", "-pdf", f"-jobname={base_path}", tex_file],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
).returncode

if os.getenv("CI") == "true":
    print("Detected CI=true")
    if ret_val != 0:
        with open(f"{base_path}.log", mode="r") as file:
            print(file.read())
        raise SystemExit(f"latexmk failed with return code {ret_val}. See log above.")

print("Delete LaTeX auxiliary files")
for file in os.listdir(in_dir):
    if file.endswith(("aux", "log", "fls", "fdb_latexmk")):
        os.remove(f"{in_dir}/{file}")

pdf_to_svg_png_compressed(f"{base_path}.pdf")

print("Update readme table listing all figures in assets/")
subprocess.run(["python", "scripts/update_readme_table.py"])
