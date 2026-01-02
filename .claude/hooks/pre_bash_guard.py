#!/usr/bin/env python3
import json
import re
import sys

# Claude Code hook: PreToolUse for Bash
# Purpose: block obviously dangerous commands; fail-open if payload shape changes.

DANGEROUS = [
    re.compile(r"\brm\s+-rf\b"),
    re.compile(r"\bmkfs\b"),
    re.compile(r"\bshutdown\b"),
    re.compile(r":\(\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:\s*$"),  # fork bomb
]

def main() -> int:
    raw = sys.stdin.read().strip()
    if not raw:
        return 0

    try:
        payload = json.loads(raw)
    except Exception:
        return 0

    # Common shapes seen in hook payloads:
    # payload.tool_input.command or payload.toolInput.command
    cmd = None
    for path in (
        ("tool_input", "command"),
        ("toolInput", "command"),
        ("input", "command"),
    ):
        cur = payload
        ok = True
        for k in path:
            if isinstance(cur, dict) and k in cur:
                cur = cur[k]
            else:
                ok = False
                break
        if ok and isinstance(cur, str):
            cmd = cur
            break

    if not cmd:
        return 0

    for pat in DANGEROUS:
        if pat.search(cmd):
            # exit code 2 is commonly treated as "block" in hook systems.
            print(f"Blocked dangerous shell command by policy: {cmd}", file=sys.stderr)
            return 2

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
