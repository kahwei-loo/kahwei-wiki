#!/bin/bash
# push-wiki.sh — 从 KahWei-Brain/80 Wiki/ 同步到 Quartz 并推送到 GitHub
# 用法：bash /d/kahwei-wiki/scripts/push-wiki.sh

set -e

WIKI_SOURCE="${WIKI_SOURCE:-D:/KahWei-Brain/80 Wiki}"
REPO_DIR="/d/kahwei-wiki"
CONTENT_DIR="$REPO_DIR/content"

echo "=== 同步 Wiki 到 Quartz ==="

# 清理旧内容（保留 index.md landing page）
find "$CONTENT_DIR" -name "*.md" ! -name "index.md" -delete 2>/dev/null

# 复制 Wiki 文件（排除 README.md）
find "$WIKI_SOURCE" -name "*.md" ! -name "README.md" -exec cp {} "$CONTENT_DIR/" \;

echo "已同步的文件："
ls "$CONTENT_DIR/"

# Git 提交并推送
cd "$REPO_DIR"
git add -A
if git diff --cached --quiet; then
  echo "没有变更，跳过推送。"
else
  git commit -m "wiki: sync from KahWei-Brain $(date +%Y-%m-%d)"
  git push origin main
  echo "=== 推送完成，GitHub Actions 将自动部署 ==="
fi
