#!/bin/bash
# 手动加载所有插件（确保正确顺序）

PLUGIN_DIR="/data/workspace/.tmux-plugins"

# 先加载 which-key（重要）
if [ -f "$PLUGIN_DIR/tmux-which-key/plugin/init.tmux" ]; then
  tmux source-file "$PLUGIN_DIR/tmux-which-key/plugin/init.tmux" 2>/dev/null
fi

# 然后加载其他插件
plugins=(
  "$PLUGIN_DIR/tmux-fzf/main.tmux"
  "$PLUGIN_DIR/tmux-sessionx/sessionx.tmux"
  "$PLUGIN_DIR/tmux-copycat/copycat.tmux"
  "$PLUGIN_DIR/tmux-thumbs/tmux-thumbs.tmux"
  "$PLUGIN_DIR/tmux-resurrect/resurrect.tmux"
  "$PLUGIN_DIR/tmux-continuum/continuum.tmux"
)

for plugin in "${plugins[@]}"; do
  if [ -f "$plugin" ]; then
    tmux run-shell "$plugin" 2>/dev/null
  fi
done

# 最后加载我们的覆盖配置（确保 ? 绑定生效）
if [ -f "$HOME/.tmux/.tmux.conf.local.whichkey" ]; then
  tmux source-file "$HOME/.tmux/.tmux.conf.local.whichkey" 2>/dev/null
fi
