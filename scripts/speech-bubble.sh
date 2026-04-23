#!/bin/bash
# Stop hook: extract <!-- buddy: ... --> from LLM response, write to reaction.json
# CC passes JSON via stdin with field "last_assistant_message"

# --- Windows (Git Bash / Cygwin): delegate to bun ------------------------------
# The Linux path below uses jq (often missing on Git Bash) and passes /tmp as a
# literal string to Python — Windows Python interprets that as C:\tmp\, which
# doesn't match statusline.mjs's os.tmpdir(). Handle Windows natively via bun
# so the reaction file lands where the statusline reads it.
_win_speech_bubble() {
  local BUN_PATH
  BUN_PATH=$(command -v bun 2>/dev/null)
  [ -z "$BUN_PATH" ] && [ -x "$HOME/.bun/bin/bun" ] && BUN_PATH="$HOME/.bun/bin/bun"
  [ -z "$BUN_PATH" ] && exit 0
  exec "$BUN_PATH" -e "$(cat <<'JS'
import { writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join } from 'path';
const file = join(tmpdir(), '.cc-companion-reaction.json');
let data = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (c) => { data += c; });
process.stdin.on('end', () => {
  let msg = '';
  try { msg = String(JSON.parse(data).last_assistant_message ?? ''); } catch {}
  if (!msg) return;
  const m = [...msg.matchAll(/<!--\s*buddy:\s*(.*?[^\s])\s*-->/g)];
  if (!m.length) return;
  try { writeFileSync(file, JSON.stringify({ reaction: m[m.length - 1][1], timestamp: Date.now() })); } catch {}
});
JS
)"
}
case "$OSTYPE" in
  msys*|cygwin*|win32*) _win_speech_bubble ;;
esac
# --- End Windows branch -------------------------------------------------------

TMPDIR_PATH="${TMPDIR:-/tmp}"
REACTION_FILE="${TMPDIR_PATH}/.cc-companion-reaction.json"

INPUT=$(cat)
MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // ""' 2>/dev/null)
[ -z "$MSG" ] && exit 0

COMMENT=$(echo "$MSG" | sed -n 's/.*<!-- *buddy: *\(.*[^ ]\) *-->.*/\1/p' | tail -1)
[ -z "$COMMENT" ] && exit 0

python3 -c "
import json, time, sys
reaction = sys.stdin.read().strip()
if reaction:
    json.dump({'reaction': reaction, 'timestamp': int(time.time()*1000)},
        open('${REACTION_FILE}', 'w'))
" <<< "$COMMENT"
