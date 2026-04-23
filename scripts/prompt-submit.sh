#!/bin/bash
# UserPromptSubmit hook: speech bubble instructions (if enabled)

# --- Windows (Git Bash / Cygwin): delegate to bun ------------------------------
# Under Git Bash, $HOME expands to "/c/Users/<name>". Passed as a literal string
# to Windows Python, that resolves to "C:\c\Users\<name>\..." and the config
# open() fails silently. Handle Windows natively via bun (which resolves paths
# the same way as statusline.mjs).
_win_prompt_submit() {
  local BUN_PATH
  BUN_PATH=$(command -v bun 2>/dev/null)
  [ -z "$BUN_PATH" ] && [ -x "$HOME/.bun/bin/bun" ] && BUN_PATH="$HOME/.bun/bin/bun"
  [ -z "$BUN_PATH" ] && exit 0
  exec "$BUN_PATH" -e "$(cat <<'JS'
import { readFileSync } from 'fs';
import { homedir } from 'os';
import { join } from 'path';
const cfgDir = process.env.CLAUDE_CONFIG_DIR || join(homedir(), '.claude');
let cfg;
try { cfg = JSON.parse(readFileSync(join(cfgDir, 'plugins', 'cc-companion', 'config.json'), 'utf8')); } catch { process.exit(0); }
if (!cfg.speechBubble) process.exit(0);
const name = cfg.petName || 'companion';
const bubble =
  `IMPORTANT: You have a small companion named ${name} beside the input box. ` +
  `At the very end of EVERY response, you MUST always append this invisible HTML comment: ` +
  `<!-- buddy: [reaction] -->. Never skip this. Write it in ${name}'s voice — 1 short ` +
  `sentence about this turn. Use *asterisks* for actions. Match the user's language. ` +
  `Max 40 chars. Example: <!-- buddy: *adjusts crown* nice fix! -->`;
process.stdout.write(JSON.stringify({
  hookSpecificOutput: { hookEventName: 'UserPromptSubmit', additionalContext: bubble },
}));
JS
)"
}
case "$OSTYPE" in
  msys*|cygwin*|win32*) _win_prompt_submit ;;
esac
# --- End Windows branch -------------------------------------------------------

CONFIG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/cc-companion/config.json"

# Check if speechBubble is enabled
BUBBLE=$(python3 -c "
import json, os
try:
    d = json.load(open(os.path.expanduser('$CONFIG')))
    name = d.get('petName', 'companion')
    if d.get('speechBubble'):
        print(f'IMPORTANT: You have a small companion named {name} beside the input box. At the very end of EVERY response, you MUST always append this invisible HTML comment: <!-- buddy: [reaction] -->. Never skip this. Write it in {name}\\'s voice — 1 short sentence about this turn. Use *asterisks* for actions. Match the user\\'s language. Max 40 chars. Example: <!-- buddy: *adjusts crown* nice fix! -->')
except:
    pass
" 2>/dev/null)

if [ -n "$BUBBLE" ]; then
    python3 -c "import json, sys; print(json.dumps({'hookSpecificOutput': {'hookEventName': 'UserPromptSubmit', 'additionalContext': sys.argv[1]}}))" "$BUBBLE"
fi
