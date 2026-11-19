#!/usr/bin/env bash
set -euo pipefail

PROJECTS_ROOT="${1:-$HOME/projects}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. Install global security-baseline plugin
PLUGIN_DST="$HOME/.gemini/config/plugins/security-baseline"
mkdir -p "$PLUGIN_DST/rules"
cp "$REPO_ROOT/plugins/security-baseline/plugin.json" "$PLUGIN_DST/plugin.json"
cp "$REPO_ROOT/plugins/security-baseline/rules/AGENTS.md" "$PLUGIN_DST/rules/AGENTS.md"
echo "[OK] Installed security-baseline plugin -> $PLUGIN_DST"

# 2. Configure global gitignore for GEMINI.md and STATE.md
GLOBAL_IGNORE="$HOME/.gitignore_global"
touch "$GLOBAL_IGNORE"
grep -qxF "GEMINI.md" "$GLOBAL_IGNORE" || echo "GEMINI.md" >> "$GLOBAL_IGNORE"
grep -qxF "STATE.md"  "$GLOBAL_IGNORE" || echo "STATE.md"  >> "$GLOBAL_IGNORE"
git config --global core.excludesfile "$GLOBAL_IGNORE"
echo "[OK] Configured global gitignore -> $GLOBAL_IGNORE"

# 3. Initialize _control-plane if not present
CONTROL_PLANE="$PROJECTS_ROOT/_control-plane"
if [ ! -d "$CONTROL_PLANE" ]; then
  mkdir -p "$CONTROL_PLANE/manifests" "$CONTROL_PLANE/generated-prompts"
  cp "$REPO_ROOT/templates/control-plane/GEMINI.md" "$CONTROL_PLANE/GEMINI.md"
  cp "$REPO_ROOT/templates/control-plane/PORTFOLIO.md" "$CONTROL_PLANE/PORTFOLIO.md"
  cp -r "$REPO_ROOT/templates/control-plane/.agents" "$CONTROL_PLANE/.agents"
  echo "[OK] Initialized _control-plane -> $CONTROL_PLANE"
else
  echo "[SKIP] _control-plane already exists -> $CONTROL_PLANE"
fi
