#!/bin/bash
# sync-wiki.sh — 从 KahWei-Brain/80 Wiki/ 同步内容到 Quartz content/
# 用法：在 kahwei-wiki/ 目录下运行 bash sync-wiki.sh

WIKI_SOURCE="${WIKI_SOURCE:-D:/KahWei-Brain/80 Wiki}"
CONTENT_DIR="./content"

# 保留 index.md（landing page），同步其他所有 Wiki 文件
echo "同步 Wiki: $WIKI_SOURCE → $CONTENT_DIR"

# 复制 Wiki 文件（排除 README.md）
find "$WIKI_SOURCE" -name "*.md" ! -name "README.md" -exec cp {} "$CONTENT_DIR/" \;

echo "同步完成。文件列表："
ls -la "$CONTENT_DIR/"
