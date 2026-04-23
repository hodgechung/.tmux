#!/usr/bin/env bash
# pack-online.sh —— 在**有网机器**上从零构建一份 tmux 离线部署包
#
# 与 pack-offline.sh 的区别：
#   pack-online.sh  = 从零：git clone 仓库 + 自动安装插件 + 下载 AppImage
#                     适合在一台干净、有网、但没装/没用过本配置的机器上打包
#   pack-offline.sh = 打包已有的 ~/.tmux（假设 plugins 已克隆好）
#                     适合在自己日常使用的机器上直接打包
#
# 产物结构与 pack-offline.sh 完全一致，install.offline.sh 可以直接使用。
#
# 用法：
#   bash scripts/pack-online.sh
#   bash scripts/pack-online.sh -o /tmp/tmux.tgz
#   bash scripts/pack-online.sh --repo https://github.com/hodgechung/.tmux.git
#   bash scripts/pack-online.sh --tmux-version 3.3a
#   bash scripts/pack-online.sh --no-tmux              # 不打包 tmux 二进制
#   bash scripts/pack-online.sh --keep-workdir         # 调试用
#
# 离线机器用法（同 pack-offline.sh）：
#   tar xzf tmux-offline.tar.gz -C "$HOME"
#   bash "$HOME/.tmux/scripts/install.offline.sh"

set -euo pipefail

# ---------- 默认值 ----------
OUT="$PWD/tmux-offline.tar.gz"
REPO="https://github.com/hodgechung/.tmux.git"
TMUX_VERSION="3.5a"
WITH_TMUX=true
KEEP_WORKDIR=false

usage() {
  sed -n '2,23p' "$0"
}

# ---------- 解析参数 ----------
while [ $# -gt 0 ]; do
  case "$1" in
    -o|--output)        OUT="$2"; shift 2 ;;
    --repo)             REPO="$2"; shift 2 ;;
    --tmux-version)     TMUX_VERSION="$2"; shift 2 ;;
    --no-tmux)          WITH_TMUX=false; shift ;;
    --keep-workdir)     KEEP_WORKDIR=true; shift ;;
    -h|--help)          usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage >&2; exit 1 ;;
  esac
done

# ---------- 前置检查 ----------
need() {
  command -v "$1" >/dev/null 2>&1 || { echo "✗ 缺少依赖: $1" >&2; exit 1; }
}
need git
need tar
need gzip
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "✗ 需要 curl 或 wget 之一" >&2
  exit 1
fi

# ---------- 临时工作目录 ----------
WORK="$(mktemp -d -t tmux-pack-online.XXXXXX)"
cleanup() {
  if [ "$KEEP_WORKDIR" = true ]; then
    echo "ⓘ 保留工作目录: $WORK"
  else
    rm -rf "$WORK"
  fi
}
trap cleanup EXIT

echo "→ 工作目录: $WORK"

# ---------- 1) clone 仓库 ----------
echo "→ clone $REPO"
git clone --depth 1 "$REPO" "$WORK/.tmux" >/dev/null 2>&1 || {
  echo "✗ git clone 失败: $REPO" >&2
  exit 1
}
echo "✓ clone 完成"

TMUX_DIR="$WORK/.tmux"
BIN_DIR="$TMUX_DIR/bin"

# ---------- 2) 安装插件 ----------
# 从 .tmux.conf.local 解析 @plugin 声明作为"预期插件清单"
parse_plugin_list() {
  local conf="$1"
  [ -f "$conf" ] || return 0
  # 匹配未被注释的 `set -g @plugin 'user/repo'`，忽略空字符串行
  grep -E "^[[:space:]]*set[[:space:]]+-g[[:space:]]+@plugin[[:space:]]+['\"][^'\"]+['\"]" "$conf" \
    | sed -E "s/.*@plugin[[:space:]]+['\"]([^'\"]+)['\"].*/\1/" \
    | grep -v '^[[:space:]]*$' || true
}

