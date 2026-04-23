---
description: "Show your CC companion pet with ASCII art, stats, and rarity"
allowed-tools: Bash(bun:*), Bash(command:*), Bash(python3:*), Read
---

## Your task

### Step 1: Check and initialize config

```bash
python3 -c "
import json, os
p = os.path.expanduser('~/.claude/plugins/cc-companion/config.json')
defaults = {
  'displayMode': 'hud',
  'animationMode': 'classic',
  'screensaver': False,
  'screensaverMode': 'random',
  'screensaverInterval': 5,
  'speechBubble': False,
  'collection': []
}
try:
    d = json.load(open(p))
except:
    d = {}
changed = False
for k, v in defaults.items():
    if k not in d:
        d[k] = v
        changed = True
if changed:
    os.makedirs(os.path.dirname(p), exist_ok=True)
    json.dump(d, open(p, 'w'), indent=2)
    print('FIRST_RUN')
else:
    print('OK')
"
```

If the output is `FIRST_RUN`, this is a new user. Read the following files to get full context before proceeding:

```bash
PLUGIN_DIR=$(for d in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/cc-companion/cc-companion/*/; do [ -d "$d" ] && echo "$d"; done | sort -V | tail -n1)
echo "$PLUGIN_DIR"
```

Then read `${PLUGIN_DIR}README.md` and `${PLUGIN_DIR}CONFIG.md`.

After reading, briefly introduce what cc-companion can do (2-3 sentences), then continue to Step 2.

### Step 2: Show the companion pet

```bash
PLUGIN_DIR=$(for d in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/cc-companion/cc-companion/*/; do [ -d "$d" ] && echo "$d"; done | sort -V | tail -n1)
BUN_PATH=$(command -v bun 2>/dev/null || echo "$HOME/.bun/bin/bun")
"$BUN_PATH" "${PLUGIN_DIR}scripts/companion.mjs"
```

Show the output to the user exactly as printed.

### Step 3: Check pet name

```bash
python3 -c "import json, os; d=json.load(open(os.path.expanduser('~/.claude/plugins/cc-companion/config.json'))); print(d.get('petName',''))" 2>/dev/null
```

If the pet name is empty, ask: "Want to give your companion a name?"

If yes, ask for the name, then save it:
```bash
python3 -c "
import json, os
p = os.path.expanduser('~/.claude/plugins/cc-companion/config.json')
try: d = json.load(open(p))
except: d = {}
d['petName'] = '<NAME>'
json.dump(d, open(p, 'w'), indent=2)
print('Named!')
"
```
