# tmux + CPU 监控 - 最终使用指南

## ✅ 配置完成

- **插件位置**: `/data/workspace/.tmux-plugins` (持久化存储)
- **符号链接**: `~/.tmux/plugins -> /data/workspace/.tmux-plugins`
- **gpakosz/.tmux**: 未修改（保持原始状态）

## 📱 使用流程

### 1. 连接到服务器
```bash
ssh anydev_ts3
```

### 2. 启动或连接 tmux
```bash
# 创建新会话
tmux new -s work

# 或连接到现有会话
tmux attach -t final-working
```

### 3. ⚠️ 应用自定义状态栏
```bash
~/.tmux/apply_custom_statusbar.sh
```

**输出应该是：**
```
✅ 自定义状态栏已应用

当前状态栏：
 ⌨ | CPU: #(/data/workspace/.tmux-plugins/tmux-cpu/scripts/cpu_percentage.sh) | %H:%M | #(whoami)@#H
```

### 4. 查看底部状态栏

应该显示：
```
⌨ | CPU: 27.4% | 15:46 | 02-Apr | root@hodgezhong-1uetogvoya
```

## 🔧 自动化（可选）

在 `~/.bashrc` 或 `~/.zshrc` 添加：

```bash
# 自动应用自定义 tmux 状态栏
if [ -n "$TMUX" ]; then
  ~/.tmux/apply_custom_statusbar.sh >/dev/null 2>&1
fi
```

重新加载：
```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

## 🐛 故障排查

### 符号链接丢失
```bash
cd ~/.tmux
ln -sf /data/workspace/.tmux-plugins plugins
```

### 插件脚本不可执行
```bash
chmod +x /data/workspace/.tmux-plugins/*/scripts/*.sh
```

### 状态栏不显示 CPU
```bash
# 手动设置
tmux set -g status-right " ⌨ | CPU: #(/data/workspace/.tmux-plugins/tmux-cpu/scripts/cpu_percentage.sh) | %H:%M | #(whoami)@#H "
```

## 🎯 插件快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+B, F` | tmux-fzf 模糊搜索 |
| `Ctrl+B, Shift+O` | tmux-sessionx 会话管理 |
| `Ctrl+B, Space` | tmux-thumbs 快速复制 |
| `Ctrl+B, /` | tmux-copycat 正则搜索 |
| `Ctrl+B, Ctrl+S` | tmux-resurrect 保存会话 |
| `Ctrl+B, Ctrl+R` | tmux-resurrect 恢复会话 |

## 📚 更多文档

- `README.custom.md` - 安装说明
- `PLUGINS.md` - 插件详细指南
- `QUICK_START.md` - 快速上手

## 🔗 GitHub

https://github.com/hodgechung/.tmux

---
最后更新: $(date)
