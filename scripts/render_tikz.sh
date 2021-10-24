#!/bin/bash

# From the project's root dir, use via `scripts/newtikz.sh assets/tex-file/tex-file.tex`.

# Get name of directory containing the TeX file.
# bash string manipulation via ${STR%/*} strips the shortest match of /* from STR
dir=${1%/*}

# Get basepath of TeX file, i.e. path without extension.
basepath=${1%.tex}

# Create PDF from TeX file.
latexmk -silent -pdf -jobname="$basepath" "$1"

# Delete LaTeX auxiliary files.
find -E "$dir" -type f -regex ".*\.(aux|log|fls|fdb_latexmk)$" -delete

# Compress PDF. iLovePDF performs much better than Ghostscript but the API only offers 250 free compressions per month.
# scripts/gs_pdf_compress.sh "$dir"
pdf-compressor --inplace "$basepath.pdf"

# Convert PDF to SVG and compress.
# Requires pdf2svg and svgo to be installed (`brew install pdf2svg svgo`).
pdf2svg "$basepath.pdf" "$basepath.svg"
# If the SVG is larger than 2 MB, delete it instead of compressing. Don't want large files in the repo.
if ((`stat -f%z "$basepath.svg"` > 2000000)); then
  rm "$basepath.svg"
else
  svgo "$basepath.svg"
fi

# Convert PDF to PNG at low and high resolution, then compress both.
# Requires convert and imageoptim to be installed (`brew install imagemagick imageoptim-cli`).
convert -density 200 "$basepath.pdf" "$basepath.png"
convert -density 400 "$basepath.pdf" "$basepath-hd.png"
imageoptim --quality 40-60 --speed 5 "$basepath*.png"
