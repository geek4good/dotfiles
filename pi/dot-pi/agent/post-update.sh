#!/usr/bin/env bash
# Re-apply local customizations after Pi updates.
# This script is called from dotfiles/sync.
#
# It handles:
#   1. Error-cause patch (surface ECONNRESET/etc instead of "Connection error.")
#   2. Legacy agent-pi overrides (models.json, teams.yaml, theme) — dormant now
#   3. Deletes unwanted agent files — dormant now
set -euo pipefail

# --- 1. Re-apply the connection-error-cause patch to the pi bundle ---
# pi is installed via npm and `pi update --self` replaces the bundle, so this
# must be re-applied after every update. Idempotent + safe to run anytime.
PATCH_SCRIPT="$HOME/.pi/agent/patch-pi-error-cause.py"
if [[ -x "$PATCH_SCRIPT" ]]; then
    "$PATCH_SCRIPT" || echo "⚠ error-cause patch failed (see above)"
else
    echo "⚠ $PATCH_SCRIPT not found — run dotfiles sync to install it"
fi

# --- 1b. Re-apply the provider-error cause-chain patch (openai-completions) ---
# normalizeProviderError() only reads error.message, so network failures from
# OpenAI-compatible providers (e.g. glm-coding-plan) surface as a bare
# "Connection error.". This appends the .cause chain at the source.
PATCH_DETAIL="$HOME/.local/bin/pi-patch-error-detail"
if [[ -x "$PATCH_DETAIL" ]]; then
    "$PATCH_DETAIL" || echo "⚠ provider-error cause-chain patch failed (see above)"
else
    echo "⚠ $PATCH_DETAIL not found — run dotfiles sync / stow bin to install it"
fi

# --- Legacy agent-pi local overrides (repo no longer exists; kept for safety) ---
REPO_DIR="$HOME/.pi/agent/git/github.com/ruizrica/agent-pi"
PATCH_FILE="$HOME/.pi/agent/local-overrides.patch"

if [[ ! -d "$REPO_DIR" ]]; then
    exit 0
fi

cd "$REPO_DIR"

# --- 1. Apply patch for modified files ---
if [[ -f "$PATCH_FILE" ]]; then
    # Check if changes are already applied (dirty working tree matches patch)
    if ! git diff --quiet HEAD -- agents/models.json agents/teams.yaml themes/midnight-ocean.json 2>/dev/null; then
        echo "ℹ Pi local overrides already applied"
    elif git apply --check "$PATCH_FILE" 2>/dev/null; then
        git apply "$PATCH_FILE"
        echo "✓ Pi local overrides applied"
    else
        echo "⚠ Pi local overrides patch does not apply cleanly — upstream may have changed"
        echo "  Fix: cd $REPO_DIR && edit files && git diff HEAD -- agents/models.json agents/teams.yaml themes/midnight-ocean.json > $PATCH_FILE"
    fi
fi

# --- 2. Delete unwanted agent files ---
DELETED_AGENTS=(
    agents/builder-gemini-3-1-flash-lite-preview.md
    agents/builder-gpt-5-1-codex-mini.md
    agents/builder-kimi-k2-5.md
    agents/builder-minimax-m2-5.md
    agents/builder-qwen3-5-122b-a10b.md
    agents/builder-qwen3-5-flash-02-23.md
    agents/builder-qwen3-coder-next.md
    agents/builder-qwen3-coder.md
    agents/copilot-agent.md
)

for agent in "${DELETED_AGENTS[@]}"; do
    if [[ -f "$agent" ]]; then
        rm "$agent"
    fi
done

echo "✓ Unwanted agents removed"
