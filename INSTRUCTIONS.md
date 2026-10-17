# towebp and toavif – installation guide

As of 2026-10-17 · [Polska wersja](INSTRUKCJA.md)

## What towebp and toavif are

Two command-line tools that batch-convert JPG/JPEG and PNG images into modern, lighter formats: **towebp** to WebP, **toavif** to AVIF. You install them with two Homebrew commands; the whole setup takes about 5 minutes.

- They convert many files at once: by default as many in parallel as your CPU has cores.
- They never corrupt files: output is written to a temporary file first, and an existing `.webp`/`.avif` is never overwritten.
- Originals are kept unless you add the `--delete` option yourself.
- They can run in the background (cron) and automatically convert new images, e.g. in your Downloads folder.

Source code: [mnich/towebp](https://github.com/mnich/towebp), [mnich/toavif](https://github.com/mnich/toavif). Current version of both tools: 1.1.0.

## Requirements

All you need is macOS and Homebrew. The tools have been tested on macOS with Apple Silicon. They should work the same on Intel Macs and on Linux with Homebrew, but that has not been tested.

1. Open the **Terminal** app (Spotlight: ⌘ Space, type "Terminal").
2. Check whether you have Homebrew:

   ```bash
   brew --version
   ```

   If you see a version number, skip to the next section.
3. If you get `command not found: brew`, install Homebrew with the official script from [brew.sh](https://brew.sh):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
4. At the end, the installer prints a **Next steps** section with two commands that add `brew` to your `PATH`. Run them, close Terminal, open it again, and check `brew --version` once more.

Homebrew installs the remaining dependencies (`cwebp` from the `webp` package, `avifenc` from the `libavif` package) together with the tools.

## Installation

The tools are installed from a dedicated Homebrew repository (a "tap") called `mnich/tools`. You can install both or just one.

1. Add the tap (once):

   ```bash
   brew tap mnich/tools
   ```
2. Install the tools:

   ```bash
   brew install towebp toavif
   ```

   Just one: `brew install towebp` or `brew install toavif`.
3. Check that they work:

   ```bash
   towebp --version
   toavif --version
   ```

   You should see `towebp 1.1.0` and `toavif 1.1.0`.

## Manual use

Always pass a folder (`-d`). Without it, the tool processes your entire `~/Downloads` folder including all subfolders, which can mean tens of thousands of images.

```bash
towebp -d <folder> [options]
toavif -d <folder> [options]
```

| Option | What it does | Default |
| --- | --- | --- |
| `-d`, `--dir <folder>` | Folder with images | `~/Downloads` |
| `-q`, `--quality <0-100>` | Output quality | towebp: 80, toavif: 60 |
| `-s`, `--speed <0-10>` | toavif only: encoder speed, 0 = slowest and smallest file | 6 |
| `-t`, `--threads <n>` | How many files to convert at once | number of cores |
| `--max-depth <n>` | How deep to go into subfolders; `1` = only the given folder | unlimited |
| `--newer-than <file>` | Only images added after the given file was last changed | off |
| `--min-age <minutes>` | Skip files changed in the last N minutes (e.g. still downloading) | 0 |
| `--delete` | Delete the original after a successful conversion | off |
| `-h`, `--help` / `-v`, `--version` | Help / version | |

Examples:

```bash
# Photos from one folder, no subfolders, originals kept
towebp -d ~/Desktop/photos --max-depth 1

# Higher-quality AVIF, slower and more thorough encoding
toavif -d ~/Desktop/photos -q 70 -s 4

# Convert and delete the originals
towebp -d ~/Desktop/photos --delete
```

An image is skipped if a file with the same name and a `.webp`/`.avif` extension already exists next to it, so running the tool again only processes new files. If a folder contains e.g. `photo.jpg` and `photo.png`, only one of them is converted and the other is left untouched.

## Automatic conversion in Downloads

Cron runs the tool every minute, so every new image in Downloads gets its `.webp`/`.avif` version within 1–2 minutes. This setup is safe for a folder that already holds thousands of files:

- `--max-depth 1`: handles only files directly in Downloads, not in subfolders;
- `--newer-than`: handles only files added after the automation was enabled and leaves older ones alone;
- `--min-age 1`: waits until a file has not changed for a minute, so downloads in progress are never picked up.

1. Create the marker files. They set the cut-off: only images added later will be converted.

   ```bash
   touch ~/.towebp-since ~/.toavif-since
   ```
2. Add the cron entries. This command appends them to your existing ones and fills in the correct paths. If you use only one tool, remove the other one's line.

   ```bash
   ( crontab -l 2>/dev/null
     echo "* * * * * $(brew --prefix)/bin/towebp -d $HOME/Downloads --max-depth 1 --newer-than $HOME/.towebp-since --min-age 1 > /tmp/towebp_cron.log 2>&1"
     echo "* * * * * $(brew --prefix)/bin/toavif -d $HOME/Downloads --max-depth 1 --newer-than $HOME/.toavif-since --min-age 1 > /tmp/toavif_cron.log 2>&1"
   ) | crontab -
   ```
3. Give cron access to Downloads. Without it, macOS blocks cron and the log shows `Operation not permitted`.
   1. Open **System Settings → Privacy & Security → Full Disk Access**.
   2. Click **+** and confirm with your password or Touch ID.
   3. Press **⌘⇧G**, type `/usr/sbin/cron`, press Enter and choose **Open**.
   4. Make sure the toggle next to `cron` is on.
4. Test it: drop any PNG or JPG image into Downloads and check the logs after 2 minutes.

   ```bash
   cat /tmp/towebp_cron.log /tmp/toavif_cron.log
   ```

   They should contain `Converted: ...` lines, and `.webp` and `.avif` files should appear next to the image.

Do not change the marker files (e.g. with another `touch`). That moves the cut-off, and images added earlier that have not been converted yet will be skipped.

Do not add `--delete` when using both tools at once. Whichever finishes first would delete the original before the other one converts it. With a single tool, `--delete` is safe.

**Turning the automation off** (removes only these two tools' entries):

```bash
crontab -l | grep -v -E 'towebp|toavif' | crontab -
```

## Updating and uninstalling

New versions arrive through Homebrew. The cron entries keep working after an update and need no changes.

```bash
brew update
brew upgrade towebp toavif
```

Full uninstall:

1. Turn the automation off with the command from the previous section.
2. Remove the tools, the tap and the marker files:

   ```bash
   brew uninstall towebp toavif
   brew untap mnich/tools
   rm -f ~/.towebp-since ~/.toavif-since
   ```

The `webp` and `libavif` packages stay installed. Remove them with `brew uninstall webp libavif` if nothing else uses them.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Cron log shows `Operation not permitted` | macOS has not given cron access to Downloads | Give `/usr/sbin/cron` Full Disk Access (step 3 of the automation) |
| `Bad CPU type in executable` for every file | An old Intel Homebrew `cwebp`/`avifenc` in `/usr/local/bin`, carried over from a previous Mac | Run `which -a cwebp avifenc`; the first path listed should be in `/opt/homebrew/bin`. Remove the old copies or ask me for help |
| `command not found: towebp` | Homebrew is not in your `PATH`, or the installation failed | Run the **Next steps** commands from the Homebrew installer, open a new Terminal, repeat `brew install` |
| `Another towebp instance is already running` | The previous run is still in progress | Nothing to do: this prevents overlapping runs. The next run will go ahead |
| The automation ignores a file in a subfolder | By design: `--max-depth 1` handles only files directly in Downloads | Move the file into Downloads or convert it manually with `-d` |
| An image was skipped | A `.webp`/`.avif` with the same name already exists next to it (possibly from another image, e.g. `photo.png` next to `photo.jpg`) | Rename the image or delete the old output file |

The tool exits with code 1 if any conversion fails. Files that could not be converted are marked `Conversion failed` in the log. For questions and bugs, message me or open an issue in the [towebp](https://github.com/mnich/towebp/issues) or [toavif](https://github.com/mnich/toavif/issues) repository.
