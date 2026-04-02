#!/bin/bash

echo "=========================================="
echo "🔧 安装 tmux 自动配置"
echo "=========================================="

# 检测 shell 配置文件
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
  SHELL_NAME="zsh"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
  SHELL_NAME="bash"
else
  echo "❌ 未找到 .zshrc 或 .bashrc"
  exit 1
fi

echo ""
echo "检测到 shell: $SHELL_NAME"
echo "配置文件: $SHELL_RC"

# 检查是否已安装
if grep -q "apply_custom_statusbar.sh" "$SHELL_RC" 2>/dev/null; then
  echo ""
  echo "✅ 已经安装，无需重复添加"
  exit 0
fi

# 添加配置
echo ""
echo "📝 添加自动配置到 $SHELL_RC ..."

cat >> "$SHELL_RC" << 'CONFIG'

# ==========================================
# tmux 自动配置
# ==========================================
# 进入 tmux 时自动应用插件和 CPU 监控
if [ -n "$TMUX" ]; then
  ~/.tmux/apply_custom_statusbar.sh >/dev/null 2>&1
fi
CONFIG

echo "✅ 安装完成！"
echo ""
echo "=========================================="
echo "🎉 配置已添加"
echo "=========================================="
echo ""
echo "📋 已添加的内容："
echo "  - 自动检测 tmux 环境"
echo "  - 自动加载插件"
echo "  - 自动应用 CPU 监控"
echo ""
echo "🔄 使配置生效："
echo "  source $SHELL_RC"
echo ""
echo "或者重新登录/新开终端"
echo ""
echo "✨ 现在每次进入 tmux 都会自动配置好！"
