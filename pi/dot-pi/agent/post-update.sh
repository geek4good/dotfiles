#!/usr/bin/env bash
# Re-apply local customizations after Pi updates.
# This script is called from dotfiles/sync.
#
# It handles:
#   1. Error-cause patch (surface ECONNRESET/etc instead of "Connection error.")
#   2. Provider-error cause-chain patch (openai-completions)
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
