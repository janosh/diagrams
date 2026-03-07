import os
import shutil
import subprocess


def compress_png(png_path: str) -> None:
    """Compress a PNG file with pngquant and zopflipng if available."""
    if not os.path.isfile(png_path):
        print(f"  skipping {png_path} (not found)")
        return

    if shutil.which("pngquant"):
        subprocess.run(
            ["pngquant", "32", "--skip-if-larger", "--ext", ".png", "--force", png_path]
        )
    if shutil.which("zopflipng"):
        subprocess.run(["zopflipng", "-y", png_path, png_path])


def pdf_to_svg_png_compressed(pdf_path: str) -> str:
    """Convert a PDF to SVG and PNG with compression."""
    base_path = os.path.splitext(pdf_path)[0]

    if shutil.which("pdf-compressor"):
        print("\n--- pdf-compressor ---")
        subprocess.run(["pdf-compressor", "--inplace", f"{base_path}.pdf"])

    print("Converting PDF to SVG and compressing")
    if not shutil.which("pdf2svg"):
        print("pdf2svg not found, skipping SVG generation")
    elif subprocess.run(["pdf2svg", f"{base_path}.pdf", f"{base_path}.svg"]).returncode != 0:
        print("pdf2svg failed, skipping SVG generation")
    elif os.stat(f"{base_path}.svg").st_size > 500_000:
        os.remove(f"{base_path}.svg")
    elif shutil.which("svgo"):
        subprocess.run(["svgo", "--multipass", f"{base_path}.svg"])

    # https://stackoverflow.com/q/52998331
    if os.getenv("CI") == "true":
        subprocess.run(
            ["sudo", "sed", "-i", "/disable ghostscript format types/,+6d",
             "/etc/ImageMagick-6/policy.xml"]
        )

    magick_cmd = "magick" if shutil.which("magick") else "convert"
    print(f"\n--- {magick_cmd}: convert PDF to PNG ---")
    subprocess.run([magick_cmd, "-density", "200", f"{base_path}.pdf", f"{base_path}.png"])
    subprocess.run([magick_cmd, "-density", "400", f"{base_path}.pdf", f"{base_path}-hd.png"])

    print("\n--- compress PNGs ---")
    compress_png(f"{base_path}.png")
    compress_png(f"{base_path}-hd.png")

    return base_path
