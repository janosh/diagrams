#!/bin/bash

# Bash script that recursively compresses all PDFs in encountered in the
# directory provided as first argument. Requires the ghostscript CLI
# (brew install ghostscript).

# Example invocation: scripts/pdfcompress.sh assets

find "$1" -name "*.pdf" | while read file; do
  basename=${file%.pdf}

  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
    -dNOPAUSE -dBATCH -dQUIET -sOutputFile="$basename-min.pdf" "$file"

  compressed_pdf_size=$(stat -f %z "$basename-min.pdf")
  original_pdf_size=$(stat -f %z "$basename")
  if (($compressed_pdf_size < $original_pdf_size)); then
    rm "$basename.pdf"
    mv "$basename-min.pdf" "$basename.pdf"
  else
    rm "$basename-min.pdf"
  fi
done
