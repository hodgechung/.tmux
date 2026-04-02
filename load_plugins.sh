#!/bin/bash
# 手动加载所有插件（静默模式）

PLUGIN_DIR="/data/workspace/.tmux-plugins"

# 定义插件列表（插件名:脚本路径）
plugins=(
  "tmux-fzf:$PLUGIN_DIR/tmux-fzf/main.tmux"
  "tmux-which-key:$PLUGIN_DIR/tmux-which-key/plugin.sh.tmux"
  "tmux-sessionx:$PLUGIN_DIR/tmux-sessionx/sessionx.tmux"
  "tmux-copycat:$PLUGIN_DIR/tmux-copycat/copycat.tmux"
  "tmux-thumbs:$PLUGIN_DIR/tmux-thumbs/tmux-thumbs.tmux"
  "tmux-resurrect:$PLUGIN_DIR/tmux-resurrect/resurrect.tmux"
  "tmux-continuum:$PLUGIN_DIR/tmux-continuum/continuum.tmux"
)

for entry in "${plugins[@]}"; do
  name="${entry%%:*}"
  plugin="${entry#*:}"
  
  if [ -f "$plugin" ]; then
    # 静默运行，不显示输出
    tmux run-shell "$plugin" >/dev/null 2>&1
  fi
done
