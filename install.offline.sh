#!/usr/bin/env bash
# install.offline.sh —— 在离线机器上一键部署本 tmux 配置
#
# 用法：
#   1. 在有网机器：
#        git clone --depth 1 git@github.com:hodgechung/.tmux.git
#        cd .tmux && bash pack-offline.sh     # 生成 tmux-offline.tar.gz
#   2. 拷贝 tmux-offline.tar.gz 到目标机器
#   3. 在目标机器：
#        tar xzf tmux-offline.tar.gz -C "$HOME"
#        bash "$HOME/.tmux/install.offline.sh"
#
# 脚本做什么：
#   - 确保 ~/.tmux.conf symlink 指向 ~/.tmux/.tmux.conf
#   - 检查 tmux 版本，提示是否低于 3.0（某些功能会失效）
#   - 检查 plugins 目录是否就位
#   - 立即 source 配置（若当前有 tmux session 运行）

set -euo pipefail

TMUX_DIR="$HOME/.tmux"
CONF="$HOME/.tmux.conf"

# 1. 必要文件检查
[[ -d "$TMUX_DIR" ]] || { echo "ERR: $TMUX_DIR 不存在，请先解包"; exit 1; }
[[ -f "$TMUX_DIR/.tmux.conf" ]] || { echo "ERR: $TMUX_DIR/.tmux.conf 不存在"; exit 1; }

# 2. 建立 symlink
if [[ -L "$CONF" || ! -e "$CONF" ]]; then
  ln -sfn "$TMUX_DIR/.tmux.conf" "$CONF"
  echo "✓ symlink 就位: $CONF -> $TMUX_DIR/.tmux.conf"
else
  echo "⚠ $CONF 已存在且不是 symlink，已备份为 ${CONF}.bak"
  mv "$CONF" "${CONF}.bak"
  ln -sfn "$TMUX_DIR/.tmux.conf" "$CONF"
fi

# 3. 脚本可执行位
chmod +x "$TMUX_DIR/apply_cheatsheet.sh" 2>/dev/null || true

# 4. tmux 版本检查
if ! command -v tmux >/dev/null 2>&1; then
  echo "⚠ 系统没装 tmux，请先安装 tmux 3.0+（推荐 3.4）"
  exit 0
fi
VER=$(tmux -V | awk '{print $2}')
MAJ=${VER%%.*}; MIN=${VER#*.}; MIN=${MIN%%.*}; MIN=${MIN%%[a-z]*}
if (( MAJ < 3 )); then
  echo "⚠ 当前 tmux $VER，本配置需要 3.0+，帮助菜单的 {} 块语法将失效"
fi
echo "✓ tmux $VER"

# 5. 插件目录检查
PLUG="$TMUX_DIR/plugins"
if [[ -L "$PLUG" ]]; then
  TGT=$(readlink "$PLUG")
  if [[ ! -d "$PLUG/" ]]; then
    echo "⚠ plugins 是一个断开的 symlink → $TGT"
    echo "   请把插件目录准备好，或删除 symlink 让 tpm 重装（需要网络）"
  else
    echo "✓ plugins symlink → $TGT"
  fi
elif [[ -d "$PLUG" ]]; then
  COUNT=$(find "$PLUG" -maxdepth 1 -mindepth 1 -type d | wc -l)
  echo "✓ plugins 目录在本仓库内 ($COUNT 个插件)"
else
  echo "⚠ plugins 目录缺失（cpu/copycat/resurrect 等功能不可用）"
fi

# 6. 若当前在 tmux 里，立即 reload
if [[ -n "${TMUX:-}" ]]; then
  tmux source-file "$CONF" && echo "✓ 已 reload 当前 tmux session"
else
  echo "→ 下次启动 tmux 即可生效"
fi

echo
echo "部署完成。测试："
echo "  tmux new-session -A -s main"
echo "  按 C-b ?  查看菜单"
echo "  按 C-b    底部第二行应亮起 cheat-sheet"
