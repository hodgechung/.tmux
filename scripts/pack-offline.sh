#!/usr/bin/env bash
# pack-offline.sh —— 在有网机器上打包一份可在离线机器解压即用的 tmux 配置
#
# 产物：tmux-offline.tar.gz （约 580 KB）
# 离线机器用法：
#   tar xzf tmux-offline.tar.gz -C "$HOME"
#   bash "$HOME/.tmux/scripts/install.offline.sh"

set -euo pipefail

# 脚本在 ~/.tmux/scripts/，TMUX_DIR 是 ~/.tmux
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMUX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="${1:-$PWD/tmux-offline.tar.gz}"

TOP="$(dirname "$TMUX_DIR")"
REL="$(basename "$TMUX_DIR")"  # 通常是 .tmux

echo "→ 打包 $TMUX_DIR"
tar czf "$OUT" \
    --dereference \
    --exclude="$REL/.git" \
    --exclude=".git" \
    --exclude="*.bak.*" \
    --exclude="*.backup.*" \
    --exclude="tmux-*.log" \
    --exclude="tpm_log.txt" \
    --exclude="test-file" \
    --exclude=".omc" \
    -C "$TOP" \
    "$REL"

SZ=$(du -h "$OUT" | cut -f1)
echo "✓ 输出: $OUT ($SZ)"
echo
echo "在离线机器上："
echo "  tar xzf $(basename "$OUT") -C \"\$HOME\""
echo "  bash \"\$HOME/$REL/scripts/install.offline.sh\""
