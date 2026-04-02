#!/bin/bash

echo "=========================================="
echo "🔧 应用 tmux 自定义配置"
echo "=========================================="

# 1. 检查插件目录
echo "1. 检查插件目录..."
if [ ! -L "$HOME/.tmux/plugins" ]; then
  echo "🔧 重建符号链接..."
  "$HOME/.tmux/ensure_plugins.sh"
else
  echo "✅ 插件可访问"
fi

# 2. 加载插件
echo ""
echo "2. 加载插件..."
"$HOME/.tmux/load_plugins.sh"

# 3. 应用状态栏配置
echo ""
echo "3. 应用自定义状态栏..."
if [ -f "$HOME/.tmux/.tmux.conf.override" ]; then
  tmux source-file "$HOME/.tmux/.tmux.conf.override" 2>/dev/null
fi

echo ""
echo "=========================================="
echo "✅ 配置完成"
echo "=========================================="

# 显示状态栏预览
echo ""
echo "状态栏："
tmux display-message -p "#{status-right}" 2>/dev/null | head -1

echo ""
echo ""
echo "可用快捷键："
echo "  Ctrl+B, '         - which-key 菜单"
echo "  Ctrl+B, F         - tmux-fzf 模糊搜索"
echo "  Ctrl+B, Shift+O   - tmux-sessionx 会话管理"
echo "  Ctrl+B, Space     - tmux-thumbs 快速复制"
echo "  Ctrl+B, /         - tmux-copycat 搜索"
echo "  Ctrl+B, Ctrl+S    - tmux-resurrect 保存会话"
echo "  Ctrl+B, Ctrl+R    - tmux-resurrect 恢复会话"

# ==========================================
# 💡 自动化建议
# ==========================================
echo ""
echo "=========================================="
echo "💡 自动化配置建议"
echo "=========================================="
echo ""
echo "每次进入 tmux 手动运行此脚本比较麻烦。"
echo "推荐将配置自动化，添加到 shell 启动文件。"
echo ""

# 检查是否已添加
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
  if grep -q "apply_custom_statusbar.sh" "$SHELL_RC" 2>/dev/null; then
    echo "✅ 已经添加到 $SHELL_RC"
  else
    echo "📝 建议添加以下内容到 $SHELL_RC："
    echo ""
    echo "────────────────────────────────────────"
    cat << 'SUGGESTION'
# tmux 自动配置（进入 tmux 时自动应用插件和 CPU 监控）
if [ -n "$TMUX" ]; then
  # 静默运行，避免干扰终端输出
  ~/.tmux/apply_custom_statusbar.sh >/dev/null 2>&1
fi
SUGGESTION
    echo "────────────────────────────────────────"
    echo ""
    echo "🚀 一键添加（推荐）："
    echo "  $0 --install"
    echo ""
    echo "📝 手动添加："
    echo "  vim $SHELL_RC"
    echo "  # 然后粘贴上面的内容"
    echo ""
  fi
fi