# fallback：手动 clone TPM + 从 conf 解析出的插件
clone_plugins_fallback() {
  local plugin_dir="$TMUX_DIR/plugins"
  mkdir -p "$plugin_dir"
  echo "→ fallback: 手动 clone 插件"

  # TPM 本身
  if [ ! -d "$plugin_dir/tpm" ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm.git \
      "$plugin_dir/tpm" >/dev/null 2>&1 \
      && echo "  ✓ tpm" || echo "  ✗ tpm 失败"
  fi

  # 从 .tmux.conf.local 解析
  local conf="$TMUX_DIR/.tmux.conf.local"
  local plugins
  plugins=$(parse_plugin_list "$conf")

  # 若解析为空，退回到一个已知的默认清单
  if [ -z "$plugins" ]; then
    plugins=$(cat <<'EOF'
tmux-plugins/tmux-sensible
tmux-plugins/tmux-resurrect
tmux-plugins/tmux-continuum
tmux-plugins/tmux-yank
tmux-plugins/tmux-copycat
tmux-plugins/tmux-cpu
sainnhe/tmux-fzf
omerxx/tmux-sessionx
EOF
)
  fi

  while IFS= read -r slug; do
    [ -z "$slug" ] && continue
    local name="${slug##*/}"
    local dest="$plugin_dir/$name"
    if [ -d "$dest/.git" ] || [ -d "$dest" ]; then
      echo "  • $slug (已存在，跳过)"
      continue
    fi
    if git clone --depth 1 "https://github.com/${slug}.git" "$dest" >/dev/null 2>&1; then
      echo "  ✓ $slug"
    else
      echo "  ⚠ $slug clone 失败"
    fi
  done <<< "$plugins"
}

# 统计 plugins 目录下（忽略 tpm 自己）的插件数量
count_plugins() {
  local d="$TMUX_DIR/plugins"
  [ -d "$d" ] || { echo 0; return; }
  find "$d" -maxdepth 1 -mindepth 1 -type d ! -name tpm 2>/dev/null | wc -l
}

# 优先尝试让 TPM 自动 clone（前提是系统装了 tmux）
install_plugins_via_tpm() {
  command -v tmux >/dev/null 2>&1 || return 1

  local sess="_packsetup_$$"
  echo "→ 通过临时 tmux session 触发 TPM 自动安装（最多 60s）"
  # 用隔离 HOME 启动；conf 里 _apply_plugins 会负责 clone
  HOME="$WORK" tmux -f "$TMUX_DIR/.tmux.conf" \
    new-session -d -s "$sess" "sleep 90" >/dev/null 2>&1 || return 1

  local waited=0
  local cnt=0
  while [ $waited -lt 60 ]; do
    sleep 3
    waited=$((waited + 3))
    cnt=$(count_plugins)
    # 至少拿到 TPM + 1 个插件就认为成功启动
    if [ -d "$TMUX_DIR/plugins/tpm" ] && [ "$cnt" -ge 1 ]; then
      # 再等一小会儿，让剩余插件 clone 完
      sleep 5
      break
    fi
  done

  HOME="$WORK" tmux kill-session -t "$sess" >/dev/null 2>&1 || true

  cnt=$(count_plugins)
  if [ -d "$TMUX_DIR/plugins/tpm" ] && [ "$cnt" -ge 1 ]; then
    echo "  ✓ TPM 自动安装: tpm + $cnt 个插件"
    return 0
  fi
  return 1
}

if ! install_plugins_via_tpm; then
  echo "ⓘ TPM 自动安装不可用（系统无 tmux 或 hook 未触发），改用 fallback"
  clone_plugins_fallback
fi

# 补全：如果 TPM 成功但预期插件清单里还有漏的，补 clone 一遍
EXPECTED=$(parse_plugin_list "$TMUX_DIR/.tmux.conf.local")
if [ -n "$EXPECTED" ]; then
  MISSING=""
  while IFS= read -r slug; do
    [ -z "$slug" ] && continue
    name="${slug##*/}"
    [ -d "$TMUX_DIR/plugins/$name" ] || MISSING="$MISSING$slug"$'\n'
  done <<< "$EXPECTED"
  if [ -n "$MISSING" ]; then
    echo "→ 补装缺失插件："
    while IFS= read -r slug; do
      [ -z "$slug" ] && continue
      name="${slug##*/}"
      if git clone --depth 1 "https://github.com/${slug}.git" \
           "$TMUX_DIR/plugins/$name" >/dev/null 2>&1; then
        echo "  ✓ $slug"
      else
        echo "  ⚠ $slug clone 失败"
      fi
    done <<< "$MISSING"
  fi
fi

echo "✓ 插件就绪（$(count_plugins) 个，含 tpm 总共 $(find "$TMUX_DIR/plugins" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)）"

# ---------- 3) 下载并预解压 tmux AppImage ----------
if [ "$WITH_TMUX" = true ]; then
  URL="https://github.com/nelsonenzo/tmux-appimage/releases/download/${TMUX_VERSION}/tmux.appimage"
  APPIMAGE="$BIN_DIR/tmux.appimage"
  mkdir -p "$BIN_DIR"

  echo "→ 下载 tmux $TMUX_VERSION AppImage"
  echo "   $URL"
  if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 -o "$APPIMAGE" "$URL" || {
      echo "✗ 下载失败：$URL" >&2; exit 1;
    }
  else
    wget -q -O "$APPIMAGE" "$URL" || {
      echo "✗ 下载失败：$URL" >&2; rm -f "$APPIMAGE"; exit 1;
    }
  fi
  chmod +x "$APPIMAGE"

  # 预解压：在 BIN_DIR 下产出 squashfs-root/
  echo "→ 预解压 AppImage"
  if ( cd "$BIN_DIR" && "$APPIMAGE" --appimage-extract >/dev/null 2>&1 ); then
    echo "✓ 预解压完成: $BIN_DIR/squashfs-root/"
  else
    echo "⚠ 本机无法 --appimage-extract（可能缺 FUSE / 二进制架构不符）"
    echo "  tarball 将只含 AppImage 本体；离线机器需自行处理"
  fi

  # 修正权限
  if [ -d "$BIN_DIR/squashfs-root" ]; then
    find "$BIN_DIR/squashfs-root" \
         -type f \( -name "tmux" -o -name "*.so*" -o -name "*.sh" \) \
         -exec chmod 755 {} + 2>/dev/null || true
    chmod 755 "$BIN_DIR/squashfs-root/AppRun" 2>/dev/null || true
  fi
  chmod 755 "$APPIMAGE" 2>/dev/null || true

  # 写版本号
  printf '%s\n' "$TMUX_VERSION" > "$BIN_DIR/.tmux-version"

  # 生成 wrapper（与 pack-offline.sh line 135-150 等价）
  TERMINFO_REL="bin/squashfs-root/usr/share/terminfo"
  REAL_TMUX_REL="bin/squashfs-root/usr/bin/tmux"
  cat > "$BIN_DIR/tmux-wrapper" <<WRAPPER_EOF
#!/usr/bin/env bash
# 预生成的 wrapper（由 pack-online.sh 打包时生成）
# 功能：给随包解压出的 tmux 注入 TERMINFO_DIRS
TI="\${HOME}/.tmux/$TERMINFO_REL"
if [ -n "\${TERMINFO_DIRS:-}" ]; then
  export TERMINFO_DIRS="\${TERMINFO_DIRS}:\$TI"
else
  export TERMINFO_DIRS="\$TI"
fi
# 外部 TERM 查不到就兜底
if [ -z "\${TERM:-}" ] || ! TERMINFO_DIRS="\$TERMINFO_DIRS" infocmp "\$TERM" >/dev/null 2>&1; then
  export TERM=screen-256color
fi
exec "\${HOME}/.tmux/$REAL_TMUX_REL" "\$@"
WRAPPER_EOF
  chmod 755 "$BIN_DIR/tmux-wrapper"
  ln -sf "tmux-wrapper" "$BIN_DIR/tmux"
  echo "✓ wrapper 已生成; bin/tmux -> tmux-wrapper"

  # 预解压成功后删除原 AppImage 省空间
  if [ -d "$BIN_DIR/squashfs-root" ]; then
    rm -f "$APPIMAGE"
    echo "ⓘ 已删除原 AppImage（squashfs-root 就绪）"
  fi
fi

# ---------- 4) 清理不该打包的东西 ----------
# .git 由 tar --exclude 过滤；其它零碎文件现在显式清
find "$TMUX_DIR" -name "tpm_log.txt" -delete 2>/dev/null || true
find "$TMUX_DIR" -name "*.bak.*" -delete 2>/dev/null || true
find "$TMUX_DIR" -name "*.backup.*" -delete 2>/dev/null || true
find "$TMUX_DIR" -name "tmux-*.log" -delete 2>/dev/null || true
find "$TMUX_DIR" -name "test-file" -delete 2>/dev/null || true

# 确保 scripts/*.sh 可执行
find "$TMUX_DIR/scripts" -type f -name "*.sh" -exec chmod 755 {} + 2>/dev/null || true

# ---------- 5) 打包 ----------
echo "→ 打包 $OUT"
tar czf "$OUT" \
    --exclude=".tmux/.git" \
    --exclude=".git" \
    --exclude="*.bak.*" \
    --exclude="*.backup.*" \
    --exclude="tmux-*.log" \
    --exclude="tpm_log.txt" \
    --exclude="test-file" \
    --exclude=".tmux/.omc" \
    -C "$WORK" \
    ".tmux"

# ---------- 6) 验证 ----------
if [ ! -f "$OUT" ]; then
  echo "✗ tarball 未生成: $OUT" >&2; exit 1
fi

SZ_BYTES=$(stat -c%s "$OUT" 2>/dev/null || stat -f%z "$OUT")
SZ_HUMAN=$(du -h "$OUT" | cut -f1)

# 体积合理性检查
MIN=$((500 * 1024))                             # 500KB
[ "$WITH_TMUX" = true ] && MIN=$((3 * 1024 * 1024))  # 3MB
if [ "$SZ_BYTES" -lt "$MIN" ]; then
  echo "⚠ tarball 体积偏小：$SZ_HUMAN（< $((MIN/1024))KB），请检查产物" >&2
fi

echo
echo "✓ 输出: $OUT ($SZ_HUMAN)"
echo
echo "── tarball 顶层结构 (head -20) ──"
tar -tzf "$OUT" | head -20
echo

echo "在离线机器上："
echo "  scp $OUT user@offline:/tmp/"
echo "  ssh user@offline 'tar xzf /tmp/$(basename "$OUT") -C \$HOME && bash \$HOME/.tmux/scripts/install.offline.sh'"
if [ "$WITH_TMUX" = true ]; then
  echo
  echo "（已附带 tmux $TMUX_VERSION AppImage；install 脚本会引导把 ~/.tmux/bin 加入 PATH）"
fi
