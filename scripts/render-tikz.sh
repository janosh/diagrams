#!/bin/bash

# From the project's root dir, use via `scripts/newtikz.sh assets/tex-file/tex-file.tex`.

# Get name of directory containing the TeX file.
# bash string manipulation via ${STR%/*} strips the shortest match of /* from STR
dir=${1%/*}

# Get basepath of TeX file, i.e. path without extension.
basepath=${1%.tex}

echo "Running latexmk to generate PDF from TeX file"
ret_val=$(latexmk -silent -pdf -jobname="$basepath" "$1")

if [ "$CI" = true ]; then
  echo "Detected CI=$CI"
  if [ "$ret_val" -ne 0 ]; then
    echo "latexmk failed with return code $ret_val"
    cat "$basepath.log"
    exit 1
  fi
fi


echo "Delete LaTeX auxiliary files"
find "$dir" -type f -regex ".*\.(aux|log|fls|fdb_latexmk)$" -delete

echo "Compressing output PDF with pdf-compressor"
# iLovePDF performs much better than Ghostscript but the API only offers
# 250 free compressions per month.
# scripts/gs-pdf-compress.sh "$dir"
pdf-compressor --inplace "$basepath.pdf"

echo "Converting PDF to SVG and compressing"
# Requires pdf2svg and svgo to be installed (`brew install pdf2svg svgo`).
pdf2svg "$basepath.pdf" "$basepath.svg"
# If the SVG is larger than 1 MB, delete it instead of compressing.
# Don't want large files in the repo.
svg_size=$(stat -f %z "$basepath.svg")
if (($svg_size > 1000000)); then
  rm "$basepath.svg"
else
  svgo --multipass "$basepath.svg"
fi

# https://stackoverflow.com/q/52998331
if [ "$CI" = true ]; then
  sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml
fi
echo "Converting PDF to low + high res PNG, then compressing both"
# Requires convert, pngquant and zopflipng to be installed:
# brew install imagemagick pngquant zopfli
convert -density 200 "$basepath.pdf" "$basepath.png"
convert -density 400 "$basepath.pdf" "$basepath-hd.png"

pngquant 32 --skip-if-larger --ext .png --force "$basepath.png"
pngquant 32 --skip-if-larger --ext .png --force "$basepath-hd.png"

zopflipng -y "$basepath.png" "$basepath.png"
zopflipng -y "$basepath-hd.png" "$basepath-hd.png"
