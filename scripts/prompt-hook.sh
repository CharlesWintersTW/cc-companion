#!/bin/bash
# Wrapper: find latest plugin dir and run prompt-submit.sh
PLUGIN_DIR=$(for d in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/cc-companion/cc-companion/*/; do [ -d "$d" ] && echo "$d"; done | sort -V | tail -n1)
[ -z "$PLUGIN_DIR" ] && exit 0
exec bash "${PLUGIN_DIR}scripts/prompt-submit.sh"
