#!/bin/bash
# 应用自定义状态栏配置

tmux set -g status-right-length 250
tmux set -g status-right " ⌨#{?client_prefix,ON,} | CPU: #(/data/workspace/.tmux-plugins/tmux-cpu/scripts/cpu_percentage.sh) | %H:%M | %d-%b | #(whoami)@#H "

echo "✅ 自定义状态栏已应用"
echo ""
echo "当前状态栏："
tmux show-options -gv status-right | head -c 200
