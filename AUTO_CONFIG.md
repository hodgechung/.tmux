# tmux 自动配置

## 问题

每次进入 tmux 都需要手动运行：
```bash
~/.tmux/apply_custom_statusbar.sh
```

这很麻烦！

## 解决方案：自动化

在 shell 启动文件中添加自动检测和配置。

---

## 🚀 一键安装（推荐）

```bash
~/.tmux/install_autorun.sh
```

**完成！** 以后每次进入 tmux 会自动配置。

---

## 📝 手动安装

### 1. 编辑配置文件

```bash
# 如果使用 zsh
vim ~/.zshrc

# 如果使用 bash
vim ~/.bashrc
```

### 2. 添加以下内容

```bash
# tmux 自动配置
if [ -n "$TMUX" ]; then
  ~/.tmux/apply_custom_statusbar.sh >/dev/null 2>&1
fi
```

### 3. 使配置生效

```bash
# zsh
source ~/.zshrc

# bash
source ~/.bashrc
```

---

## ✅ 验证

```bash
# 1. 退出所有 tmux 会话
tmux kill-server

# 2. 启动新的 tmux
tmux new -s test

# 3. 检查状态栏
# 应该自动显示 CPU 监控

# 4. 测试插件
# Ctrl+B, Shift+W → 应该显示 which-key 菜单
```

---

## 🔧 工作原理

1. 检测 `$TMUX` 环境变量（只在 tmux 内部存在）
2. 如果在 tmux 中，运行配置脚本
3. 静默运行（`>/dev/null 2>&1`），不干扰终端

---

## 💡 优点

- ✅ **自动化** - 无需手动操作
- ✅ **透明** - 静默运行，不干扰
- ✅ **智能** - 只在 tmux 中运行
- ✅ **轻量** - 几乎无性能影响

---

## 🔄 卸载

如果需要禁用自动配置：

```bash
# 编辑配置文件
vim ~/.zshrc  # 或 ~/.bashrc

# 删除或注释掉这几行：
# if [ -n "$TMUX" ]; then
#   ~/.tmux/apply_custom_statusbar.sh >/dev/null 2>&1
# fi
```

---

## 📚 相关文档

- **QUICK_START_NEW_USER.md** - 新用户安装
- **FINAL_USAGE.md** - 使用指南
- **PROJECT_SUMMARY.md** - 项目总览
