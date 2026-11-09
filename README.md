# herdr-confirm-close-tab

A [herdr](https://herdr.dev) plugin that asks for confirmation before closing a tab.

herdr closes a tab straight away on `prefix+shift+x` (`close_tab`). `[ui] confirm_close`
only guards the last tab of a workspace, so an accidental keypress can kill a tab running an
agent or a long process. This plugin puts a prompt in front of that key:

```
Close tab "my-agent"? (y/n)
```

`y` closes the tab. Any other key (`n`, `Esc`, ...) cancels. If it is the last tab of the
workspace, the prompt says so, because closing it also closes the workspace.

## Requirements

- herdr 0.9.0 or newer
- Linux or macOS

## Install

```sh
herdr plugin install emrebasarannn/herdr-confirm-close-tab
```

For local development, link a checkout instead:

```sh
herdr plugin link /path/to/herdr-confirm-close-tab
```

herdr plugins cannot declare keybindings, so bind the action yourself in `config.toml`
(`~/.config/herdr/config.toml`, or `$HERDR_CONFIG_PATH`). A `[[keys.command]]` on the same key
takes it over from the built-in `close_tab`:

```toml
[[keys.command]]
key = "prefix+shift+x"
type = "plugin_action"
command = "confirm-close-tab.confirm-close-tab"
description = "Close tab (confirm)"
```

Then reload:

```sh
herdr server reload-config
```

Check the action is registered with `herdr plugin action list --plugin confirm-close-tab`.

## How it works

1. The key runs the action `scripts/open.sh` on the herdr server. It has no TTY, so it only
   reads the focused tab id from `HERDR_TAB_ID` (falling back to `tab_id` in
   `HERDR_PLUGIN_CONTEXT_JSON`) and opens the prompt pane with that id. The id is captured
   before the prompt opens, so focus moving to the prompt cannot redirect the close to another tab.
2. The prompt pane `scripts/confirm.sh` reads one key and on `y` runs
   `herdr tab close <tab-id>`. If herdr refuses (for example a close that needs confirmation
   because it would remove a worktree group), the error is shown instead of failing silently.

## Known gaps

- Closing a tab with the mouse (tab menu → Close) does not go through this plugin.
- `herdr tab close` from the CLI or socket API is unaffected.

## Uninstall

```sh
herdr plugin uninstall confirm-close-tab
```

and remove the `[[keys.command]]` block from your config.

## License

MIT
