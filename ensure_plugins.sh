#!/bin/bash
# 确保插件目录和符号链接正确设置

PLUGIN_DIR="/data/workspace/.tmux-plugins"
SYMLINK="$HOME/.tmux/plugins"

# 1. 确保持久化目录存在
if [ ! -d "$PLUGIN_DIR" ]; then
  echo "⚠️ 插件目录不存在，正在创建..."
  mkdir -p "$PLUGIN_DIR"
fi

# 2. 如果符号链接不存在或损坏，重建它
if [ ! -L "$SYMLINK" ] || [ ! -d "$SYMLINK" ]; then
  echo "🔧 重建符号链接..."
  
  # 如果是普通目录，先清空
  if [ -d "$SYMLINK" ] && [ ! -L "$SYMLINK" ]; then
    find "$SYMLINK" -mindepth 1 -delete 2>/dev/null
    rmdir "$SYMLINK" 2>/dev/null
  fi
  
  # 删除损坏的符号链接
  [ -L "$SYMLINK" ] && unlink "$SYMLINK"
  
  # 创建新符号链接
  ln -sf "$PLUGIN_DIR" "$SYMLINK"
  echo "✅ 符号链接已重建"
else
  echo "✅ 符号链接正常"
fi

# 3. 验证
if [ -d "$SYMLINK/tmux-cpu" ]; then
  echo "✅ 插件可访问"
else
  echo "⚠️ 插件目录为空，可能需要安装插件"
fi
