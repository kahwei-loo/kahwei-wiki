#!/bin/bash
# push-wiki.sh — Sync KahWei-Brain/80 Wiki/ to Quartz and push to GitHub
# Usage: bash /d/kahwei-wiki/scripts/push-wiki.sh

set -e

WIKI_SOURCE="${WIKI_SOURCE:-D:/KahWei-Brain/80 Wiki}"
REPO_DIR="/d/kahwei-wiki"
CONTENT_DIR="$REPO_DIR/content"

echo "=== Syncing Wiki to Quartz ==="

# Clean old content (preserve index.md landing page)
find "$CONTENT_DIR" -name "*.md" ! -name "index.md" -delete 2>/dev/null

# Copy Wiki files (exclude README.md)
find "$WIKI_SOURCE" -name "*.md" ! -name "README.md" -exec cp {} "$CONTENT_DIR/" \;

echo "Synced files:"
ls "$CONTENT_DIR/"

# Git commit and push
cd "$REPO_DIR"
git add -A
if git diff --cached --quiet; then
  echo "No changes, skipping push."
else
  git commit -m "wiki: sync from KahWei-Brain $(date +%Y-%m-%d)"
  git push origin main
  echo "=== Push complete. GitHub Actions will auto-deploy. ==="
fi
