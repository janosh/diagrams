import os
import shutil
import subprocess

import yaml

PNG_VARIANTS = ((".png", "200"), ("-hd.png", "400"))


def finalize_pngs(base_path: str) -> None:
    """Losslessly compress both PNG sizes and generate the themed README preview."""
    for suffix, _ppi in PNG_VARIANTS:
        png_path = f"{base_path}{suffix}"
        if not os.path.isfile(png_path):
            raise FileNotFoundError(png_path)
        if shutil.which("zopflipng"):
            subprocess.run(["zopflipng", "-y", png_path, png_path], check=True)

    with open(f"{base_path}.yml") as file:
        metadata = yaml.safe_load(file)
    if metadata.get("hide") or metadata.get("preserve_colors"):
        return
    # CSS invert(0.9) hue-rotate(180deg), operating on sRGB, with alpha untouched.
    # The hue rotation restores the color families after inversion; brightness changes.
    subprocess.run(
        [
            "magick",
            f"{base_path}.png",
            "-channel",
            "RGB",
            "-negate",
            "-evaluate",
            "Multiply",
            "0.8",
            "-evaluate",
            "Add",
            "10%",
            "-color-matrix",
            "-0.574 1.43 0.144 0.426 0.43 0.144 0.426 1.43 -0.856",
            "+channel",
            f"{base_path}-dark.png",
        ],
        check=True,
    )


def pdf_to_svg_png_compressed(pdf_path: str) -> str:
    """Convert a PDF to SVG and PNG with compression."""
    base_path = os.path.splitext(pdf_path)[0]

    if shutil.which("pdf-compressor"):
        print("\n--- pdf-compressor ---")
        subprocess.run(["pdf-compressor", "--inplace", f"{base_path}.pdf"])

    print("Converting PDF to SVG and compressing")
    if not shutil.which("pdf2svg"):
        print("pdf2svg not found, skipping SVG generation")
    elif (
        subprocess.run(["pdf2svg", f"{base_path}.pdf", f"{base_path}.svg"]).returncode
        != 0
    ):
        print("pdf2svg failed, skipping SVG generation")
    elif os.stat(f"{base_path}.svg").st_size > 500_000:
        os.remove(f"{base_path}.svg")
    elif shutil.which("svgo"):
        subprocess.run(["svgo", "--multipass", f"{base_path}.svg"])

    # https://stackoverflow.com/q/52998331
    if os.getenv("CI") == "true":
        xml_uri = "/etc/ImageMagick-6/policy.xml"
        subprocess.run(
            ["sudo", "sed", "-i", "/disable ghostscript format types/,+6d", xml_uri]
        )

    print("\n--- magick: convert PDF to PNG ---")
    # check=True: these PNGs are the assets the site renders, so fail loudly if missing
    for suffix, density in PNG_VARIANTS:
        subprocess.run(
            [
                "magick",
                "-density",
                density,
                "-background",
                "none",
                f"{base_path}.pdf",
                f"{base_path}{suffix}",
            ],
            check=True,
        )

    finalize_pngs(base_path)

    return base_path
