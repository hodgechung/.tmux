#!/usr/bin/env bash
# install.offline.sh —— 在离线机器上一键部署本 tmux 配置
#
# 用法：
#   1. 在有网机器：
#        git clone --depth 1 git@github.com:hodgechung/.tmux.git
#        bash .tmux/scripts/pack-offline.sh     # 生成 tmux-offline.tar.gz
#   2. 拷贝 tmux-offline.tar.gz 到目标机器
#   3. 在目标机器：
#        tar xzf tmux-offline.tar.gz -C "$HOME"
#        bash "$HOME/.tmux/scripts/install.offline.sh"
#
# 脚本做什么：
#   - 确保 ~/.tmux.conf symlink 指向 ~/.tmux/.tmux.conf
#   - 检查 tmux 版本，提示是否低于 3.0（某些功能会失效）
#   - 检查 plugins 目录是否就位
#   - 立即 source 配置（若当前有 tmux session 运行）

set -euo pipefail

# 对极简 shell（busybox / 受限容器 / PATH 未继承）补全 PATH，
# 否则 ln/chmod/tmux/awk/mv 等基础命令会 command not found
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

# 解析 ln / chmod 的绝对路径，真的没 ln 时退化为 cp
LN_BIN=$(command -v ln || true)
CHMOD_BIN=$(command -v chmod || true)
TMUX_BIN=$(command -v tmux || true)

TMUX_DIR="$HOME/.tmux"
CONF="$HOME/.tmux.conf"

# 1. 必要文件检查
[ -d "$TMUX_DIR" ]          || { echo "ERR: $TMUX_DIR 不存在，请先解包"; exit 1; }
[ -f "$TMUX_DIR/.tmux.conf" ] || { echo "ERR: $TMUX_DIR/.tmux.conf 不存在"; exit 1; }

# 2. 建立 .tmux.conf（优先 symlink；没 ln 就复制）
link_or_copy() {
  local src="$1" dst="$2"
  if [ -n "$LN_BIN" ]; then
    "$LN_BIN" -sfn "$src" "$dst"
    echo "✓ symlink: $dst -> $src"
  else
    cp -f "$src" "$dst"
    echo "⚠ 未找到 ln，已退化为 cp；日后改配置请重新跑本脚本同步: $dst"
  fi
}

if [ -L "$CONF" ] || [ ! -e "$CONF" ]; then
  link_or_copy "$TMUX_DIR/.tmux.conf" "$CONF"
else
  mv -f "$CONF" "${CONF}.bak"
  echo "⚠ $CONF 已存在且不是 symlink，已备份为 ${CONF}.bak"
  link_or_copy "$TMUX_DIR/.tmux.conf" "$CONF"
fi

# 3. 脚本可执行位
if [ -n "$CHMOD_BIN" ]; then
  "$CHMOD_BIN" +x "$TMUX_DIR/scripts/"*.sh 2>/dev/null || true
fi

# 4. tmux 版本检查
if [ -z "$TMUX_BIN" ]; then
  echo
  echo "✗ 系统没装 tmux。本配置需要 tmux 3.0+（推荐 3.4）。"
  echo "  离线机器部署建议："
  echo "    1) 下载 nelsonenzo/tmux-appimage（静态单文件）"
  echo "       https://github.com/nelsonenzo/tmux-appimage/releases"
  echo "    2) 或从有网机器 apt-get download tmux libevent libtinfo"
  echo "       拷贝 .deb 过来 dpkg -i"
  echo "    3) 或在源机器 tar 里一并带上 tmux 二进制"
  exit 0
fi

VER=$("$TMUX_BIN" -V | awk '{print $2}')
MAJ=${VER%%.*}
case "$MAJ" in
  [3-9]|[1-9][0-9]*) TMUX_OK=1 ;;
  *) TMUX_OK=0 ;;
esac

echo "✓ tmux $VER"
if [ "$TMUX_OK" = "0" ]; then
  echo "✗ tmux $VER < 3.0，本配置大量依赖 3.0+ 特性："
  echo "    - display-menu/popup 的 { ... } 块语法 (3.0+)"
  echo "    - display-popup                       (3.2+)"
  echo "    - set-clipboard on 的 OSC52 行为      (3.2+)"
  echo "    - set-hook 的大部分 hook 名            (3.0+)"
  echo "  你会看到大量解析错误，且帮助菜单/cheat-sheet/剪贴板都不工作。"
  echo "  **建议先升级 tmux 再跑本脚本**。"
fi

# 5. 插件目录检查
PLUG="$TMUX_DIR/plugins"
if [ -L "$PLUG" ]; then
  TGT=$(readlink "$PLUG" 2>/dev/null || echo "?")
  if [ ! -d "$PLUG/" ]; then
    echo "⚠ plugins 是断开的 symlink → $TGT"
  else
    echo "✓ plugins symlink → $TGT"
  fi
elif [ -d "$PLUG" ]; then
  COUNT=$(find "$PLUG" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
  echo "✓ plugins 目录存在（$COUNT 个子目录）"
else
  echo "⚠ plugins 目录缺失（cpu/copycat/resurrect 等功能不可用）"
fi

# 6. 若当前在 tmux 里且版本 OK，立即 reload
if [ -n "${TMUX:-}" ] && [ "$TMUX_OK" = "1" ]; then
  "$TMUX_BIN" source-file "$CONF" && echo "✓ 已 reload 当前 tmux session"
elif [ -z "${TMUX:-}" ]; then
  echo "→ 不在 tmux 里，下次启动 tmux 即可生效"
fi

echo
echo "部署完成。测试："
echo "  tmux new-session -A -s main"
echo "  按 C-b ?  查看菜单"
echo "  按 C-b    底部第二行应亮起 cheat-sheet"
