#!/bin/sh

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

workspace_id="${NAME#workspace.}"
omniwmctl_bin="$(command -v omniwmctl 2>/dev/null || printf '%s' '/Applications/OmniWM.app/Contents/MacOS/omniwmctl')"
active_workspace="$("$omniwmctl_bin" query workspaces --current --format json 2>/dev/null \
  | jq -r '.result.payload.workspaces[0].number // empty' 2>/dev/null)"

if [ "$workspace_id" = "$active_workspace" ]; then
  sketchybar --set "$NAME" background.drawing=on
else
  sketchybar --set "$NAME" background.drawing=off
fi
