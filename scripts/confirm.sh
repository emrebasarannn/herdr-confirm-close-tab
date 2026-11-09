#!/bin/sh
# Prompt pane `confirm-close-tab.confirm`.
#
# Runs inside a real herdr pane (has a TTY). Reads one key: y/Y closes the tab
# captured by open.sh, anything else (n, Esc, ...) cancels. Then the pane goes away.
set -u

herdr="${HERDR_BIN_PATH:-herdr}"
target="${CONFIRM_CLOSE_TAB_ID:-}"
self="${HERDR_PANE_ID:-}"

saved_tty=''
cleanup() {
  [ -n "$saved_tty" ] && stty "$saved_tty" 2>/dev/null
  # Overlay panes are expected to vanish when their command exits, but that is
  # not documented, so close our own pane explicitly. Harmless if it is already
  # gone (e.g. it lived inside the tab we just closed).
  [ -n "$self" ] && "$herdr" plugin pane close "$self" >/dev/null 2>&1
  return 0
}
trap cleanup EXIT
trap 'exit 130' INT TERM

pause() {
  printf 'Press any key to dismiss.'
  read_key >/dev/null
}

read_key() {
  if [ -n "$saved_tty" ]; then
    dd bs=1 count=1 2>/dev/null
  else
    IFS= read -r line && printf '%s' "$line"
  fi
}

if saved_tty=$(stty -g 2>/dev/null); then
  stty -echo -icanon min 1 time 0 2>/dev/null || saved_tty=''
fi

if [ -z "$target" ]; then
  printf 'confirm-close-tab: no target tab id was passed in.\n'
  pause
  exit 1
fi

# Tab label and whether this is the last tab of its workspace (closing the last
# tab also closes the workspace). Parsed with grep so jq is not required.
tab_json=$("$herdr" tab get "$target" 2>/dev/null || true)
label=$(printf '%s' "$tab_json" | grep -o '"label":"[^"]*"' | head -n 1 | sed 's/^"label":"//; s/"$//')
workspace="${target%%:*}"
tab_count=$("$herdr" tab list --workspace "$workspace" 2>/dev/null | grep -o '"tab_id":' | wc -l | tr -d ' ')

if [ -n "$label" ]; then
  printf 'Close tab "%s"? (y/n) ' "$label"
else
  printf 'Close tab %s? (y/n) ' "$target"
fi
if [ "$tab_count" = "1" ]; then
  printf '\nThis is the last tab: the workspace will close too. '
fi

key=$(read_key)
printf '\n'

case "$key" in
  y|Y)
    if ! out=$("$herdr" tab close "$target" 2>&1); then
      printf 'Could not close tab: %s\n' "$out"
      pause
      exit 1
    fi
    ;;
  *)
    printf 'Cancelled.\n'
    ;;
esac
