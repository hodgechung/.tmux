#!/bin/bash
# 应用自定义状态栏配置（包含插件检查）

# 1. 确保插件目录正确
~/.tmux/ensure_plugins.sh

# 2. 应用自定义状态栏
tmux set -g status-right-length 250
tmux set -g status-right " ⌨#{?client_prefix,ON,} | CPU: #(/data/workspace/.tmux-plugins/tmux-cpu/scripts/cpu_percentage.sh) | %H:%M | %d-%b | #(whoami)@#H "

echo "✅ 自定义状态栏已应用"
echo ""
echo "当前状态栏："
tmux show-options -gv status-right | head -c 200
