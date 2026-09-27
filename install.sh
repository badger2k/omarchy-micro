#!/usr/bin/env bash
#
# Make micro the default text editor on Omarchy and theme it dynamically:
# every `omarchy theme set` regenerates a micro colorscheme from the theme's
# colors.toml, the same way Omarchy themes helix, btop and friends.
#
# Safe to re-run; every step is idempotent.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MICRO_DIR="$HOME/.config/micro"
THEMED_DIR="$HOME/.config/omarchy/themed"
CURRENT_THEME="$HOME/.local/state/omarchy/current/theme"
EDITOR_STATE="$HOME/.local/state/omarchy/defaults/editor"
APPS_DIR="$HOME/.local/share/applications"

# Text types opened with micro (text/html stays with the browser).
MIME_TYPES=(
  text/plain text/english text/markdown text/x-log text/x-makefile
  text/x-chdr text/x-csrc text/x-c text/x-c++ text/x-c++hdr text/x-c++src
  text/x-java text/x-dsrc text/x-pascal text/x-perl text/x-python text/x-tex
  text/x-tcl text/x-sql text/x-diff text/x-shellscript text/css text/csv
  application/x-shellscript application/xml application/json
  application/x-yaml application/toml
)

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m!!!\033[0m %s\n' "$*" >&2; exit 1; }

# --- preflight -------------------------------------------------------------

command -v omarchy >/dev/null || die "omarchy CLI not found - is this an Omarchy system?"

if ! command -v micro >/dev/null; then
  say "Installing micro"
  omarchy pkg add micro
fi

# --- 1. default editor -----------------------------------------------------

# `omarchy default editor` doesn't list micro, but omarchy-launch-editor
# reads this state file and already knows to open micro in a terminal.
say "Setting micro as Omarchy's default editor"
mkdir -p "$(dirname "$EDITOR_STATE")"
printf 'micro\n' >"$EDITOR_STATE"

# The packaged micro.desktop uses Terminal=true, which opens in whatever
# terminal GLib guesses. This override launches it in Omarchy's terminal.
say "Installing micro.desktop launcher"
mkdir -p "$APPS_DIR"
install -m 644 "$SRC/micro.desktop" "$APPS_DIR/micro.desktop"
update-desktop-database "$APPS_DIR" 2>/dev/null || true

say "Opening text files with micro"
xdg-mime default micro.desktop "${MIME_TYPES[@]}"

# --- 2. dynamic theme ------------------------------------------------------

say "Installing micro colorscheme template"
mkdir -p "$THEMED_DIR"
install -m 644 "$SRC/micro.micro.tpl" "$THEMED_DIR/micro.micro.tpl"

# Omarchy renders the template into the current theme dir; micro reads it
# through this symlink, so it always points at the active theme.
mkdir -p "$MICRO_DIR/colorschemes"
ln -sfn "$CURRENT_THEME/micro.micro" "$MICRO_DIR/colorschemes/omarchy.micro"

say "Selecting the omarchy colorscheme in micro"
SETTINGS="$MICRO_DIR/settings.json"
if [[ ! -s $SETTINGS ]]; then
  printf '{\n    "colorscheme": "omarchy"\n}\n' >"$SETTINGS"
elif command -v jq >/dev/null; then
  tmp="$(mktemp)"
  jq '.colorscheme = "omarchy"' "$SETTINGS" >"$tmp" && mv "$tmp" "$SETTINGS"
else
  die "$SETTINGS exists and jq is missing; set \"colorscheme\": \"omarchy\" by hand."
fi

# Re-apply the current theme so the colorscheme is generated right away.
say "Re-applying theme to generate the colorscheme"
omarchy theme set "$(omarchy theme current)"

[[ -f $CURRENT_THEME/micro.micro ]] || die "Colorscheme was not generated - check $THEMED_DIR/micro.micro.tpl"

say "Done. micro is the default editor and follows the Omarchy theme."
