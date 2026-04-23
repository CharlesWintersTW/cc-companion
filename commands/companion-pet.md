---
description: "Pet your companion! Shows hearts animation"
allowed-tools: Bash
---

## Your task

Run the pet script:
```bash
PLUGIN_DIR=$(for d in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/cc-companion/cc-companion/*/; do [ -d "$d" ] && echo "$d"; done | sort -V | tail -n1)
bash "${PLUGIN_DIR}scripts/pet.sh"
```

Do not add any extra commentary. The script output speaks for itself.
