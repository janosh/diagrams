import os
import runpy
import subprocess
import sys

# Get name of directory containing the TeX file.
tex_file = sys.argv[1]
in_dir = os.path.dirname(os.path.abspath(tex_file))

# Get basepath of TeX file, i.e. path without extension.
basepath = os.path.splitext(tex_file)[0]

print("Running latexmk to generate PDF from TeX file")
ret_val = subprocess.run(
    ["latexmk", "-silent", "-pdf", f"-jobname={basepath}", tex_file],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
).returncode

if os.getenv("CI") == "true":
    print("Detected CI=true")
    if ret_val != 0:
        with open(f"{basepath}.log", "r") as f:
            print(f.read())
        raise SystemExit(f"latexmk failed with return code {ret_val}. See log above.")

print("Delete LaTeX auxiliary files")
for file in os.listdir(in_dir):
    if file.endswith(("aux", "log", "fls", "fdb_latexmk")):
        os.remove(f"{in_dir}/{file}")

print("\n--- pdf-compressor ---")
os.system(f"pdf-compressor --inplace {basepath}.pdf")

print("Converting PDF to SVG and compressing")
if os.system(f"pdf2svg {basepath}.pdf {basepath}.svg") != 0:
    print("pdf2svg failed, skipping SVG generation")
else:
    svg_size = os.stat(f"{basepath}.svg").st_size
    if svg_size > 500_000:
        os.remove(f"{basepath}.svg")
    else:
        os.system(f"svgo --multipass {basepath}.svg")

# https://stackoverflow.com/q/52998331
if os.getenv("CI") == "true":
    os.system(
        "sudo sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml"
    )

print("\n--- imagemagick: convert PDF to PNG ---")
os.system(f"convert -density 200 {basepath}.pdf {basepath}.png")
os.system(f"convert -density 400 {basepath}.pdf {basepath}-hd.png")

print("\n--- pngquant: compress ---")
os.system(f"pngquant 32 --skip-if-larger --ext .png --force {basepath}.png")
os.system(f"pngquant 32 --skip-if-larger --ext .png --force {basepath}-hd.png")

print("\n--- zopfli: compress ---")
os.system(f"zopflipng -y {basepath}.png {basepath}.png")
os.system(f"zopflipng -y {basepath}-hd.png {basepath}-hd.png")

print("Update readme table listing all TikZ figures in assets/")
runpy.run_path("scripts/update_readme.py")
