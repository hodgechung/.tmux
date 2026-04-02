#!/bin/bash
# tmux CPU 显示测试脚本

echo "=========================================="
echo "tmux CPU 显示测试"
echo "=========================================="

echo ""
echo "1. 插件目录检查："
ls -ld ~/.tmux/plugins/tmux-cpu

echo ""
echo "2. CPU 脚本检查："
ls -l ~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh

echo ""
echo "3. 直接执行脚本："
bash ~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh

echo ""
echo "4. 检查 tmux 配置："
tmux show-options -gv status-right | grep -o "CPU.*" | head -c 100

echo ""
echo "5. 当前 tmux 会话："
tmux list-sessions

echo ""
echo "6. 建议："
echo "   - 连接到会话: tmux attach -t working-session"
echo "   - 查看底部状态栏"
echo "   - CPU 显示应该在那里"
echo ""
echo "如果看不到 CPU 值，可能是："
echo "   a) 脚本执行有延迟"
echo "   b) 需要等待几秒让 tmux 刷新"
echo "   c) Hook 执行时机问题"
