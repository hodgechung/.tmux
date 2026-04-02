#!/bin/bash
# 手动加载所有插件（带错误处理）

PLUGIN_DIR="/data/workspace/.tmux-plugins"

echo "加载插件..."

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
    echo -n "  [$name] "
    if tmux run-shell "$plugin" 2>/dev/null; then
      echo "✓"
    else
      echo "⚠️ (跳过)"
    fi
  else
    echo "  [$name] ✗ 文件不存在"
  fi
done

echo ""
echo "✅ 插件加载完成（部分插件可能被跳过）"
