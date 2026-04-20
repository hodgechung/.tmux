#!/usr/bin/env bash
# install.offline.sh —— 在离线机器上一键部署本 tmux 配置
#
# 用法：
#   1. 在有网机器：
#        git clone --depth 1 git@github.com:hodgechung/.tmux.git
#        bash .tmux/scripts/pack-offline.sh --with-tmux   # 或不带 --with-tmux
#   2. 拷 tmux-offline.tar.gz 到目标机器
#   3. 在目标机器：
#        tar xzf tmux-offline.tar.gz -C "$HOME"
#        bash "$HOME/.tmux/scripts/install.offline.sh"
#
# 由于 pack-offline.sh 已在打包机上预解压 AppImage + chmod 755 +
# 预生成 wrapper，本脚本只做：
#   - 建立 ~/.tmux.conf symlink（没 ln 就 cp）
#   - 检查 tmux 版本
#   - 引导把 $HOME/.tmux/bin 加入 PATH
#   - 如果在 tmux 里则立即 reload

set -euo pipefail

# 极简 shell 里 PATH 可能没继承，补全
export PATH="$HOME/.tmux/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

LN_BIN=$(command -v ln || true)
CHMOD_BIN=$(command -v chmod || true)

TMUX_DIR="$HOME/.tmux"
CONF="$HOME/.tmux.conf"

# 1. 必要文件检查
[ -d "$TMUX_DIR" ]          || { echo "ERR: $TMUX_DIR 不存在，请先解包"; exit 1; }
[ -f "$TMUX_DIR/.tmux.conf" ] || { echo "ERR: $TMUX_DIR/.tmux.conf 不存在"; exit 1; }

# 2. 兜底 chmod（tar 一般保留 mode，但某些 ACL/umask 场景仍会丢失）
if [ -n "$CHMOD_BIN" ]; then
  "$CHMOD_BIN" 755 "$TMUX_DIR/scripts/"*.sh 2>/dev/null || true
  [ -d "$TMUX_DIR/bin" ] && {
    "$CHMOD_BIN" 755 "$TMUX_DIR/bin/tmux-wrapper" 2>/dev/null || true
    "$CHMOD_BIN" 755 "$TMUX_DIR/bin/tmux.appimage" 2>/dev/null || true
    [ -d "$TMUX_DIR/bin/squashfs-root" ] && \
      find "$TMUX_DIR/bin/squashfs-root" \
           -type f \( -name "tmux" -o -name "*.sh" -o -name "AppRun" \) \
           -exec "$CHMOD_BIN" 755 {} + 2>/dev/null || true
  }
fi

# 3. ~/.tmux.conf symlink（或 cp fallback）
link_or_copy() {
  local src="$1" dst="$2"
  if [ -n "$LN_BIN" ]; then
    "$LN_BIN" -sfn "$src" "$dst"
    echo "✓ symlink: $dst -> $src"
  else
    cp -f "$src" "$dst"
    echo "⚠ 未找到 ln，已退化为 cp；日后改配置需重跑本脚本同步: $dst"
  fi
}
if [ -L "$CONF" ] || [ ! -e "$CONF" ]; then
  link_or_copy "$TMUX_DIR/.tmux.conf" "$CONF"
else
  mv -f "$CONF" "${CONF}.bak"
  echo "⚠ $CONF 已存在且不是 symlink，已备份为 ${CONF}.bak"
  link_or_copy "$TMUX_DIR/.tmux.conf" "$CONF"
fi

# 4. 定位 tmux：优先随包，其次系统
BUNDLED_TMUX="$TMUX_DIR/bin/tmux"
TMUX_BIN=""
if [ -x "$BUNDLED_TMUX" ] && "$BUNDLED_TMUX" -V >/dev/null 2>&1; then
  TMUX_BIN="$BUNDLED_TMUX"
  echo "✓ 随包 tmux 可用: $("$BUNDLED_TMUX" -V)"
else
  TMUX_BIN=$(command -v tmux || true)
  if [ -n "$TMUX_BIN" ]; then
    echo "✓ 系统 tmux: $("$TMUX_BIN" -V)"
  fi
fi

if [ -z "$TMUX_BIN" ]; then
  echo
  echo "✗ 无可用 tmux。问题与排查："
  echo "  a) 检查随包二进制:"
  echo "       ls -la $TMUX_DIR/bin/"
  echo "       $BUNDLED_TMUX -V"
  echo "  b) 如果报 'Permission denied'，可能 \$HOME 是 noexec 挂载"
  echo "       mount | grep \"\$(df -P \"\$HOME\" | tail -1 | awk '{print \$NF}')\""
  echo "       若含 noexec，把 $TMUX_DIR/bin 整个复制到一个 exec 允许的目录"
  echo "       （例如 /tmp、/opt/bin），再把该目录加入 PATH"
  echo "  c) 如果报 terminfo 错，重跑本脚本触发 wrapper 路径修正"
  exit 1
fi

# 5. 版本检查
VER=$("$TMUX_BIN" -V | awk '{print $2}')
MAJ=${VER%%.*}
case "$MAJ" in
  [3-9]|[1-9][0-9]*) TMUX_OK=1 ;;
  *) TMUX_OK=0 ;;
esac
if [ "$TMUX_OK" = "0" ]; then
  echo "✗ tmux $VER < 3.0，本配置依赖 3.0+ 特性（{} 块语法、display-popup、"
  echo "  set-clipboard OSC52、众多 hook 名）。请升级 tmux 后再跑本脚本。"
fi

# 6. 插件目录
PLUG="$TMUX_DIR/plugins"
if [ -L "$PLUG" ]; then
  TGT=$(readlink "$PLUG" 2>/dev/null || echo "?")
  [ -d "$PLUG/" ] && echo "✓ plugins symlink → $TGT" \
                  || echo "⚠ plugins 是断开的 symlink → $TGT"
elif [ -d "$PLUG" ]; then
  COUNT=$(find "$PLUG" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
  echo "✓ plugins 目录存在（$COUNT 个子目录）"
else
  echo "⚠ plugins 目录缺失"
fi

# 7. 若已在 tmux 里，立即 reload
if [ -n "${TMUX:-}" ] && [ "$TMUX_OK" = "1" ]; then
  "$TMUX_BIN" source-file "$CONF" && echo "✓ 已 reload 当前 tmux session"
elif [ -z "${TMUX:-}" ]; then
  echo "→ 不在 tmux 里，下次启动 tmux 即可生效"
fi

# 8. PATH 持久化引导
echo
echo "────────────────────────────────────────"
echo "最后一步：把 $TMUX_DIR/bin 加入 PATH（如果还没加过）"
echo "  for bash/zsh:"
echo "    echo 'export PATH=\"\$HOME/.tmux/bin:\$PATH\"' >> ~/.bashrc"
echo "    source ~/.bashrc"
echo
echo "然后："
echo "  tmux -V             # 应显示 tmux $VER"
echo "  tmux new-session -A -s main"
echo "  按 C-b ?  查看菜单"
