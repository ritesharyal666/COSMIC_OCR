#!/usr/bin/env bash
# Installs ocr-capture to ~/.local/bin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.local/bin"

mkdir -p "$DEST"
install -m 0755 "$SCRIPT_DIR/ocr-capture" "$DEST/ocr-capture"

echo "Installed ocr-capture to $DEST/ocr-capture"

case ":$PATH:" in
  *":$DEST:"*) ;;
  *) echo "Note: $DEST is not on your PATH. Add it to your shell profile:"
     echo '  export PATH="$HOME/.local/bin:$PATH"' ;;
esac

# Check for required tools and warn about any missing ones.
missing=()
for cmd in cosmic-screenshot wl-paste wl-copy tesseract; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 || missing+=("imagemagick")

if [ "${#missing[@]}" -gt 0 ]; then
  echo
  echo "Missing dependencies: ${missing[*]}"
  echo "On Pop!_OS / Ubuntu / Debian:"
  echo "  sudo apt install wl-clipboard tesseract-ocr tesseract-ocr-eng imagemagick libnotify-bin"
fi

echo
echo "Next: set COSMIC's screenshot portal to Rectangle + Copy to clipboard (see README),"
echo "then bind ocr-capture to a keyboard shortcut."
