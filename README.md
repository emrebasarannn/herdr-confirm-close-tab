# herdr-confirm-close-tab

A [herdr](https://herdr.dev) plugin that asks `Close tab? (y/n)` before closing a tab.

herdr closes a tab straight away on `prefix+shift+x`. `[ui] confirm_close` only guards the
last tab of a workspace, so an accidental keypress can kill a tab running an agent or a long
process. This plugin puts a y/n prompt in front of that key.

Work in progress. See the open pull request for the implementation.

## License

MIT
