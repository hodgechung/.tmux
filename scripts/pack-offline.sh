#!/usr/bin/env bash
# pack-offline.sh —— 在有网机器上打包一份可在离线机器解压即用的 tmux 配置
#
# 用法：
#   bash scripts/pack-offline.sh                         # 只打包配置（~580KB）
#   bash scripts/pack-offline.sh --with-tmux             # 附带 tmux 3.5a AppImage
#   bash scripts/pack-offline.sh --with-tmux=3.3a        # 指定 tmux 版本（3.5a/3.3a/3.2a/3.1c）
#   bash scripts/pack-offline.sh --with-tmux /tmp/out.tgz  # 自定义输出路径
#
# 产物：tmux-offline.tar.gz
#   - 不带 tmux   ：~580 KB（含 6 插件 + 脚本 + 配置）
#   - 带 tmux     ：~3–6 MB（追加 ~HOME/.tmux/bin/tmux 静态 AppImage）
#
# 离线机器用法：
#   tar xzf tmux-offline.tar.gz -C "$HOME"
#   bash "$HOME/.tmux/scripts/install.offline.sh"
#   # install 脚本会自动把 ~/.tmux/bin/tmux 加入 PATH
#
# AppImage 来源：
#   https://github.com/nelsonenzo/tmux-appimage/releases
#   （静态链接 libevent/libtinfo；要求内核支持 FUSE）

set -euo pipefail

# ---------- 解析参数 ----------
WITH_TMUX=false
TMUX_VER="3.5a"   # nelsonenzo/tmux-appimage 最新稳定版（命名带字母后缀）
OUT=""

for arg in "$@"; do
  case "$arg" in
    --with-tmux)       WITH_TMUX=true ;;
    --with-tmux=*)     WITH_TMUX=true; TMUX_VER="${arg#*=}" ;;
    --help|-h)
      sed -n '2,18p' "$0"
      exit 0
      ;;
    *.tar.gz|*.tgz|/*) OUT="$arg" ;;
    *)                 echo "未知参数: $arg" >&2; exit 1 ;;
  esac
done

# ---------- 路径 ----------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMUX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="${OUT:-$PWD/tmux-offline.tar.gz}"
TOP="$(dirname "$TMUX_DIR")"
REL="$(basename "$TMUX_DIR")"   # 通常是 .tmux

BIN_DIR="$TMUX_DIR/bin"
APPIMAGE="$BIN_DIR/tmux"

# ---------- 可选：下载 tmux AppImage ----------
download_tmux() {
  local ver="$1"
  local url="https://github.com/nelsonenzo/tmux-appimage/releases/download/${ver}/tmux.appimage"

  mkdir -p "$BIN_DIR"

  if [ -x "$APPIMAGE" ] && "$APPIMAGE" -V 2>/dev/null | grep -q "^tmux $ver"; then
    echo "✓ $APPIMAGE 已存在且版本匹配 ($ver)，跳过下载"
    return 0
  fi

  echo "→ 下载 tmux $ver AppImage"
  echo "   $url"

  # 先用 HEAD 探测文件是否存在，给出更友好的错误
  if command -v curl >/dev/null 2>&1; then
    local head_code
    head_code=$(curl -sIL -o /dev/null -w "%{http_code}" "$url")
    if [ "$head_code" != "200" ]; then
      echo "✗ HEAD 请求返回 $head_code —— tag '$ver' 下没有 tmux.appimage 资源" >&2
      echo "  已知可用 tag：3.5a / 3.3a / 3.2a / 3.1c 等（都是带字母后缀）" >&2
      echo "  重试：bash scripts/pack-offline.sh --with-tmux=3.5a" >&2
      return 1
    fi
    curl -fL --retry 3 -o "$APPIMAGE" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -q --show-progress -O "$APPIMAGE" "$url" || {
      echo "✗ 下载失败。已知可用 tag：3.5a / 3.3a / 3.2a / 3.1c" >&2
      rm -f "$APPIMAGE"
      return 1
    }
  else
    echo "✗ 找不到 curl 或 wget" >&2
    return 1
  fi

  chmod +x "$APPIMAGE"

  # 简单校验：至少能 exec 且打印版本（需要本机支持 FUSE 才能 exec；
  # 不支持也没关系，AppImage 在离线机器上才需要运行）
  if "$APPIMAGE" -V >/dev/null 2>&1; then
    echo "✓ 校验通过: $("$APPIMAGE" -V)"
  else
    echo "⚠ 本机 exec AppImage 失败（可能是 FUSE 缺失），但文件已下载，"
    echo "  大小: $(du -h "$APPIMAGE" | cut -f1)"
    echo "  离线机器若也没 FUSE，install.offline.sh 会自动尝试 --appimage-extract。"
  fi
}

if [ "$WITH_TMUX" = true ]; then
  download_tmux "$TMUX_VER"
else
  # 没选 --with-tmux 时，如果旧的 AppImage 仍在目录里，从打包里排掉
  [ -d "$BIN_DIR" ] && echo "ⓘ 当前未请求 --with-tmux，bin/ 目录会被打包进去（如不需要请手动删除）"
fi

# ---------- 打包 ----------
echo "→ 打包 $TMUX_DIR -> $OUT"
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
if [ "$WITH_TMUX" = true ]; then
  echo
  echo "（已附带 tmux $TMUX_VER AppImage；install 脚本会自动把 ~/.tmux/bin 加到 PATH）"
fi