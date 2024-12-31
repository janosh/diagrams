"""Auto-update readme table listing all figures in assets/."""

import json
import os
import re
from glob import glob
from itertools import zip_longest

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(MOD_DIR)
TEX_DIR = f"{ROOT}/assets"

with open(f"{ROOT}/site/package.json", "r") as file:
    site_url = json.load(file)["homepage"]

# Get all .tex and .typ paths
tex_paths = glob(f"{TEX_DIR}/**/*.tex")
typ_paths = glob(f"{TEX_DIR}/**/*.typ")

# Create a dict mapping directory names to file paths
# Prefer .typ files over .tex files when both exist
path_dict = {}
for path in sorted(tex_paths + typ_paths):
    dir_name = os.path.basename(os.path.dirname(path))
    if dir_name not in path_dict or path.endswith(".typ"):
        path_dict[dir_name] = path

# Convert back to sorted list
unique_paths = sorted(path_dict.values())

md_table = f"| {'&emsp;' * 22} | {'&emsp;' * 22} |\n| :---: | :---: |\n"

for path1, path2 in zip_longest(unique_paths[::2], unique_paths[1::2]):
    dir1, dir2 = map(os.path.dirname, (path1, path2 or ""))
    fig1, fig2 = map(os.path.basename, (dir1, dir2))

    # file name row
    dir_link1 = f"[`{fig1}`]({site_url}/{fig1})"
    dir_link2 = f"[`{fig2}`]({site_url}/{fig2})" if path2 else ""
    md_table += f"| {dir_link1} | {dir_link2} |\n"

    # image row
    img_link1 = f"![`{fig1}.png`](assets/{fig1}/{fig1}.png)"
    img_link2 = f"![`{fig2}.png`](assets/{fig2}/{fig2}.png)" if path2 else ""
    md_table += f"| {img_link1} | {img_link2} |\n"

with open(f"{ROOT}/README.md", "r") as file:
    readme = file.read()

# insert table markdown between "## Images\n" and "## Scripts\n" headings
readme = re.sub(
    r"(?<=## Images\n)(.*)(?=## Scripts\n)",
    f"\n{md_table}\n",
    readme,
    flags=re.DOTALL,
)

# update count in "Collection of **110** "
readme = re.sub(r"(?<=Collection of \*\*)\d+(?=\*\* )", str(len(unique_paths)), readme)

with open(f"{ROOT}/README.md", "w") as file:
    file.write(readme)

# run pre-commit on readme to format white space in table
os.system("pre-commit run --files readme.md")
