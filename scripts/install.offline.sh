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
export PATH="$HOME/.tmux/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

# 解析 ln / chmod 的绝对路径，真的没 ln 时退化为 cp
LN_BIN=$(command -v ln || true)
CHMOD_BIN=$(command -v chmod || true)
# 优先用随包携带的 ~/.tmux/bin/tmux（AppImage），其次系统 tmux
TMUX_BIN=$(command -v tmux || true)

TMUX_DIR="$HOME/.tmux"
CONF="$HOME/.tmux.conf"

# 如果存在打包好的 tmux AppImage，确保它可执行并优先使用
BUNDLED_TMUX="$TMUX_DIR/bin/tmux"
WRAPPER="$TMUX_DIR/bin/tmux-wrapper"
if [ -f "$BUNDLED_TMUX" ]; then
  [ -n "$CHMOD_BIN" ] && "$CHMOD_BIN" +x "$BUNDLED_TMUX" 2>/dev/null || true
  # FUSE 检测：能 -V 就直接用
  if "$BUNDLED_TMUX" -V >/dev/null 2>&1; then
    TMUX_BIN="$BUNDLED_TMUX"
    echo "✓ 使用随包 tmux: $BUNDLED_TMUX ($("$BUNDLED_TMUX" -V))"
  else
    # 没有 FUSE / 内核限制，尝试自动解压 AppImage
    echo "⚠ $BUNDLED_TMUX 无法直接运行（通常是内核无 FUSE 支持）"

    # 解压目标：先试就地解压。如果 $HOME 挂载了 noexec（常见于
    # /data/home 这种 NAS），解压出来的 tmux 也不可执行，需要搬到 /tmp
    EXTRACT_DIR="$TMUX_DIR/bin"
    if [ ! -x "$EXTRACT_DIR/squashfs-root/usr/bin/tmux" ]; then
      echo "→ 尝试用 --appimage-extract 就地解压..."
      ( cd "$EXTRACT_DIR" && "$BUNDLED_TMUX" --appimage-extract >/dev/null 2>&1 ) || true
    fi
    [ -n "$CHMOD_BIN" ] && "$CHMOD_BIN" +x "$EXTRACT_DIR/squashfs-root/usr/bin/tmux" 2>/dev/null || true

    # 检测就地解压的二进制能否执行（noexec 场景会返回非 0）
    if ! "$EXTRACT_DIR/squashfs-root/usr/bin/tmux" -V >/dev/null 2>&1; then
      echo "⚠ 就地解压的 tmux 无法执行（$HOME 可能是 noexec 挂载）"
      # 搬到 /tmp
      ALT_DIR="/tmp/tmux-appimage-$(id -u)"
      echo "→ 搬到 $ALT_DIR 并重新解压..."
      rm -rf "$ALT_DIR"
      mkdir -p "$ALT_DIR"
      cp -f "$BUNDLED_TMUX" "$ALT_DIR/tmux.appimage"
      [ -n "$CHMOD_BIN" ] && "$CHMOD_BIN" +x "$ALT_DIR/tmux.appimage"
      ( cd "$ALT_DIR" && "$ALT_DIR/tmux.appimage" --appimage-extract >/dev/null 2>&1 ) || true
      EXTRACT_DIR="$ALT_DIR"
    fi

    REAL_TMUX="$EXTRACT_DIR/squashfs-root/usr/bin/tmux"
    TERMINFO_DIR="$EXTRACT_DIR/squashfs-root/usr/share/terminfo"

    if [ -x "$REAL_TMUX" ] && "$REAL_TMUX" -V >/dev/null 2>&1; then
      # AppImage 解压后 tmux 找不到 terminfo，写一个 wrapper 自动设置环境
      cat > "$WRAPPER" <<WRAPPER_EOF
#!/usr/bin/env bash
# 自动生成的 wrapper：为随包解压出的 tmux 提供 terminfo 路径
# 由 install.offline.sh 生成，请勿手改
TI="$TERMINFO_DIR"
if [ -n "\${TERMINFO_DIRS:-}" ]; then
  export TERMINFO_DIRS="\${TERMINFO_DIRS}:\$TI"
else
  export TERMINFO_DIRS="\$TI"
fi
# 外部 TERM 引用的条目若不在系统 terminfo 也不在我们打包的 terminfo 里，
# 则兜底用 screen-256color（总是能工作）
if [ -z "\${TERM:-}" ] || ! TERMINFO_DIRS="\$TERMINFO_DIRS" infocmp "\$TERM" >/dev/null 2>&1; then
  export TERM=screen-256color
fi
exec "$REAL_TMUX" "\$@"
WRAPPER_EOF
      [ -n "$CHMOD_BIN" ] && "$CHMOD_BIN" +x "$WRAPPER" 2>/dev/null || true

      # 判断 wrapper 本身能否直接执行（$HOME noexec 时不能）
      if [ -x "$WRAPPER" ] && "$WRAPPER" -V >/dev/null 2>&1; then
        # 可以直接执行：让 ~/.tmux/bin/tmux 软链到 wrapper
        if [ -n "$LN_BIN" ]; then
          mv -f "$BUNDLED_TMUX" "$TMUX_DIR/bin/tmux.appimage" 2>/dev/null || true
          "$LN_BIN" -sfn "$WRAPPER" "$BUNDLED_TMUX"
        fi
        TMUX_BIN="$WRAPPER"
        echo "✓ 已生成 wrapper: $WRAPPER"
      else
        # wrapper 所在目录可能 noexec；用 bash 间接调用的 stub 替代 tmux
        echo "⚠ wrapper 不可执行（$HOME 是 noexec），创建 bash 中转 stub"
        STUB="/tmp/tmux-stub-$(id -u)"
        cat > "$STUB" <<STUB_EOF
#!/usr/bin/env bash
exec bash "$WRAPPER" "\$@"
STUB_EOF
        [ -n "$CHMOD_BIN" ] && "$CHMOD_BIN" +x "$STUB" 2>/dev/null || true
        if [ -n "$LN_BIN" ]; then
          mv -f "$BUNDLED_TMUX" "$TMUX_DIR/bin/tmux.appimage" 2>/dev/null || true
          "$LN_BIN" -sfn "$STUB" "$BUNDLED_TMUX" 2>/dev/null || cp -f "$STUB" "$BUNDLED_TMUX"
        fi
        TMUX_BIN="$STUB"
        echo "✓ 中转 stub: $STUB (bash $WRAPPER)"
      fi
      echo "  真 tmux: $REAL_TMUX"
      echo "  terminfo: $TERMINFO_DIR"
      # 让当前脚本会话立即能用
      export PATH="$TMUX_DIR/bin:$PATH"
    else
      echo "✗ 解压也失败或二进制不可执行，请手动处理。"
      echo "  尝试: mkdir -p /tmp/tmux-bin && cp $BUNDLED_TMUX /tmp/tmux-bin/ &&"
      echo "        cd /tmp/tmux-bin && chmod +x tmux && ./tmux --appimage-extract"
      echo "        然后把 /tmp/tmux-bin/squashfs-root/usr/bin 加到 PATH"
    fi
  fi
fi

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
