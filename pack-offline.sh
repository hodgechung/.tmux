#!/usr/bin/env bash
# pack-offline.sh —— 在有网机器上打包一份可在离线机器解压即用的 tmux 配置
#
# 产物：tmux-offline.tar.gz （约 3.5 MB）
# 离线机器用法：
#   tar xzf tmux-offline.tar.gz -C "$HOME"
#   bash "$HOME/.tmux/install.offline.sh"

set -euo pipefail

cd "$(dirname "$0")"
OUT="${1:-$PWD/tmux-offline.tar.gz}"

# 打包 .tmux 整个目录（含 dereference 后的 plugins）
# 放在 $HOME/ 下，解压时加 -C "$HOME"
TOP=$(cd .. && pwd)
REL=$(basename "$PWD")  # 通常是 .tmux

echo "→ 打包 $TOP/$REL"
tar czf "$OUT" \
    --dereference \
    --exclude="$REL/.git" \
    --exclude=".git" \
    --exclude="*.bak.*" \
    --exclude="*.backup.*" \
    --exclude="tmux-*.log" \
    --exclude="tpm_log.txt" \
    --exclude="test-file" \
    -C "$TOP" \
    "$REL"

SZ=$(du -h "$OUT" | cut -f1)
echo "✓ 输出: $OUT ($SZ)"
echo
echo "在离线机器上："
echo "  tar xzf $(basename "$OUT") -C \"\$HOME\""
echo "  bash \"\$HOME/$REL/install.offline.sh\""
