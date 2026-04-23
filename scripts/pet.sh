#!/bin/bash
# Pet your companion — triggers hearts animation (5 frames, 1s protection window)

# --- Windows (Git Bash / Cygwin): delegate to bun ------------------------------
# Python is needed only to read the pet name and emit the heart state. Windows
# Python doesn't resolve Git Bash paths ($HOME="/c/Users/..."), so handle
# Windows natively via bun.
_win_pet() {
  local BUN_PATH
  BUN_PATH=$(command -v bun 2>/dev/null)
  [ -z "$BUN_PATH" ] && [ -x "$HOME/.bun/bin/bun" ] && BUN_PATH="$HOME/.bun/bin/bun"
  [ -z "$BUN_PATH" ] && { echo "bun not found"; exit 1; }
  exec "$BUN_PATH" -e "$(cat <<'JS'
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { homedir, tmpdir } from 'os';
import { join } from 'path';
const cfgDir = process.env.CLAUDE_CONFIG_DIR || join(homedir(), '.claude');
const cfgPath = join(cfgDir, 'plugins', 'cc-companion', 'config.json');
if (!existsSync(cfgPath)) { console.log('No companion config found'); process.exit(1); }
writeFileSync(join(tmpdir(), '.cc-companion-heart-frame.json'),
  JSON.stringify({ framesLeft: 5, frame: 0, writtenAt: Date.now() }));
let name = 'companion';
try { name = JSON.parse(readFileSync(cfgPath, 'utf8')).petName || 'companion'; } catch {}
console.log(`petted ${name}! ❤`);
JS
)"
}
case "$OSTYPE" in
  msys*|cygwin*|win32*) _win_pet ;;
esac
# --- End Windows branch -------------------------------------------------------

CONFIG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/cc-companion/config.json"
if [ ! -f "$CONFIG" ]; then echo "No companion config found"; exit 1; fi

TMPDIR_PATH="${TMPDIR:-/tmp}"
# Write heart state with timestamp for protection window
python3 -c "
import json, time
print(json.dumps({'framesLeft':5,'frame':0,'writtenAt':int(time.time()*1000)}))
" > "${TMPDIR_PATH}/.cc-companion-heart-frame.json"

# Print pet name
python3 -c "
import json
d = json.load(open('$CONFIG'))
name = d.get('petName', 'companion')
print(f'petted {name}! \u2764')
"
