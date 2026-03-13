#!/bin/bash

# --- Configuration ---
# Finds the absolute path to the script's directory, making it location-independent.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# The source directory, located next to the script.
SOURCE_DIR="$SCRIPT_DIR/svg"
# The destination directory for all output folders, created next to the script.
DEST_DIR="$SCRIPT_DIR/exported_pngs"
# The desired output sizes for the PNGs.
SIZES=(256 128 64 32)

# --- Pre-run Checks ---
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory not found at '$SOURCE_DIR'."
  exit 1
fi

if ! command -v inkscape &> /dev/null; then
    echo "Error: Inkscape is not installed or not in your PATH."
    exit 1
fi

# Create the main destination folder.
mkdir -p "$DEST_DIR"

# --- Main Logic ---
echo "🚀 Starting SVG export process..."
echo "Source: $SOURCE_DIR"
echo "Destination: $DEST_DIR"

find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.svg" -print0 | while IFS= read -r -d '' SVG_FILE; do

  FILENAME=$(basename -- "$SVG_FILE")
  BASE_NAME="${FILENAME%.svg}"
  
  # Create a dedicated output folder for this icon inside the main destination folder.
  OUTPUT_DIR="$DEST_DIR/$BASE_NAME"
  mkdir -p "$OUTPUT_DIR"

  echo "Processing '$FILENAME' -> exporting to '$OUTPUT_DIR/'..."

  for SIZE in "${SIZES[@]}"; do
    # Provide a full, absolute path for the output PNG. This is crucial for WSL.
    PNG_OUTPUT_PATH="$OUTPUT_DIR/${BASE_NAME}.${SIZE}x${SIZE}.png"
    echo "  🎨 Exporting to ${SIZE}x${SIZE}..."

    # MODERN SYNTAX for Inkscape 1.0+
    # Uses --export-filename and omits deprecated flags.
    inkscape --export-filename="$PNG_OUTPUT_PATH" \
             --export-width="$SIZE" \
             --export-height="$SIZE" \
             "$SVG_FILE"
  done
done

echo "✅ Export complete! Check the '$DEST_DIR' folder."
