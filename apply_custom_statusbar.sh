#!/bin/bash
# 应用自定义状态栏配置（包含插件检查和加载）

echo "=========================================="
echo "🔧 应用 tmux 自定义配置"
echo "=========================================="

# 1. 确保插件目录正确
echo "1. 检查插件目录..."
~/.tmux/ensure_plugins.sh

# 2. 加载插件
echo ""
echo "2. 加载插件..."
~/.tmux/load_plugins.sh

# 3. 应用自定义状态栏
echo ""
echo "3. 应用自定义状态栏..."
tmux set -g status-right-length 250
tmux set -g status-right " ⌨#{?client_prefix,ON,} | CPU: #(/data/workspace/.tmux-plugins/tmux-cpu/scripts/cpu_percentage.sh) | %H:%M | %d-%b | #(whoami)@#H "

echo ""
echo "=========================================="
echo "✅ 配置完成"
echo "=========================================="
echo ""
echo "状态栏："
tmux show-options -gv status-right | head -c 150
echo ""
echo ""
echo "可用快捷键："
echo "  Ctrl+B, F         - tmux-fzf 模糊搜索"
echo "  Ctrl+B, Shift+O   - tmux-sessionx 会话管理"
echo "  Ctrl+B, Space     - tmux-thumbs 快速复制"
echo "  Ctrl+B, /         - tmux-copycat 搜索"
echo "  Ctrl+B, Ctrl+S    - tmux-resurrect 保存会话"
echo "  Ctrl+B, Ctrl+R    - tmux-resurrect 恢复会话"
