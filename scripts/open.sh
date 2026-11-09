#!/bin/sh
# Action `confirm-close-tab.confirm-close-tab`.
#
# Runs on the herdr server with no TTY. The tab id is captured HERE, before the
# prompt pane exists: once the overlay opens, focus moves to it, and anything
# that asked "which tab is focused?" later could get the wrong answer.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"
target="${HERDR_TAB_ID:-}"

# Fallback for builds that only expose the id through the context JSON.
if [ -z "$target" ] && [ -n "${HERDR_PLUGIN_CONTEXT_JSON:-}" ] && command -v jq >/dev/null 2>&1; then
  target=$(printf '%s' "$HERDR_PLUGIN_CONTEXT_JSON" | jq -r '.tab_id // empty' 2>/dev/null || true)
fi

# No tab id means we cannot know what to close. Do nothing rather than guess.
if [ -z "$target" ]; then
  echo "confirm-close-tab: no tab id in action environment, nothing to do" >&2
  exit 0
fi

exec "$herdr" plugin pane open \
  --plugin confirm-close-tab \
  --entrypoint confirm \
  --placement overlay \
  --focus \
  --env "CONFIRM_CLOSE_TAB_ID=$target"
