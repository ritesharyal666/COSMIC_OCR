# cosmic-ocr

Select a region of your screen, and the text in it lands on your clipboard. One keystroke, fully offline, nothing written to disk.

Built for **Pop!\_OS COSMIC** (and other compositors using the COSMIC screenshot portal), where the usual `grim | tesseract` pipeline doesn't work because COSMIC doesn't expose the `wlr-screencopy` protocol.

## Why this exists

On wlroots compositors (Sway, Hyprland, river) you can OCR a region with a one-liner:

```bash
grim -g "$(slurp)" - | tesseract stdin stdout | wl-copy
```

That doesn't work on COSMIC — `grim` reports `compositor doesn't support wlr-screencopy-unstable-v1`. COSMIC captures only through the XDG Desktop Portal, whose CLI (`cosmic-screenshot`) can save to a file but can't pipe pixels to stdout.

The trick this project uses: COSMIC's portal can be set to copy a rectangle selection **straight to the clipboard as an image**. So instead of going through a file, we capture to the clipboard, read the image back out, OCR it, and replace the clipboard contents with text. The image only ever lives in the clipboard — it never touches your disk, and nothing is sent over the network.

## How it works

1. The script triggers the COSMIC screenshot portal (region select → clipboard).
2. It reads the captured PNG out of the clipboard.
3. ImageMagick upscales and grayscales the image for better recognition.
4. Tesseract OCRs it locally.
5. The recognized text replaces the image on your clipboard.

## Requirements

- `cosmic-screenshot` (ships with COSMIC)
- `wl-clipboard` (`wl-copy` / `wl-paste`)
- `tesseract-ocr` and the language data for your language(s)
- `imagemagick`
- `libnotify` (optional, for desktop notifications)

Install on Pop!\_OS / Ubuntu / Debian:

```bash
sudo apt install wl-clipboard tesseract-ocr tesseract-ocr-eng imagemagick libnotify-bin
```

(Add more `tesseract-ocr-<lang>` packages for other languages.)

## Install

```bash
git clone https://github.com/YOUR_USERNAME/cosmic-ocr.git
cd cosmic-ocr
./install.sh
```

`install.sh` copies `ocr-capture` to `~/.local/bin` and makes it executable. Make sure `~/.local/bin` is on your `PATH` (it is by default on Pop!\_OS).

## One-time COSMIC setup (important)

The script relies on COSMIC's screenshot portal being set to copy a **rectangle** selection to the **clipboard**. Do one normal COSMIC screenshot first and set it that way:

1. Trigger a screenshot (default key: `Print`).
2. In the capture UI, choose **Rectangle** selection.
3. Choose **Copy to clipboard** as the destination.
4. Take the shot.

COSMIC remembers these as defaults. You can confirm the setting here:

```bash
cat ~/.config/cosmic/com.system76.CosmicPortal/v1/screenshot
```

You want to see `save_location: Clipboard` and `choice: Rectangle`.

## Usage

Run it directly:

```bash
ocr-capture
```

A region-select overlay appears. Drag a box around the text. The recognized text is now on your clipboard — paste it anywhere.

### Bind it to a keyboard shortcut

In **Settings → Keyboard → Keyboard shortcuts → Add custom shortcut**:

- **Command:** `/home/YOUR_USERNAME/.local/bin/ocr-capture` (use the full path; `~` is not reliably expanded)
- **Key combination:** something `Super`-based, e.g. `Super+Shift+S` (avoid `Ctrl`/`Alt` combos that apps like browsers grab)

If the GUI shortcut doesn't fire, you can write the binding directly to
`~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom`:

```
{
    (
        modifiers: [Super, Shift],
        key: "s",
        description: Some("OCR Capture"),
    ): Spawn("/home/YOUR_USERNAME/.local/bin/ocr-capture"),
}
```

Log out and back in to be sure COSMIC reloads it.

## Configuration

Set the OCR language with the `OCR_LANG` environment variable (default `eng`):

```bash
OCR_LANG=deu ocr-capture        # German
OCR_LANG=eng+fra ocr-capture    # English + French
```

Install the matching `tesseract-ocr-<lang>` package first.

## Tips for better accuracy

Tesseract does best on clean, high-contrast printed text. The script already upscales 3× and grayscales, which handles most small UI text. For very small or low-contrast text, select a tighter region around just the text you want.

## Privacy

Everything runs locally. Tesseract is fully offline; no image or text is sent anywhere. The captured image stays in the clipboard only until OCR replaces it with text. Note that if you use a clipboard-history manager, the OCR'd text (and possibly the intermediate image) may be stored in its history — exclude this from history if you OCR sensitive material.

## License

MIT — see [LICENSE](LICENSE).
