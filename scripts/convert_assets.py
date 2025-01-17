import os


def pdf_to_svg_png_compressed(pdf_path: str) -> str:
    base_path = os.path.splitext(pdf_path)[0]

    print("\n--- pdf-compressor ---")
    os.system(f"pdf-compressor --inplace {base_path}.pdf")

    print("Converting PDF to SVG and compressing")
    if os.system(f"pdf2svg {base_path}.pdf {base_path}.svg") != 0:
        print("pdf2svg failed, skipping SVG generation")
    else:
        svg_size = os.stat(f"{base_path}.svg").st_size
        if svg_size > 500_000:
            os.remove(f"{base_path}.svg")
        else:
            os.system(f"svgo --multipass {base_path}.svg")

    # https://stackoverflow.com/q/52998331
    if os.getenv("CI") == "true":
        os.system(
            "sudo sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml"
        )

    print("\n--- imagemagick: convert PDF to PNG ---")
    os.system(f"convert -density 200 {base_path}.pdf {base_path}.png")
    os.system(f"convert -density 400 {base_path}.pdf {base_path}-hd.png")

    print("\n--- pngquant: compress ---")
    os.system(f"pngquant 32 --skip-if-larger --ext .png --force {base_path}.png")
    os.system(f"pngquant 32 --skip-if-larger --ext .png --force {base_path}-hd.png")

    print("\n--- zopfli: compress ---")
    os.system(f"zopflipng -y {base_path}.png {base_path}.png")
    os.system(f"zopflipng -y {base_path}-hd.png {base_path}-hd.png")

    return base_path
