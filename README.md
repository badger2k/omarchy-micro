# omarchy-micro

Makes [micro](https://micro-editor.github.io/) the default text editor on
[Omarchy](https://omarchy.org/). It also themes micro from your Omarchy theme,
so micro's colors change whenever you run `omarchy theme set`.

```bash
git clone https://github.com/badger2k/omarchy-micro
cd omarchy-micro
./install.sh
```

The script is safe to run more than once.

## What it does

- **Default editor.** Writes `micro` to `~/.local/state/omarchy/defaults/editor`,
  which `omarchy launch editor` reads. `omarchy default editor` doesn't list micro,
  but the launcher already opens it in a terminal.
- **File types.** Installs a `micro.desktop` that opens micro in Omarchy's terminal,
  then makes it the default for plain text, markdown, source code, JSON, YAML, TOML
  and similar types. HTML still opens in the browser.
- **Dynamic theme.** Installs `micro.micro.tpl` into `~/.config/omarchy/themed/`.
  On every theme change Omarchy renders it from the theme's `colors.toml` into
  `~/.local/state/omarchy/current/theme/micro.micro`. The symlink
  `~/.config/micro/colorschemes/omarchy.micro` points there, and micro's
  `settings.json` selects `"colorscheme": "omarchy"`.

micro's background is left unset, so the themed terminal background (and its
transparency) shows through.

## Notes

- A micro window that's already open keeps its colors after a theme switch.
  Reopen the file, or run `set colorscheme omarchy` (Ctrl+E).
- If a theme ships its own `micro.micro`, Omarchy uses it instead of the template.
- To change the colors for every theme, edit `micro.micro.tpl` and re-run
  `./install.sh`. The available placeholders are listed by
  `omarchy-theme-color --file ~/.local/state/omarchy/current/theme/colors.toml --all`.
