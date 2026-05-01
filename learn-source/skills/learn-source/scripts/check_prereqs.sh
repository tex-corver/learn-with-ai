#!/bin/sh
# check_prereqs.sh — preflight for learn-source
#
# Emits a JSON object on stdout:
#   {"ok": bool, "missing": [...], "warnings": [...], "hints": {key: hint}, "slug": "..."}
#
# Usage: check_prereqs.sh [path-to-source-file]
#
# Always exits 0. Caller parses JSON and decides hard-fail vs warn.

set -u

file_arg="${1:-}"
plugin_root="${CLAUDE_PLUGIN_ROOT:-}"

missing=""
warnings=""
hints=""
slug_json="null"

_escape_json() {
    # Escape backslash and double-quote for safe JSON string interpolation.
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

add_missing() {
    _k=$(_escape_json "$1")
    if [ -z "$missing" ]; then missing="\"$_k\""; else missing="$missing, \"$_k\""; fi
}
add_warning() {
    _k=$(_escape_json "$1")
    if [ -z "$warnings" ]; then warnings="\"$_k\""; else warnings="$warnings, \"$_k\""; fi
}
add_hint() {
    _k=$(_escape_json "$1")
    _v=$(_escape_json "$2")
    entry="\"$_k\": \"$_v\""
    if [ -z "$hints" ]; then hints="$entry"; else hints="$hints, $entry"; fi
}

# 1. nlm CLI installed
if ! command -v nlm >/dev/null 2>&1; then
    add_missing "nlm"
    add_hint "nlm" "Install with: uv tool install notebooklm-mcp-cli"
else
    # 2. nlm authenticated — prefer documented `nlm login --check`, fallback to `nlm auth status`
    if nlm login --check >/dev/null 2>&1; then
        :
    elif nlm auth status >/dev/null 2>&1; then
        :
    else
        add_missing "nlm_auth"
        add_hint "nlm_auth" "Run: nlm login (or 'nlm auth login' on older CLI builds)"
    fi
fi

# 3. Sibling plugins — probe under ${CLAUDE_PLUGIN_ROOT}/.. if provided
if [ -n "$plugin_root" ]; then
    if [ ! -f "$plugin_root/../learn/skills/learn/SKILL.md" ]; then
        add_missing "learn_skill"
        add_hint "learn_skill" "Install the 'learn' plugin from the same marketplace"
    fi
    if [ ! -f "$plugin_root/../notebooklm/skills/notebooklm/workflows/ask.md" ]; then
        add_warning "notebooklm_missing"
        add_hint "notebooklm_missing" "notebooklm plugin not found; QA notes will lack resolved citations"
    fi
fi

# 4. Vault check — is there a Notes/ dir in cwd or any parent?
vault_root=""
dir="$(pwd)"
while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -d "$dir/Notes" ]; then
        vault_root="$dir"
        break
    fi
    dir="$(dirname "$dir")"
done
if [ -z "$vault_root" ]; then
    add_warning "no_vault"
    add_hint "no_vault" "No Notes/ folder found in cwd or parents; falling back to ~/.claude/learn-source/"
elif [ ! -w "$vault_root" ]; then
    add_warning "vault_readonly"
    add_hint "vault_readonly" "Vault root is not writable; falling back to ~/.claude/learn-source/"
fi

# 5. If a file was passed: exists, readable, supported extension, reasonable size, compute slug
if [ -n "$file_arg" ]; then
    if [ ! -e "$file_arg" ]; then
        add_missing "file_not_readable"
        add_hint "file_not_readable" "Path does not exist: $file_arg"
    elif [ ! -r "$file_arg" ]; then
        add_missing "file_not_readable"
        add_hint "file_not_readable" "Path exists but is not readable: $file_arg"
    else
        ext=$(printf '%s' "$file_arg" | awk -F. '{print tolower($NF)}')
        case "$ext" in
            pdf|md|markdown|txt) ;;
            *)
                add_missing "unsupported_extension"
                add_hint "unsupported_extension" "Supported extensions: pdf, md, markdown, txt (got: $ext)"
                ;;
        esac
        # size check — warn above ~50 MB
        size=$(wc -c < "$file_arg" 2>/dev/null | tr -d ' ')
        if [ -n "$size" ] && [ "$size" -gt 52428800 ]; then
            add_warning "large_file"
            add_hint "large_file" "File is larger than 50MB; NotebookLM indexing may be slow"
        fi
        # Canonical slug: kebab(stem) + "-" + md5(file)[:6]
        stem=$(basename "$file_arg" | sed 's/\.[^.]*$//')
        kebab=$(printf '%s' "$stem" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
        if command -v md5sum >/dev/null 2>&1; then
            hash=$(md5sum "$file_arg" 2>/dev/null | cut -c1-6)
        elif command -v md5 >/dev/null 2>&1; then
            hash=$(md5 -q "$file_arg" 2>/dev/null | cut -c1-6)
        else
            hash=""
            add_warning "no_md5"
            add_hint "no_md5" "Neither md5sum nor md5 found; slug hash unavailable"
        fi
        if [ -n "$kebab" ] && [ -n "$hash" ]; then
            slug_escaped=$(_escape_json "${kebab}-${hash}")
            slug_json="\"$slug_escaped\""
        fi
    fi
fi

if [ -z "$missing" ]; then
    ok="true"
else
    ok="false"
fi

printf '{"ok": %s, "missing": [%s], "warnings": [%s], "hints": {%s}, "slug": %s}\n' \
    "$ok" "$missing" "$warnings" "$hints" "$slug_json"

exit 0
