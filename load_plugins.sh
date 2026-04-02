#!/bin/bash
# 手动加载所有插件

PLUGIN_DIR="/data/workspace/.tmux-plugins"

echo "加载插件..."

# 加载每个插件的主脚本
for plugin in \
  "$PLUGIN_DIR/tmux-fzf/main.tmux" \
  "$PLUGIN_DIR/tmux-which-key/plugin.sh.tmux" \
  "$PLUGIN_DIR/tmux-sessionx/sessionx.tmux" \
  "$PLUGIN_DIR/tmux-copycat/copycat.tmux" \
  "$PLUGIN_DIR/tmux-thumbs/tmux-thumbs.tmux" \
  "$PLUGIN_DIR/tmux-resurrect/resurrect.tmux" \
  "$PLUGIN_DIR/tmux-continuum/continuum.tmux"
do
  if [ -f "$plugin" ]; then
    echo "  ✓ $(basename $(dirname $plugin))"
    tmux run-shell "$plugin"
  else
    echo "  ✗ $plugin 不存在"
  fi
done

echo ""
echo "✅ 插件加载完成"
